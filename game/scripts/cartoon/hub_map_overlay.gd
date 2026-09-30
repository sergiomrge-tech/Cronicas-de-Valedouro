class_name ValedouroCartoonHubMapOverlay
extends Control

const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
const StoryMap = preload("res://scripts/cartoon/cartoon_main_story_map.gd")

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
	return map_rect.position+Vector2(
		world_pos.x/Region.REGION_SIZE.x*map_rect.size.x,
		world_pos.y/Region.REGION_SIZE.y*map_rect.size.y
	)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color(0.035,0.045,0.065,0.97))
	draw_rect(map_rect,Color(0.14,0.28,0.16,0.98))
	draw_rect(map_rect,Color(0.28,0.62,0.92),false,4.0)

	var font: Font = ThemeDB.fallback_font
	draw_string(font,Vector2(48,28),"MAPA — BERÇO DE VALEDOURO",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color(0.88,0.95,1.0))
	draw_string(font,Vector2(625,28),"7x • Ato I",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color(0.70,0.82,1.0))

	var route: PackedVector2Array = StoryMap.act1_route_points()
	var scaled: PackedVector2Array = PackedVector2Array()
	for p in route:
		scaled.append(_world_to_map(p))
	if scaled.size() >= 2:
		draw_polyline(scaled,Color(0.78,0.66,0.40),5.0,true)

	for row in StoryMap.act1_locations():
		var id: String = String(row.get("id",""))
		var p: Vector2 = _world_to_map(row.get("pos",Vector2.ZERO))
		var active: bool = id == target_id
		var col: Color = Color(1.0,0.82,0.24) if active else Color(0.48,0.84,1.0)
		draw_circle(p,8.0 if active else 6.0,col)
		draw_circle(p,10.5 if active else 8.0,Color(0.03,0.05,0.08),false,2.0)
		draw_string(font,p+Vector2(10,4),_short_label(id),HORIZONTAL_ALIGNMENT_LEFT,-1,12,col)

	for row in StoryMap.region_transitions():
		var p: Vector2 = _world_to_map(row.get("pos",Vector2.ZERO))
		draw_circle(p,7.0,Color(0.45,0.95,0.50))
		draw_string(font,p+Vector2(10,4),"Floresta",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color(0.45,0.95,0.50))

	if player != null:
		var pp: Vector2 = _world_to_map(player.position)
		draw_circle(pp,8.5,Color(0.35,0.80,1.0))
		draw_circle(pp,12.0,Color.WHITE,false,2.0)
		draw_string(font,pp+Vector2(12,-8),"VOCÊ",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color.WHITE)

	draw_string(font,Vector2(48,432),"● missão principal   verde: próxima região   azul: jogador",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color(0.84,0.88,0.92))

func _short_label(id: String) -> String:
	match id:
		"LOC_VAL_GATE": return "Portão"
		"LOC_VAL_GUILD": return "Guilda"
		"LOC_VAL_NORTH_ROAD": return "Estrada"
		"LOC_FIRST_WIND_RUINS": return "Ruínas"
		"LOC_ALPHA_CLEARING": return "Alfa"
		"LOC_ECHO_MINE": return "Mina"
		"LOC_ECHO_MINE_CORE": return "Guardião"
		"LOC_SIX_CROWNS_ARCHIVE": return "Arquivo"
		_: return ""
