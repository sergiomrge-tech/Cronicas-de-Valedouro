extends SceneTree

const HUDStatus = preload("res://scripts/cartoon/cartoon_hud_status.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var state = root.get_node_or_null("CartoonPlayerState")
	assert(state != null)
	state.reset_progress(true)
	state.start_new_game()

	assert(state.player_level == 1)
	assert(state.player_xp == 0)
	assert(state.xp_to_next(1) == 63)

	var first: Dictionary = state.gain_xp(63)
	assert(bool(first.get("leveled_up",false)))
	assert(int(first.get("levels",0)) == 1)
	assert(state.player_level == 2)
	assert(state.player_xp == 0)
	assert(state.player_max_hp == 124)
	assert(state.player_hp == 124)

	var needed_level_2: int = state.xp_to_next()
	var partial: Dictionary = state.gain_xp(needed_level_2-1)
	assert(not bool(partial.get("leveled_up",false)))
	assert(state.player_level == 2)
	assert(state.player_xp == needed_level_2-1)
	assert(state.xp_ratio() > 0.9)

	state.gain_xp(1)
	assert(state.player_level == 3)
	assert(state.player_xp == 0)

	var hud: Control = HUDStatus.new()
	root.add_child(hud)
	hud.setup("VALEDOURO")
	hud.refresh(state.player_hp,state.player_max_hp,123,state.player_level,state.player_xp,state.xp_to_next())
	assert(hud.region_label.text == "VALEDOURO • Guerreiro")
	assert(hud.level_label.text == "Nv 3")
	assert(hud.gold_label.text.contains("123"))
	assert(hud.hp_text.text.contains("%d / %d" % [state.player_hp,state.player_max_hp]))
	assert(hud.xp_text.text.contains("XP"))

	state.player_level = 99
	state.player_xp = 0
	var to_max: int = state.xp_to_next()
	state.gain_xp(to_max)
	assert(state.player_level == 100)
	assert(state.player_xp == 0)
	assert(state.xp_to_next() == 0)
	assert(is_equal_approx(state.xp_ratio(),1.0))
	hud.refresh(state.player_hp,state.player_max_hp,999,state.player_level,state.player_xp,state.xp_to_next())
	assert(hud.level_label.text == "Nv 100")
	assert(hud.xp_text.text.contains("NÍVEL MÁXIMO"))

	state.reset_progress(true)
	print("hud_progression_v018: PASS — HUD, XP, level up e teto 100")
	quit(0)
