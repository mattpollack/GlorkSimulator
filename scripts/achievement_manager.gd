extends Node3D

class_name AchievementManager 

@onready var upgrade_text_1 = $"../../UI/achievements/_/left/upgrade_text_1"
@onready var upgrade_text_2 = $"../../UI/achievements/_/left/upgrade_text_2"
@onready var upgrade_mass_1 = $"../../UI/achievements/_/right/upgrade_mass_1"
@onready var upgrade_mass_2 = $"../../UI/achievements/_/right/upgrade_mass_2"

@onready var player = $"../../spider"

var killed_units = {}

class Achievement:
	var text : String
	var mass : float
	var condition : Callable
	
	func _init(text, mass, condition):
		self.text = text
		self.mass = mass
		self.condition = condition
	
	func check() -> bool:
		return self.condition.call()

var achievements := [
	Achievement.new("Eat a citizen", 10, func():
		return killed_units.has("citizen") and killed_units["citizen"] >= 1),
	Achievement.new("All upgrades to level 2", 40, func():
		return player.speed_upgrade_count >= 1 and player.durability_upgrade_count >= 1 and player.tentacles_upgrade_count >= 1 and player.damage_upgrade_count >= 1),
	Achievement.new("Eat a tank", 15, func():
		return killed_units.has("tank") and killed_units["tank"] >= 1),
	Achievement.new("Eat a building", 20, func():
		return killed_units.has("building") and killed_units["building"] >= 1),
	Achievement.new("Eat ten citizens", 10, func():
		return killed_units.has("citizen") and killed_units["citizen"] >= 10),
	Achievement.new("Eat ten tanks", 100, func():
		return killed_units.has("tank") and killed_units["tank"] >= 10),
	Achievement.new("Eat ten buildings", 300, func():
		return killed_units.has("building") and killed_units["building"] >= 10),
	Achievement.new("All upgrades to level 6", 400, func():
		return player.speed_upgrade_count >= 5 and player.durability_upgrade_count >= 5 and player.tentacles_upgrade_count >= 5 and player.damage_upgrade_count >= 5),
	Achievement.new("Eat a jet", 200, func():
		return killed_units.has("jet") and killed_units["jet"] >= 1),
	Achievement.new("Eat one hundred buildings", 500, func():
		return killed_units.has("building") and killed_units["building"] >= 100),
	Achievement.new("Eat a satellite", 600, func():
		return killed_units.has("satellite") and killed_units["satellite"] >= 1),
	Achievement.new("Eat one thousand buildings", 1000, func():
		return killed_units.has("building") and killed_units["building"] >= 100),
	Achievement.new("Eat ten satellites", 1000, func():
		return killed_units.has("satellite") and killed_units["satellite"] >= 10),
	Achievement.new("All upgrades to level 15", 2000, func():
		return player.speed_upgrade_count >= 10 and player.durability_upgrade_count >= 10 and player.tentacles_upgrade_count >= 10 and player.damage_upgrade_count >= 10),
]

func killed(unit : String):
	if !killed_units.has(unit):
		killed_units[unit] = 0
	
	killed_units[unit] += 1

func _process(delta):
	if achievements.size() == 0:
		upgrade_text_1.text = ""
		upgrade_mass_1.text = ""
		upgrade_text_2.text = ""
		upgrade_mass_2.text = ""
	elif achievements.size() == 1:
		upgrade_text_1.text = achievements[0].text
		upgrade_mass_1.text = "$ %.0f" % achievements[0].mass
		upgrade_text_2.text = ""
		upgrade_mass_2.text = ""

		if achievements[0].check():
			player.mass += achievements[0].mass
			achievements.remove_at(0)
	else:
		upgrade_text_1.text = achievements[0].text
		upgrade_mass_1.text = "$ %.0f" % achievements[0].mass
		upgrade_text_2.text = achievements[1].text
		upgrade_mass_2.text = "$ %.0f" % achievements[1].mass
		
		
		
		if achievements[0].check():
			player.mass += achievements[0].mass
			achievements.remove_at(0)
		elif achievements[1].check():
			player.mass += achievements[1].mass
			achievements.remove_at(1)
