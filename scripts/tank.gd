extends CharacterBody3D

class_name Tank

@export var player : Spider
@export var bullet_manager : BulletManager

@onready var back_wheels : MeshInstance3D = $"back-wheels"
@onready var front_wheels : MeshInstance3D = $"front-wheels"
@onready var gun : MeshInstance3D = $gun
@onready var chassis : MeshInstance3D = $chassis
@onready var muzzle = $gun/bullet_start/muzzle
@onready var bullet_start = $gun/bullet_start
@onready var main_collision = $main_collision
@onready var attack_collision = $Area3D/attack_collision

var fire_rate = 0.25
var fire_d = 0
var dead := false
var mass = 5
var hp_max := 10
var hp := hp_max

func _shoot():
	muzzle.restart()
	muzzle.emitting = true
	bullet_manager.fire(bullet_start.global_transform)

func _process(delta):
	if dead:
		return

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
	
	if hp <= 0 and !dead:
		main_collision.queue_free()
		attack_collision.queue_free()
		if node != null and node.get("caught_objects") != null:
			reparent(node.caught_objects)
		dead = true

