extends SceneTree
const REG = preload("res://scripts/reg001_world.gd")
const SAVE: String = "user://valedouro_v1.json"

func _initialize() -> void:
	call_deferred("run_test")

func kill_guardian(game: Node2D) -> void:
	game.enemies.clear()
	var enemy: Dictionary = game.make_enemy("Guardião", game.player + Vector2(24, 0))
	enemy["hp"] = 1
	enemy["max_hp"] = 1
	game.enemies.append(enemy)
	game.facing = Vector2.RIGHT
	game.attack_cooldown = 0.0
	game.attack()
	game.update_enemies(.8)

func visible_assets(asset: String) -> int:
	var n: int = 0
	for o_value in REG.objects:
		var o: Dictionary = o_value
		if str(o["asset"]) == asset and not REG.is_hidden(o):
			n += 1
	return n

func total_assets(asset: String) -> int:
	var n: int = 0
	for o_value in REG.objects:
		if str((o_value as Dictionary)["asset"]) == asset:
			n += 1
	return n

func emitters_visible() -> int:
	var n: int = 0
	for e_value in REG.emitters:
		var e: Dictionary = e_value
		if str(e["zone"]) == "masmorra" and not REG.is_hidden(e):
			n += 1
	return n

func write_save(data: Dictionary) -> void:
	var f: FileAccess = FileAccess.open(SAVE, FileAccess.WRITE)
	f.store_string(JSON.stringify(data))
	f.close()

