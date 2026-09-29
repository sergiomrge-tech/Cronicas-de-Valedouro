extends RefCounted
# REG_001 — renderização da camada de mundo (decalques, objetos ordenados por Y, emissores ambientais).
# Sem alocações por quadro: emissores são funções puras do tempo (não há pool a gerenciar) e as listas vêm em cache
# por chunk (reg001_procedural.gd). Só desenha assets APPROVED ("APP:") ou modelados com status liberado no manifesto.

const PROC = preload("res://scripts/reg001_procedural.gd")
const REG = preload("res://scripts/reg001_world.gd")
const MODELED = preload("res://scripts/modeled_assets.gd")
const CAST = preload("res://scripts/cast_shadow.gd")

# Sem sombra projetada em tempo real: rasteiros/decalques/água/interior e o relevo (que tem sombra assada no piso, ver bake_ground.py).
const NO_CAST: Array = ["nat_decal", "ter_", "str_crop", "nat_ford", "nat_fissure", "nat_pit", "nat_trap", "nat_flowers", "nat_grass", "nat_mushrooms", "nat_bedroll", "nat_bones", "nat_reeds", "int_", "fx_", "nat_plateau_", "nat_ridge_", "nat_wall_cliff_", "nat_cliff_", "nat_hill_", "nat_rock_pillars", "nat_waterfall", "str_dock", "str_boat", "nat_snow_mound", "nat_dune", "APP:city_floor", "APP:city_water", "APP:dungeon_floor", "APP:dungeon_spikes", "APP:city_house_door", "APP:city_house_window"]

static var last_draw_count: int = 0
static var shadows_enabled: bool = true
static var last_shadow_count: int = 0

static func resolve_asset(entry: Array) -> String:
	var asset: String = str(entry[PROC.IT_ASSET])
	var owner: Variant = entry[PROC.IT_OWNER]
	if owner is Dictionary and (owner as Dictionary).has("poi") and asset.begins_with("nat_chest_"):
		var poi_id: String = str((owner as Dictionary)["poi"])
		if REG.has_mark("opened", poi_id):
			return "nat_chest_open"
	return asset

static func frame_for(frames: int, time: float, phase: float) -> int:
	if frames <= 1:
		return 0
	if frames == 2:
		return int(time * 1.6 + phase) % 2
	return int(time * 7.0 + phase * 3.0) % frames

