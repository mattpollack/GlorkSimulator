extends CharacterBody3D

class_name Tank

@export var player : Spider
@export var bullet_manager : BulletManager
@export var achievement_manager : AchievementManager

@onready var back_wheels : MeshInstance3D = $"tank/back-wheels"
@onready var front_wheels : MeshInstance3D = $"tank/front-wheels"
@onready var gun : MeshInstance3D = $"tank/gun"
@onready var chassis : MeshInstance3D = $"tank/chassis"
@onready var muzzle = $tank/gun/bullet_start/muzzle
@onready var bullet_start = $tank/gun/bullet_start
@onready var main_collision = $main_collision
@onready var attack_collision = $Area3D/attack_collision
@onready var shoot_sound = $tank/gun/bullet_start/shoot_sound

var fire_rate = 0.25
var fire_d = 0
var dead := false
var mass = 5
var hp_max := 10
var hp := hp_max
var last_hit_frames : float = 100

func _ready():
	chassis.get_surface_override_material(0).next_pass.set_shader_parameter("hit_fade", 0)

func _shoot():
	muzzle.restart()
	muzzle.emitting = true
	bullet_manager.fire(bullet_start.global_transform)
	shoot_sound.play()

func _process(delta):
	if Utils.paused:
		return
	
	if dead:
		return
	
	last_hit_frames += delta
	
	if last_hit_frames <= 2.0:
		chassis.get_surface_override_material(0).next_pass.set_shader_parameter("hit_fade", 1 - clampf(last_hit_frames * 4, 0.0, 1.0))

	fire_d += delta
	
	if fire_d > fire_rate:
		fire_d = 0
		_shoot()
	
	gun.look_at(player.aim_at_me.global_position)
	
	var target = player.global_position
	target *= 6000 / target.distance_to(Vector3(0, -6000, 0))

	# Within firing range
	if global_position.distance_to(target) > 100 and global_position.distance_to(target) < 500:
		# TODO: This is fine but causes the piling issue  ?
		var rot = rotation
		look_at(target, Vector3.UP)
		var rot_at = rotation
		rotation = lerp(rot, rot_at, delta)
		translate_object_local(Vector3.FORWARD * delta * 20)
	
	var gravity = (Vector3(0, -6000, 0) - global_position).normalized() * 9.81 * delta
	
	if !is_on_floor():
		velocity += gravity
	
	move_and_slide()

func hit(node : Node3D, dmg_base : float = 1.0):
	hp -= dmg_base
	last_hit_frames = 0
	if hp <= 0 and !dead:
		achievement_manager.killed("tank")
		chassis.get_surface_override_material(0).next_pass.set_shader_parameter("hit_fade", 1)
		main_collision.queue_free()
		attack_collision.queue_free()
		if node != null and node.get("caught_objects") != null:
			reparent(node.caught_objects)
		dead = true

