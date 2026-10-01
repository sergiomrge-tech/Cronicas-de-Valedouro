extends Node2D

const UISkin = preload("res://scripts/cartoon/cartoon_ui_theme.gd")
const RoyalAssets = preload("res://scripts/cartoon/cartoon_royal_assets.gd")
const Assets = preload("res://scripts/cartoon/cartoon_visual_assets.gd")

const InventoryUIScript = preload("res://scripts/cartoon/cartoon_inventory_ui.gd")

var ui: CanvasLayer
var menu_panel: PanelContainer
var options_panel: PanelContainer
var inventory_ui: Control
var profile_label: Label
var zoom_label: Label
var fullscreen_button: Button
var continue_button: Button
var delete_button: Button
var confirmation_panel: PanelContainer
var confirmation_label: Label
var confirmation_mode: String = ""
var anim_t: float = 0.0

func _ready() -> void:
	_build_ui()
	get_viewport().size_changed.connect(_layout_title)
	_layout_title()
	queue_redraw()

func _process(delta: float) -> void:
	anim_t += delta
	queue_redraw()

func _state():
	return get_node_or_null("/root/CartoonPlayerState")

func _draw() -> void:
	draw_set_transform(Vector2.ZERO,0.0,get_viewport_rect().size/Vector2(960,540))
	draw_rect(Rect2(0,0,960,540),Color(0.18,0.46,0.72))
	draw_circle(Vector2(790,95),54,Color(1.0,0.84,0.38))
	draw_circle(Vector2(770,78),45,Color(1.0,0.91,0.55,0.35))
	var far_hills: PackedVector2Array = PackedVector2Array([
		Vector2(0,285),Vector2(120,180),Vector2(235,260),Vector2(355,145),
		Vector2(485,255),Vector2(620,165),Vector2(760,255),Vector2(880,175),
		Vector2(960,235),Vector2(960,540),Vector2(0,540)
	])
	draw_colored_polygon(far_hills,Color(0.24,0.47,0.42))
	var near_hills: PackedVector2Array = PackedVector2Array([
		Vector2(0,350),Vector2(150,265),Vector2(280,330),Vector2(430,235),
		Vector2(570,330),Vector2(710,255),Vector2(840,335),Vector2(960,280),
		Vector2(960,540),Vector2(0,540)
	])
	draw_colored_polygon(near_hills,Color(0.18,0.38,0.27))
	draw_rect(Rect2(0,360,960,180),Color(0.26,0.55,0.28))
	var path: PackedVector2Array = PackedVector2Array([
		Vector2(400,540),Vector2(560,540),Vector2(535,420),Vector2(500,345),
		Vector2(470,300),Vector2(452,300),Vector2(430,350),Vector2(420,430)
	])
	draw_colored_polygon(path,Color(0.72,0.56,0.34))
	_draw_castle(Vector2(330,370))
	for x in [55.0,105.0,165.0,815.0,865.0,915.0]:
		var sway: float = sin(anim_t*0.8+x*0.01)*2.0
		_draw_tree(Vector2(x,370+sway),1.0 if x < 200 else 0.92)
	draw_rect(Rect2(0,0,960,540),Color(0.03,0.05,0.09,0.24))
	draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _draw_castle(base: Vector2) -> void:
	draw_texture_rect(RoyalAssets.texture("royal_castle"),Rect2(base-Vector2(180,280),Vector2(360,300)),false)

func _draw_tree(p: Vector2, scale_value: float) -> void:
	draw_texture_rect(Assets.texture("tree_0"),Rect2(p-Vector2(72,174)*scale_value,Vector2(144,189)*scale_value),false)

