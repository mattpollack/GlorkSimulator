extends Marker3D

class_name TentacleTargetIK

@onready var target_step : Marker3D = $"../target_step_container/target_step_cast/target_step"

@export var step_distance : float = 16
@export var speed_move : float = 6
@export var neighbour : TentacleTargetIK

var stepping := false
var should_step := true

func _ready():
	step()

func _process(delta):
	if Utils.paused:
		return
	
	if abs(global_position.distance_to(target_step.global_position)) > step_distance and (neighbour == null or neighbour.stepping == false) and should_step:
		step()

func step():
	stepping = true
	var target_pos = target_step.global_position
	var half_way = (global_position + target_step.global_position)/2
	var t = get_tree().create_tween()
	t.tween_property(self, "global_position", half_way, 0.1/speed_move)
	t.tween_property(self, "global_position", target_pos, 0.1/speed_move)
	t.finished.connect(func():
		stepping = false
		)

