<script lang="ts">
import MarkdownIt from "markdown-it";

interface EncData {
	content: string;
	salt: string;
	iv: string;
}

// Encrypted data injected by [...slug].astro — built by remark-encrypt plugin
let { encData }: { encData: EncData } = $props();

let password = $state("");
let decryptedHtml = $state("");
let error = $state("");
let loading = $state(false);

const md = new MarkdownIt({
	html: false, // strip raw HTML from decrypted markdown (XSS prevention)
	linkify: true,
});

function base64ToBuf(base64: string): ArrayBuffer {
	return Uint8Array.from(atob(base64), (c) => c.charCodeAt(0)).buffer;
}

async function decrypt() {
	loading = true;
	error = "";

	try {
		// Parse base64-encoded crypto parameters
		const salt = base64ToBuf(encData.salt);
		const iv = base64ToBuf(encData.iv);
		const raw = new Uint8Array(base64ToBuf(encData.content));
		// Last 16 bytes are the GCM authentication tag
		const ciphertext = raw.slice(0, -16);
		const tag = raw.slice(-16);

		// Derive key using PBKDF2 (must match remark-encrypt.mjs parameters)
		const keyMaterial = await crypto.subtle.importKey(
			"raw",
			new TextEncoder().encode(password),
			"PBKDF2",
			false,
			["deriveKey"],
		);
		const key = await crypto.subtle.deriveKey(
			{
				name: "PBKDF2",
				salt,
				iterations: 100000,
				hash: "SHA-256",
			},
			keyMaterial,
			{ name: "AES-GCM", length: 256 },
			false,
			["decrypt"],
		);

		// Concatenate ciphertext + tag for Web Crypto's AES-GCM
		const combined = new Uint8Array(ciphertext.length + tag.length);
		combined.set(ciphertext, 0);
		combined.set(tag, ciphertext.length);

		// AES-256-GCM decrypt — throws on authentication failure (wrong password)
		const decrypted = await crypto.subtle.decrypt(
			{ name: "AES-GCM", iv },
			key,
			combined,
		);

		decryptedHtml = md.render(new TextDecoder().decode(decrypted));
	} catch {
		error = "密码错误";
	} finally {
		loading = false;
	}
}
</script>

<div class="password-protected w-full">
	{#if decryptedHtml}
		<!--
			Decrypted content rendered with same classes as Markdown.astro
			No data-pagefind-body — runtime-decrypted content should never be indexed
		-->
		<div class="prose dark:prose-invert prose-base !max-w-none custom-md">
			{@html decryptedHtml}
		</div>
	{:else}
		<!-- Password prompt -->
		<div class="flex flex-col items-center justify-center py-16 gap-6">
			<div class="text-4xl select-none">🔒</div>
			<p class="text-lg font-medium text-black/70 dark:text-white/70">
				此内容已加密，请输入密码查看
			</p>
			<div class="flex gap-3 w-full max-w-sm">
				<input
					type="password"
					bind:value={password}
					placeholder="输入密码"
					class="flex-1 px-4 py-2.5 rounded-xl border border-black/10 dark:border-white/10 bg-black/5 dark:bg-white/5 text-black/80 dark:text-white/80 placeholder-black/30 dark:placeholder-white/30 outline-none focus:border-[var(--primary)] transition"
					onkeydown={(e: KeyboardEvent) => {
						if (e.key === "Enter") decrypt();
					}}
				/>
				<button
					onclick={decrypt}
					disabled={loading}
					class="px-6 py-2.5 rounded-xl bg-[var(--primary)] text-white font-medium hover:opacity-90 disabled:opacity-50 transition active:scale-95 select-none"
				>
					{loading ? "解密中..." : "解密"}
				</button>
			</div>
			{#if error}
				<p class="text-red-500 text-sm">{error}</p>
			{/if}
		</div>
	{/if}
</div>
