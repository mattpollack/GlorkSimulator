extends Node3D

@onready var jet_meshes := $jet_meshes

@export var player : Spider
@export var bullet_manager : BulletManager

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

func _process(delta):
	if dead:
		return
	
	rotate_object_local(Vector3.BACK, delta / 5)
	
	if jet_meshes.global_position.distance_to(player.global_position) < 1000:
		bullet_manager.fire((jet_meshes.global_transform as Transform3D).looking_at(player.aim_at_me.global_position))
