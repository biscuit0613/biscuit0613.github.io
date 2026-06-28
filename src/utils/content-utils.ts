import { type CollectionEntry, getCollection } from "astro:content";
import I18nKey from "@i18n/i18nKey";
import { i18n } from "@i18n/translation";
import { getCategoryUrl } from "@utils/url-utils.ts";

async function getRawSortedPosts() {
	const allBlogPosts = await getCollection("posts", ({ data }) => {
		return import.meta.env.PROD ? data.draft !== true : true;
	});

	const sorted = allBlogPosts.sort((a, b) => {
		if (a.data.pinned && !b.data.pinned) return -1;
		if (!a.data.pinned && b.data.pinned) return 1;

		const dateA = new Date(a.data.published);
		const dateB = new Date(b.data.published);
		return dateA > dateB ? -1 : 1;
	});
	return sorted;
}

async function getReadingOrderSortedPosts() {
	const allBlogPosts = await getCollection("posts", ({ data }) => {
		return import.meta.env.PROD ? data.draft !== true : true;
	});

	const sorted = allBlogPosts.sort((a, b) => {
		if (a.data.pinned && !b.data.pinned) return -1;
		if (!a.data.pinned && b.data.pinned) return 1;

		const catA = a.data.category || "";
		const catB = b.data.category || "";
		if (catA !== catB) return catA.localeCompare(catB);

		const orderA = a.data.order ?? 999999;
		const orderB = b.data.order ?? 999999;
		if (orderA !== orderB) return orderA - orderB;

		const dateA = new Date(a.data.published);
		const dateB = new Date(b.data.published);
		return dateA > dateB ? -1 : 1;
	});
	return sorted;
}

export async function getSortedPosts() {
	const sorted = await getRawSortedPosts();
	const readingSorted = await getReadingOrderSortedPosts();

	for (let i = 1; i < sorted.length; i++) {
		sorted[i].data.nextSlug = sorted[i - 1].slug;
		sorted[i].data.nextTitle = sorted[i - 1].data.title;
	}
	for (let i = 0; i < sorted.length - 1; i++) {
		sorted[i].data.prevSlug = sorted[i + 1].slug;
		sorted[i].data.prevTitle = sorted[i + 1].data.title;
	}

	const byCategory = new Map<string, CollectionEntry<"posts">[]>();
	for (const post of readingSorted) {
		const cat = post.data.category || "";
		if (!byCategory.has(cat)) byCategory.set(cat, []);
		byCategory.get(cat)!.push(post);
	}

	const roMap = new Map<
		string,
		{ nextSlug: string; nextTitle: string; prevSlug: string; prevTitle: string }
	>();
	for (const [, posts] of byCategory) {
		for (let i = 0; i < posts.length; i++) {
			const info = { nextSlug: "", nextTitle: "", prevSlug: "", prevTitle: "" };
			if (i < posts.length - 1) {
				info.nextSlug = posts[i + 1].slug;
				info.nextTitle = posts[i + 1].data.title;
			}
			if (i > 0) {
				info.prevSlug = posts[i - 1].slug;
				info.prevTitle = posts[i - 1].data.title;
			}
			roMap.set(posts[i].slug, info);
		}
	}

	for (const entry of sorted) {
		const roInfo = roMap.get(entry.slug);
		if (roInfo) {
			entry.data.readingOrderNextSlug = roInfo.nextSlug;
			entry.data.readingOrderNextTitle = roInfo.nextTitle;
			entry.data.readingOrderPrevSlug = roInfo.prevSlug;
			entry.data.readingOrderPrevTitle = roInfo.prevTitle;
		}
	}

	return sorted;
}

export type PostForList = {
	slug: string;
	data: CollectionEntry<"posts">["data"];
};

export async function getSortedPostsList(): Promise<PostForList[]> {
	const sortedFullPosts = await getRawSortedPosts();

	const sortedPostsList = sortedFullPosts.map((post) => ({
		slug: post.slug,
		data: post.data,
	}));

	return sortedPostsList;
}

export async function getPostsForArchive() {
	const timeSorted = await getRawSortedPosts();
	const readingSorted = await getReadingOrderSortedPosts();

	return {
		timeOrdered: timeSorted.map((post) => ({
			slug: post.slug,
			data: post.data,
		})),
		readingOrdered: readingSorted.map((post) => ({
			slug: post.slug,
			data: post.data,
		})),
	};
}

export type Tag = {
	name: string;
	count: number;
};

export async function getTagList(): Promise<Tag[]> {
	const allBlogPosts = await getCollection<"posts">("posts", ({ data }) => {
		return import.meta.env.PROD ? data.draft !== true : true;
	});

	const countMap: { [key: string]: number } = {};
	allBlogPosts.map((post: { data: { tags: string[] } }) => {
		post.data.tags.map((tag: string) => {
			if (!countMap[tag]) countMap[tag] = 0;
			countMap[tag]++;
		});
	});

	const keys: string[] = Object.keys(countMap).sort((a, b) => {
		return a.toLowerCase().localeCompare(b.toLowerCase());
	});

	return keys.map((key) => ({ name: key, count: countMap[key] }));
}

export type Category = {
	name: string;
	count: number;
	url: string;
};

export async function getCategoryList(): Promise<Category[]> {
	const allBlogPosts = await getCollection<"posts">("posts", ({ data }) => {
		return import.meta.env.PROD ? data.draft !== true : true;
	});
	const count: { [key: string]: number } = {};
	allBlogPosts.map((post: { data: { category: string | null } }) => {
		if (!post.data.category) {
			const ucKey = i18n(I18nKey.uncategorized);
			count[ucKey] = count[ucKey] ? count[ucKey] + 1 : 1;
			return;
		}

		const categoryName =
			typeof post.data.category === "string"
				? post.data.category.trim()
				: String(post.data.category).trim();

		count[categoryName] = count[categoryName] ? count[categoryName] + 1 : 1;
	});

	const lst = Object.keys(count).sort((a, b) => {
		return a.toLowerCase().localeCompare(b.toLowerCase());
	});

	const ret: Category[] = [];
	for (const c of lst) {
		ret.push({
			name: c,
			count: count[c],
			url: getCategoryUrl(c),
		});
	}
	return ret;
}
