extends SceneTree
# Gate REG_001: elites, baús, recursos, segredos, atalhos, santuários, armadilhas, Cripta Esquecida e persistência.
const WORLD = preload("res://scripts/world_map.gd")
const REG = preload("res://scripts/reg001_world.gd")

var game: Node2D

func _initialize() -> void:
	call_deferred("check")

func poi(id: String) -> Dictionary:
	return REG.poi_by_id[id] as Dictionary

func stand_at(id: String) -> void:
	var p: Dictionary = poi(id)
	game.zone = str(p["zone"])
	game.player = (p["pos"] as Vector2) + Vector2(0, 30)
	game.dialog.hide()
	game.enemies.clear()

func kill_elite(id: String) -> void:
	game.reg_game.update_elites()
	var found: Variant = game.reg_game.elite_enemy(id)
	assert(found != null, "elite não surgiu: " + id)
	var enemy: Dictionary = found as Dictionary
	assert(int(enemy["max_hp"]) > 60, "elite deveria ser mais forte")
	enemy["hp"] = 0
	enemy["dead"] = true
	var index: int = game.enemies.find(enemy)
	game.finish_enemy(index)
	assert(REG.has_mark("elites", id), "elite não registrado como derrotado")

func crypt_reachable() -> Dictionary:
	var start: Vector2i = Vector2i(15, 25)
	var queue: Array[Vector2i] = [start]
	var visited: Dictionary = {start: true}
	var heads: int = 0
	while heads < queue.size():
		var p: Vector2i = queue[heads]
		heads += 1
		for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var next: Vector2i = p + offset
			if visited.has(next) or next.x < 1 or next.x >= 30 or next.y < 1 or next.y >= 28:
				continue
			if game.walkable(Vector2(next.x * 32 + 16, next.y * 32 + 16)):
				visited[next] = true
				queue.append(next)
	return visited

