extends Node3D

@onready var satellite_meshes = $satellite_meshes

@export var player : Spider
@export var bullet_manager : BulletManager
@onready var laser_sound = $laser_sound

var orbit = 1000
var rad = 6000 + orbit
var angle = 0
var hp_max = 100
var hp = hp_max
var dead := false
func _ready():
	rotate_x(randf_range(0, PI * 2))
	rotate_y(randf_range(0, PI * 2))
	rotate_z(randf_range(0, PI * 2))
	global_position = Vector3(0, -6000, 0)
	satellite_meshes.translate(Vector3(0, rad, 0))
	laser_sound.pitch_scale += randf_range(0, 0.2)

func _process(delta):
	if Utils.paused:
		return

	if dead:
		return
	
	rotate_object_local(Vector3.BACK, delta / 20)
	
	if satellite_meshes.global_position.distance_to(player.global_position) < 6000 + player.width():
		laser_sound.playing = true
		bullet_manager.fire_laser((satellite_meshes.global_transform as Transform3D).looking_at(player.aim_at_me.global_position))