func _build_ui() -> void:
	ui = CanvasLayer.new()
	ui.name = "MenuUI"
	ui.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(ui)

	var title: Label = Label.new()
	title.name = "MenuTitle"
	title.position = Vector2(44,38)
	title.size = Vector2(530,88)
	title.text = "CRÔNICAS\nDE VALEDOURO"
	title.add_theme_font_size_override("font_size",38)
	title.add_theme_color_override("font_color",Color(1.0,0.87,0.43))
	title.add_theme_color_override("font_shadow_color",Color(0.05,0.04,0.08))
	title.add_theme_constant_override("shadow_offset_x",3)
	title.add_theme_constant_override("shadow_offset_y",4)
	ui.add_child(title)

	var subtitle: Label = Label.new()
	subtitle.name = "MenuSubtitle"
	subtitle.position = Vector2(48,130)
	subtitle.size = Vector2(480,28)
	subtitle.text = "UM RPG DE EXPLORAÇÃO EM ELYNDOR"
	subtitle.add_theme_font_size_override("font_size",15)
	subtitle.add_theme_color_override("font_color",Color(0.92,0.95,0.88))
	subtitle.add_theme_color_override("font_shadow_color",Color.BLACK)
	subtitle.add_theme_constant_override("shadow_offset_y",2)
	ui.add_child(subtitle)

	menu_panel = PanelContainer.new()
	menu_panel.position = Vector2(600,62)
	menu_panel.size = Vector2(320,424)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.045,0.055,0.075,0.94)
	style.border_color = Color(0.90,0.68,0.25)
	style.set_border_width_all(4)
	style.corner_radius_top_left = 22
	style.corner_radius_top_right = 22
	style.corner_radius_bottom_left = 22
	style.corner_radius_bottom_right = 22
	menu_panel.add_theme_stylebox_override("panel",UISkin.box(UISkin.INK,UISkin.GOLD))
	ui.add_child(menu_panel)
	UISkin.bind(menu_panel,Vector2(320,424),"menu")

	var menu_body: Control = Control.new()
	menu_body.name = "MenuContent"
	menu_body.custom_minimum_size = Vector2(312,416)
	menu_body.mouse_filter = Control.MOUSE_FILTER_PASS
	menu_panel.add_child(menu_body)

	var crest: Label = Label.new()
	crest.position = Vector2(30,16)
	crest.size = Vector2(260,42)
	crest.text = "◆  VALEDOURO  ◆"
	crest.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	crest.add_theme_font_size_override("font_size",20)
	crest.add_theme_color_override("font_color",Color(1.0,0.82,0.34))
	menu_body.add_child(crest)

	var new_game: Button = _menu_button("NOVO JOGO",Vector2(32,132))
	new_game.name = "NewGameButton"
	new_game.pressed.connect(_new_game)
	menu_body.add_child(new_game)

	continue_button = _menu_button("CONTINUAR",Vector2(32,72))
	continue_button.name = "ContinueButton"
	continue_button.pressed.connect(_continue_game)
	menu_body.add_child(continue_button)

	var bag: Button = _menu_button("INVENTÁRIO",Vector2(32,192))
	bag.name = "InventoryButton"
	bag.pressed.connect(func(): inventory_ui.open_panel())
	menu_body.add_child(bag)

	var options: Button = _menu_button("OPÇÕES",Vector2(32,252))
	options.name = "OptionsButton"
	options.pressed.connect(_open_options)
	menu_body.add_child(options)

	var exit_game: Button = _menu_button("SAIR DO JOGO",Vector2(32,312))
	exit_game.name = "ExitGameButton"
	exit_game.visible = OS.get_name() == "Windows"
	_style_button(exit_game,Color(0.25,0.08,0.10),Color(0.80,0.31,0.34))
	exit_game.pressed.connect(_quit_game)
	menu_body.add_child(exit_game)

	delete_button = _menu_button("EXCLUIR PROGRESSO",Vector2(32,276))
	delete_button.name = "DeleteSaveButton"
	_style_button(delete_button,Color(0.25,0.08,0.10),Color(0.80,0.31,0.34))
	delete_button.pressed.connect(_delete_save)
	menu_body.add_child(delete_button)

	profile_label = Label.new()
	profile_label.position = Vector2(24,360)
	profile_label.size = Vector2(272,46)
	profile_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	profile_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	profile_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	profile_label.add_theme_font_size_override("font_size",12)
	profile_label.add_theme_color_override("font_color",Color(0.72,0.82,0.86))
	menu_body.add_child(profile_label)

	inventory_ui = InventoryUIScript.new()
	inventory_ui.name = "MenuInventory"
	ui.add_child(inventory_ui)
	inventory_ui.setup(null,null,false)

	_build_options()
	_build_confirmation()
	_refresh_profile()

	var version: Label = Label.new()
	version.position = Vector2(18,508)
	version.size = Vector2(924,24)
	var desktop_mode: bool = OS.get_name() == "Windows"
	version.text = "ELYNDOR • PC Full HD 1920×1080 • F11 tela cheia" if desktop_mode else "ELYNDOR • Progresso salvo neste aparelho"
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	version.add_theme_font_size_override("font_size",12)
	version.add_theme_color_override("font_color",Color(1,1,1,0.72))
	ui.add_child(version)
	UISkin.bind(version,Vector2(924,24),"footer")

