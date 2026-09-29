extends Node2D
# Palco de composição do Lote 2 (Ato II): desenha uma composição de data/act02_compositions.json com o MESMO renderer do jogo
# (REGR.draw_item / cast_item + ground_bake), para revisão visual real no Godot antes da implantação no mapa pelo Gerente.
const PROC = preload("res://scripts/reg001_procedural.gd")
const REGR = preload("res://scripts/reg001_render.gd")
const GROUND = preload("res://scripts/ground_bake.gd")
const MODELED = preload("res://scripts/modeled_assets.gd")

var comp: Dictionary = {}
var flags: Dictionary = {}
var time_acc: float = 3.7
var approved: Dictionary = {}
var tex_cache: Dictionary = {}

func set_scene(composition: Dictionary, active_flags: Array) -> void:
	comp = composition
	# texturas do chão carregadas FORA do _draw (no renderer Compatibility/mobile, carregar dentro do draw usa placeholder no 1º quadro)
	for path in [str(comp.get("ground_png", ""))] + comp.get("ground_overlays", []).map(func(ov: Dictionary) -> String: return str(ov["png"])):
		if not path.is_empty() and not tex_cache.has(path):
			tex_cache[path] = load(path)
	flags = {}
	for f in active_flags:
		flags[str(f)] = true
	queue_redraw()

func flag_on(key: String) -> bool:
	# "!flag" = flag ausente
	if key.begins_with("!"):
		return not flag_on(key.substr(1))
	# revanche: "rematch:<ID>" faz a leitura VISUAL de "elites:<ID>" (primeira derrota, persistente) valer como falsa, sem apagar o estado (igual a REG.rematch_boss)
	if key.begins_with("elites:") and flags.has("rematch:" + key.substr(7)):
		return false
	return flags.has(key)

func visible_obj(o: Dictionary) -> bool:
	var hide_key: String = str(o.get("hide_when", ""))
	if not hide_key.is_empty() and flag_on(hide_key):
		return false
	var show_key: String = str(o.get("show_when", ""))
	if not show_key.is_empty() and not flag_on(show_key):
		return false
	return true

func entry_for(o: Dictionary) -> Array:
	var e: Array = []
	e.resize(9)
	e[PROC.IT_SY] = float(o["y"])
	e[PROC.IT_ASSET] = str(o["asset"])
	e[PROC.IT_X] = float(o["x"])
	e[PROC.IT_Y] = float(o["y"])
	e[PROC.IT_ANIM] = float(o.get("anim", 0.0))
	e[PROC.IT_SCALE] = float(o.get("scale", 1.0))
	e[PROC.IT_FLIP] = bool(o.get("flip", false))
	e[PROC.IT_OWNER] = null
	e[PROC.IT_KIND] = 0
	return e

func draw_trail(t: Dictionary) -> void:
	# trilha de terra irregular (mesmo tom das trilhas do mundo): borda escura + miolo gasto, sem contorno reto
	var pts: Array = t["pts"]
	var half: float = float(t.get("half", 22))
	var seed: float = float(t.get("seed", 1))
	for pass_i in 2:
		var w: float = half if pass_i == 0 else half * .62
		var col: Color = Color(.36, .25, .15, .92) if pass_i == 0 else Color(.55, .4, .24, .95)
		for i in range(pts.size() - 1):
			var a: Vector2 = Vector2(float((pts[i] as Array)[0]), float((pts[i] as Array)[1]))
			var b: Vector2 = Vector2(float((pts[i + 1] as Array)[0]), float((pts[i + 1] as Array)[1]))
			var steps: int = int(a.distance_to(b) / 6.0) + 1
			for k in steps:
				var f: float = float(k) / float(steps)
				var c: Vector2 = a.lerp(b, f)
				var wob: float = sin(c.x * .05 + seed) * 3.0 + cos(c.y * .07 + seed * 2.0) * 3.0
				draw_circle(c + Vector2(0, wob * .4), w + wob * .6, col)

