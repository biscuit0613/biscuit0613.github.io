<script lang="ts">
	let open = $state(false);
	let dragging = $state(false);
	let snapRight = $state(true);
	let offsetX = $state(24);
	let offsetY = $state(24);
	let atTop = $state(true);

	const ITEM_GAP = 56;

	let dragState: {
		startX: number;
		startY: number;
		baseX: number;
		baseY: number;
	} | null = null;

	function loadState() {
		try {
			const raw = localStorage.getItem("fab-pos");
			if (raw) {
				const p = JSON.parse(raw);
				snapRight = p.right ?? true;
				offsetX = p.x ?? 24;
				offsetY = p.y ?? 24;
			}
		} catch {}
		const sidebarPref = localStorage.getItem("fab-sidebar-hidden");
		if (sidebarPref) {
			const section = document.getElementById("sidebar-section");
			if (section) section.classList.add("hidden");
		}
	}

	function persist() {
		localStorage.setItem(
			"fab-pos",
			JSON.stringify({ x: offsetX, y: offsetY, right: snapRight }),
		);
	}

	function close() {
		open = false;
	}

	function toggleOpen() {
		open = !open;
	}

	function onPointerDown(e: PointerEvent) {
		const t = e.target as HTMLElement | null;
		if (!t?.closest("#fab-main")) {
			if (open) close();
			return;
		}
		dragging = true;
		open = false;
		const el = document.getElementById("fab-main");
		if (el) el.style.transition = "none";
		dragState = {
			startX: e.clientX,
			startY: e.clientY,
			baseX: offsetX,
			baseY: offsetY,
		};
	}

	function onPointerMove(e: PointerEvent) {
		if (!dragState) return;
		offsetX = Math.max(8, Math.min(window.innerWidth - 56, dragState.baseX + (dragState.startX - e.clientX)));
		offsetY = Math.max(8, Math.min(window.innerHeight - 56, dragState.baseY + (e.clientY - dragState.startY)));
	}

	function onPointerUp() {
		if (!dragState) return;
		dragState = null;
		dragging = false;
		const el = document.getElementById("fab-main");
		if (el) el.style.transition = "";

		const w = window.innerWidth;
		snapRight = offsetX >= w / 2;
		persist();
	}

	function onMainClick(e: MouseEvent) {
		if (dragState) return;
		const target = e.currentTarget as HTMLElement;
		toggleOpen();
	}

	function onMainKeyDown(e: KeyboardEvent) {
		if (e.key === "Enter" || e.key === " ") {
			e.preventDefault();
			toggleOpen();
		}
	}

	$effect(() => {
		loadState();
		window.addEventListener("pointerdown", onPointerDown);
		window.addEventListener("pointermove", onPointerMove);
		window.addEventListener("pointerup", onPointerUp);
		return () => {
			window.removeEventListener("pointerdown", onPointerDown);
			window.removeEventListener("pointermove", onPointerMove);
			window.removeEventListener("pointerup", onPointerUp);
		};
	});

	$effect(() => {
		const handler = () => {
			atTop = window.scrollY < 100;
		};
		handler();
		window.addEventListener("scroll", handler, { passive: true });
		return () => window.removeEventListener("scroll", handler);
	});

	function scrollTop() {
		window.scroll({ top: 0, behavior: "smooth" });
		close();
	}

	function toggleSidebar() {
		const section = document.getElementById("sidebar-section");
		if (!section) return;
		const hidden = section.classList.toggle("hidden");
		localStorage.setItem("fab-sidebar-hidden", hidden ? "1" : "");
		close();
	}

	const items = [
		{ icon: "↑", label: "回到顶部", action: scrollTop, disabled: () => atTop },
		{ icon: "☰", label: "侧边栏", action: toggleSidebar, disabled: () => false },
	] as const;
</script>

<div
	id="fab-root"
	class="fab-root"
	style:right={snapRight ? `${offsetX}px` : void 0}
	style:left={snapRight ? void 0 : `${offsetX}px`}
	style:bottom={`${offsetY}px`}