func _menu_button(text_value: String, pos: Vector2) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.position = pos
	button.size = Vector2(256,48)
	button.add_theme_font_size_override("font_size",16)
	_style_button(button,Color(0.12,0.18,0.25),Color(0.83,0.64,0.25))
	return button

func _style_button(button: Button, bg: Color, border: Color) -> void:
	UISkin.button(button,UISkin.SURFACE.lerp(bg,0.20),UISkin.GOLD if bg.r < 0.2 else Color("b48472"))

func _play() -> void:
	# Compatibilidade com chamadas antigas: Jogar continua um save ou inicia uma aventura.
	var state = _state()
	if state != null and state.has_campaign_save():
		_continue_game()
	else:
		_new_game()

func _new_game() -> void:
	var state = _state()
	if state == null:
		return
	if state.has_campaign_save():
		_show_confirmation("new","Iniciar um NOVO JOGO?\nO progresso atual da campanha será apagado.")
	else:
		_start_new_game_now()

func _start_new_game_now() -> void:
	var state = _state()
	if state == null:
		return
	state.start_new_game()
	get_tree().change_scene_to_file(state.continue_scene_path())

func _continue_game() -> void:
	var state = _state()
	if state == null or not state.has_campaign_save():
		return
	get_tree().change_scene_to_file(state.continue_scene_path())

func _delete_save() -> void:
	var state = _state()
	if state == null or not state.has_campaign_save():
		return
	_show_confirmation("delete","Excluir o progresso salvo?\nEsta ação remove campanha, equipamentos e materiais.")

func _show_confirmation(mode: String,text_value: String) -> void:
	confirmation_mode = mode
	if inventory_ui != null:
		inventory_ui.close_panel()
	if options_panel != null:
		options_panel.visible = false
	confirmation_label.text = text_value
	confirmation_panel.visible = true

func _confirm_action() -> void:
	var mode: String = confirmation_mode
	confirmation_panel.visible = false
	confirmation_mode = ""
	if mode == "new":
		_start_new_game_now()
	elif mode == "delete":
		var state = _state()
		if state != null:
			state.delete_profile()
		_refresh_profile()
		_refresh_zoom()

func _cancel_confirmation() -> void:
	confirmation_panel.visible = false
	confirmation_mode = ""

func _refresh_profile() -> void:
	var state = _state()
	if state == null or profile_label == null:
		return
	var has_save: bool = state.has_campaign_save()
	if continue_button != null:
		continue_button.disabled = not has_save
	if delete_button != null:
		delete_button.disabled = not has_save
	profile_label.text = state.profile_summary() if has_save else "Sem aventura salva\n%s" % state.profile_summary()

