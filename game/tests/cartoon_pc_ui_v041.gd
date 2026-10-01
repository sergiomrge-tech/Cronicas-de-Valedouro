extends SceneTree

const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
const HubEnvironment = preload("res://scripts/cartoon/hub_environment.gd")

func _init() -> void:
	var errors: PackedStringArray = PackedStringArray()

	var layout_source: String = FileAccess.get_file_as_string("res://scripts/cartoon/cartoon_game_layout.gd")
	var menu_source: String = FileAccess.get_file_as_string("res://scripts/cartoon/cartoon_main_menu.gd")
	var hub_source: String = FileAccess.get_file_as_string("res://scripts/cartoon/valedouro_cartoon_hub.gd")

	if not layout_source.contains('spell_bar.name = "PCSpellBar"'):
		errors.append("barra inferior de magias PC ausente")
	if not layout_source.contains('area.end.y-78'):
		errors.append("barra de magias não está ancorada na parte inferior")
	if not layout_source.contains('fullscreen_pause_button.name = "FullscreenButton"'):
		errors.append("botão de tela inteira no pause ausente")
	if not layout_source.contains('exit_game_button.name = "ExitGameButton"'):
		errors.append("botão de sair no pause ausente")
	if not menu_source.contains('exit_game.name = "ExitGameButton"'):
		errors.append("botão de sair no menu principal ausente")
	if not menu_source.contains('fullscreen_button.name = "FullscreenButton"'):
		errors.append("opção visual de tela inteira no menu principal ausente")
	if not hub_source.contains('var priority_poi: Dictionary = environment.nearest_poi(hero.position,260.0)'):
		errors.append("prioridade ampliada da entrada do castelo ausente")
	if not hub_source.contains('E — ENTRAR'):
		errors.append("dica de entrada do castelo para PC ausente")

	var environment = HubEnvironment.new()
	environment._build_layout()
	var door: Vector2 = Region.world_from_hub(Region.CASTLE_DOOR)
	var approach: Vector2 = door + Vector2(0,120)
	var poi: Dictionary = environment.nearest_poi(approach,260.0)
	if String(poi.get("id","")) != "POI_REG001_CASTLE":
		errors.append("aproximação da porta não resolve para o POI do castelo")
	if not environment.is_walkable(approach):
		errors.append("aproximação da porta do castelo não é caminhável")

	if errors.is_empty():
		print("cartoon_pc_ui_v041: PASS")
		quit(0)
	else:
		for error in errors:
			push_error(error)
		print("cartoon_pc_ui_v041: FAIL")
		quit(1)