>
	<div
		id="fab-main"
		class="fab-main"
		class:open
		class:dragging
		tabindex="0"
		role="button"
		aria-label="功能菜单"
		onclick={onMainClick}
		onkeydown={onMainKeyDown}
	>
		<div class="fab-glow-ring"></div>
		<div class="fab-glass">
			<div class="fab-spot fab-spot-1"></div>
			<div class="fab-spot fab-spot-2"></div>
			<span class="fab-icon">{open ? "✕" : "＋"}</span>
		</div>
	</div>

	{#each items as item, i (item.icon)}
		<button
			class="fab-item"
			class:visible={open}
			class:disabled={item.disabled()}
			style:transition-delay={open ? `${i * 50}ms` : `${(items.length - 1 - i) * 30}ms`}
			style:bottom={`${(i + 1) * ITEM_GAP + 8}px`}
			onclick={item.action}
		>
			<span class="fab-item-icon">{item.icon}</span>
			<span class="fab-tooltip">{item.label}</span>
		</button>
	{/each}
</div>

<style>
	.fab-root {
		position: fixed;
		z-index: 100;
		bottom: 16px;
	}

	.fab-main {
		position: relative;
		width: 48px;
		height: 48px;
		border-radius: 50%;
		cursor: grab;
		z-index: 101;
		user-select: none;
		-webkit-user-select: none;
		touch-action: none;
	}

	.fab-main:active {
		cursor: grabbing;
	}

	.fab-main.dragging {
		scale: 1.08;
	}

	@property --fab-angle {
		syntax: "<angle>";
		initial-value: 0deg;
		inherits: false;
	}

	.fab-glow-ring {
		position: absolute;
		inset: -3px;
		border-radius: 50%;
		background: conic-gradient(
			from var(--fab-angle),
			transparent 20%,
			oklch(0.75 0.12 250 / 0.4) 40%,
			oklch(0.85 0.08 210 / 0.25) 50%,
			transparent 70%
		);
		animation: fab-spin 4s linear infinite;
		transition: opacity 0.3s, animation-duration 0.3s;
		pointer-events: none;
	}

	.fab-main.open .fab-glow-ring {
		animation-duration: 2s;
		opacity: 0.7;
	}

	.fab-glass {
		position: absolute;
		inset: 0;
		border-radius: 50%;
		background: oklch(0.92 0.02 250 / 0.55);
		backdrop-filter: blur(16px);
		-webkit-backdrop-filter: blur(16px);
		box-shadow: 0 4px 20px oklch(0 0 0 / 0.15), inset 0 1px 0 oklch(1 0 0 / 0.5);
		display: flex;
		align-items: center;
		justify-content: center;
		overflow: hidden;
		transition: background 0.2s;
	}

	:root.dark .fab-glass {
		background: oklch(0.25 0.02 250 / 0.6);
		box-shadow: 0 4px 20px oklch(0 0 0 / 0.35), inset 0 1px 0 oklch(1 0 0 / 0.08);
	}

	.fab-spot {
		position: absolute;
		border-radius: 50%;
		background: oklch(1 0 0 / 0.25);
		filter: blur(8px);
		pointer-events: none;
		animation: fab-drift 5s ease-in-out infinite alternate;
	}

	.fab-spot-1 {
		width: 16px;
		height: 10px;
		top: 20%;
		left: 15%;
		animation-delay: -1s;
	}

	.fab-spot-2 {
		width: 10px;
		height: 16px;
		bottom: 20%;
		right: 15%;
		animation-delay: -3s;
		background: oklch(0.8 0.08 250 / 0.2);
	}

	.fab-main.open .fab-spot {
		opacity: 0.7;
	}

	.fab-icon {
		position: relative;
		z-index: 1;
		font-size: 1.25rem;
		line-height: 1;
		color: oklch(0.3 0.04 250);
		transition: transform 0.15s cubic-bezier(0.34, 1.56, 0.64, 1);
	}

	.fab-main.open .fab-icon {
		transform: rotate(135deg);
	}

	:root.dark .fab-icon {
		color: oklch(0.85 0.03 250);
	}

	.fab-item {
		position: absolute;
		width: 40px;
		height: 40px;
		border-radius: 50%;
		border: none;
		padding: 0;
		cursor: pointer;
		z-index: 101;
		display: flex;
		align-items: center;
		justify-content: center;
		background: oklch(0.93 0.01 250 / 0.7);
		backdrop-filter: blur(12px);
		-webkit-backdrop-filter: blur(12px);
		box-shadow: 0 2px 10px oklch(0 0 0 / 0.1);
		opacity: 0;
		transform: scale(0.4) translateY(4px);
		transition:
			opacity 0.18s cubic-bezier(0.34, 1.56, 0.64, 1),
			transform 0.18s cubic-bezier(0.34, 1.56, 0.64, 1),
			background 0.15s;
		touch-action: none;
	}

	.fab-item.visible {
		opacity: 1;
		transform: scale(1) translateY(0);
	}

	.fab-item:hover {
		background: oklch(0.88 0.03 250 / 0.85);
		box-shadow: 0 4px 14px oklch(0 0 0 / 0.15);
	}

	.fab-item.disabled {
		opacity: 0.35;
		pointer-events: none;
	}

	:root.dark .fab-item {
		background: oklch(0.28 0.02 250 / 0.65);
		box-shadow: 0 2px 10px oklch(0 0 0 / 0.25);
	}

	:root.dark .fab-item:hover {
		background: oklch(0.35 0.03 250 / 0.75);
	}

	.fab-item-icon {
		font-size: 1rem;
		line-height: 1;
	}

	.fab-tooltip {
		position: absolute;
		right: calc(100% + 8px);
		top: 50%;
		translate: 0 -50%;
		padding: 3px 8px;
		border-radius: 6px;
		background: oklch(0.18 0 0 / 0.85);
		color: oklch(0.92 0 0);
		font-size: 0.75rem;
		font-weight: 500;
		white-space: nowrap;
		backdrop-filter: blur(8px);
		-webkit-backdrop-filter: blur(8px);
		opacity: 0;
		translate: 4px -50%;
		transition: opacity 0.12s, translate 0.12s;
		pointer-events: none;
	}

	.fab-item:hover .fab-tooltip {
		opacity: 1;
		translate: 0 -50%;
	}

	@keyframes fab-spin {
		to {
			--fab-angle: 360deg;
		}
	}

	@keyframes fab-drift {
		0% {
			translate: 0 0;
		}
		50% {
			translate: 4px -4px;
		}
		100% {
			translate: -2px 3px;
		}
	}
</style>
