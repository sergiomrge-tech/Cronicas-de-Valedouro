extends SceneTree
# Capturas REAIS (Godot 4.7.2) dos ícones gratuitos adaptados: inventário, bolsa de materiais, slots do HUD e aviso de loot.
# Uso: godot --path game --script tests/qa_capture_icons.gd -- <dir_saida>
var game: Node2D
var out_dir: String

func _initialize() -> void:
	call_deferred("run")

func snap(name: String) -> void:
	game.queue_redraw()
	for i in 4:
		await process_frame
	root.get_texture().get_image().save_png("%s/%s.png" % [out_dir, name])
	print("CAPTURED ", name)

func run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	out_dir = args[0] if args.size() > 0 else ProjectSettings.globalize_path("user://icon_captures")
	DirAccess.make_dir_recursive_absolute(out_dir)
	game = load("res://scenes/Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.player = Vector2(1900, 1790)
	game.level = 12
	game.quest = 4
	game.equipped_weapon = {"name": "Espada de Âmbar", "kind": "sword", "tier": 2, "req": 6, "chapter": 3, "atk": 8}
	game.equipped_armor = {"name": "Armadura de Bronze", "kind": "armor", "tier": 2, "req": 6, "chapter": 3, "def": 4}
	game.stored_items = [
		{"name": "Arco do Bosque", "kind": "bow", "tier": 1, "req": 1, "chapter": 0, "atk": 4},
		{"name": "Cajado da Geada", "kind": "staff", "tier": 3, "req": 10, "chapter": 4, "atk": 12},
		{"name": "Espada Glacial", "kind": "sword", "tier": 3, "req": 10, "chapter": 4, "atk": 12},
		{"name": "Armadura de Gelo", "kind": "armor", "tier": 3, "req": 10, "chapter": 4, "def": 6}]
	for m in ["Couro de lobo", "Núcleo de limo", "Seda sombria", "Minério bruto", "Cristal gelado", "Fragmento de Eco"]:
		game.materials[m] = 3
	game.loot_popup(game.material_icon("Couro de lobo"), "+1")
	game.loot_popup(game.item_icon({"kind": "bow", "tier": 2}), "Arco do Sol")
	await snap("loot_popup_hud_slots")
	game.show_inventory()
	await snap("inventario_equipamentos")
	game.show_materials()
	await snap("bolsa_materiais")
	quit(0)
