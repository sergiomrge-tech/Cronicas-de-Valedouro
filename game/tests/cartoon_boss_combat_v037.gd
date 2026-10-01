extends SceneTree

const Hub = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const Monster = preload("res://scripts/cartoon/cartoon_monster.gd")

func _initialize() -> void:
	call_deferred("run")

func settle() -> void:
	for i in range(8):
		await process_frame

func run() -> void:
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	state.start_new_game()

	root.size = Vector2i(640,360)
	root.content_scale_size = root.size
	var hub = Hub.instantiate()
	root.add_child(hub)
	current_scene = hub
	await settle()
	hub.set_process(false)
	hub.hero.set_process(false)
	if hub.wildlife != null:
		hub.wildlife.set_process(false)
	var layout = hub.get_node("HUD/GameLayout")
	if layout.demon_director != null:
		layout.demon_director.set_process(false)
	for mob in hub.monsters:
		if is_instance_valid(mob):
			mob.set_process(false)

	var boss = Monster.new()
	boss.name = "BossCombatV037"
	boss.setup({
		"kind":"ash_general",
		"name":"General da Cinza",
		"boss_id":"BOSS_GENERAL_CINZA_001",
		"level":24,
		"hp":100,
		"damage":20,
		"speed":80.0,
		"pos":hub.hero.position+Vector2(120,0),
		"scale":1.2
	})
	hub.objects.add_child(boss)
	hub.monsters.append(boss)
	boss.set_process(false)
	await settle()

	layout._process(0.01)
	assert(layout.boss_panel.visible)
	assert(not layout.quest_panel.visible)
	assert(not layout.minimap.visible)
	for button in layout.spell_buttons+[layout.heal_button,layout.attack_button,layout.dodge_button,layout.interact_button]:
		if button.is_visible_in_tree(): assert(not layout.boss_panel.get_global_rect().intersects(button.get_global_rect()))
	assert(not layout.boss_panel.get_global_rect().intersects(hub.hud_status.panel.get_global_rect()))
	assert(layout.boss_name_label.text.contains("General da Cinza"))
	assert(layout.boss_phase_label.text.contains("FASE I"))
	assert(int(layout.boss_bar.value) == 100)
	assert(not layout.boss_bar.get_global_rect().intersects(layout.boss_phase_label.get_global_rect()))

	boss.take_damage(40)
	layout._process(0.01)
	assert(boss.boss_phase == 2)
	assert(layout.boss_phase_label.text.contains("FASE II"))
	assert(int(layout.boss_bar.value) == 60)

	boss.position = hub.hero.position+Vector2(28,0)
	boss.attack_cooldown = 0.0
	boss.lunge_t = 0.0
	boss.boss_attack_index = 2
	assert(not boss.advance_contact(hub.hero,0.0,52.0))
	assert(boss.strike_special)
	assert(boss.windup_t > 0.9)
	assert(boss.strike_radius >= 130.0)
	assert(boss.contact_damage > boss.base_contact_damage)
	var phase2_special_damage: int = boss.contact_damage
	assert(boss.advance_contact(hub.hero,2.0,52.0))
	assert(phase2_special_damage == roundi(float(boss.base_contact_damage)*1.45))
	await process_frame
	assert(boss.contact_damage == boss.base_contact_damage)

	boss.take_damage(30)
	layout._process(0.01)
	assert(boss.boss_phase == 3)
	assert(layout.boss_phase_label.text.contains("FASE III"))
	assert(int(layout.boss_bar.value) == 30)

	boss.attack_cooldown = 0.0
	boss.lunge_t = 0.0
	boss.boss_attack_index = 1
	assert(not boss.advance_contact(hub.hero,0.0,52.0))
	assert(boss.strike_special)
	assert(boss.strike_radius >= 150.0)
	assert(boss.contact_damage == roundi(float(boss.base_contact_damage)*1.65))

	var normal = Monster.new()
	normal.setup({
		"kind":"wolf","name":"Lobo","level":2,"hp":40,"damage":8,
		"speed":80.0,"pos":hub.hero.position+Vector2(30,0)
	})
	hub.objects.add_child(normal)
	normal.set_process(false)
	assert(not normal.advance_contact(hub.hero,0.0,52.0))
	assert(not normal.strike_special)
	assert(is_equal_approx(normal.windup_duration,0.45))
	assert(is_equal_approx(normal.strike_radius,64.0))
	assert(normal.contact_damage == normal.base_contact_damage)

	boss.hp = boss.max_hp
	boss._update_boss_phase()
	boss.position = hub.hero.position+Vector2(900,0)
	layout._process(0.01)
	assert(not layout.boss_panel.visible)
	assert(layout.quest_panel.visible)

	normal.queue_free()
	boss.queue_free()
	hub.queue_free()
	await settle()
	state.reset_progress(true)
	print("cartoon_boss_combat_v037: PASS — boss HUD, three phases, special telegraphs, phase damage and normal-enemy isolation")
	quit(0)