func _build_options() -> void:
	options_panel = PanelContainer.new()
	options_panel.position = Vector2(300,150)
	options_panel.size = Vector2(360,390)
	options_panel.visible = false
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.045,0.055,0.075,0.985)
	style.border_color = Color(0.45,0.70,0.91)
	style.set_border_width_all(4)
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	options_panel.add_theme_stylebox_override("panel",UISkin.box(UISkin.INK,UISkin.GOLD))
	ui.add_child(options_panel)
	UISkin.bind(options_panel,Vector2(360,340),"center",true)

	var options_body: Control = Control.new()
	options_body.name = "OptionsContent"
	options_body.custom_minimum_size = Vector2(352,382)
	options_body.mouse_filter = Control.MOUSE_FILTER_PASS
	options_panel.add_child(options_body)

	var title: Label = Label.new()
	title.position = Vector2(24,20)
	title.size = Vector2(312,32)
	title.text = "OPÇÕES"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size",22)
	title.add_theme_color_override("font_color",Color(0.74,0.89,1.0))
	options_body.add_child(title)

	var zoom_title: Label = Label.new()
	zoom_title.position = Vector2(28,72)
	zoom_title.size = Vector2(130,30)
	zoom_title.text = "Zoom da câmera"
	zoom_title.add_theme_font_size_override("font_size",15)
	options_body.add_child(zoom_title)

	var minus: Button = Button.new()
	minus.text = "−"
	minus.position = Vector2(170,66)
	minus.size = Vector2(46,42)
	_style_button(minus,Color(0.11,0.15,0.21),Color(0.47,0.68,0.86))
	minus.pressed.connect(func(): _change_zoom(-0.15))
	options_body.add_child(minus)

	zoom_label = Label.new()
	zoom_label.position = Vector2(220,72)
	zoom_label.size = Vector2(70,28)
	zoom_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	zoom_label.add_theme_font_size_override("font_size",16)
	options_body.add_child(zoom_label)

	var plus: Button = Button.new()
	plus.text = "+"
	plus.position = Vector2(294,66)
	plus.size = Vector2(46,42)
	_style_button(plus,Color(0.11,0.15,0.21),Color(0.47,0.68,0.86))
	plus.pressed.connect(func(): _change_zoom(0.15))
	options_body.add_child(plus)

	var reset: Button = _menu_button("PADRÃO 100%",Vector2(62,126))
	reset.size = Vector2(236,48)
	reset.add_theme_font_size_override("font_size",14)
	reset.pressed.connect(func(): _set_zoom(1.0))
	options_body.add_child(reset)

	fullscreen_button = _menu_button("TELA INTEIRA",Vector2(62,184))
	fullscreen_button.name = "FullscreenButton"
	fullscreen_button.size = Vector2(236,48)
	fullscreen_button.add_theme_font_size_override("font_size",14)
	fullscreen_button.visible = OS.get_name() == "Windows"
	fullscreen_button.pressed.connect(_toggle_fullscreen)
	options_body.add_child(fullscreen_button)

	var close: Button = _menu_button("VOLTAR",Vector2(62,300))
	close.size = Vector2(236,48)
	close.add_theme_font_size_override("font_size",14)
	close.pressed.connect(func(): options_panel.visible=false)
	options_body.add_child(close)
	delete_button.reparent(options_body,false)
	delete_button.position = Vector2(62,242)
	delete_button.size = Vector2(236,48)
	_refresh_zoom()
	_refresh_fullscreen_button()

