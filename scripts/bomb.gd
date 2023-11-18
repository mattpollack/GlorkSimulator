extends Node3D

class_name Bomb

@export var player : Spider 
@export var bullet_manager : BulletManager

@onready var decal = $decal
@onready var explosion : Explosion = $explosion
@onready var timer = $Timer
@onready var bomb = $bomb_align/bomb
@onready var aftermath = $aftermath
@onready var area_3d = $Area3D

var collided = {}
var target := Vector3(0, 0, 0)
var height := 500
var exploded := false
var delay := 10

func _ready():
	# drop on the player
	self.global_transform = player.global_transform.translated_local(Vector3(0, -1, 0) * (player.global_position.distance_to(Vector3(0, -6000, 0)) - 6000))
	
	decal.scale = Vector3(2, 2, 2)
	timer.wait_time = delay
	timer.start()
	timer.timeout.connect(explode)
	bomb.translate(Vector3(0, 0, -height))
	aftermath.hide()

func explode():
	decal.hide()
	bomb.hide()
	explosion.explode()
	aftermath.show()
	exploded = true
	
	for n in collided:
		if n.get("hit") != null:
			n.get("hit").call(self, 40000.0)

func _physics_process(delta):
	if !exploded:
		decal.rotate_object_local(Vector3.UP, delta)
		decal.scale *= 1 - delta/delay
		bomb.translate(Vector3(0, 0, 1) * (height/delay) * delta)

func _on_area_3d_area_entered(node):
	collided[node] = true

func _on_area_3d_body_entered(node):
	collided[node] = true

func _on_area_3d_area_exited(node):
	collided.erase(node)

func _on_area_3d_body_exited(node):
	collided.erase(node)
