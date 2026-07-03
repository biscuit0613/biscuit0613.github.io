<script lang="ts">
	let dragging = $state(false);
	let open = $state(false);
	let atTop = $state(true);
	let snapRight = $state(true);
	let offX = $state(24);
	let offY = $state(24);

	let mainEl: HTMLDivElement | undefined = $state(undefined);

	let _pid = -1;
	let _bx = 24, _by = 24;
	let _sx = 0, _sy = 0;
	let _moved = false;

	function load() {
		try {
			const p = JSON.parse(localStorage.getItem("fab-pos") ?? "null");
			if (p) { snapRight = p.r ?? true; offX = p.x ?? 24; offY = p.y ?? 24; }
		} catch {}
		if (localStorage.getItem("fab-sidebar-hidden")) {
			document.getElementById("sidebar-section")?.classList.add("hidden");
		}
	}

	function save() {
		localStorage.setItem("fab-pos", JSON.stringify({ r: snapRight, x: offX, y: offY }));
	}

	function close() { open = false; }

	function onDown(e: PointerEvent) {
		const t = e.target instanceof Node ? e.target : null;
		if (!t?.closest("#fab-main")) { close(); return; }
		_sx = e.clientX; _sy = e.clientY;
		_bx = offX; _by = offY;
		_moved = false;
		_pid = e.pointerId;
		dragging = true;
		close();
		if (mainEl) {
			mainEl.style.transition = "none";
			mainEl.setPointerCapture(e.pointerId);
		}
	}

	function onMove(e: PointerEvent) {
		if (!dragging || e.pointerId !== _pid) return;
		const dx = e.clientX - _sx;
		const dy = e.clientY - _sy;
		if (Math.abs(dx) > 4 || Math.abs(dy) > 4) _moved = true;
		offX = Math.max(8, Math.min(innerWidth - 56, _bx - dx));
		offY = Math.max(8, Math.min(innerHeight - 56, _by + dy));
	}

	function onUp(e: PointerEvent) {
		if (!dragging || e.pointerId !== _pid) return;
		dragging = false;
		_pid = -1;
		if (mainEl) {
			mainEl.style.removeProperty("transition");
			try { mainEl.releasePointerCapture(e.pointerId); } catch {}
		}
		if (_moved) {
			snapRight = offX >= innerWidth / 2;
			save();
			_moved = false;
		}
	}

	function onClick() {
		if (_moved) { _moved = false; return; }
		open = !open;
	}

	function doTop() { scroll({ top: 0, behavior: "smooth" }); close(); }
	function doSidebar() {
		const s = document.getElementById("sidebar-section");
		if (!s) return;
		const h = s.classList.toggle("hidden");
		localStorage.setItem("fab-sidebar-hidden", h ? "1" : "");
		close();
	}

	$effect(() => load());
	$effect(() => {
		const h = () => atTop = scrollY < 100;
		h();
		addEventListener("scroll", h, { passive: true });
		return () => removeEventListener("scroll", h);
	});
</script>

<div
	id="fab-wrap"
	class="fab-wrap"
	class:snap-left={!snapRight}
	style:right={snapRight ? `${offX}px` : void 0}
	style:left={snapRight ? void 0 : `${offX}px`}
	style:bottom={`${offY}px`}
