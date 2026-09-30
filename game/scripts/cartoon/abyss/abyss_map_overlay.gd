class_name ValedouroCartoonAbyssMapOverlay
extends Control

const Abyss = preload("res://scripts/cartoon/abyss/abyss_region_config.gd")
const StoryMap = preload("res://scripts/cartoon/abyss/abyss_story_map.gd")

var player: Node2D
var target_id: String = ""
var map_rect: Rect2 = Rect2(48,42,754,366)

func setup(player_node: Node2D) -> void:
	player = player_node
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func set_target(id: String) -> void:
	target_id = id
	queue_redraw()

func _process(_delta: float) -> void:
	if visible:
		queue_redraw()

func _world_to_map(world_pos: Vector2) -> Vector2:
	return map_rect.position+Vector2(world_pos.x/Abyss.REGION_SIZE.x*map_rect.size.x,world_pos.y/Abyss.REGION_SIZE.y*map_rect.size.y)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color(0.025,0.015,0.04,0.98))
	draw_rect(map_rect,Color(0.10,0.07,0.16,0.99))
	draw_rect(map_rect,Color(0.62,0.32,0.82),false,4.0)
	var font: Font = ThemeDB.fallback_font
	draw_string(font,Vector2(48,28),"MAPA — CORAÇÃO ABISSAL",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color(0.92,0.82,1.0))
	draw_string(font,Vector2(650,28),"8x • final",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color(0.75,0.61,0.88))
	var scaled: PackedVector2Array = PackedVector2Array()
	for p in StoryMap.route_points():
		scaled.append(_world_to_map(p))
	if scaled.size() >= 2:
		draw_polyline(scaled,Color(0.58,0.42,0.67),5.0,true)
	for row in StoryMap.optional_pois():
		draw_circle(_world_to_map(row.get("pos",Vector2.ZERO)),4.0,Color(0.58,0.47,0.67))
	for row in StoryMap.locations():
		var id: String = String(row.get("id",""))
		var p: Vector2 = _world_to_map(row.get("pos",Vector2.ZERO))
		var active: bool = id == target_id
		var col: Color = Color(1.0,0.82,0.27) if active else Color(0.79,0.47,0.96)
		draw_circle(p,8.0 if active else 6.0,col)
		draw_circle(p,10.5 if active else 8.0,Color(0.03,0.02,0.05),false,2.0)
		draw_string(font,p+Vector2(10,4),_short_label(id),HORIZONTAL_ALIGNMENT_LEFT,-1,12,col)
	if player != null:
		var pp: Vector2 = _world_to_map(player.position)
		draw_circle(pp,8.5,Color(0.35,0.80,1.0))
		draw_circle(pp,12.0,Color.WHITE,false,2.0)
		draw_string(font,pp+Vector2(12,-8),"VOCÊ",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color.WHITE)
	draw_string(font,Vector2(48,432),"● missão principal   • ecos das regiões   azul: jogador",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color(0.84,0.77,0.90))

func _short_label(id: String) -> String:
	match id:
		"LOC_LAST_MAP_GATE": return "Último Mapa"
		"LOC_HALL_LOST_PATHS": return "Caminhos"
		"LOC_VOID_ARCHIVE": return "Arquivo"
		"LOC_EMPTY_THRONE_ANTECHAMBER": return "Adrian"
		"LOC_EMPTY_THRONE": return "Azharel"
		"LOC_EARTH_GATE": return "Terra"
		_: return ""
