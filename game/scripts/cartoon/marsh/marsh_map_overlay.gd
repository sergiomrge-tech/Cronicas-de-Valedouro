class_name ValedouroCartoonMarshMapOverlay
extends Control

const UISkin = preload("res://scripts/cartoon/cartoon_ui_theme.gd")
var frame_style: StyleBoxFlat

const Marsh = preload("res://scripts/cartoon/marsh/marsh_region_config.gd")
const StoryMap = preload("res://scripts/cartoon/marsh/marsh_story_map.gd")

var player: Node2D
var target_id: String = ""
var map_rect: Rect2 = Rect2(48,42,754,366)

func setup(player_node: Node2D) -> void:
	player = player_node
	frame_style = UISkin.box(UISkin.INK,UISkin.GOLD)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func set_target(id: String) -> void:
	target_id = id
	queue_redraw()

func _process(_delta: float) -> void:
	if visible:
		queue_redraw()

func _world_to_map(world_pos: Vector2) -> Vector2:
	return map_rect.position+Vector2(
		world_pos.x/Marsh.REGION_SIZE.x*map_rect.size.x,
		world_pos.y/Marsh.REGION_SIZE.y*map_rect.size.y
	)

func _draw() -> void:
	draw_style_box(frame_style,Rect2(Vector2.ZERO,size))
	draw_rect(map_rect,Color(0.11,0.25,0.22,0.98))
	draw_rect(map_rect,UISkin.GOLD.darkened(0.30),false,2.0)

	var font: Font = ThemeDB.fallback_font
	draw_string(font,Vector2(48,28),"MAPA — PÂNTANOS SOMBRIOS",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color(0.78,1.0,0.88))

	var route: PackedVector2Array = StoryMap.route_points()
	var scaled: PackedVector2Array = PackedVector2Array()
	for p in route:
		scaled.append(_world_to_map(p))
	if scaled.size() >= 2:
		draw_polyline(scaled,Color(0.66,0.62,0.39),5.0,true)

	for row in StoryMap.optional_pois():
		var p: Vector2 = _world_to_map(row.get("pos",Vector2.ZERO))
		draw_circle(p,4.0,Color(0.63,0.79,0.64))

	for row in StoryMap.locations():
		var id: String = String(row.get("id",""))
		var p: Vector2 = _world_to_map(row.get("pos",Vector2.ZERO))
		var active: bool = id == target_id
		var col: Color = Color(1.0,0.82,0.27) if active else Color(0.49,0.92,0.70)
		draw_circle(p,8.0 if active else 6.0,col)
		draw_circle(p,10.5 if active else 8.0,Color(0.02,0.07,0.06),false,2.0)
		draw_string(font,p+Vector2(10,4),_short_label(id),HORIZONTAL_ALIGNMENT_LEFT,-1,12,col)

	if player != null:
		var pp: Vector2 = _world_to_map(player.position)
		draw_circle(pp,8.5,Color(0.35,0.80,1.0))
		draw_circle(pp,12.0,Color.WHITE,false,2.0)
		draw_string(font,pp+Vector2(12,-8),"VOCÊ",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color.WHITE)

	draw_string(font,Vector2(48,432),"● missão principal   • exploração   azul: jogador",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color(0.82,0.92,0.86))

func _short_label(id: String) -> String:
	match id:
		"LOC_MARSH_STILT_VILLAGE": return "Lanternas"
		"LOC_DROWNED_BELL_TOWER": return "Sino"
		"LOC_FLOODED_MONASTERY": return "Mosteiro"
		"LOC_REED_SANCTUM": return "Santuário"
		"LOC_REED_THRONE": return "Trono"
		"LOC_MARSH_ECHO_SLICE": return "Comporta"
		_: return ""
