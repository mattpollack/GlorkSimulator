extends Node3D

@onready var upgrade_hud = $UI/upgrade_hud
@onready var player : Spider = $spider

var show_upgrades := false
var upgrade_tentacle_count := 1
var upgrade_speed_count := 1
var upgrade_durability_count := 1

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(e : InputEvent):
	if e.is_action_pressed("upgrade_menu"):
		show_upgrades = true
	
	if e.is_action_released("upgrade_menu"):
		show_upgrades = false

func _process(delta):
	if show_upgrades:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		upgrade_hud.show()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		upgrade_hud.hide()
	
	$UI/_/health_parent/health_container/mass_text.text = "$ %d / $ %d" % [player.mass, 15000]

func _on_upgrade_tentacles_gui_input(e : InputEvent):
	var price = 10 * pow(upgrade_tentacle_count, 3)
	var price_new = 10 * pow(upgrade_tentacle_count + 1, 3)
	
	if e.is_action_pressed("click"):
		if player.upgrade_tentacles(price):
			upgrade_tentacle_count += 1
			$UI/upgrade_hud/_/_/_/upgrade_tentacles/bg/quantity.text = "%d" % upgrade_tentacle_count
			$UI/upgrade_hud/_/_/_/upgrade_tentacles/price.text = "$ %d" % price_new

func _on_upgrade_speed_gui_input(e : InputEvent):
	var price = 10 * pow(upgrade_speed_count, 3)
	var price_new = 10 * pow(upgrade_speed_count + 1, 3)
	
	if e.is_action_pressed("click"):
		if player.upgrade_speed(price):
			upgrade_speed_count += 1
			$UI/upgrade_hud/_/_/_/upgrade_speed/bg/quantity.text = "%d" % upgrade_speed_count
			$UI/upgrade_hud/_/_/_/upgrade_speed/price.text = "$ %d" % price_new

func _on_upgrade_durability_gui_input(e : InputEvent):
	var price = 10 * pow(upgrade_durability_count, 3)
	var price_new = 10 * pow(upgrade_durability_count + 1, 3)
	
	if e.is_action_pressed("click"):
		if player.upgrade_durability(price):
			upgrade_durability_count += 1
			$UI/upgrade_hud/_/_/_/upgrade_durability/bg/quantity.text = "%d" % upgrade_durability_count
			$UI/upgrade_hud/_/_/_/upgrade_durability/price.text = "$ %d" % price_new
