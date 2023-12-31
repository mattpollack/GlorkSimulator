class_name Utils

static func basis_from_normal(normal : Vector3, transform : Transform3D, scale : Vector3) -> Basis:
	var result := Basis()
	result.x = normal.cross(transform.basis.z)
	result.y = normal
	result.z = transform.basis.x.cross(normal)
	
	result = result.orthonormalized()
	result.x *= scale.x
	result.y *= scale.y
	result.z *= scale.z
	
	return result

static var paused := false
static var game_over := false
static var game_win := false
static var tutorial := true
static var demo := true
static var played_a_game := false

static var muted := false
static var music_volume := 0
static var master_volume := 0
static var effect_volume := 0

