extends Node3D

class_name Tentacle

@onready var ik = $Armature/Skeleton3D/ik
@onready var target_ik : TentacleTargetIK = $Armature/target_ik
@onready var target_step : Marker3D = $Armature/target_step_container/target_step_cast/target_step
@onready var target_step_cast : TentacleTargetStep = $Armature/target_step_container/target_step_cast
@onready var target_step_container = $Armature/target_step_container

var prev_pos := Vector3.ZERO
var offset : float = 20.0

func _ready():
	prev_pos = self.global_position

func _process(delta):
	var velocity = self.global_position - prev_pos
	target_step_container.global_position = self.global_position + velocity * offset
	prev_pos = self.global_position
