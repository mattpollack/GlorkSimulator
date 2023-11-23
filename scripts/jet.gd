extends Node3D

@onready var jet_meshes := $jet_meshes

@export var player : Spider
@export var bullet_manager : BulletManager
@onready var shoot_sound = $shoot_sound
@onready var jet_sound = $jet_sound

var orbit = 350
var rad = 6000 + orbit
var angle = 0
var hp_max = 10
var hp = hp_max
var dead := false

func _ready():
	rotate_x(randf_range(0, PI * 2))
	rotate_y(randf_range(0, PI * 2))
	rotate_z(randf_range(0, PI * 2))
	global_position = Vector3(0, -6000, 0)
	jet_meshes.translate(Vector3(0, rad, 0))

var close := false

func _process(delta):
	if Utils.paused:
		return

	if dead:
		return
	
	rotate_object_local(Vector3.BACK, delta / 8)
	
	if jet_meshes.global_position.distance_to(player.global_position) < 1000:
		if !close:
			jet_sound.play()
			close = true
		bullet_manager.fire((jet_meshes.global_transform as Transform3D).looking_at(player.aim_at_me.global_position))
		shoot_sound.play()
	else:
		close = false
