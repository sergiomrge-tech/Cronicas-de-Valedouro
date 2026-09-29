extends RefCounted
# REG_001 — jogabilidade dos pontos de interesse: elites, baús, recursos raros, segredos, atalhos, santuários,
# armadilhas, mirantes, NPCs viajantes e a Cripta Esquecida. Toda a lógica de estado passa por reg001_world.gd
# (IDs persistentes) e é salva no bloco "reg001" do save.

const REG = preload("res://scripts/reg001_world.gd")
const MAP = preload("res://scripts/world_map.gd")

const INTERACT_PRIORITY: Array = [["chest", "resource", "secret", "gate", "entrance", "checkpoint"], ["lore", "camp", "shrine", "viewpoint", "landmark"]]

var game: Node2D
var elite_timer: float = 0.0
var trap_cooldown: float = 0.0
var npc_line: Dictionary = {}
var discover_timer: float = 0.0

func _init(g: Node2D) -> void:
	game = g

# ------------------------------------------------------------------ ciclo
func tick(delta: float) -> void:
	REG.ensure_loaded()
	elite_timer -= delta
	trap_cooldown = maxf(0.0, trap_cooldown - delta)
	discover_timer -= delta
	if elite_timer <= 0.0:
		elite_timer = .45
		update_elites()
	if discover_timer <= 0.0:
		discover_timer = .6
		update_discovery()
	update_traps()

func update_discovery() -> void:
	for poi_value in REG.pois_in_zone(game.zone):
		var poi: Dictionary = poi_value
		if not bool(poi.get("show_label", true)):
			continue
		var id: String = str(poi["id"])
		if REG.has_mark("visited", id):
			continue
		if (poi["pos"] as Vector2).distance_to(game.player) < float(poi["radius"]) * .8:
			REG.mark("visited", id)
			if game.hint_timer <= 0:
				game.message("Local descoberto: %s" % str(poi["label"]))

# ------------------------------------------------------------------ elites
func elite_enemy(poi_id: String) -> Variant:
	for enemy_value in game.enemies:
		var enemy: Dictionary = enemy_value
		if str(enemy.get("elite", "")) == poi_id and not bool(enemy.get("dead", false)):
			return enemy
	return null

func make_elite(poi: Dictionary) -> Dictionary:
	var d: Dictionary = poi["data"] as Dictionary
	var enemy: Dictionary = game.make_enemy(str(d["enemy"]), (poi["pos"] as Vector2) + Vector2(0, -34))
	var hp_mult: float = float(d.get("hp_mult", 3.0))
	enemy["max_hp"] = int(float(enemy["max_hp"]) * hp_mult)
	enemy["hp"] = enemy["max_hp"]
	enemy["elite"] = str(poi["id"])
	enemy["elite_name"] = str(d.get("name", "Elite"))
	enemy["dmg_mult"] = float(d.get("dmg_mult", 1.4))
	enemy["xp_mult"] = float(d.get("xp_mult", 4.0))
	enemy["gold_mult"] = float(d.get("gold_mult", 4.0))
	return enemy

func update_elites() -> void:
	if game.dialog.visible:
		return
	for poi_value in REG.pois_in_zone(game.zone):
		var poi: Dictionary = poi_value
		if str(poi["kind"]) != "elite":
			continue
		var id: String = str(poi["id"])
		if REG.has_mark("elites", id):
			continue
		var d: Dictionary = poi["data"] as Dictionary
		var trigger: float = float(d.get("trigger", 220))
		var dist: float = (poi["pos"] as Vector2).distance_to(game.player)
		var active: Variant = elite_enemy(id)
		if active == null and dist < trigger:
			game.enemies.append(make_elite(poi))
			game.message("%s surge da penumbra!" % str(d.get("name", "Elite")))
		elif active != null and dist > trigger * 3.2:
			game.enemies.erase(active)

func on_enemy_defeated(enemy: Dictionary) -> void:
	var id: String = str(enemy.get("elite", ""))
	if id.is_empty() or not REG.poi_by_id.has(id):
		return
	var poi: Dictionary = REG.poi_by_id[id]
	var d: Dictionary = poi["data"] as Dictionary
	REG.mark("elites", id)
	var drop: Dictionary = (d.get("drop", {}) as Dictionary).get("materials", {}) as Dictionary
	for name_value in drop.keys():
		game.materials[str(name_value)] = int(game.materials.get(str(name_value), 0)) + int(drop[name_value])
	var lore_id: String = str(d.get("lore", ""))
	game.message("%s derrotado! Um baú foi liberado por perto." % str(enemy.get("elite_name", "Elite")))
	if not lore_id.is_empty():
		REG.mark("lore", lore_id)
	game.save_game()

