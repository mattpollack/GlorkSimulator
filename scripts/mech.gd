extends Node3D

class_name Mech

@export var player : Spider
@export var bullet_manager : BulletManager

@onready var fire_l = $"arm-lower-l/fire-l"
@onready var fire_r = $"arm-lower-r/fire-r"

@onready var chamber_l = $"mech/Armature/Skeleton3D/gun-chamber-left/gun-chamber-left"
@onready var chamber_r = $"mech/Armature/Skeleton3D/gun-chamber-right/gun-chamber-right"

func _process(delta):
	bullet_manager.fire((fire_l.global_transform as Transform3D).scaled_local(Vector3(1.0/4.0, 1.0/4.0, 1.0/4.0)).rotated_local(Vector3.MODEL_LEFT, PI/2))
	bullet_manager.fire((fire_r.global_transform as Transform3D).scaled_local(Vector3(1.0/4.0, 1.0/4.0, 1.0/4.0)).rotated_local(Vector3.MODEL_LEFT, PI/2))
	
	chamber_l.rotation.z += delta
	chamber_r.rotation.z -= delta