func check() -> void:
	if FileAccess.file_exists("user://valedouro_v1.json"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://valedouro_v1.json"))
	game = load("res://scenes/Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	REG.clear_progress()
	# ---- baú simples
	stand_at("REG001_POI_CHEST_LENHADOR")
	var gold_before: int = game.gold
	assert(game.reg_game.try_interact(), "baú do lenhador não respondeu")
	assert(REG.has_mark("opened", "REG001_POI_CHEST_LENHADOR"))
	assert(game.gold > gold_before, "baú sem ouro")
	var gold_after: int = game.gold
	game.reg_game.try_interact()
	assert(game.gold == gold_after, "baú abriu duas vezes")
	# ---- baú de elite: selado até derrotar o elite
	stand_at("REG001_POI_CHEST_ANCIAO")
	var items_before: int = game.stored_items.size()
	game.reg_game.try_interact()
	assert(not REG.has_mark("opened", "REG001_POI_CHEST_ANCIAO"), "baú de elite abriu sem o elite")
	game.player = (poi("REG001_POI_ANCIAO_CLAREIRA")["pos"] as Vector2) + Vector2(0, 60)
	kill_elite("REG001_POI_ANCIAO_CLAREIRA")
	stand_at("REG001_POI_CHEST_ANCIAO")
	game.reg_game.try_interact()
	assert(REG.has_mark("opened", "REG001_POI_CHEST_ANCIAO"), "baú do elite não abriu após a vitória")
	assert(game.stored_items.size() == items_before + 1, "item único do baú não entregue")
	# ---- segredo: galhos bloqueiam até revelar
	var bush_point: Vector2 = Vector2(98, 606)
	game.zone = "cidade"
	assert(WORLD.obstacle_at(bush_point), "a vegetação secreta deveria bloquear")
	stand_at("REG001_POI_SEGREDO_MATA")
	game.player = (poi("REG001_POI_SEGREDO_MATA")["pos"] as Vector2) + Vector2(-70, 40)
	assert(game.reg_game.try_interact(), "segredo não respondeu")
	assert(REG.has_mark("found", "REG001_POI_SEGREDO_MATA"))
	assert(not WORLD.obstacle_at(bush_point), "passagem secreta deveria abrir")
	stand_at("REG001_POI_CHEST_SEGREDO_MATA")
	game.reg_game.try_interact()
	assert(REG.has_mark("opened", "REG001_POI_CHEST_SEGREDO_MATA"), "baú secreto não abriu")
	# ---- atalho: portão da fazenda
	assert(WORLD.obstacle_at(Vector2(300, 1985)), "portão fechado deveria bloquear")
	stand_at("REG001_POI_PORTAO_FAZENDA")
	game.reg_game.try_interact()
	assert(REG.has_mark("found", "REG001_POI_PORTAO_FAZENDA"))
	assert(not WORLD.obstacle_at(Vector2(300, 1985)), "portão aberto deveria liberar a passagem")
	# ---- recurso raro
	stand_at("REG001_POI_RES_ERVA_A")
	game.reg_game.try_interact()
	assert(int(game.materials.get("Erva Luminosa", 0)) >= 2, "recurso não coletado")
	assert(REG.has_mark("gathered", "REG001_POI_RES_ERVA_A"))
	# ---- santuário cura e lore registra
	game.hp = 5
	stand_at("REG001_POI_SANTUARIO_VALE")
	game.hp = 5
	game.reg_game.try_interact()
	assert(game.hp == game.max_hp, "santuário não curou")
	# ---- lore com recompensa única
	stand_at("REG001_POI_RUINAS_PRIMEIRO_VENTO")
	var echoes: int = int(game.materials.get("Fragmento de Eco", 0))
	game.reg_game.try_interact()
	assert(game.dialog.visible, "lore não abriu diálogo")
	game.dialog.hide()
	assert(int(game.materials.get("Fragmento de Eco", 0)) == echoes + 1, "recompensa de lore ausente")
	game.reg_game.try_interact()
	game.dialog.hide()
	assert(int(game.materials.get("Fragmento de Eco", 0)) == echoes + 1, "recompensa de lore duplicada")
	# ---- NPC viajante
	game.zone = "cidade"
	game.dialog.hide()
	game.player = game.reg_game.npc_position(poi("REG001_POI_VIAJANTE_NORTE"))
	game.reg_game.try_interact()
	assert(game.dialog.visible, "NPC não falou")
	game.dialog.hide()
	# ---- armadilha: só fere quando ativa
	stand_at("REG001_POI_TRAP_DUNAS_A")
	game.player = poi("REG001_POI_TRAP_DUNAS_A")["pos"]
	game.hp = game.max_hp
	game.invulnerable = 0.0
	var period: float = float((poi("REG001_POI_TRAP_DUNAS_A")["data"] as Dictionary)["period"])
	game.time_acc = period * .1
	game.reg_game.update_traps()
	assert(game.hp == game.max_hp, "armadilha inativa não deveria ferir")
	game.time_acc = period * .93
	game.reg_game.update_traps()
	assert(game.hp < game.max_hp, "armadilha ativa deveria ferir")
	# ---- Cripta Esquecida (mini-dungeon)
	game.hp = game.max_hp
	game.invulnerable = 0.0
	stand_at("REG001_POI_CRIPTA_ENTRADA")
	game.reg_game.try_interact()
	assert(game.dialog.visible, "entrada da cripta sem diálogo")
	game.dialog.hide()
	game.change_zone("cripta", Vector2(480, 800))
	assert(game.zone == "cripta" and game.walkable(game.player))
	var visited: Dictionary = crypt_reachable()
	for target_id in ["REG001_POI_CRIPTA_ALTAR", "REG001_POI_CRIPTA_CHECKPOINT", "REG001_POI_CRIPTA_ELITE", "REG001_POI_CRIPTA_CHEST"]:
		var tp: Vector2 = poi(target_id)["pos"]
		var best: float = 1.0e9
		for cell in visited.keys():
			var cv: Vector2i = cell
			best = minf(best, Vector2(cv.x * 32 + 16, cv.y * 32 + 16).distance_to(tp))
		assert(best <= float(poi(target_id)["radius"]) * .95, "cripta: alvo inalcançável " + target_id)
	assert(not game.walkable(Vector2(100, 605)), "parede da cripta deveria bloquear")
	assert(game.walkable(Vector2(480, 605)), "porta da cripta deveria estar livre")
	game.player = Vector2(480, 450)
	kill_elite("REG001_POI_CRIPTA_ELITE")
	game.hp = 3
	stand_at("REG001_POI_CRIPTA_CHECKPOINT")
	game.hp = 3
	game.reg_game.try_interact()
	assert(game.hp == game.max_hp, "cristal da cripta não curou")
	game.player = Vector2(480, 830)
	game.interact()
	assert(game.zone == "cidade", "saída da cripta falhou")
	# ---- masmorra principal: elite + checkpoint
	game.change_zone("masmorra", Vector2(476, 745))
	game.player = poi("REG001_POI_DG_ELITE")["pos"]
	game.enemies.clear()
	kill_elite("REG001_POI_DG_ELITE")
	# ---- persistência (save aditivo) e reset
	game.change_zone("cidade", town_start())
	game.save_game()
	var snapshot: Dictionary = REG.export_state()
	REG.clear_progress()
	assert(not REG.has_mark("opened", "REG001_POI_CHEST_LENHADOR"))
	game.load_game()
	assert(REG.has_mark("opened", "REG001_POI_CHEST_LENHADOR"), "estado do baú não persistiu")
	assert(REG.has_mark("found", "REG001_POI_SEGREDO_MATA") and REG.has_mark("elites", "REG001_POI_ANCIAO_CLAREIRA"), "segredos/elites não persistiram")
	assert((REG.export_state()["opened"] as Dictionary).size() == (snapshot["opened"] as Dictionary).size())
	# save antigo (sem bloco reg001) continua carregando
	var legacy: FileAccess = FileAccess.open("user://valedouro_v1.json", FileAccess.WRITE)
	legacy.store_string(JSON.stringify({"version": 4, "zone": "cidade", "px": 1534, "py": 1195, "level": 3, "gold": 50, "quest": 1}))
	legacy.close()
	game.load_game()
	assert(game.level == 3 and (REG.export_state()["opened"] as Dictionary).is_empty(), "save v4 antigo deveria zerar o estado REG_001")
	print("REG001 GAMEPLAY PASS: baús, elites, segredos, atalho, recurso, santuário, lore, NPC, armadilha, cripta e save aditivo")
	quit(0)

func town_start() -> Vector2:
	return WORLD.TOWN + Vector2(884, 696)
