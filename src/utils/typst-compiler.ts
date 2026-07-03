import { execSync } from "node:child_process";
import {
	existsSync,
	mkdirSync,
	readFileSync,
	readdirSync,
	writeFileSync,
	unlinkSync,
} from "node:fs";
import { join, basename } from "node:path";

const TYPST_SRC = join(process.cwd(), "typst");
const CACHE_DIR = join(process.cwd(), "node_modules", ".cache", "typst");

function typstBin(): string {
	const local = join(process.cwd(), "node_modules", ".bin", "typst");
	if (existsSync(local)) return local;
	return "typst";
}

export interface TypstMeta {
	title: string;
	description?: string;
	published?: string;
	tags?: string[];
	draft?: boolean;
}

export interface TypstFile {
	slug: string;
	sourcePath: string;
	meta: TypstMeta;
}

export interface CompiledSvg {
	/** HTML string of all SVG pages concatenated */
	html: string;
	/** Number of pages */
	pageCount: number;
	/** Plain text for search indexing */
	plainText: string;
}

export function scanTypstFiles(): TypstFile[] {
	if (!existsSync(TYPST_SRC)) return [];

	return readdirSync(TYPST_SRC)
		.filter((f) => f.endsWith(".typ"))
		.map((f) => {
			const slug = basename(f, ".typ");
			const metaPath = join(TYPST_SRC, `${slug}.meta.json`);
			const meta: TypstMeta = { title: slug };
			if (existsSync(metaPath)) {
				try {
					const parsed = JSON.parse(readFileSync(metaPath, "utf-8"));
					Object.assign(meta, parsed);
				} catch {
					console.warn(`[typst] invalid meta: ${metaPath}`);
				}
			}
			return { slug, sourcePath: join(TYPST_SRC, f), meta };
		})
		.filter((f) => !f.meta.draft);
}

export function compileToSvg(file: TypstFile): CompiledSvg {
	const outDir = join(CACHE_DIR, "svg", file.slug);
	mkdirSync(outDir, { recursive: true });

	// Clean stale files from previous compilations
	for (const f of readdirSync(outDir)) {
		if (f.endsWith(".svg")) {
			try { unlinkSync(join(outDir, f)); } catch {}
		}
	}

	execSync(
		`${typstBin()} compile --format svg --pages 1- "${file.sourcePath}" "${join(outDir, "{p}.svg")}"`,
		{ stdio: "pipe" },
	);

	const pages = readdirSync(outDir)
		.filter((f) => f.endsWith(".svg"))
		.sort((a, b) => {
			const na = Number.parseInt(a.replace(".svg", ""), 10);
			const nb = Number.parseInt(b.replace(".svg", ""), 10);
			return na - nb;
		});

	const svgContents = pages.map((f) => readFileSync(join(outDir, f), "utf-8"));

	const html = svgContents
		.map((svg, i) => {
			const pageClass = pages.length > 1 ? "typst-page" : "";
			return `<div class="${pageClass}">${svg}</div>`;
		})
		.join("");

	const plainText = extractTextFromSource(readFileSync(file.sourcePath, "utf-8"));

	return { html, pageCount: pages.length, plainText };
}

export function compileSnippetToSvg(code: string): string {
	const slug = hashStr(code);
	const outDir = join(CACHE_DIR, "snippets");
	mkdirSync(outDir, { recursive: true });
	const srcPath = join(outDir, `${slug}.typ`);
	const outPath = join(outDir, `${slug}.svg`);

	if (!existsSync(outPath)) {
		writeFileSync(srcPath, code, "utf-8");
		execSync(
			`${typstBin()} compile --format svg "${srcPath}" "${outPath}"`,
			{ stdio: "pipe" },
		);
	}

	return readFileSync(outPath, "utf-8");
}

function extractTextFromSource(source: string): string {
	let text = source
		.replace(/\/\/.*$/gm, "")
		.replace(/\/\*[\s\S]*?\*\//g, "")
		.replace(/`[^`]*`/g, "")
		.replace(/#raw\([^)]*\)/g, "")
		.replace(/#set\s+\w+[\s\S]*?(?=\n\n|$)/g, "")
		.replace(/==+\s*/g, "")
		.replace(/#\w+/g, " ")
		.replace(/@\w+/g, " ")
		.replace(/[_*$~]/g, " ")
		.replace(/\n{2,}/g, "\n")
		.replace(/\s+/g, " ")
		.trim();
	return text;
}

function hashStr(s: string): string {
	let h = 0;
	for (let i = 0; i < s.length; i++) {
		h = (Math.imul(31, h) + s.charCodeAt(i)) | 0;
	}
	return Math.abs(h).toString(36);
}
