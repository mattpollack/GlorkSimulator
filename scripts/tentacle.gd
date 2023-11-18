extends Node3D

class_name Tentacle

@export var player : Spider

@onready var ik = $Armature/Skeleton3D/ik
@onready var target_ik : TentacleTargetIK = $Armature/target_ik
@onready var target_step : Marker3D = $Armature/target_step_container/target_step_cast/target_step
@onready var target_step_cast : TentacleTargetStep = $Armature/target_step_container/target_step_cast
@onready var target_step_container = $Armature/target_step_container
@onready var target_step_under_cast = $Armature/target_step_container/target_step_under_cast
@onready var tentacle_tip_shape : CollisionShape3D = $Armature/target_ik/Area3D/tentacle_tip_shape
@onready var tentacle_end = $Armature/Skeleton3D/tentacle_end
@onready var caught_objects = $Armature/Skeleton3D/tentacle_end/attack_place/caught_objects
@onready var attack_place_shape = $Armature/Skeleton3D/tentacle_end/attack_place/attack_place_shape
@onready var attack_place = $Armature/Skeleton3D/tentacle_end/attack_place

var prev_pos := Vector3.ZERO
var offset : float = 20.0
var should_step := true
var should_attack := false
var attack_target : Node3D 
var attack_state := "in"
var attack_speed := 60

func _ready():
	prev_pos = self.global_position

func _set_target(attack_target : Node3D):
	self.attack_target = attack_target
	self.attack_state = "in"

func _process(delta):
	target_ik.should_step = should_step
	attack_place.should_attack = should_attack

	var velocity = self.global_position - prev_pos
	prev_pos = self.global_position
	
	if should_step:
		target_step_container.global_position = self.global_position + velocity * offset
	elif should_attack and attack_target != null:
		target_ik.global_position += velocity
		
		match attack_state:
			"out":
				if target_ik.global_position.distance_to(attack_target.global_position) < delta * attack_speed or tentacle_end.global_position.distance_to(target_ik.global_position) > delta * attack_speed:
					attack_state = "in"
					attack_target.hit(self, player.damage)
				else:
					target_ik.global_position -= (target_ik.global_position - attack_target.global_position).normalized() * delta * attack_speed
			"in":
				if target_ik.global_position.distance_to(self.global_position) < delta * attack_speed:
					attack_state = "out"
					attack_target = null
					
					for n in caught_objects.get_children():
						player.killed(n)
						n.queue_free()
				else:
					target_ik.global_position -= (target_ik.global_position - self.global_position).normalized() * delta * attack_speed
	else:
		for n in caught_objects.get_children():
			player.killed(n)
			n.queue_free()
		
		target_step_container.global_position = self.global_position
		target_ik.global_position = lerp(target_ik.global_position, target_step_container.global_position, delta * 10)
