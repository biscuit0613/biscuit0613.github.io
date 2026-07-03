import { execSync } from "node:child_process";
import { existsSync, mkdirSync } from "node:fs";
import { platform, arch } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = join(fileURLToPath(import.meta.url), "..", "..");
const LOCAL_BIN = join(ROOT, "node_modules", ".bin", "typst");
const TYPST_VERSION = "0.14.2";

function isAvailable(bin) {
	try {
		execSync(`${bin} --version`, { stdio: "pipe" });
		return true;
	} catch {
		return false;
	}
}

async function download(url, dest) {
	const resp = await fetch(url);
	if (!resp.ok) throw new Error(`HTTP ${resp.status} ${resp.statusText}`);
	const buf = Buffer.from(await resp.arrayBuffer());

	if (url.endsWith(".tar.xz")) {
		const tmp = join(ROOT, "node_modules", ".cache", "typst.tar.xz");
		mkdirSync(join(ROOT, "node_modules", ".cache"), { recursive: true });
		const { writeFileSync, unlinkSync } = await import("node:fs");
		writeFileSync(tmp, buf);
		execSync(`tar xJf "${tmp}" -C "${join(ROOT, "node_modules", ".cache")}"`, {
			stdio: "inherit",
		});
		const extracted = join(
			ROOT,
			"node_modules",
			".cache",
			`typst-${getTarget()}`,
			"typst",
		);
		const { renameSync } = await import("node:fs");
		renameSync(extracted, dest);
		unlinkSync(tmp);
	} else {
		const { writeFileSync, chmodSync } = await import("node:fs");
		writeFileSync(dest, buf);
		chmodSync(dest, 0o755);
	}
}

function getTarget() {
	const map = {
		"linux-x64": "x86_64-unknown-linux-musl",
		"darwin-x64": "x86_64-apple-darwin",
		"darwin-arm64": "aarch64-apple-darwin",
	};
	const key = `${platform()}-${arch()}`;
	const t = map[key];
	if (!t) throw new Error(`Unsupported platform: ${key}`);
	return t;
}

async function main() {
	if (isAvailable("typst")) {
		console.log("[typst] ✓ found in PATH");
		return;
	}
	if (existsSync(LOCAL_BIN) && isAvailable(LOCAL_BIN)) {
		console.log("[typst] ✓ found locally");
		return;
	}

	const target = getTarget();
	const url = `https://github.com/typst/typst/releases/download/v${TYPST_VERSION}/typst-${target}.tar.xz`;

	console.log(`[typst] ↓ downloading ${target}...`);
	mkdirSync(join(ROOT, "node_modules", ".bin"), { recursive: true });
	await download(url, LOCAL_BIN);
	console.log(`[typst] ✓ installed to ${LOCAL_BIN}`);
}

main().catch((err) => {
	console.error("[typst] ✗", err.message);
	process.exit(1);
});