# ------------------------------------------------------------------ armadilhas
func trap_phase(poi: Dictionary) -> float:
	var d: Dictionary = poi["data"] as Dictionary
	var period: float = float(d.get("period", 3.0))
	return fposmod(game.time_acc + float(d.get("phase", 0.0)), period) / period

func trap_armed(poi: Dictionary) -> float:
	# 0..1 = telégrafo crescente; >= 1 = ativa (janela curta no fim do ciclo)
	var t: float = trap_phase(poi)
	if t < .72:
		return 0.0
	if t < .86:
		return (t - .72) / .14
	return 1.0

func update_traps() -> void:
	if trap_cooldown > 0.0 or game.invulnerable > 0.0 or game.dialog.visible:
		return
	for poi_value in REG.pois_in_zone(game.zone):
		var poi: Dictionary = poi_value
		if str(poi["kind"]) != "trap":
			continue
		var dist: float = (poi["pos"] as Vector2).distance_to(game.player)
		if dist > float(poi["radius"]) or trap_armed(poi) < 1.0:
			continue
		var d: Dictionary = poi["data"] as Dictionary
		var taken: int = maxi(1, int(d.get("damage", 5)) - game.armor - int(game.equipped_armor.get("def", 0)))
		game.hp = maxi(1, game.hp - taken)
		game.invulnerable = .9
		trap_cooldown = .6
		game.floaters.append({"pos": game.player + Vector2(0, -52), "text": "-%d" % taken, "t": .7, "color": Color(1, .55, .3)})
		game.message("Uma armadilha foi acionada!")
		return

# ------------------------------------------------------------------ interação
func try_interact() -> bool:
	REG.ensure_loaded()
	if game.dialog.visible:
		return false
	# NPCs primeiro (proximidade real ao personagem, não ao centro do assentamento)
	for poi_value in REG.pois_in_zone(game.zone):
		var poi: Dictionary = poi_value
		var d: Dictionary = poi["data"] as Dictionary
		if d.has("npc") and npc_position(poi).distance_to(game.player) < 74.0:
			talk_npc(poi)
			return true
	for group in INTERACT_PRIORITY:
		var poi_hit: Dictionary = nearest_interactive(group)
		if poi_hit.is_empty():
			continue
		if handle_poi(poi_hit):
			return true
	return false

func nearest_interactive(group: Array) -> Dictionary:
	# Como REG.nearest_poi, mas ignora baús de segredo ainda não revelados (o gatilho é o próprio segredo).
	var best: Dictionary = {}
	var best_d: float = 1.0e9
	for poi_value in REG.pois_in_zone(game.zone):
		var poi: Dictionary = poi_value
		var kind: String = str(poi["kind"])
		if not group.has(kind):
			continue
		if kind == "chest" and (poi["data"] as Dictionary).has("requires_secret") and not REG.poi_available(poi):
			continue
		var dist: float = (poi["pos"] as Vector2).distance_to(game.player)
		if dist <= float(poi["radius"]) and dist < best_d:
			best = poi
			best_d = dist
	return best

func handle_poi(poi: Dictionary) -> bool:
	var kind: String = str(poi["kind"])
	var d: Dictionary = poi["data"] as Dictionary
	var id: String = str(poi["id"])
	match kind:
		"chest":
			open_chest(poi)
			return true
		"resource":
			gather(poi)
			return true
		"secret":
			reveal_secret(poi)
			return true
		"gate":
			if REG.has_mark("found", id):
				game.message("O portão já está aberto.")
			else:
				REG.mark("found", id)
				game.message("Você abriu o %s." % str(poi["label"]).to_lower())
				game.save_game()
			return true
		"entrance":
			var target: String = str(d.get("zone", "cripta"))
			var entry_a: Array = d.get("entry", [480, 800]) as Array
			var entry: Vector2 = Vector2(float(entry_a[0]), float(entry_a[1]))
			game.show_dialog(str(poi["label"]), str(d.get("text", "Entrar?")), [["Entrar", func(): game.dialog.hide(); game.change_zone(target, entry)]])
			return true
		"checkpoint", "camp", "shrine":
			heal_at(poi)
			var lore_id: String = str(d.get("lore", ""))
			if not lore_id.is_empty() and not REG.has_mark("lore", lore_id):
				show_lore(lore_id, poi)
			return true
		"lore":
			var lore_key: String = str(d.get("lore", ""))
			if not lore_key.is_empty():
				show_lore(lore_key, poi)
				return true
			return false
		"viewpoint":
			for target_id in d.get("reveal", []) as Array:
				REG.mark("visited", str(target_id))
			game.message(str(d.get("text", "Uma bela vista.")))
			return true
		"landmark":
			var hint: String = str(d.get("hint", ""))
			if hint.is_empty():
				return false
			game.message(hint)
			var lore_key2: String = str(d.get("lore", ""))
			if not lore_key2.is_empty() and not REG.has_mark("lore", lore_key2):
				show_lore(lore_key2, poi)
			return true
	return false

