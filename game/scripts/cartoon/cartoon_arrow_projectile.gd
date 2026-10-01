class_name ValedouroCartoonArrowProjectile
extends Node2D
## Snapshot damage; impact uses each region's canonical quest/reward guard.
const Spell = preload("res://scripts/cartoon/cartoon_spell_projectile.gd")
const FX = preload("res://scripts/cartoon/cartoon_combat_fx.gd")
static var active_count: int = 0
const LIMIT: int = 24
var host_ref: WeakRef
var target_ref: WeakRef
var director_ref: WeakRef
var damage: int = 0
var direction: Vector2 = Vector2.RIGHT
var traveled: float = 0
var age: float = 0

static func launch(host, hero, target: Node2D, base_damage: int, director = null):
	if not hero.bow_equipped or hero.death_t>0 or hero.dodge_t>0 or hero.get_tree().paused: return null
	if is_instance_valid(target) and hero.global_position.distance_to(target.global_position)>hero.combat_range(105): return null
	if active_count>=LIMIT or not is_instance_valid(target) or target.hp<=0 or hero.bow_cooldown>0: return null
	if not Spell.line_clear(host,hero.global_position,target.global_position):
		host._show_toast("Uma construção bloqueia a flecha. Procure uma linha de visão livre.")
		return null
	var arrow = ValedouroCartoonArrowProjectile.new()
	arrow.host_ref = weakref(host)
	arrow.target_ref = weakref(target)
	if director != null: arrow.director_ref = weakref(director)
	arrow.damage = hero.hunting_damage(base_damage) if director != null else hero.attack_damage(base_damage)
	hero.bow_cooldown = 0.65
	hero.attack_t = 0.65
	hero.facing = (target.global_position-hero.global_position).normalized()
	host.add_child(arrow)
	arrow.global_position = hero.global_position+Vector2(0,-28)
	arrow.direction = hero.facing
	return arrow

func _ready() -> void:
	active_count += 1
	z_index = 8
	add_to_group("cartoon_arrows")
func _exit_tree() -> void: active_count -= 1
func _process(delta: float) -> void:
	var host = host_ref.get_ref()
	var target = target_ref.get_ref()
	if not is_instance_valid(host) or not is_instance_valid(target) or target.is_queued_for_deletion() or target.hp<=0:
		queue_free()
		return
	if host.hero.death_t>0 or (host.get("interiors") != null and host.interiors.active):
		queue_free()
		return
	if Spell.blocked(host): return
	age += delta
	var destination: Vector2 = target.global_position+Vector2(0,-28)
	var next: Vector2 = global_position.move_toward(destination,560*delta)
	direction = (destination-global_position).normalized()
	traveled += next.distance_to(global_position)
	if traveled>340 or age>1.0 or not Spell.line_clear(host,global_position+Vector2(0,28),next+Vector2(0,28)):
		queue_free()
		return
	global_position = next
	queue_redraw()
	if global_position.distance_to(destination)>5: return
	var hit: bool = false
	if director_ref != null:
		var director = director_ref.get_ref()
		if is_instance_valid(director) and director.active.has(target.slot_id):
			target.take_damage(damage)
			hit = true
	else: hit = host._damage_monster(target,damage)
	if hit: FX.spawn(host.objects,host.objects.to_local(global_position),"hit",direction,Color("ffeab8"))
	queue_free()
func _draw() -> void:
	var tail: Vector2 = -direction*22
	draw_line(tail-direction*12,tail,Color("e1bd73",0.3),3,true)
	draw_line(tail,Vector2.ZERO,Color("ffe4aa"),2,true)
	var normal: Vector2 = direction.orthogonal()
	draw_colored_polygon(PackedVector2Array([direction*5,-direction*3+normal*3,-direction*3-normal*3]),Color("eafaff"))
	draw_line(tail,tail-direction*4+normal*4,Color("69e8dd"),2,true)
	draw_line(tail,tail-direction*4-normal*4,Color("69e8dd"),2,true)
