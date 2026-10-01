extends Control
## Native buttons retain their labels, keyboard focus and touch ownership.
var kind: String = ""
var icon_width: int = 24
var last_text: String = ""
var last_disabled: bool = false
var texture: Texture2D
var orb_cache: Dictionary = {}
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
func _process(_delta: float) -> void:
	var button: Button = get_parent()
	if button.text!=last_text or button.disabled!=last_disabled:
		last_text = button.text
		last_disabled = button.disabled
		queue_redraw()
func _draw() -> void:
	var button: Button = get_parent()
	var lines: PackedStringArray = button.text.split("\n")
	var spell: bool = kind in ["fire","ice","arcane"]
	var font: Font = button.get_theme_font("font")
	var font_size: int = 11 if size.x<80 else 15
	var width: float = minf(icon_width,size.y-19)
	var y: float = maxf(3,(size.y-width-17)*0.5-2)
	if spell:
		if not orb_cache.has(kind): orb_cache[kind] = load("res://assets/ui/radial/"+kind+"_orb.svg")
		draw_texture_rect(orb_cache[kind],Rect2(Vector2.ZERO,size),false)
		width = size.x*0.63
		y = 5
	if texture != null:
		draw_texture_rect(texture,Rect2(Vector2((size.x-width)*0.5,y),Vector2(width,width)),false,Color(0.8,0.8,0.8) if button.disabled else Color.WHITE)
	if spell:
		var plate = StyleBoxFlat.new()
		plate.bg_color = Color("180d14")
		plate.border_color = Color("bf9348")
		plate.set_border_width_all(1)
		plate.set_corner_radius_all(4)
		draw_style_box(plate,Rect2(2,size.y-15,size.x-4,15))
	var baseline: float = size.y-5
	draw_string_outline(font,Vector2(0,baseline),lines[0],HORIZONTAL_ALIGNMENT_CENTER,size.x,font_size,2,Color("180c0b"))
	draw_string(font,Vector2(0,baseline),lines[0],HORIZONTAL_ALIGNMENT_CENTER,size.x,font_size,Color("fff4dd"))
	if lines.size()>1:
		var badge = StyleBoxFlat.new()
		badge.bg_color = Color(0.05,0.03,0.06,0.94)
		badge.set_corner_radius_all(5)
		var rect = Rect2(size.x-29,size.y-32,28,16)
		draw_style_box(badge,rect)
		draw_string(font,rect.position+Vector2(0,12),lines[1],HORIZONTAL_ALIGNMENT_CENTER,28,10,Color.WHITE)
	if spell and button.disabled:
		var remaining: float = float(lines[1].trim_suffix(" s")) if lines.size()>1 else 0
		var layout = button.get_parent()
		var duration: float = maxf(2.2,3.0-0.08*layout.host.hero._skill("focus"))
		draw_arc(size*0.5,size.x*0.5-2,-PI/2,-PI/2+TAU*clampf(remaining/duration,0,1),40,Color("fff1bd"),2,true)
