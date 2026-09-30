extends RefCounted
# VFX e projéteis a partir dos assets gratuitos adaptados (data/external_vfx.json) + desenho dos mobs animados Foozle
# (data/external_mobs.json). Mobile: pool com teto fixo, uma textura por efeito, sem partículas de GPU nem shaders.
const VFX_DATA: String = "res://data/external_vfx.json"
const MOB_DATA: String = "res://data/external_mobs.json"
const MAX_FX: int = 48
const MAX_PROJ: int = 24

var vfx: Dictionary = {}
var mobs: Dictionary = {}          # nome do inimigo -> meta
var tex: Dictionary = {}
var active: Array = []              # [id, pos, t, scale_mul, flip, color, rot, loop_until]
var strikes: Array = []             # marcas no chão (telegraph) -> impacto: {pos, delay, t, radius, dmg, vfx, color}
var landed: Array = []
var projectiles: Array = []         # {pos, target, speed, vfx, owner, dmg, aoe, t, on_hit_vfx, dissipate_vfx, kind}

func _init() -> void:
	vfx = _json(VFX_DATA).get("vfx", {})
	for m in _json(MOB_DATA).get("mobs", []):
		mobs[str(m["kind"])] = m
	for id in vfx.keys():
		tex[id] = load(str(vfx[id]["path"]))
	for k in mobs.keys():
		tex["mob:" + k] = load(str(mobs[k]["path"]))

func _json(path: String) -> Dictionary:
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var v: Variant = JSON.parse_string(f.get_as_text())
	return v if v is Dictionary else {}

func has_mob(kind: String) -> bool:
	return mobs.has(kind)

func duration(id: String) -> float:
	if not vfx.has(id):
		return 0.0
	return float(vfx[id]["frames"]) / float(vfx[id]["fps"])

func spawn(id: String, pos: Vector2, scale_mul: float = 1.0, flip: bool = false, color: Color = Color.WHITE, rot: float = 0.0) -> void:
	if not vfx.has(id):
		return
	if active.size() >= MAX_FX:
		active.remove_at(0)
	active.append([id, pos, 0.0, scale_mul, flip, color, rot])

func shoot(owner: String, from: Vector2, to: Vector2, speed: float, travel_vfx: String, dmg: int, aoe: float, hit_vfx: String, dissipate_vfx: String, kind: String = "") -> void:
	if projectiles.size() >= MAX_PROJ:
		projectiles.remove_at(0)
	projectiles.append({"pos": from, "target": to, "speed": speed, "vfx": travel_vfx, "owner": owner, "dmg": dmg, "aoe": aoe, "t": 0.0, "hit": hit_vfx, "diss": dissipate_vfx, "kind": kind})

func strike(pos: Vector2, delay: float, radius: float, dmg: int, impact_vfx: String, color: Color) -> void:
	# CAST (quem conjura) -> TELEGRAPH (marca crescendo no chão) -> IMPACTO (VFX + dano no fim do delay) -> DISSIPAÇÃO (fumaça)
	if strikes.size() >= 12:
		strikes.remove_at(0)
	strikes.append({"pos": pos, "delay": delay, "t": 0.0, "radius": radius, "dmg": dmg, "vfx": impact_vfx, "color": color})

func update(delta: float) -> Array:
	landed.clear()
	for i in range(strikes.size() - 1, -1, -1):
		var s: Dictionary = strikes[i]
		s["t"] = float(s["t"]) + delta
		if float(s["t"]) >= float(s["delay"]):
			spawn(str(s["vfx"]), (s["pos"] as Vector2) + Vector2(0, -34))
			spawn("vfx_smoke", s["pos"], 1.0, false, Color(1, 1, 1, .7))
			landed.append(s)
			strikes.remove_at(i)
	# devolve os projéteis que chegaram neste quadro (o jogo aplica o dano no MOMENTO do impacto)
	for i in range(active.size() - 1, -1, -1):
		var a: Array = active[i]
		a[2] = float(a[2]) + delta
		if float(a[2]) >= duration(str(a[0])):
			active.remove_at(i)
	var arrived: Array = []
	for i in range(projectiles.size() - 1, -1, -1):
		var p: Dictionary = projectiles[i]
		p["t"] = float(p["t"]) + delta
		var pos: Vector2 = p["pos"]
		var target: Vector2 = p["target"]
		var step: float = float(p["speed"]) * delta
		if pos.distance_to(target) <= step or float(p["t"]) > 2.5:
			p["pos"] = target
			if not str(p["hit"]).is_empty():
				spawn(str(p["hit"]), target)
			if not str(p["diss"]).is_empty():
				spawn(str(p["diss"]), target + Vector2(0, -6), .9, false, Color(1, 1, 1, .8))
			arrived.append(p)
			projectiles.remove_at(i)
		else:
			p["pos"] = pos + (target - pos).normalized() * step
	return arrived