static func shadow(canvas: CanvasItem, c: Vector2, rx: float, ry: float, alpha: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	for step in 14:
		var a: float = TAU * float(step) / 14.0
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	canvas.draw_colored_polygon(pts, Color(0, 0, 0, alpha))

static func draw_item(canvas: CanvasItem, entry: Array, time: float, approved: Dictionary) -> bool:
	var owner: Variant = entry[PROC.IT_OWNER]
	if owner is Dictionary and REG.is_hidden(owner as Dictionary):
		return false
	var asset: String = resolve_asset(entry)
	var ground: Vector2 = Vector2(float(entry[PROC.IT_X]), float(entry[PROC.IT_Y]))
	var scale_mul: float = float(entry[PROC.IT_SCALE])
	var flip: bool = bool(entry[PROC.IT_FLIP])
	if asset.begins_with("APP:"):
		var key: String = asset.substr(4)
		if not approved.has(key):
			return false
		var atex: Texture2D = approved[key] as Texture2D
		var ds: float = scale_mul if scale_mul != 1.0 else .5
		var sz: Vector2 = atex.get_size() * ds
		if key.begins_with("city_tree"):
			shadow(canvas, ground + Vector2(4, -2), 31.0, 10.0, .22)
		canvas.draw_texture_rect(atex, Rect2(ground - Vector2(sz.x * .5, sz.y), sz), false)
		return true
	if not MODELED.has(asset):
		return false
	var e: Dictionary = MODELED.entry(asset)
	var tex: Texture2D = MODELED.texture(asset)
	if tex == null:
		return false
	var fs: Array = e["frame_size"]
	var fw: float = float(fs[0])
	var fh: float = float(fs[1])
	var foot: Array = e["foot"]
	var s: float = float(e["draw_scale"]) * scale_mul
	var frames: int = int(e["frames"])
	var frame: int = frame_for(frames, time, float(entry[PROC.IT_ANIM]))
	var r: float = float(e.get("blocks_radius", 0.0))
	if r > 0.0 and not asset.begins_with("nat_decal"):
		shadow(canvas, ground + Vector2(0, -1), r * 1.5, r * .55, .2)
	var dst_w: float = fw * s
	var dst: Rect2 = Rect2(ground - Vector2(float(foot[0]) * s, float(foot[1]) * s), Vector2(dst_w, fh * s))
	if flip:
		dst = Rect2(Vector2(dst.position.x + dst_w, dst.position.y), Vector2(-dst_w, fh * s))
	canvas.draw_texture_rect_region(tex, dst, Rect2(frame * fw, 0, fw, fh))
	return true

static func draw_ground(canvas: CanvasItem, view: Dictionary, rect: Rect2, time: float, approved: Dictionary) -> void:
	var margin: Rect2 = rect.grow(200.0)
	for entry_value in view["ground"] as Array:
		var entry: Array = entry_value
		if margin.has_point(Vector2(float(entry[PROC.IT_X]), float(entry[PROC.IT_Y]))):
			draw_item(canvas, entry, time, approved)

static func draw_objects(canvas: CanvasItem, view: Dictionary, rect: Rect2, y_from: float, y_to: float, time: float, approved: Dictionary) -> int:
	# Desenha objetos com sort_y no intervalo (y_from, y_to]; o chamador intercala herói/inimigos.
	var ys: PackedFloat32Array = view["ys"] as PackedFloat32Array
	var objs: Array = view["objs"] as Array
	var top: float = maxf(y_from, rect.position.y - 20.0)
	var bottom: float = minf(y_to, rect.end.y + 320.0)
	var i: int = PROC.first_index(ys, top)
	var drawn: int = 0
	var x_min: float = rect.position.x - 220.0
	var x_max: float = rect.end.x + 220.0
	while i < objs.size():
		var entry: Array = objs[i]
		i += 1
		var sy: float = float(entry[PROC.IT_SY])
		if sy <= y_from:
			continue
		if sy > bottom:
			break
		var x: float = float(entry[PROC.IT_X])
		if x < x_min or x > x_max:
			continue
		if draw_item(canvas, entry, time, approved):
			drawn += 1
	last_draw_count = drawn
	return drawn

# ------------------------------------------------------------------ emissores ambientais (stateless)
static func draw_emitters(canvas: CanvasItem, rect: Rect2, zone: String, time: float) -> void:
	var margin: Rect2 = rect.grow(120.0)
	for em_value in REG.emitters:
		var em: Dictionary = em_value
		if str(em["zone"]) != zone:
			continue
		var pos: Vector2 = em["pos"]
		if not margin.has_point(pos):
			continue
		if (em.has("hide_when") or em.has("show_when")) and REG.is_hidden(em):
			continue
		var kind: String = str(em["kind"])
		var radius: float = float(em["radius"])
		var seed: float = pos.x * .013 + pos.y * .007
		if kind == "smoke":
			for i in 5:
				var life: float = fposmod(time * .45 + float(i) * .2 + seed, 1.0)
				var puff: Vector2 = pos + Vector2(sin(life * 5.0 + float(i)) * 6.0 * life, -18.0 - life * 46.0)
				canvas.draw_rect(Rect2(puff - Vector2(2, 2) * (1.0 + life), Vector2(4, 4) * (1.0 + life)), Color(.78, .76, .78, .34 * (1.0 - life)))
		elif kind == "sparkle":
			for i in 6:
				var t: float = fposmod(time * .7 + float(i) * .37 + seed, 1.0)
				var ang: float = float(i) * 2.4 + seed
				var sp: Vector2 = pos + Vector2(cos(ang), sin(ang) * .6) * radius * (.3 + .7 * fposmod(float(i) * .31 + seed, 1.0)) + Vector2(0, -t * 14.0)
				var a: float = sin(t * PI)
				var col: Color = Color(.86, .95, 1, a)
				canvas.draw_rect(Rect2(sp - Vector2(1, 0), Vector2(3, 1)), col)
				canvas.draw_rect(Rect2(sp - Vector2(0, 1), Vector2(1, 3)), col)
		elif kind == "spray":
			for i in 7:
				var life2: float = fposmod(time * .9 + float(i) * .14 + seed, 1.0)
				var sp2: Vector2 = pos + Vector2((float(i) - 3.0) * 12.0 + sin(life2 * 6.0) * 4.0, 30.0 - life2 * 40.0)
				canvas.draw_rect(Rect2(sp2, Vector2(2, 2)), Color(.88, .98, 1, .5 * (1.0 - life2)))

# ------------------------------------------------------------------ sombra projetada (passada única sob todos os objetos)
static func casts_shadow(asset: String) -> bool:
	for prefix in NO_CAST:
		if asset.begins_with(str(prefix)):
			return false
	return true

static func cast_item(canvas: CanvasItem, entry: Array, time: float, approved: Dictionary) -> bool:
	var owner: Variant = entry[PROC.IT_OWNER]
	if owner is Dictionary and REG.is_hidden(owner as Dictionary):
		return false
	var asset: String = resolve_asset(entry)
	if not casts_shadow(asset):
		return false
	var ground: Vector2 = Vector2(float(entry[PROC.IT_X]), float(entry[PROC.IT_Y]))
	var scale_mul: float = float(entry[PROC.IT_SCALE])
	var flip: bool = bool(entry[PROC.IT_FLIP])
	if asset.begins_with("APP:"):
		var key: String = asset.substr(4)
		if not approved.has(key):
			return false
		var atex: Texture2D = approved[key] as Texture2D
		var ds: float = scale_mul if scale_mul != 1.0 else .5
		var sz: Vector2 = atex.get_size() * ds
		if key.begins_with("city_roof"):
			# a casa (porta + janela + telhado) projeta UMA sombra de caixa, sem empilhar as três peças
			CAST.box(canvas, ground + Vector2(0, 78), 86.0 * ds / .52, sz.y + 78.0 - 22.0, CAST.ALPHA_DEFAULT)
			return true
		var alpha_a: float = CAST.ALPHA_TREE if key.begins_with("city_tree") else CAST.ALPHA_DEFAULT
		CAST.sprite(canvas, atex, Rect2(ground - Vector2(sz.x * .5, sz.y), sz), Rect2(Vector2.ZERO, atex.get_size()), ground, false, alpha_a, .8 if sz.y > 160.0 else 1.0)
		return true
	if not MODELED.has(asset):
		return false
	var e: Dictionary = MODELED.entry(asset)
	var tex: Texture2D = MODELED.texture(asset)
	if tex == null:
		return false
	var fs: Array = e["frame_size"]
	var fw: float = float(fs[0])
	var fh: float = float(fs[1])
	var foot: Array = e["foot"]
	var s: float = float(e["draw_scale"]) * scale_mul
	var frame: int = frame_for(int(e["frames"]), time, float(entry[PROC.IT_ANIM]))
	var dst: Rect2 = Rect2(ground - Vector2(float(foot[0]) * s, float(foot[1]) * s), Vector2(fw * s, fh * s))
	if flip:
		dst.position.x = ground.x - (fw - float(foot[0])) * s
	var tall: bool = float(foot[1]) * s > 160.0
	var alpha: float = CAST.ALPHA_TREE if (asset.contains("tree") or asset.contains("pine") or asset.contains("palm")) else CAST.ALPHA_DEFAULT
	CAST.sprite(canvas, tex, dst, Rect2(frame * fw, 0, fw, fh), ground, flip, alpha, .75 if tall else 1.0)
	return true

static func draw_shadows(canvas: CanvasItem, view: Dictionary, rect: Rect2, time: float, approved: Dictionary) -> int:
	if not shadows_enabled:
		return 0
	var ys: PackedFloat32Array = view["ys"] as PackedFloat32Array
	var objs: Array = view["objs"] as Array
	var top: float = rect.position.y - 130.0
	var bottom: float = rect.end.y + 320.0
	var i: int = PROC.first_index(ys, top)
	var n: int = 0
	var x_min: float = rect.position.x - 340.0
	var x_max: float = rect.end.x + 220.0
	while i < objs.size():
		var entry: Array = objs[i]
		i += 1
		if float(entry[PROC.IT_SY]) > bottom:
			break
		var x: float = float(entry[PROC.IT_X])
		if x < x_min or x > x_max:
			continue
		if cast_item(canvas, entry, time, approved):
			n += 1
	last_shadow_count = n
	return n