func _build_confirmation() -> void:
	confirmation_panel = PanelContainer.new()
	confirmation_panel.position = Vector2(280,145)
	confirmation_panel.size = Vector2(400,250)
	confirmation_panel.visible = false
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.035,0.045,0.065,0.995)
	style.border_color = Color(0.92,0.58,0.24)
	style.set_border_width_all(4)
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	confirmation_panel.add_theme_stylebox_override("panel",UISkin.box(UISkin.INK,Color("b48472")))
	ui.add_child(confirmation_panel)
	UISkin.bind(confirmation_panel,Vector2(400,250),"center",true)

	var confirmation_body: Control = Control.new()
	confirmation_body.name = "ConfirmationContent"
	confirmation_body.custom_minimum_size = Vector2(392,242)
	confirmation_body.mouse_filter = Control.MOUSE_FILTER_PASS
	confirmation_panel.add_child(confirmation_body)

	var title: Label = Label.new()
	title.position = Vector2(26,20)
	title.size = Vector2(348,34)
	title.text = "CONFIRMAR"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size",22)
	title.add_theme_color_override("font_color",Color(1.0,0.82,0.38))
	confirmation_body.add_child(title)

	confirmation_label = Label.new()
	confirmation_label.position = Vector2(30,66)
	confirmation_label.size = Vector2(340,74)
	confirmation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	confirmation_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	confirmation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	confirmation_label.add_theme_font_size_override("font_size",15)
	confirmation_body.add_child(confirmation_label)

	var confirm: Button = _menu_button("CONFIRMAR",Vector2(32,162))
	confirm.size = Vector2(158,48)
	confirm.pressed.connect(_confirm_action)
	confirmation_body.add_child(confirm)

	var cancel: Button = _menu_button("CANCELAR",Vector2(208,162))
	cancel.size = Vector2(158,48)
	cancel.pressed.connect(_cancel_confirmation)
	confirmation_body.add_child(cancel)

func _open_options() -> void:
	inventory_ui.close_panel()
	if confirmation_panel != null:
		confirmation_panel.visible = false
	options_panel.visible = true
	_refresh_zoom()
	_refresh_fullscreen_button()

func _change_zoom(delta_value: float) -> void:
	var state = _state()
	if state != null:
		_set_zoom(float(state.camera_zoom)+delta_value)

func _set_zoom(value: float) -> void:
	var state = _state()
	if state != null:
		state.set_camera_zoom(value)
	_refresh_zoom()

func _refresh_zoom() -> void:
	var state = _state()
	if state != null and zoom_label != null:
		zoom_label.text = "%d%%" % int(round(float(state.camera_zoom)*100.0))

func _toggle_fullscreen() -> void:
	if OS.get_name() != "Windows": return
	var current_mode := DisplayServer.window_get_mode()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)
	call_deferred("_refresh_fullscreen_button")

func _refresh_fullscreen_button() -> void:
	if fullscreen_button == null: return
	var fullscreen: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fullscreen_button.text = "TELA INTEIRA: LIGADA" if fullscreen else "TELA INTEIRA: DESLIGADA"

func _quit_game() -> void:
	var state = _state()
	if state != null and state.has_campaign_save():
		state.save_profile()
	get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F11 and OS.get_name() == "Windows":
		_toggle_fullscreen()
		get_viewport().set_input_as_handled()
		return
	if not event.is_action_pressed("ui_cancel"): return
	if confirmation_panel.visible: _cancel_confirmation()
	elif options_panel.visible: options_panel.visible = false
	elif inventory_ui.is_open(): inventory_ui.close_panel()
	get_viewport().set_input_as_handled()

func _layout_title() -> void:
	var area: Rect2 = UISkin.usable(get_viewport())
	var title: Label = ui.get_node("MenuTitle")
	var subtitle: Label = ui.get_node("MenuSubtitle")
	var width: float = minf(550.0,menu_panel.position.x-area.position.x-38.0)
	var font_size: int = int(clampf(width/14.0,22,38))
	title.position = area.position+Vector2(20,18)
	title.size = Vector2(width,float(font_size)*3.0)
	title.add_theme_font_size_override("font_size",font_size)
	subtitle.position = title.position+Vector2(2,title.size.y+10)
	subtitle.size = Vector2(width,42)
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_font_size_override("font_size",13)
