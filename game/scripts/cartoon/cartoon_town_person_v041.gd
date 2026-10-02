extends AnimatedSprite2D
const Art = preload("res://scripts/cartoon/cartoon_pilot_art_v041.gd")
var role: String
func setup(key: String) -> void:
	role = key
	sprite_frames = Art.people_frames(role)
	scale = Vector2.ONE*float(Art.manifest.people[role].scale)
	frame_changed.connect(_align_boots)
	animation_changed.connect(_align_boots)
	play("idle")
	_align_boots()
func set_walking(moving: bool, left: bool) -> void:
	flip_h = left
	var next: StringName = &"walk" if moving else &"idle"
	if animation!=next:
		play(next)
		set_frame_and_progress(0,0.0)
	_align_boots()
func _align_boots() -> void:
	if role.is_empty() or sprite_frames==null: return
	var pose: int = Art.pose_index(animation,frame)
	var tex: Texture2D = Art.people_texture(role,pose)
	var anchor: Vector2 = Art.people_anchor(role,pose)
	offset = tex.get_size()*0.5-anchor
	if flip_h: offset.x = -offset.x
