extends RayCast3D

class_name TentacleTargetStep

@onready var target_step = $target_step

func _physics_process(delta):
	var hit_point := get_collision_point()

	if hit_point:
		target_step.global_position = hit_point