>
	<div
		bind:this={mainEl}
		id="fab-main"
		class="fab-main"
		class:open
		class:dragging
		role="button"
		tabindex="0"
		aria-label="功能菜单"
		onpointerdown={onDown}
		onpointermove={onMove}
		onpointerup={onUp}
		onclick={onClick}
		onkeydown={(e: KeyboardEvent) => { if (e.key === "Enter" || e.key === " ") { e.preventDefault(); open = !open; } }}
	>
		<div class="fab-ring"></div>
		<div class="fab-body">
			<div class="spot-a"></div>
			<div class="spot-b"></div>
			<span class="fab-x">{open ? "✕" : "＋"}</span>
		</div>
	</div>

	{#each [{ i: "↑", l: "回到顶部", a: doTop, d: () => atTop }, { i: "☰", l: "侧边栏", a: doSidebar, d: () => false }] as item, idx}
		<button
			class="fab-item" class:v={open} class:dim={item.d()}
			style:bottom={`${54 * (idx + 1)}px`}
			style:transition-delay={open ? `${idx * 50}ms` : `${(1 - idx) * 30}ms`}
			onclick={item.a}
		>
			<span class="fi-i">{item.i}</span>
			<span class="fi-l">{item.l}</span>
		</button>
	{/each}
</div>

<style>
	.fab-wrap {
		position: fixed;
		z-index: 100;
		min-width: 48px;
		min-height: 48px;
	}

	.fab-main {
		width: 48px;
		height: 48px;
		border-radius: 50%;
		cursor: grab;
		z-index: 101;
		user-select: none;
		touch-action: none;
	}
	.fab-main:active { cursor: grabbing; }
	.fab-main.dragging { scale: 1.08; }

	@property --fa { syntax: "<angle>"; initial-value: 0deg; inherits: false; }
	.fab-ring {
		position: absolute; inset: -3px; border-radius: 50%;
		background: conic-gradient(from var(--fa), transparent 20%, oklch(.75 .12 250 / .4) 40%, oklch(.85 .08 210 / .25) 50%, transparent 70%);
		animation: rn 4s linear infinite;
		transition: opacity .3s, animation-duration .3s;
		pointer-events: none;
	}
	.fab-main.open .fab-ring { animation-duration: 2s; opacity: .7; }

	.fab-body {
		position: absolute; inset: 0; border-radius: 50%;
		background: oklch(.92 .02 250 / .55);
		backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px);
		box-shadow: 0 4px 20px oklch(0 0 0 / .15), inset 0 1px 0 oklch(1 0 0 / .5);
		display: flex; align-items: center; justify-content: center; overflow: hidden;
	}
	:root.dark .fab-body {
		background: oklch(.25 .02 250 / .6);
		box-shadow: 0 4px 20px oklch(0 0 0 / .35), inset 0 1px 0 oklch(1 0 0 / .08);
	}

	.spot-a, .spot-b {
		position: absolute; border-radius: 50%; pointer-events: none;
		background: oklch(1 0 0 / .25); filter: blur(8px);
		animation: df 5s ease-in-out infinite alternate;
	}
	.spot-a { width: 16px; height: 10px; top: 20%; left: 15%; animation-delay: -1s; }
	.spot-b { width: 10px; height: 16px; bottom: 20%; right: 15%; animation-delay: -3s; background: oklch(.8 .08 250 / .2); }
	.fab-main.open .spot-a, .fab-main.open .spot-b { opacity: .7; }

	.fab-x {
		position: relative; z-index: 1;
		font-size: 1.25rem; line-height: 1;
		color: oklch(.3 .04 250);
		transition: transform .15s cubic-bezier(.34,1.56,.64,1);
	}
	.fab-main.open .fab-x { transform: rotate(135deg); }
	:root.dark .fab-x { color: oklch(.85 .03 250); }

	.fab-item {
		position: absolute; width: 40px; height: 40px; border-radius: 50%;
		border: 0; padding: 0; cursor: pointer; z-index: 101;
		display: flex; align-items: center; justify-content: center;
		background: oklch(.93 .01 250 / .7);
		backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px);
		box-shadow: 0 2px 10px oklch(0 0 0 / .1);
		opacity: 0; transform: scale(.4) translateY(4px);
		transition: opacity .18s cubic-bezier(.34,1.56,.64,1), transform .18s cubic-bezier(.34,1.56,.64,1), background .15s;
	}
	.fab-item.v { opacity: 1; transform: scale(1) translateY(0); }
	.fab-item:hover { background: oklch(.88 .03 250 / .85); box-shadow: 0 4px 14px oklch(0 0 0 / .15); }
	.fab-item.dim { opacity: .35; pointer-events: none; }
	:root.dark .fab-item { background: oklch(.28 .02 250 / .65); box-shadow: 0 2px 10px oklch(0 0 0 / .25); }
	:root.dark .fab-item:hover { background: oklch(.35 .03 250 / .75); }

	.fi-i { font-size: 1rem; line-height: 1; }
	.fi-l {
		position: absolute; right: calc(100% + 8px); top: 50%; translate: 4px -50%;
		padding: 3px 8px; border-radius: 6px;
		background: oklch(.18 0 0 / .85); color: oklch(.92 0 0);
		font-size: .75rem; font-weight: 500; white-space: nowrap;
		backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px);
		opacity: 0; transition: opacity .12s, translate .12s; pointer-events: none;
	}
	.fab-item:hover .fi-l { opacity: 1; translate: 0 -50%; }

	@keyframes rn { to { --fa: 360deg; } }
	@keyframes df { 0% { translate: 0 0; } 50% { translate: 4px -4px; } 100% { translate: -2px 3px; } }
</style>
