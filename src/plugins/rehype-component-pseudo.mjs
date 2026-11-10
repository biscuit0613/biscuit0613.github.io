/// <reference types="mdast" />
import { h } from "hastscript";

/**
 * Renders a :::pseudo container as a code-block-like box.
 * Content is regular markdown, so inline math is already rendered by KaTeX.
 *
 * @param {Object} properties - The properties of the component.
 * @param {import('mdast').RootContent[]} children - The children elements of the component.
 * @returns {import('mdast').Parent} The created pseudocode component.
 */
export function PseudoCodeComponent(properties, children) {
	if (!Array.isArray(children) || children.length === 0)
		return h(
			"div",
			{ class: "hidden" },
			'Invalid pseudo directive. (Use ":::pseudo[optional label] <content> :::")',
		);

	let label = null;
	let body = children;
	if (properties?.["has-directive-label"]) {
		label = children[0]; // The first child is the label
		body = children.slice(1);
	}

	const title = label?.children?.length ? label.children : ["Pseudocode"];

	return h("div", { class: "pseudo-code" }, [
		h("div", { class: "pseudo-code-header" }, [
			h("span", { class: "pseudo-code-title" }, title),
			h("span", { class: "pseudo-code-lang" }, "pseudo"),
		]),
		h("div", { class: "pseudo-code-body" }, body),
	]);
}
