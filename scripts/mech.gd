extends Node3D

class_name Mech

@export var player : Spider
@export var bullet_manager : BulletManager
@export var achievement_manager : AchievementManager

@onready var fire_l = $"arm-lower-l/fire-l"
@onready var fire_r = $"arm-lower-r/fire-r"
@onready var chamber_l = $"mech/Armature/Skeleton3D/gun-chamber-left/gun-chamber-left"
@onready var chamber_r = $"mech/Armature/Skeleton3D/gun-chamber-right/gun-chamber-right"
@onready var animation_tree = $AnimationTree
@onready var shoot_sound = $shoot_sound

var dead := false
var max_hp := 100
var hp := max_hp

func _process(delta):
	if dead or Utils.paused:
		return
	
	look_at((player.aim_at_me.global_position - Vector3(0, 6000, 0)).normalized() * (global_position - Vector3(0, 6000, 0)).length(), Vector3.UP)
	rotate_object_local(Vector3.RIGHT, PI/2)
	
	if global_position.distance_to(player.global_position) < 400 + player.width():
		bullet_manager.fire((fire_l.global_transform as Transform3D).scaled_local(Vector3(1.0/4.0, 1.0/4.0, 1.0/4.0)).rotated_local(Vector3.MODEL_LEFT, PI/2).looking_at(player.aim_at_me.global_position))
		bullet_manager.fire((fire_r.global_transform as Transform3D).scaled_local(Vector3(1.0/4.0, 1.0/4.0, 1.0/4.0)).rotated_local(Vector3.MODEL_LEFT, PI/2).looking_at(player.aim_at_me.global_position))
		shoot_sound.play()
	
		chamber_l.rotation.z += delta
		chamber_r.rotation.z -= delta
		
		animation_tree.set("parameters/conditions/shoot", true)
		animation_tree.set("parameters/conditions/run", false)
		animation_tree.set("parameters/conditions/idle", false)
	else:
		translate_object_local(Vector3.FORWARD * delta * 32)
		global_position = global_position.move_toward(Vector3(0, -6000, 0), global_position.distance_to(Vector3(0, -6000, 0)) - 5984)
		animation_tree.set("parameters/conditions/shoot", false)
		animation_tree.set("parameters/conditions/run", true)
		animation_tree.set("parameters/conditions/idle", false)
