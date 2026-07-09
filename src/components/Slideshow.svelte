<script lang="ts">
import Icon from "@iconify/svelte";

let {
	title = "",
	pageSvgs = [] as string[],
}: {
	title?: string;
	pageSvgs?: string[];
} = $props();

let active = $state(false);
let current = $state(0);
let containerEl: HTMLDivElement | undefined = $state();

function open() {
	active = true;
	current = 0;
	document.body.style.overflow = "hidden";
	requestAnimationFrame(() => {
		containerEl?.requestFullscreen().catch(() => {});
	});
}

function close() {
	active = false;
	document.body.style.overflow = "";
	if (document.fullscreenElement) {
		document.exitFullscreen().catch(() => {});
	}
}

function prev() {
	if (current > 0) current--;
}

function next() {
	if (current < pageSvgs.length - 1) current++;
}

function onKeydown(e: KeyboardEvent) {
	const key = e.key;
	if (key === "ArrowLeft" || key === "ArrowUp" || key === "PageUp") {
		e.preventDefault();
		prev();
	} else if (
		key === "ArrowRight" ||
		key === "ArrowDown" ||
		key === "PageDown" ||
		key === " "
	) {
		e.preventDefault();
		next();
	} else if (key === "Escape") {
		close();
	}
}

function onFullscreenChange() {
	if (!document.fullscreenElement && active) {
		close();
	}
}

function onContainerClick(e: MouseEvent) {
	if (
		(e.target as HTMLElement).closest(
			"button, a, [role='button'], .slideshow-topbar, .slideshow-dots, .slideshow-nav-hint",
		)
	)
		return;
	const rect = containerEl?.getBoundingClientRect();
	if (!rect) return;
	const x = e.clientX - rect.left;
	if (x < rect.width * 0.35) {
		prev();
	} else if (x > rect.width * 0.65) {
		next();
	}
}

let touchStartX = 0;
function onTouchStart(e: TouchEvent) {
	touchStartX = e.touches[0].clientX;
}

function onTouchEnd(e: TouchEvent) {
	const dx = e.changedTouches[0].clientX - touchStartX;
	if (Math.abs(dx) > window.innerWidth * 0.12) {
		if (dx > 0) prev();
		else next();
	}
}

$effect(() => {
	if (active) {
		window.addEventListener("keydown", onKeydown);
		document.addEventListener("fullscreenchange", onFullscreenChange);
		return () => {
			window.removeEventListener("keydown", onKeydown);
			document.removeEventListener("fullscreenchange", onFullscreenChange);
		};
	}
});
</script>

