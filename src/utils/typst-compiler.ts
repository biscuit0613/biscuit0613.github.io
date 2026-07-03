import { execSync } from "node:child_process";
import {
	existsSync,
	mkdirSync,
	readdirSync,
	readFileSync,
	statSync,
	unlinkSync,
	writeFileSync,
} from "node:fs";
import { basename, join } from "node:path";

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
	category?: string;
	pinned?: boolean;
	order?: number;
	draft?: boolean;
}

export interface TypstFile {
	slug: string;
	sourcePath: string;
	meta: TypstMeta;
}

export interface CompiledSvg {
	html: string;
	pageCount: number;
	plainText: string;
	coverSvg: string;
	coverAspect: number;
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
	const cacheStamp = join(outDir, ".stamp");

	// mtime-based cache — skip recompile if source unchanged
	const needsCompile =
		!existsSync(cacheStamp) ||
		statSync(file.sourcePath).mtimeMs > Number(readFileSync(cacheStamp, "utf-8"));

	if (needsCompile) {
		for (const f of readdirSync(outDir)) {
			try {
				unlinkSync(join(outDir, f));
			} catch {}
		}
		execSync(
			`${typstBin()} compile --format svg --pages 1- "${file.sourcePath}" "${join(outDir, "{p}.svg")}"`,
			{ stdio: "pipe" },
		);
		writeFileSync(cacheStamp, String(statSync(file.sourcePath).mtimeMs));
	}

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
			const cls = pages.length > 1 ? "typst-page" : "";
			return `<div class="${cls}">${svg}</div>`;
		})
		.join("");

	const coverSvg = svgContents[0] || "";
	const coverAspect = parseViewBoxAspect(coverSvg);
	const plainText = extractTextFromSource(readFileSync(file.sourcePath, "utf-8"));

	return { html, pageCount: pages.length, plainText, coverSvg, coverAspect };
}

export function compileSnippetToSvg(code: string): string {
	const slug = hashStr(code);
	const outDir = join(CACHE_DIR, "snippets");
	mkdirSync(outDir, { recursive: true });
	const srcPath = join(outDir, `${slug}.typ`);
	const outPath = join(outDir, `${slug}.svg`);

	if (!existsSync(outPath)) {
		writeFileSync(srcPath, code, "utf-8");
		execSync(`${typstBin()} compile --format svg "${srcPath}" "${outPath}"`, {
			stdio: "pipe",
		});
	}

	return readFileSync(outPath, "utf-8");
}

export function getDocumentsByCategory(
	docs: (TypstFile & { compiled: CompiledSvg })[],
	category: string,
) {
	return docs
		.filter((d) => d.meta.category === category)
		.sort((a, b) => (a.meta.order ?? 99) - (b.meta.order ?? 99));
}

function parseViewBoxAspect(svg: string): number {
	const m = svg.match(/viewBox="[^"]*\s(\d+\.?\d*)\s(\d+\.?\d*)"/);
	if (m) {
		const w = Number.parseFloat(m[1]);
		const h = Number.parseFloat(m[2]);
		if (w > 0 && h > 0) return w / h;
	}
	return 210 / 297;
}

function extractTextFromSource(source: string): string {
	return source
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
}

function hashStr(s: string): string {
	let h = 0;
	for (let i = 0; i < s.length; i++) {
		h = (Math.imul(31, h) + s.charCodeAt(i)) | 0;
	}
	return Math.abs(h).toString(36);
}
