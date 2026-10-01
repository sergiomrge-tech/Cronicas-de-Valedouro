extends SceneTree

const Hub = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")

func _initialize() -> void:
	call_deferred("run")

func settle() -> void:
	for i in range(8):
		await process_frame

func run() -> void:
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	state.start_new_game()

	assert(state.player_level == 1)
	assert(state.spell_unlocked(0))
	assert(not state.spell_unlocked(1))
	assert(not state.spell_unlocked(2))
	assert(state.unlocked_spell_count() == 1)

	root.size = Vector2i(640,360)
	root.content_scale_size = root.size
	var hub = Hub.instantiate()
	root.add_child(hub)
	current_scene = hub
	await settle()

	hub.set_process(false)
	hub.hero.set_process(false)
	var layout = hub.get_node("HUD/GameLayout")
	if layout.demon_director != null:
		layout.demon_director.set_process(false)
	for mob in hub.monsters:
		if is_instance_valid(mob):
			mob.set_process(false)

	layout._process(0.0)
	assert(layout.spell_buttons[0].visible)
	assert(not layout.spell_buttons[1].visible)
	assert(not layout.spell_buttons[2].visible)
	assert(hub.hero.cast_spell(hub,1) == false)

	state.player_level = 10
	layout._process(0.0)
	await settle()
	assert(layout.spell_buttons[0].visible)
	assert(layout.spell_buttons[1].visible)
	assert(not layout.spell_buttons[2].visible)
	assert(state.unlocked_spell_count() == 2)

	state.player_level = 25
	layout._process(0.0)
	await settle()
	assert(layout.spell_buttons[2].visible)
	assert(state.unlocked_spell_count() == 3)

	state.player_gold = 432
	hub.player_gold = 432
	hub.inventory_ui.open_panel("equipment")
	await settle()
	assert(hub.inventory_ui.gold_label != null)
	assert(hub.inventory_ui.gold_label.text.contains("432"))
	assert(hub.inventory_ui.preview_container != null)
	assert(hub.inventory_ui.preview_viewport != null)
	assert(hub.inventory_ui.preview_hero != null)
	assert(hub.inventory_ui.content.get_node_or_null("CharacterPreviewFrame") != null)
	for slot in ["helmet","gloves","cape","legs","boots"]:
		assert(hub.inventory_ui.piece_buttons.has(slot),"Missing paper-doll slot "+slot)
		var button: Button = hub.inventory_ui.piece_buttons[slot]
		assert(button.visible and button.size.x >= 44 and button.size.y >= 38)
	hub.inventory_ui.close_panel()

	layout.mission_ui.open_panel()
	await settle()
	layout.mission_ui.show_tab("available")
	await settle()
	var vbar: VScrollBar = layout.mission_ui.scroll.get_v_scroll_bar()
	assert(vbar.visible)
	assert(vbar.max_value > vbar.page)
	var before: int = layout.mission_ui.scroll.scroll_vertical
	var drag: InputEventScreenDrag = InputEventScreenDrag.new()
	drag.index = 7
	drag.relative = Vector2(0,-130)
	layout.mission_ui._scroll_input(drag)
	await settle()
	assert(layout.mission_ui.scroll.scroll_vertical > before)
	layout.mission_ui.close_panel()

	assert(hub.objective_label.max_lines_visible == 1)
	layout._toggle_quest()
	assert(hub.objective_label.max_lines_visible == 6)
	layout._toggle_quest()

	# Reproduce the interrupted gate: long loot feedback plus all three spells.
	# v0.35 adds a temporary level-up banner that intentionally hides the guild
	# summary in the same band; clear it so this legacy test isolates overlap.
	layout.level_banner_timer = 0.0
	layout.level_banner.visible = false
	var contracts = preload("res://scripts/cartoon/cartoon_guild_contracts.gd")
	assert(contracts.accept(state,"GUILD_RABBITS"))
	state.player_level = 25
	hub._show_toast("DROP RARO: Espada dos Ecos\n+1 Frasco de Cura e materiais\nDetalhe adicional para testar truncamento")
	for dimensions: Vector2i in [Vector2i(640,360),Vector2i(800,450),Vector2i(960,540),Vector2i(1280,720)]:
		root.size = dimensions
		root.content_scale_size = dimensions
		await settle()
		layout._layout()
		layout._process(0.0)
		await settle()
		assert(layout.contract_panel.visible)
		assert(hub.toast_label.max_lines_visible==2 and hub.toast_label.tooltip_text==hub.toast_label.text)
		for message in [hub.toast_label,hub.poi_label]:
			var rect: Rect2 = message.get_global_rect()
			assert(root.get_visible_rect().encloses(rect))
			for control in layout.spell_buttons+[layout.quest_panel,layout.contract_panel,layout.dodge_button,layout.map_button,layout.pause_button,hub.zoom_controls.panel,hub.inventory_ui.toggle_button,hub.crafting_ui.toggle_button]:
				if control.is_visible_in_tree(): assert(not rect.intersects(control.get_global_rect()),"Combat feedback overlaps %s at %s" % [control.name,dimensions])
		assert(not hub.toast_label.get_global_rect().intersects(hub.poi_label.get_global_rect()),"Messages overlap at %s: %s / %s" % [dimensions,hub.toast_label.get_global_rect(),hub.poi_label.get_global_rect()])
	hub.queue_free()
	await settle()
	state.reset_progress(true)
	print("cartoon_ui_progression_v032: PASS — 1/2/3 spells by level, gold + paper-doll inventory, compact HUD and mission touch scroll")
	quit(0)