func _frame(id: String, t: float) -> int:
	var d: Dictionary = vfx[id]
	return mini(int(d["frames"]) - 1, int(t * float(d["fps"])))

func draw_one(canvas: CanvasItem, id: String, pos: Vector2, t: float, scale_mul: float = 1.0, flip: bool = false, color: Color = Color.WHITE, rot: float = 0.0, loop: bool = false, restore: Vector2 = Vector2.ZERO) -> void:
	if not vfx.has(id):
		return
	var d: Dictionary = vfx[id]
	var w: float = float(d["w"])
	var h: float = float(d["h"])
	var n: int = int(d["frames"])
	var fr: int = int(t * float(d["fps"])) % n if loop else _frame(id, t)
	var s: float = float(d["scale"]) * scale_mul
	canvas.draw_set_transform(pos, rot, Vector2(-s if flip else s, s))
	canvas.draw_texture_rect_region(tex[id], Rect2(Vector2(-w * .5, -h * .5), Vector2(w, h)), Rect2(fr * w, 0, w, h), color)
	canvas.draw_set_transform(restore)

func draw_telegraphs(canvas: CanvasItem, camera: Vector2) -> void:
	# marcas no chão desenhadas ANTES dos personagens (leitura de combate mobile: área clara, sem cobrir o herói)
	for s in strikes:
		var k: float = clampf(float(s["t"]) / float(s["delay"]), 0.0, 1.0)
		var c: Color = s["color"]
		var r: float = float(s["radius"])
		var pos: Vector2 = s["pos"]
		canvas.draw_set_transform(pos - camera, 0, Vector2(1, .5))
		canvas.draw_circle(Vector2.ZERO, r * k, Color(c.r, c.g, c.b, .22 + .2 * k))
		canvas.draw_arc(Vector2.ZERO, r, 0, TAU, 32, Color(c.r, c.g, c.b, .85), 2.0)
		canvas.draw_set_transform(-camera)

func draw(canvas: CanvasItem, camera: Vector2) -> void:
	for a in active:
		draw_one(canvas, str(a[0]), (a[1] as Vector2) - camera, float(a[2]), float(a[3]), bool(a[4]), a[5] as Color, float(a[6]), false, -camera)
	for p in projectiles:
		var dir: Vector2 = (p["target"] as Vector2) - (p["pos"] as Vector2)
		var id: String = str(p["vfx"])
		if id == "arrow":
			var tip: Vector2 = p["pos"]
			var back: Vector2 = tip - dir.normalized() * 16.0
			canvas.draw_line(back, tip, Color(.35, .25, .15), 2)
			canvas.draw_line(tip - dir.normalized() * 4.0, tip, Color(.9, .95, 1), 2)
			continue
		if id == "stone":
			canvas.draw_circle(p["pos"], 3.5, Color(.55, .5, .45))
			canvas.draw_circle((p["pos"] as Vector2) + Vector2(-1, -1), 1.5, Color(.8, .76, .7))
			continue
		draw_one(canvas, id, (p["pos"] as Vector2) - camera, float(p["t"]), 1.0, false, Color.WHITE, dir.angle(), true, -camera)

# ------------------------------------------------------------------ mobs Foozle (8 quadros × estados × 3 direções, escala 2)
func draw_mob(canvas: CanvasItem, enemy: Dictionary, player: Vector2, camera: Vector2, frame: int, state: String, tint: Color) -> bool:
	var kind: String = str(enemy["kind"])
	if not mobs.has(kind):
		return false
	var m: Dictionary = mobs[kind]
	var states: Array = m["states"]
	var st: int = states.find(state)
	if st < 0:
		st = 0
	var p: Vector2 = enemy["pos"]
	var d: Vector2 = player - p
	var dir: int = 0
	var flip: bool = d.x < 0.0
	if absf(d.y) > absf(d.x) * 1.3 and state != "death":
		dir = 1 if d.y > 0 else 2
		flip = false
	var cell: float = float(m["cell"])
	var s: float = float(m["scale"]) * (1.25 if enemy.has("elite") else 1.0)
	var row: int = st * 3 + dir
	canvas.draw_set_transform(p - camera, 0, Vector2(-s if flip else s, s))
	canvas.draw_texture_rect_region(tex["mob:" + kind], Rect2(Vector2(-cell * .5, -cell + 3.0), Vector2(cell, cell)), Rect2(frame * cell, row * cell, cell, cell), tint)
	canvas.draw_set_transform(-camera)
	return true
