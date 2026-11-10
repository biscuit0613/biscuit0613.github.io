declare global {
	interface HTMLElementTagNameMap {
		"table-of-contents": HTMLElement & {
			init?: () => void;
		};
	}

	interface Window {
		// Define swup type directly since @swup/astro doesn't export AstroIntegration
		swup: any;
		pagefind: {
			search: (query: string) => Promise<{
				results: Array<{
					data: () => Promise<SearchResult>;
				}>;
			}>;
		};
		translate?: {
			service: {
				use: (service: string) => void;
			};
			language: {
				setLocal: (language: string) => void;
				getLocal: () => string;
				translateLocal: boolean;
			};
			setAutoDiscriminateLocalLanguage: () => void;
			ignore: {
				class: string[];
				tag: string[];
			};
			selectLanguageTag: {
				show: boolean;
			};
			storage: {
				set: () => void;
			};
			listener: {
				start: () => void;
			};
			execute: () => void;
			reset?: () => void;
			to?: string;
		};
		mobileTOCInit?: () => void;
		semifullScrollHandler?: (() => void) | null;
		initSemifullScrollDetection?: () => void;
		closeAnnouncement?: () => void;
		iconifyLoaded?: boolean;
		loadTranslateScript?: () => Promise<void>;
		galleryManager: {
			isInitialized: boolean;
			init: () => void;
			cleanup: () => void;
		};
		__iconifyLoader?: {
			isLoaded: boolean;
			load: () => Promise<void>;
			addToPreloadQueue: (icons: string | string[]) => void;
			onLoad: (callback: () => void) => void;
		};
	}
}

export {};

interface SearchResult {
	url: string;
	meta: {
		title: string;
	};
	excerpt: string;
	content?: string;
	word_count?: number;
	filters?: Record<string, unknown>;
	anchors?: Array<{
		element: string;
		id: string;
		text: string;
		location: number;
	}>;
	weighted_locations?: Array<{
		weight: number;
		balanced_score: number;
		location: number;
	}>;
	locations?: number[];
	raw_content?: string;
	raw_url?: string;
	sub_results?: SearchResult[];
}
