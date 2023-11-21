extends Node3D

@onready var gpu_particles_3d = $GPUParticles3D
@onready var bullet = $bullet

var start_pos : Vector3

func _ready():
	start_pos = global_position

func _process(delta):
	if Utils.paused:
		return

	translate(Vector3.FORWARD * delta * 500)
	
	if start_pos.distance_to(global_position) > 600:
		queue_free()

func _on_static_body_3d_area_entered(area):
	gpu_particles_3d.global_position = global_position
	gpu_particles_3d.restart()
	gpu_particles_3d.emitting = true
	bullet.hide()

func _on_static_body_3d_body_entered(body):
	gpu_particles_3d.global_position = global_position
	gpu_particles_3d.restart()
	gpu_particles_3d.emitting = true
	bullet.hide()
