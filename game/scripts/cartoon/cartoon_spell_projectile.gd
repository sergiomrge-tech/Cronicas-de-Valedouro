class_name ValedouroCartoonSpellProjectile
extends Node2D
## Physical spell presentation; all monster damage stays in the region's reward/gate path.
const FX = preload("res://scripts/cartoon/cartoon_combat_fx.gd")
const COLORS = {"ember":Color("ff9a47"),"frost":Color("7feaff"),"arcane":Color("d5a1ff")}
static var active_count: int = 0
const LIMIT = 16
var host_ref: WeakRef
var target_epoch: int = 0
var target_ref: WeakRef
var director_ref: WeakRef
var spell_kind: String = "ember"
var damage: int = 1
var burn_damage: int = 1
var is_echo: bool = false
var phase: String = "flight"
var age: float = 0.0
var burn_time: float = 0.0
var burn_tick: float = 0.0
var ticks_left: int = 3
var effect
var chill_duration: float = 2.5
var echo_radius: float = 110.0

static func blocked(host) -> bool:
	if not is_instance_valid(host) or not host.is_inside_tree(): return true
	var layout = host.get_node_or_null("HUD/GameLayout")
	return layout != null and layout.is_blocked()

static func line_clear(host, from: Vector2, to: Vector2) -> bool:
	var environment = host.get("environment")
	if environment == null or not environment.has_method("blocks_spell"): return true
	var steps: int = maxi(1,ceili(from.distance_to(to)/12.0))
	for i in range(steps+1):
		if environment.blocks_spell(host.to_local(from.lerp(to,float(i)/steps))): return false
	return true

static func launch(host, hero, target: Node2D, base_damage: int, director = null):
	if active_count >= LIMIT or not is_instance_valid(target) or target.hp<=0: return null
	if not line_clear(host,hero.global_position,target.global_position):
		host._show_toast("O cenário bloqueia a magia. Procure uma linha de visão livre.")
		return null
	var shot = ValedouroCartoonSpellProjectile.new()
	shot.host_ref = weakref(host)
	shot.target_ref = weakref(target)
	shot.target_epoch = int(target.get_meta("spawn_epoch",0))
	if director != null: shot.director_ref = weakref(director)
	shot.spell_kind = hero.SPELLS[hero.spell_index]
	var equipped_damage: int = hero.magic_damage(base_damage,director != null)
	shot.damage = roundi(equipped_damage*(1.25 if shot.spell_kind=="arcane" else 1.0))
	var mastery: int = hero._skill("elements")
	shot.burn_damage = maxi(1,roundi(equipped_damage*(0.10+0.01*mastery)))
	shot.chill_duration = 2.5+0.1*mastery
	shot.echo_radius = 110.0+5*mastery
	host.add_child(shot)
	shot.global_position = hero.global_position+Vector2(0,-28)
	return shot

func _ready() -> void:
	active_count += 1
	add_to_group("cartoon_spell_projectiles")
	z_index = 4
	effect = FX.spawn(self,Vector2.ZERO,spell_kind,Vector2.RIGHT,COLORS[spell_kind])
	if effect != null:
		effect.travel_visual = false
		effect.lifetime = 1.4

func _exit_tree() -> void:
	active_count -= 1
	var target = target_ref.get_ref() if target_ref != null else null
	if is_instance_valid(target) and target.has_meta("valedouro_burn"):
		var owner_ref = target.get_meta("valedouro_burn")
		if owner_ref.get_ref()==self:
			target.burn_t = 0.0
			target.remove_meta("valedouro_burn")

func alive(target) -> bool:
	return is_instance_valid(target) and not target.is_queued_for_deletion() and target.hp>0

func cancel() -> void:
	if not is_queued_for_deletion(): queue_free()

func _process(delta: float) -> void:
	if is_queued_for_deletion(): return
	var host = host_ref.get_ref()
	var target = target_ref.get_ref()
	if not is_instance_valid(host) or not alive(target) or int(target.get_meta("spawn_epoch",0))!=target_epoch:
		cancel()
		return
	if host.get("interiors") != null and host.interiors.active:
		cancel()
		return
	if host.hero.death_t>0:
		cancel()
		return
	if blocked(host):
		if is_instance_valid(effect): effect.set_process(false)
		return
	if is_instance_valid(effect): effect.set_process(true)
	age += delta
	if phase=="burn":
		burn_time = maxf(0,burn_time-delta)
		target.burn_t = burn_time
		burn_tick += delta
		while burn_tick+0.000001>=0.6 and ticks_left>0 and alive(target):
			burn_tick = maxf(0,burn_tick-0.6)
			ticks_left -= 1
			if not apply_hit(host,target,burn_damage):
				cancel()
				return
		if ticks_left==0 or burn_time<=0 or not alive(target): cancel()
		return
	if age>1.4:
		cancel()
		return
	var destination: Vector2 = target.global_position+Vector2(0,-28)
	var next: Vector2 = global_position.move_toward(destination,420.0*delta)
	if not line_clear(host,global_position+Vector2(0,28),next+Vector2(0,28)):
		FX.spawn(host.objects,host.objects.to_local(global_position),"hit",Vector2.UP,COLORS[spell_kind])
		cancel()
		return
	if is_instance_valid(effect): effect.direction = (destination-global_position).normalized()
	global_position = next
	queue_redraw()
	if global_position.distance_to(destination)>5: return
	if not apply_hit(host,target,damage):
		cancel()
		return
	FX.spawn(host.objects,host.objects.to_local(global_position),"impact_"+spell_kind,Vector2.UP,COLORS[spell_kind])
	if spell_kind=="frost" and alive(target): target.apply_chill(chill_duration)
	elif spell_kind=="ember" and alive(target):
		if target.has_meta("valedouro_burn"):
			var previous = target.get_meta("valedouro_burn").get_ref()
			if is_instance_valid(previous): previous.cancel()
		target.set_meta("valedouro_burn",weakref(self))
		phase = "burn"
		burn_time = 1.8
		burn_tick = 0
		target.burn_t = burn_time
		if is_instance_valid(effect): effect.queue_free()
		return
	elif spell_kind=="arcane" and not is_echo: launch_echo(host,target)
	cancel()

func apply_hit(host, target, amount: int) -> bool:
	if director_ref != null:
		var director = director_ref.get_ref()
		if not is_instance_valid(director) or not director.active.has(target.slot_id): return false
		target.take_damage(amount)
		return true
	return host._damage_monster(target,amount)

func launch_echo(host, original) -> void:
	if active_count>=LIMIT: return
	var nearest = null
	var radius: float = echo_radius
	for candidate in host.monsters:
		if candidate==original or not alive(candidate): continue
		var d: float = candidate.global_position.distance_to(global_position+Vector2(0,28))
		if d<radius and host._can_damage_monster(candidate,false) and line_clear(host,global_position+Vector2(0,28),candidate.global_position):
			nearest = candidate
			radius = d
	if nearest == null: return
	var echo = ValedouroCartoonSpellProjectile.new()
	echo.host_ref = weakref(host)
	echo.target_ref = weakref(nearest)
	echo.target_epoch = int(nearest.get_meta("spawn_epoch",0))
	echo.spell_kind = "arcane"
	echo.damage = maxi(1,roundi(damage*0.5))
	echo.is_echo = true
	host.add_child(echo)
	echo.global_position = global_position

func _draw() -> void:
	if phase!="flight": return
	var radius: float = 5 if is_echo else 7
	draw_circle(Vector2.ZERO,radius,COLORS[spell_kind])
	draw_circle(Vector2.ZERO,radius*0.45,Color.WHITE)
