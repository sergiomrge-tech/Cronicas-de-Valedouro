extends SceneTree

func _init() -> void:
	var errors: PackedStringArray = PackedStringArray()
	var width: int = int(ProjectSettings.get_setting("display/window/size/window_width_override",0))
	var height: int = int(ProjectSettings.get_setting("display/window/size/window_height_override",0))
	var viewport_width: int = int(ProjectSettings.get_setting("display/window/size/viewport_width",0))
	var viewport_height: int = int(ProjectSettings.get_setting("display/window/size/viewport_height",0))
	if width != 1920: errors.append("window_width_override deve ser 1920")
	if height != 1080: errors.append("window_height_override deve ser 1080")
	if viewport_width != 960 or viewport_height != 540: errors.append("base lógica deve permanecer 960x540")
	var preset_text: String = FileAccess.get_file_as_string("res://export_presets.cfg")
	if not preset_text.contains("Windows Desktop Full HD"): errors.append("preset Windows Desktop Full HD ausente")
	if not preset_text.contains("Cronicas_de_Valedouro_PC_v0.40.exe"): errors.append("caminho do EXE v0.40 ausente")
	var layout = load("res://scripts/cartoon/cartoon_game_layout.gd")
	if layout == null: errors.append("cartoon_game_layout.gd não carregou")
	if errors.is_empty():
		print("cartoon_pc_fullhd_v040: PASS")
		quit(0)
	else:
		for error in errors: push_error(error)
		print("cartoon_pc_fullhd_v040: FAIL")
		quit(1)
