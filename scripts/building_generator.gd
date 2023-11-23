extends Node3D

class_name BuildingGenerator

@export var player : Spider

var mesh_map := {
	"road": preload("res://raw/meshes/buildings/road.res"),
	"building-0": preload("res://raw/meshes/buildings/building-3.res"),
	"building-1": preload("res://raw/meshes/buildings/building-4.res"),
	"building-2": preload("res://raw/meshes/buildings/building-5.res"),
	"building-3": preload("res://raw/meshes/buildings/building-8.res"),
	"building-4": preload("res://raw/meshes/buildings/building-6.res"),
	"building-5": preload("res://raw/meshes/buildings/building-7.res")
}

var multi_mesh_map := {}

func _ready():
	for k in mesh_map.keys():
		var mesh : ArrayMesh = mesh_map[k]
		var multi_mesh := MultiMeshInstance3D.new()
		multi_mesh.multimesh = MultiMesh.new()
		multi_mesh.multimesh.mesh = mesh
		multi_mesh.multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multi_mesh.multimesh.use_custom_data = true
		multi_mesh_map[k] = multi_mesh
		add_child(multi_mesh)
	
	_build()

class BuildingTemplate:
	var t : Transform3D
	var kind : String
	var neighbour_weight : float
	
	func _init(t : Transform3D, neighbour_weight : float):
		self.t = t
		self.neighbour_weight = neighbour_weight

func _build():
	var seed = 2
	var radius = 5980
	var rg := RandomNumberGenerator.new()
	rg.seed = seed
	
	var hotspots : Array[Vector3] = []
	
	# Generate "hotspots" by placing points near all 8 vertices of a cube on the surface of the planet 
	for i in range(16):
		var base_offset = rg.randf_range(PI/4, PI/2)
		
		for j in range(16):
			var as_1 = i*PI*2/4 + rg.randf_range(PI/8, PI/4)
			var as_2 = j*PI*2/4 + rg.randf_range(PI/8, PI/4)
			var ae_1 = (i-1)*PI*2/4 - rg.randf_range(PI/8, PI/4)
			var ae_2 = (j-1)*PI*2/4 - rg.randf_range(PI/8, PI/4)
			
			var angle_1 = (as_1 + ae_1)/2 + base_offset
			var angle_2 = (as_2 + ae_2)/2 + base_offset
		
			var x = radius * cos(angle_1) * cos(angle_2)
			var y = radius * cos(angle_1) * sin(angle_2)
			var z = radius * sin(angle_1)
			
			hotspots.append(Vector3(x, y, z))
	
	# Prep building generation
	var num_objects = 20000
	var offset = 2.0 / num_objects
	var increment = PI * (3.0 - sqrt(5.0))
	var buildings : Array[BuildingTemplate] = []
	var neighbour_weight_min : float = INF
	var neighbour_weight_max : float = 0
	
	# Calculate the desired building transforms and include them if they are close enough to hotspots
	for i in range(num_objects):
		var y = ((i * offset) - 1) + (offset / 2)
		var r = sqrt(1 - pow(y, 2))
		var phi = i * increment
		var x = cos(phi) * r
		var z = sin(phi) * r
		var pos = Vector3(x, y, z) * radius
		var rotation_dir = Vector3.UP.cross(pos.normalized()).normalized()
		var angle = acos(Vector3.UP.dot(pos.normalized()))
		var t = Transform3D(Basis.IDENTITY, pos).rotated_local(rotation_dir, angle)
		var rand_range = rg.randi_range(300, 700)
		var skip = true
		var neighbour_weight = 0
		
		for h in hotspots:
			var dist = h.distance_to(pos)
			
			if dist < rand_range * 2:
				neighbour_weight += 1
			
			if dist < rand_range:
				skip = false
		
		if !skip:
			neighbour_weight_min = min(neighbour_weight_min, neighbour_weight)
			neighbour_weight_max = max(neighbour_weight_max, neighbour_weight)
			buildings.append(BuildingTemplate.new(t, neighbour_weight))
	
	# Pre calculate instance counts for multi meshing
	var instance_counts := {}
	
	for b in buildings:
		# Pick a building type based on how hot is it
		b.neighbour_weight = (b.neighbour_weight - neighbour_weight_min) / (neighbour_weight_max - neighbour_weight_min)
		b.kind = "building-%d" % clamp(mesh_map.size() - 1 - round(b.neighbour_weight * mesh_map.size()), 0, mesh_map.size() - 2) 
		
		if !instance_counts.has(b.kind):
			instance_counts[b.kind] = 0
		
		instance_counts[b.kind] += 1

	# Set the instance counts and counters
	var instance_is := {}
	
	for k in instance_counts.keys():
		instance_is[k] = 0
		var mm = multi_mesh_map[k] as MultiMeshInstance3D
		mm.multimesh.instance_count = instance_counts[k]
	
	# Instance the pre calculated buildings
	for b in buildings:
		var mm = multi_mesh_map[b.kind] as MultiMeshInstance3D
		var shape = mm.multimesh.mesh.create_trimesh_shape()

		mm.multimesh.set_instance_transform(instance_is[b.kind], b.t)

		var collision_shape := CollisionShape3D.new()
		collision_shape.shape = shape

		var static_body := Building.new()
		static_body.transform = b.t
		static_body.add_child(collision_shape)
		static_body.add_to_group("enemy")
		static_body.mm = mm
		static_body.i = instance_is[b.kind]
		static_body.player = player

		add_child(static_body)
		
		instance_is[b.kind] += 1