func heal_at(poi: Dictionary) -> void:
	var d: Dictionary = poi["data"] as Dictionary
	if game.hp < game.max_hp:
		game.hp = game.max_hp
		game.message(str(d.get("hint", "Suas forças foram restauradas.")))
	else:
		game.message("%s • Você já está bem." % str(poi["label"]))
	REG.mark("visited", str(poi["id"]))
	game.save_game()

func show_lore(lore_id: String, poi: Dictionary) -> void:
	if not REG.lore.has(lore_id):
		return
	var entry: Dictionary = REG.lore[lore_id] as Dictionary
	var first: bool = not REG.has_mark("lore", lore_id)
	REG.mark("lore", lore_id)
	var d: Dictionary = poi["data"] as Dictionary
	var reward: Dictionary = (d.get("reward", {}) as Dictionary).get("materials", {}) as Dictionary
	var suffix: String = ""
	if first and not reward.is_empty() and not REG.has_mark("visited", "reward:" + str(poi["id"])):
		REG.mark("visited", "reward:" + str(poi["id"]))
		for name_value in reward.keys():
			game.materials[str(name_value)] = int(game.materials.get(str(name_value), 0)) + int(reward[name_value])
			suffix += "\n\n+%d %s" % [int(reward[name_value]), str(name_value)]
	game.show_dialog(str(entry["title"]), str(entry["text"]) + suffix, [])
	game.save_game()

func open_chest(poi: Dictionary) -> void:
	var id: String = str(poi["id"])
	if REG.has_mark("opened", id):
		game.message("O baú está vazio.")
		return
	if not REG.poi_available(poi):
		var d0: Dictionary = poi["data"] as Dictionary
		if d0.has("requires_elite"):
			game.message("Uma presença hostil protege este baú.")
		else:
			game.message("Há algo escondido por perto...")
		return
	var loot: Dictionary = (poi["data"] as Dictionary).get("loot", {}) as Dictionary
	var item: Dictionary = loot.get("item", {}) as Dictionary
	if not item.is_empty() and game.stored_items.size() >= 30:
		game.message("Mochila cheia! Libere espaço para abrir o baú.")
		return
	game.gold += int(loot.get("gold", 0))
	var materials: Dictionary = loot.get("materials", {}) as Dictionary
	for name_value in materials.keys():
		game.materials[str(name_value)] = int(game.materials.get(str(name_value), 0)) + int(materials[name_value])
	game.potions += int(loot.get("potions", 0))
	var found_text: String = "Baú aberto: %d moedas" % int(loot.get("gold", 0))
	if not item.is_empty():
		game.stored_items.append(item.duplicate(true))
		found_text = "Baú aberto: %s!" % str(item["name"])
	REG.mark("opened", id)
	game.message(found_text)
	game.save_game()

func gather(poi: Dictionary) -> void:
	var id: String = str(poi["id"])
	if REG.has_mark("gathered", id):
		game.message("Este recurso já foi colhido.")
		return
	var d: Dictionary = poi["data"] as Dictionary
	var mat: String = str(d.get("material", "Material"))
	var amount: int = int(d.get("amount", 1))
	game.materials[mat] = int(game.materials.get(mat, 0)) + amount
	REG.mark("gathered", id)
	game.message("Colhido: %s x%d" % [mat, amount])
	game.save_game()

func reveal_secret(poi: Dictionary) -> void:
	var id: String = str(poi["id"])
	if REG.has_mark("found", id):
		game.message("A passagem já está aberta.")
		return
	var d: Dictionary = poi["data"] as Dictionary
	REG.mark("found", id)
	game.message(str(d.get("found_text", "Você descobriu um segredo!")))
	var lore_id: String = str(d.get("lore", ""))
	if not lore_id.is_empty():
		REG.mark("lore", lore_id)
	game.save_game()

