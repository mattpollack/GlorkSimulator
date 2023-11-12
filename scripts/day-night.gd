extends DirectionalLight3D

var rad = 50000
var angle : float = 0

func _process(delta):
	angle += delta / 10

	var x = sin(angle) * rad
	var y = cos(angle) * rad
	
	global_position = Vector3(x, y, 0)
	look_at(Vector3.ZERO)
