// Remark plugin: encrypts post content with AES-256-GCM at build time
// - Reads `password` from frontmatter
// - Encrypts the raw markdown body with PBKDF2-derived key
// - Stores ciphertext + salt + iv in frontmatter (replaces original password)
// - Replaces body with placeholder text
// - Must be placed LAST in the remark plugin chain so reading-time/excerpt compute on original content first

// biome-ignore lint/suspicious/noShadowRestrictedNames: <node:crypto is a known global name>
import crypto from "node:crypto";
import { toString } from "mdast-util-to-string";

export function remarkEncrypt() {
	return (tree, vfile) => {
		const fm = vfile.data.astro.frontmatter;
		const password = fm.password;

		// Skip posts that don't have a password set
		if (!password) return;

		// Get raw markdown body — prefer vfile.value, fall back to serializing AST
		const body = typeof vfile.value === "string" ? vfile.value : toString(tree);

		// Generate random salt (16B) and initialization vector (12B for GCM)
		const salt = crypto.randomBytes(16);
		const iv = crypto.randomBytes(12);

		// Derive 256-bit key using PBKDF2 with 100,000 iterations
		const key = crypto.pbkdf2Sync(password, salt, 100000, 32, "sha256");

		// Encrypt with AES-256-GCM (authenticated encryption)
		const cipher = crypto.createCipheriv("aes-256-gcm", key, iv);
		const encrypted = Buffer.concat([
			cipher.update(body, "utf8"),
			cipher.final(),
		]);
		const tag = cipher.getAuthTag();

		// Concatenate ciphertext + auth tag, store as base64
		const combined = Buffer.concat([encrypted, tag]);
		fm.encrypted = true;
		fm.encryptedContent = combined.toString("base64");
		fm.encryptSalt = salt.toString("base64");
		fm.encryptIv = iv.toString("base64");

		// Remove the plaintext password so it never reaches the output
		delete fm.password;

		// Clear excerpt to prevent first paragraph from leaking in listings
		fm.excerpt = "";

		// Replace the entire content tree with a placeholder
		tree.children = [
			{
				type: "paragraph",
				children: [
					{
						type: "text",
						value: "[此内容已加密]",
					},
				],
			},
		];
	};
}