# ------------------------------------------------------------------ NPCs
func npc_position(poi: Dictionary) -> Vector2:
	var d: Dictionary = poi["data"] as Dictionary
	var base: Vector2 = poi["pos"]
	if d.has("path"):
		var pts: Array = d["path"] as Array
		if pts.size() >= 2:
			var total: float = 0.0
			var lens: Array[float] = []
			for i in range(pts.size() - 1):
				var seg: float = Vector2(float(pts[i][0]), float(pts[i][1])).distance_to(Vector2(float(pts[i + 1][0]), float(pts[i + 1][1])))
				lens.append(seg)
				total += seg
			var travel: float = fposmod(game.time_acc * 9.0, total * 2.0)
			if travel > total:
				travel = total * 2.0 - travel
			for i in range(lens.size()):
				if travel <= lens[i] or i == lens.size() - 1:
					var a: Vector2 = Vector2(float(pts[i][0]), float(pts[i][1]))
					var b: Vector2 = Vector2(float(pts[i + 1][0]), float(pts[i + 1][1]))
					return a.lerp(b, clampf(travel / maxf(lens[i], 1.0), 0.0, 1.0))
				travel -= lens[i]
	return base + Vector2(34, 22)

func talk_npc(poi: Dictionary) -> void:
	var d: Dictionary = poi["data"] as Dictionary
	var lines: Array = d.get("lines", []) as Array
	if lines.is_empty():
		return
	var id: String = str(poi["id"])
	var index: int = int(npc_line.get(id, 0)) % lines.size()
	npc_line[id] = index + 1
	game.show_dialog(str(d.get("name", "Viajante")), str(lines[index]), [])

# ------------------------------------------------------------------ desenho (chamado por main._draw)
func draw_npcs(canvas: CanvasItem, rect: Rect2) -> void:
	var margin: Rect2 = rect.grow(80.0)
	for poi_value in REG.pois_in_zone(game.zone):
		var poi: Dictionary = poi_value
		var d: Dictionary = poi["data"] as Dictionary
		if not d.has("npc"):
			continue
		var p: Vector2 = npc_position(poi)
		if not margin.has_point(p):
			continue
		var tint_a: Array = d.get("tint", [.9, .78, .66]) as Array
		var tint: Color = Color(float(tint_a[0]), float(tint_a[1]), float(tint_a[2]))
		var moving: bool = d.has("path")
		game.draw_shadow_oval(p + Vector2(0, 4), Vector2(11, 4), Color(0, 0, 0, .28))
		var frame: int = int(game.time_acc * 5.0 + p.x * .01) % 8 if moving else 0
		var direction: int = 2 if cos(game.time_acc * .3) > 0 else 6
		var src: Rect2 = Rect2(Vector2(frame * 48, direction * 56), Vector2(48, 56))
		canvas.draw_texture_rect_region(game.textures["hero_body"], Rect2(p - Vector2(17, 37), Vector2(34, 40)), src, tint)
		if p.distance_to(game.player) < 130.0:
			game.draw_label(str(d.get("name", "Viajante")), p + Vector2(-90, -50), Color(.86, 1, .8))

func draw_overlay(canvas: CanvasItem, rect: Rect2) -> void:
	var margin: Rect2 = rect.grow(140.0)
	var nearest_id: String = ""
	var interact_poi: Dictionary = {}
	for group in INTERACT_PRIORITY:
		interact_poi = nearest_interactive(group)
		if not interact_poi.is_empty():
			break
	if not interact_poi.is_empty():
		nearest_id = str(interact_poi["id"])
	for poi_value in REG.pois_in_zone(game.zone):
		var poi: Dictionary = poi_value
		var pos: Vector2 = poi["pos"]
		if not margin.has_point(pos):
			continue
		var kind: String = str(poi["kind"])
		var id: String = str(poi["id"])
		if kind == "trap":
			var armed: float = trap_armed(poi)
			if armed > 0.0:
				var r: float = float(poi["radius"])
				var alpha: float = .25 + .5 * armed
				canvas.draw_arc(pos, r, 0, TAU, 24, Color(1, .35, .25, alpha), 3)
				canvas.draw_circle(pos, r * armed, Color(1, .3, .2, .16 * armed))
			continue
		if bool(poi.get("show_label", true)) and kind != "npc":
			var dist: float = pos.distance_to(game.player)
			if dist < 360.0 and (REG.has_mark("visited", id) or dist < float(poi["radius"])):
				game.draw_label(str(poi["label"]), pos + Vector2(-90, -84), Color(1, .92, .7) if kind != "elite" else Color(1, .7, .9))
		if id == nearest_id:
			var can: bool = kind != "chest" or (REG.poi_available(poi) and not REG.has_mark("opened", id))
			if kind == "resource" and REG.has_mark("gathered", id):
				can = false
			if kind == "secret" and REG.has_mark("found", id):
				can = false
			if can:
				var bob: float = sin(game.time_acc * 5.0) * 3.0
				canvas.draw_circle(pos + Vector2(0, -58 + bob), 9, Color(.1, .05, .16, .85))
				canvas.draw_string(game.ui_font, pos + Vector2(-5, -52 + bob), "E", HORIZONTAL_ALIGNMENT_CENTER, 12, 15, Color(1, .92, .5))
