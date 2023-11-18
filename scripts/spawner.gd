extends Node3D

class_name Spawner

@export var player : Spider
@export var bullet_manager : BulletManager

var rg : RandomNumberGenerator
var mass_max_threat : float = 10000
var mass_winning : float = 15000
var threat : float = 40
var unit_spawn_dict = {}

enum SpawnKind { GROUND, AIR }

class MilitaryUnit:
	var scene : PackedScene
	var spawn : Callable # calculates the spawn rate based on a passed threat level
	var spawn_kind : SpawnKind
	var spawn_max : int
	
	func _init(scene : PackedScene, spawn : Callable, spawn_kind : SpawnKind, spawn_max : int):
		self.scene = scene
		self.spawn = spawn
		self.spawn_kind = spawn_kind
		self.spawn_max = spawn_max # TODO
	
	func should_spawn(threat : float, last_spawn : float) -> bool:
		return self.spawn.call(threat, last_spawn)

var unit_dict = {
	"person" = MilitaryUnit.new(
		preload("res://scenes/person_1.tscn"),
		func(threat : float, last_spawn : float) -> bool:
			return last_spawn >= 0.01 and threat < 1000
			,
		SpawnKind.GROUND,
		200,
	),
	"tank" = MilitaryUnit.new(
		preload("res://scenes/tank.tscn"),
		func(threat : float, last_spawn : float) -> bool:
			return threat >= 50 and last_spawn >= 4
			,
		SpawnKind.GROUND,
		200,
	),
	"jet" = MilitaryUnit.new(
		preload("res://scenes/jet.tscn"),
		func(threat : float, last_spawn : float) -> bool:
			return threat >= 100 and last_spawn >=  clamp(5 - threat * 500/15000 + 1, 5, 20)
			,
		SpawnKind.AIR,
		200,
	),
	"satellite" = MilitaryUnit.new(
		preload("res://scenes/satellite.tscn"),
		func(threat : float, last_spawn : float) -> bool:
			return threat >= 1000 and last_spawn >= clamp(15 - threat * 150/15000 + 1, 5, 30)
			,
		SpawnKind.AIR,
		200,
	),
	"bomb" = MilitaryUnit.new(
		preload("res://scenes/bomb.tscn"),
		func(threat : float, last_spawn : float) -> bool:
			return threat >= 2000 and (last_spawn >= 10 or (threat >= 6000 and last_spawn >= 2))
			,
		SpawnKind.AIR,
		200,
	),
}

func _ready():
	rg = RandomNumberGenerator.new()
	rg.seed = 2
	
	for k in unit_dict:
		unit_spawn_dict[k] = 0.0
	
	for i in range(30):
		_spawn(unit_dict["person"])

func _process(delta):
	threat = max(threat, player.mass)

	for k in unit_spawn_dict:
		unit_spawn_dict[k] += delta
		
		if unit_dict[k].should_spawn(threat, unit_spawn_dict[k]):
			unit_spawn_dict[k] = 0
			
			_spawn(unit_dict[k])

func _spawn(unit : MilitaryUnit):
	var unit_node = unit.scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	unit_node.player = player
	unit_node.bullet_manager = bullet_manager
	add_child(unit_node)
	
	if unit.spawn_kind == SpawnKind.GROUND:
		unit_node.global_transform = player.global_transform.rotated_local(Vector3.UP, rg.randf_range(0, 2*PI)).translated_local(Vector3(rg.randf_range(player.width() + 50, player.width() + 100), 0, 0))
		unit_node.global_position = (unit_node.global_position as Vector3).move_toward(Vector3(0, -6000, 0), unit_node.global_position.distance_to(Vector3(0, -6000, 0)) - 5985)