{#if active}
	<div
		bind:this={containerEl}
		class="slideshow-overlay"
		onclick={onContainerClick}
		ontouchstart={onTouchStart}
		ontouchend={onTouchEnd}
	>
		<div class="slideshow-topbar">
			<span class="slideshow-counter">{current + 1} / {pageSvgs.length}</span>
			<button class="slideshow-close" onclick={close} aria-label="退出放映">
				<Icon icon="material-symbols:close" class="text-xl" />
			</button>
		</div>
		<div class="slideshow-body">
			<div class="slideshow-slide">
				{@html pageSvgs[current]}
			</div>
		</div>
		<div class="slideshow-dots">
			{#each pageSvgs as _, i}
				<button
					class="slideshow-dot"
					class:active={i === current}
					onclick={() => current = i}
					aria-label={"第" + (i + 1) + "页"}
				></button>
			{/each}
		</div>
		<div class="slideshow-nav-hint slideshow-nav-prev" onclick={prev} aria-label="上一页">
			<Icon icon="material-symbols:chevron-left" class="text-3xl" />
		</div>
		<div class="slideshow-nav-hint slideshow-nav-next" onclick={next} aria-label="下一页">
			<Icon icon="material-symbols:chevron-right" class="text-3xl" />
		</div>
	</div>
{:else}
	<button class="slideshow-trigger" onclick={open}>
		<Icon icon="material-symbols:slideshow" class="text-lg" />
		<span>幻灯片放映</span>
	</button>
{/if}

<style>
	.slideshow-overlay {
		position: fixed;
		inset: 0;
		z-index: 99999;
		background: #000;
		display: flex;
		flex-direction: column;
		color: #fff;
	}

	.slideshow-topbar {
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 0.75rem 1.25rem;
		z-index: 10;
		background: linear-gradient(to bottom, rgba(0,0,0,0.6), transparent);
		pointer-events: none;
		user-select: none;
	}

	.slideshow-topbar > * {
		pointer-events: auto;
	}

	.slideshow-counter {
		font-size: 0.875rem;
		font-variant-numeric: tabular-nums;
		opacity: 0.8;
	}

	.slideshow-close {
		background: rgba(255,255,255,0.1);
		border: none;
		color: #fff;
		cursor: pointer;
		width: 2.25rem;
		height: 2.25rem;
		border-radius: 50%;
		display: flex;
		align-items: center;
		justify-content: center;
		transition: background 0.2s;
	}

	.slideshow-close:hover {
		background: rgba(255,255,255,0.25);
	}

	.slideshow-body {
		flex: 1;
		display: flex;
		align-items: center;
		justify-content: center;
		overflow: hidden;
	}

	.slideshow-slide {
		display: flex;
		align-items: center;
		justify-content: center;
		width: 100%;
		height: 100%;
		padding: 3rem;
		box-sizing: border-box;
	}

	.slideshow-slide :global(svg) {
		max-width: 100%;
		max-height: 100%;
		width: auto;
		height: auto;
		display: block;
		box-shadow: 0 4px 32px rgba(0,0,0,0.35);
		border-radius: 4px;
	}

	.slideshow-dots {
		position: absolute;
		bottom: 1.25rem;
		left: 50%;
		transform: translateX(-50%);
		display: flex;
		gap: 0.5rem;
		z-index: 10;
		padding: 0.5rem 1rem;
		background: rgba(0,0,0,0.3);
		border-radius: 999px;
		pointer-events: none;
	}

	.slideshow-dots > * {
		pointer-events: auto;
	}

	.slideshow-dot {
		width: 8px;
		height: 8px;
		border-radius: 50%;
		background: rgba(255,255,255,0.3);
		border: 2px solid transparent;
		cursor: pointer;
		transition: background 0.2s, border-color 0.2s, transform 0.2s;
		padding: 0;
	}

	.slideshow-dot.active {
		background: #fff;
		border-color: rgba(255,255,255,0.5);
		transform: scale(1.3);
	}

	.slideshow-nav-hint {
		position: absolute;
		top: 50%;
		transform: translateY(-50%);
		width: 4rem;
		height: 6rem;
		display: flex;
		align-items: center;
		justify-content: center;
		cursor: pointer;
		opacity: 0;
		transition: opacity 0.3s;
		z-index: 5;
		color: rgba(255,255,255,0.6);
	}

	.slideshow-overlay:hover .slideshow-nav-hint {
		opacity: 1;
	}

	.slideshow-nav-hint:hover {
		color: #fff;
	}

	.slideshow-nav-prev {
		left: 0;
	}

	.slideshow-nav-next {
		right: 0;
	}

	.slideshow-trigger {
		display: inline-flex;
		align-items: center;
		gap: 0.5rem;
		padding: 0.5rem 1.25rem;
		border-radius: 0.75rem;
		background: var(--primary);
		color: #fff;
		border: none;
		cursor: pointer;
		font-size: 0.9rem;
		font-weight: 600;
		transition: opacity 0.2s, transform 0.15s;
		line-height: 1.4;
	}

	.slideshow-trigger:hover {
		opacity: 0.9;
		transform: scale(1.02);
	}

	.slideshow-trigger:active {
		transform: scale(0.98);
	}
</style>
