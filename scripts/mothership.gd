extends Node3D

class_name Mothership

@export var bullet_manager : BulletManager
@export var player : Spider

@onready var lasers = $mothership/lasers

var last_player_pos : Vector3 = Vector3.ZERO

func _process(delta):
	var change_in_pos = player.aim_at_me.global_position - last_player_pos
	last_player_pos= player.aim_at_me.global_position
	
	look_at(player.aim_at_me.global_position + change_in_pos)
	
	for c in lasers.get_children():
		bullet_manager.fire_laser((c.global_transform as Transform3D).looking_at(player.aim_at_me.global_position + change_in_pos))
