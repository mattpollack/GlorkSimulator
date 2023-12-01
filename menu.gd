extends Node3D

@onready var skeleton_ik_3d_1 = $player/tentacle/Armature/Skeleton3D/SkeletonIK3D
@onready var skeleton_ik_3d_2 = $player/tentacle2/Armature/Skeleton3D/SkeletonIK3D
@onready var skeleton_ik_3d_3 = $player/tentacle3/Armature/Skeleton3D/SkeletonIK3D
@onready var skeleton_ik_3d_4 = $player/tentacle4/Armature/Skeleton3D/SkeletonIK3D
@onready var cam_anchor = $cam_anchor
@onready var demo_toggle : CheckBox = $Control/VBoxContainer2/CheckBox

func _ready():
	skeleton_ik_3d_1.start()
	skeleton_ik_3d_2.start()
	skeleton_ik_3d_3.start()
	skeleton_ik_3d_4.start()
	
	demo_toggle.set_pressed_no_signal(Utils.demo)

func _process(delta):
	cam_anchor.rotate_y(delta/8)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://game.tscn")

func _on_demo_mode_toggle(state : bool):
	Utils.demo = state
	print(Utils.demo)