func _draw() -> void:
	if comp.is_empty():
		return
	var origin: Array = comp.get("origin", [0, 0])
	var view: Rect2 = Rect2(Vector2(float(origin[0]), float(origin[1])), Vector2(960, 540))
	draw_set_transform(-view.position)
	var baked: bool = comp.has("ground_png")
	if baked:
		# chão assado por cena (tools/act02/bake_act02_ground.py): terreno, trilhas curvas, rio sinuoso e sombra de contato numa só textura
		var gtex: Texture2D = tex_cache.get(str(comp["ground_png"])) as Texture2D
		if gtex != null:
			draw_texture(gtex, view.position)
		for ov_value in comp.get("ground_overlays", []):
			var ov: Dictionary = ov_value
			if visible_obj(ov):
				var otex: Texture2D = tex_cache.get(str(ov["png"])) as Texture2D
				if otex != null:
					draw_texture(otex, view.position)
		# brilhos da água animados (poucos retângulos por quadro, custo mínimo no mobile)
		var glints: Array = comp.get("water_glints", [])
		for i in glints.size():
			var g: Array = glints[i]
			var ph: float = sin(time_acc * 2.2 + float(i) * 1.7)
			if ph > 0.2:
				draw_rect(Rect2(float(g[0]) + ph * 2.0, float(g[1]), 3.0 + ph * 2.0, 1.0), Color(.85, 1, .95, .5 * ph))
	elif comp.has("ground_solid"):
		var gs: Array = comp["ground_solid"]
		draw_rect(view, Color(float(gs[0]), float(gs[1]), float(gs[2]), 1.0))
	else:
		GROUND.draw_bosque(self, view)
	var tint: Array = comp.get("ground_tint", [0.05, 0.16, 0.1, 0.22])
	var tint_a: float = float(tint[3]) * (0.5 if baked else 1.0)
	draw_rect(view, Color(float(tint[0]), float(tint[1]), float(tint[2]), tint_a))
	if not baked:
		for w_value in comp.get("water", []):
			var w: Dictionary = w_value
			var tex: Texture2D = MODELED.texture(str(w.get("tex", "ter_tex_water_shallow")))
			var r: Rect2 = Rect2(float(w["x"]), float(w["y"]), float(w["w"]), float(w["h"]))
			if tex != null:
				draw_texture_rect(tex, r, true, Color(.55, .82, .78, 1.0))
			draw_rect(r, Color(.05, .25, .3, .18))
		for t_value in comp.get("trails", []):
			if visible_obj(t_value as Dictionary):
				draw_trail(t_value as Dictionary)
	var items: Array = []
	for o_value in comp["objects"]:
		var o: Dictionary = o_value
		if visible_obj(o):
			items.append(o)
	items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["y"]) < float(b["y"]))
	for o in items:
		if str(o.get("layer", "")) == "ground":
			REGR.draw_item(self, entry_for(o), time_acc, approved)
	for o in items:
		REGR.cast_item(self, entry_for(o), time_acc, approved)
	for o in items:
		if str(o.get("layer", "")) != "ground":
			REGR.draw_item(self, entry_for(o), time_acc, approved)
	# luz filtrada pela copa: feixes suaves e vinheta escura nas bordas (leitura de navegação preservada)
	var shafts: Array = comp.get("light_shafts", [])
	for s_value in shafts:
		var s: Array = s_value
		var p: Vector2 = Vector2(float(s[0]), float(s[1]))
		var pts: PackedVector2Array = PackedVector2Array([p, p + Vector2(46, 0), p + Vector2(46 + 120, 300), p + Vector2(120, 300)])
		draw_colored_polygon(pts, Color(1, .95, .7, .07))
	draw_set_transform(Vector2.ZERO)
	var vg: float = float(comp.get("vignette", .28))
	for i in 6:
		var a: float = vg * (1.0 - float(i) / 6.0) * .5
		draw_rect(Rect2(0, 0, 960, 540).grow(-float(i) * 14.0), Color(0, .04, .02, a), false, 14.0)