func run_test() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))
	var game: Node2D = load("res://scenes/Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	REG.ensure_loaded()
	var flag: String = REG.GUARDIAN_BOSS_ID
	assert(flag == "BOSS_GUARDIAO_PEDRA_001")
	var story: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/main_story_v1.json")) as Dictionary
	var canon_found: bool = false
	for q_value in story["quests"]:
		if (q_value as Dictionary).get("boss", "") == flag:
			canon_found = true
	assert(canon_found)
	assert(total_assets("val_eco_core") == 1 and total_assets("val_eco_core_dormant") == 1)

	# 1. antes da primeira derrota -> mina ATIVA
	REG.clear_progress()
	assert(not REG.has_mark("elites", flag))
	assert(visible_assets("val_eco_core") == 1 and visible_assets("val_eco_core_dormant") == 0)
	assert(visible_assets("val_core_floor_ring") == 1 and visible_assets("val_core_floor_ring_dormant") == 0)
	assert(visible_assets("val_eco_crystal_cluster") == 4 and visible_assets("val_eco_crystal_cluster_dormant") == 0)
	assert(visible_assets("val_eco_vein") == 2 and visible_assets("val_eco_vein_dormant") == 0)
	var active_emitters: int = emitters_visible()
	assert(active_emitters == 1)

	# 2. primeira derrota grava a flag (e só ela: fonte única em elites:)
	game.quest = 3
	game.change_zone("masmorra", Vector2(480, 700))
	assert(game.guardian_alive())
	game.player = Vector2(480, 300)
	kill_guardian(game)
	assert(REG.has_mark("elites", flag))
	assert(game.quest == 4)
	assert(not game.rematch_active)

	# 3. recarregar o save mantém a flag
	game.save_game()
	REG.clear_progress()
	assert(not REG.has_mark("elites", flag))
	game.load_game()
	assert(REG.has_mark("elites", flag))

	# 4. mundo pós-Guardião -> núcleo DORMENTE
	assert(visible_assets("val_eco_core") == 0 and visible_assets("val_eco_core_dormant") == 1)
	assert(visible_assets("val_core_floor_ring") == 0 and visible_assets("val_core_floor_ring_dormant") == 1)
	assert(visible_assets("val_eco_crystal_cluster") == 0 and visible_assets("val_eco_crystal_cluster_dormant") == 4)
	assert(visible_assets("val_eco_vein") == 0 and visible_assets("val_eco_vein_dormant") == 2)
	assert(visible_assets("val_mine_rock_wall_eco") == 0 and visible_assets("val_mine_rock_wall_eco_dormant") > 0)
	assert(emitters_visible() == 1)  # apenas o brilho residual

	# 5. revanche: o boss reaparece, a apresentação reativa, a flag NÃO é apagada
	game.change_zone("masmorra", Vector2(480, 700))
	assert(not game.guardian_alive())  # populate não respawna o boss por conta própria
	game.player = Vector2(480, 300)
	game.start_guardian_rematch()
	assert(game.rematch_active and game.guardian_alive())
	assert(REG.has_mark("elites", flag))
	assert(visible_assets("val_eco_core") == 1 and visible_assets("val_eco_core_dormant") == 0)
	game.save_game()  # salvar durante a revanche não persiste o estado temporário
	var saved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(SAVE)) as Dictionary
	assert(not (saved["reg001"] as Dictionary).has("rematch_boss"))
	assert((saved["reg001"]["elites"] as Dictionary).has(flag))

	# 6. fim da revanche -> continua pós-Guardião/dormente
	kill_guardian(game)
	assert(not game.rematch_active)
	assert(REG.has_mark("elites", flag))
	assert(visible_assets("val_eco_core") == 0 and visible_assets("val_eco_core_dormant") == 1)
	# sair no meio de uma revanche também restaura o estado narrativo
	game.player = Vector2(480, 300)
	game.start_guardian_rematch()
	assert(game.rematch_active)
	game.change_zone("cidade", Vector2(1500, 1300))
	assert(not game.rematch_active and REG.rematch_boss == "")
	assert(visible_assets("val_eco_core") == 0 and visible_assets("val_eco_core_dormant") == 1)

	# 7. portal/entrada continua acessível
	var gate: Dictionary = REG.poi_by_id["REG001_POI_CRIPTA_ENTRADA"] as Dictionary
	assert(REG.poi_available(gate))
	assert(visible_assets("val_mine_portal") == 1)
	game.zone = "cidade"
	assert(game.walkable((gate["pos"] as Vector2) + Vector2(0, 30)))

	# 8. saves antigos sem a flag continuam carregando
	write_save({"version": 4, "zone": "cidade", "px": 1500.0, "py": 1300.0, "hp": 40, "max_hp": 40, "level": 3, "xp": 0, "gold": 10, "potions": 1, "weapon": 0, "armor": 0, "kills": {"Lobo": 3}, "quest": 1, "reg001": {"opened": {}, "elites": {}, "found": {}, "gathered": {}, "lore": {}, "visited": {}}})
	REG.clear_progress()
	game.load_game()
	assert(game.quest == 1 and not REG.has_mark("elites", flag))
	assert(visible_assets("val_eco_core") == 1)
	write_save({"version": 4, "zone": "cidade", "px": 1500.0, "py": 1300.0, "hp": 40, "max_hp": 40, "level": 5, "xp": 0, "gold": 10, "potions": 1, "weapon": 0, "armor": 0, "kills": {"Lobo": 3, "Guardião": 1}, "quest": 5, "reg001": {"opened": {}, "elites": {}, "found": {}, "gathered": {}, "lore": {}, "visited": {}}})
	REG.clear_progress()
	game.load_game()
	assert(REG.has_mark("elites", flag))  # migração: boss já derrotado num save anterior à flag
	write_save({"version": 3, "zone": "cidade", "px": 1500.0, "py": 1300.0, "hp": 40, "max_hp": 40, "level": 2, "xp": 0, "gold": 10, "potions": 1, "weapon": 0, "armor": 0, "kills": {}, "quest": 0})
	REG.clear_progress()
	game.load_game()
	assert(game.quest == 0 and not REG.has_mark("elites", flag))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))
	print("GUARDIAN STATE PASS: flag elites:", flag, ", ativo->dormente, save/load, revanche temporária, portal acessível, saves antigos")
	quit(0)
