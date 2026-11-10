import { defineCollection, z } from "astro:content";

const postsCollection = defineCollection({
	schema: z.object({
		title: z.string(),
		published: z.date(),
		updated: z.date().optional(),
		draft: z.boolean().optional().default(false),
		description: z.string().optional().default(""),
		image: z.string().optional().default(""),
		tags: z.array(z.string()).optional().default([]),
		category: z.string().optional().nullable().default(""),
		lang: z.string().optional().default(""),
		pinned: z.boolean().optional().default(false),
		author: z.string().optional().default(""),
		sourceLink: z.string().optional().default(""),
		licenseName: z.string().optional().default(""),
		licenseUrl: z.string().optional().default(""),

		/* Custom reading order within a category */
		order: z.number().optional(),

		/* For internal use */
		prevTitle: z.string().default(""),
		prevSlug: z.string().default(""),
		nextTitle: z.string().default(""),
		nextSlug: z.string().default(""),
		readingOrderPrevTitle: z.string().default(""),
		readingOrderPrevSlug: z.string().default(""),
		readingOrderNextTitle: z.string().default(""),
		readingOrderNextSlug: z.string().default(""),

		/*
		 * Encryption support (added by remark-encrypt plugin)
		 * password: only exists during build, stripped from output
		 * encrypted / encryptedContent / encryptSalt / encryptIv: injected by plugin
		 */
		password: z.string().optional().default(""),
		encrypted: z.boolean().optional().default(false),
		encryptedContent: z.string().optional().default(""),
		encryptSalt: z.string().optional().default(""),
		encryptIv: z.string().optional().default(""),
	}),
});
const specCollection = defineCollection({
	schema: z.object({}),
});
export const collections = {
	posts: postsCollection,
	spec: specCollection,
};
