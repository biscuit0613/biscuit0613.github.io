import { visit } from "unist-util-visit";
import { compileSnippetToSvg } from "../utils/typst-compiler";

export function remarkTypst() {
	return (tree) => {
		visit(tree, "code", (node) => {
			if (node.lang === "typst") {
				try {
					const svg = compileSnippetToSvg(node.value);
					node.type = "html";
					node.value = `<div class="typst-inline">${svg}</div>`;
				} catch (e) {
					console.warn(`[typst] failed to compile inline snippet:`, e.message);
					node.type = "html";
					node.value = `<pre class="typst-error">Typst compilation failed: ${e.message}</pre>`;
				}
			}
		});
	};
}
