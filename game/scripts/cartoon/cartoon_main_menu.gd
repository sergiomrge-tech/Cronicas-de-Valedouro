extends Node2D

const InventoryUIScript = preload("res://scripts/cartoon/cartoon_inventory_ui.gd")

var ui: CanvasLayer
var menu_panel: PanelContainer
var options_panel: PanelContainer
var inventory_ui: Control
var profile_label: Label
var zoom_label: Label
var continue_button: Button
var delete_button: Button
var confirmation_panel: PanelContainer
var confirmation_label: Label
var confirmation_mode: String = ""
var anim_t: float = 0.0

func _ready() -> void:
	_build_ui()
	queue_redraw()

func _process(delta: float) -> void:
	anim_t += delta
	queue_redraw()

func _state():
	return get_node_or_null("/root/CartoonPlayerState")

func _draw() -> void:
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
	_draw_castle(Vector2(460,270))
	for x in [55.0,105.0,165.0,815.0,865.0,915.0]:
		var sway: float = sin(anim_t*0.8+x*0.01)*2.0
		_draw_tree(Vector2(x,370+sway),1.0 if x < 200 else 0.92)
	draw_rect(Rect2(0,0,960,540),Color(0.03,0.05,0.09,0.16))

func _draw_castle(base: Vector2) -> void:
	draw_rect(Rect2(base.x-82,base.y-66,164,82),Color(0.57,0.58,0.62))
	draw_rect(Rect2(base.x-113,base.y-92,48,108),Color(0.48,0.50,0.55))
	draw_rect(Rect2(base.x+65,base.y-92,48,108),Color(0.48,0.50,0.55))
	for x in [-103.0,-83.0,73.0,93.0]:
		draw_rect(Rect2(base.x+x,base.y-106,15,20),Color(0.43,0.44,0.49))
	draw_rect(Rect2(base.x-24,base.y-39,48,55),Color(0.22,0.18,0.21))
	draw_circle(base+Vector2(0,-72),10,Color(0.30,0.62,0.88))
	draw_line(base+Vector2(0,-82),base+Vector2(0,-126),Color(0.18,0.13,0.12),4)
	var flag: PackedVector2Array = PackedVector2Array([base+Vector2(2,-124),base+Vector2(42,-113),base+Vector2(2,-100)])
	draw_colored_polygon(flag,Color(0.18,0.48,0.80))

func _draw_tree(p: Vector2, scale_value: float) -> void:
	draw_rect(Rect2(p.x-7*scale_value,p.y-40*scale_value,14*scale_value,44*scale_value),Color(0.31,0.19,0.10))
	draw_circle(p+Vector2(0,-50*scale_value),28*scale_value,Color(0.12,0.36,0.18))
	draw_circle(p+Vector2(-17*scale_value,-40*scale_value),20*scale_value,Color(0.17,0.45,0.21))
	draw_circle(p+Vector2(18*scale_value,-41*scale_value),21*scale_value,Color(0.15,0.42,0.20))

func _build_ui() -> void:
	ui = CanvasLayer.new()
	ui.name = "MenuUI"
	add_child(ui)

	var title: Label = Label.new()
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
	menu_panel.add_theme_stylebox_override("panel",style)
	ui.add_child(menu_panel)

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

	var new_game: Button = _menu_button("NOVO JOGO",Vector2(32,68))
	new_game.name = "NewGameButton"
	new_game.pressed.connect(_new_game)
	menu_body.add_child(new_game)

	continue_button = _menu_button("CONTINUAR",Vector2(32,120))
	continue_button.name = "ContinueButton"
	continue_button.pressed.connect(_continue_game)
	menu_body.add_child(continue_button)

	var bag: Button = _menu_button("INVENTÁRIO",Vector2(32,172))
	bag.name = "InventoryButton"
	bag.pressed.connect(func(): inventory_ui.open_panel())
	menu_body.add_child(bag)

	var options: Button = _menu_button("OPÇÕES",Vector2(32,224))
	options.name = "OptionsButton"
	options.pressed.connect(_open_options)
	menu_body.add_child(options)

	delete_button = _menu_button("EXCLUIR PROGRESSO",Vector2(32,276))
	delete_button.name = "DeleteSaveButton"
	_style_button(delete_button,Color(0.25,0.08,0.10),Color(0.80,0.31,0.34))
	delete_button.pressed.connect(_delete_save)
	menu_body.add_child(delete_button)

	profile_label = Label.new()
	profile_label.position = Vector2(24,334)
	profile_label.size = Vector2(272,58)
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
	version.text = "2D Cartoon v0.19 • Godot 4.7.2 • progresso local"
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	version.add_theme_font_size_override("font_size",12)
	version.add_theme_color_override("font_color",Color(1,1,1,0.72))
	ui.add_child(version)

func _menu_button(text_value: String, pos: Vector2) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.position = pos
	button.size = Vector2(256,44)
	button.add_theme_font_size_override("font_size",16)
	_style_button(button,Color(0.12,0.18,0.25),Color(0.83,0.64,0.25))
	return button

func _style_button(button: Button, bg: Color, border: Color) -> void:
	for state_name in ["normal","hover","pressed","focus","disabled"]:
		var box: StyleBoxFlat = StyleBoxFlat.new()
		box.bg_color = bg.lightened(0.08) if state_name == "hover" else (bg.darkened(0.08) if state_name == "pressed" else (bg.darkened(0.25) if state_name == "disabled" else bg))
		box.border_color = border
		box.set_border_width_all(3)
		box.corner_radius_top_left = 14
		box.corner_radius_top_right = 14
		box.corner_radius_bottom_left = 14
		box.corner_radius_bottom_right = 14
		button.add_theme_stylebox_override(state_name,box)

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
	options_panel.size = Vector2(360,240)
	options_panel.visible = false
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.045,0.055,0.075,0.985)
	style.border_color = Color(0.45,0.70,0.91)
	style.set_border_width_all(4)
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	options_panel.add_theme_stylebox_override("panel",style)
	ui.add_child(options_panel)

	var options_body: Control = Control.new()
	options_body.name = "OptionsContent"
	options_body.custom_minimum_size = Vector2(352,232)
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
	reset.size = Vector2(236,42)
	reset.add_theme_font_size_override("font_size",14)
	reset.pressed.connect(func(): _set_zoom(1.0))
	options_body.add_child(reset)

	var close: Button = _menu_button("VOLTAR",Vector2(62,180))
	close.size = Vector2(236,42)
	close.add_theme_font_size_override("font_size",14)
	close.pressed.connect(func(): options_panel.visible=false)
	options_body.add_child(close)
	_refresh_zoom()

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
	confirmation_panel.add_theme_stylebox_override("panel",style)
	ui.add_child(confirmation_panel)

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
