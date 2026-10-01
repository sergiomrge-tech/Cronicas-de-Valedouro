extends Control
var director
func _ready() -> void: mouse_filter = Control.MOUSE_FILTER_IGNORE
func _process(_delta: float) -> void:
	if is_visible_in_tree(): queue_redraw()
func _draw() -> void:
	if director==null: return
	var overlay = get_parent()
	for actor in director.active.values():
		if not is_instance_valid(actor) or actor.is_queued_for_deletion() or actor.hp<=0: continue
		var point: Vector2 = overlay._world_to_map(actor.position)
		draw_circle(point,8,Color("371e3e"))
		draw_colored_polygon(PackedVector2Array([point+Vector2(0,-7),point+Vector2(6,4),point+Vector2(-6,4)]),Color("f777c9"))
		draw_line(point+Vector2(0,-3),point+Vector2(0,0),Color("351f39"),1.5,true)
		draw_circle(point+Vector2(0,2),0.8,Color("351f39"))
	draw_string(ThemeDB.fallback_font,Vector2(622,28),"▲ DEMÔNIOS",HORIZONTAL_ALIGNMENT_LEFT,148,12,Color("f777c9"))
