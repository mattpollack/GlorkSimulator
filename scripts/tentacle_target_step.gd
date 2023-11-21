extends RayCast3D

class_name TentacleTargetStep

@onready var target_step = $target_step
@onready var target_step_under_cast : RayCast3D = $"../target_step_under_cast"

func _physics_process(delta):
	if Utils.paused:
		return
	
	var point_top := get_collision_point()
	var point_under := target_step_under_cast.get_collision_point()

	if is_colliding():
		target_step.global_position = point_top
	elif target_step_under_cast.is_colliding():
		target_step.global_position = point_under
		
