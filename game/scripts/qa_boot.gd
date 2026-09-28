extends Node2D

const MAIN_SCENE: String = "res://scenes/Main.tscn"
const REQUIRED_RESOURCES: Array[String] = [
	"res://scripts/main.gd",
	"res://scripts/world_map.gd",
	"res://scripts/loot_system.gd",
	"res://scripts/asset_catalog.gd",
	"res://tests/asset_catalog.gd",
	"res://tests/hero_animation.gd",
	"res://tests/loot_progression.gd",
	"res://tests/monster_animation.gd",
	"res://tests/smoke.gd",
	"res://tests/world_travel.gd",
	MAIN_SCENE
]

var status_label: Label
var detail_label: Label
var passed: bool = true
var issues: Array[String] = []

func _ready() -> void:
	build_ui()
	run_gate()

func build_ui() -> void:
	var background: ColorRect = ColorRect.new()
	background.color = Color(0.035, 0.055, 0.045, 1.0)
	background.position = Vector2.ZERO
	background.size = Vector2(960, 540)
	add_child(background)

	var title: Label = Label.new()
	title.text = "CRÔNICAS DE VALEDOURO"
	title.position = Vector2(64, 72)
	title.size = Vector2(832, 44)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.96, 0.82, 0.49, 1.0))
	background.add_child(title)

	status_label = Label.new()
	status_label.text = "Godot Gate 4.7.2 — verificando..."
	status_label.position = Vector2(64, 155)
	status_label.size = Vector2(832, 50)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 22)
	background.add_child(status_label)

	detail_label = Label.new()
	detail_label.position = Vector2(95, 230)
	detail_label.size = Vector2(770, 210)
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	detail_label.add_theme_font_size_override("font_size", 17)
	detail_label.add_theme_color_override("font_color", Color(0.86, 0.9, 0.84, 1.0))
	background.add_child(detail_label)

func run_gate() -> void:
	var version: Dictionary = Engine.get_version_info()
	var version_text: String = str(version.get("string", "desconhecida"))
	if not version_text.begins_with("4.7.2"):
		passed = false
		issues.append("Versão detectada: %s (esperado 4.7.2)" % version_text)

	for path: String in REQUIRED_RESOURCES:
		if not ResourceLoader.exists(path):
			passed = false
			issues.append("Ausente: %s" % path)
			continue
		var resource: Resource = ResourceLoader.load(path)
		if resource == null:
			passed = false
			issues.append("Falha ao carregar: %s" % path)

	if passed:
		status_label.text = "GODOT GATE: PASS"
		status_label.add_theme_color_override("font_color", Color(0.55, 1.0, 0.62, 1.0))
		detail_label.text = "Godot %s\nScripts e cena principal carregados.\nEntrando automaticamente no protótipo..." % version_text
		await get_tree().create_timer(2.0).timeout
		var change_error: Error = get_tree().change_scene_to_file(MAIN_SCENE)
		if change_error != OK:
			status_label.text = "GODOT GATE: FAIL"
			detail_label.text = "A validação passou, mas a cena principal não abriu.\nCódigo: %d" % int(change_error)
	else:
		status_label.text = "GODOT GATE: FAIL"
		status_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.38, 1.0))
		detail_label.text = "Godot %s\n\n%s\n\nFaça um print desta tela e me envie." % [version_text, "\n".join(issues)]
