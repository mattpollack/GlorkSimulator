extends Sprite3D

class_name HpBar

@onready var sub_viewport = $SubViewport
@onready var progress_bar = $SubViewport/ProgressBar

func _process(delta):
	self.texture = sub_viewport.get_texture()

func set_hp(v : float):
	progress_bar.value = v
