extends Node3D

@onready var upgrade_hud = $UI/upgrade_hud
@onready var player : Spider = $spider

@onready var news_audio = $news_audio
@onready var news_timer = $news_timer
@onready var news_hud = $UI/bottom_hud/news_hud
@onready var news_body = $UI/bottom_hud/news_hud/Control/Panel/news_body
@onready var bottom_hud = $UI/bottom_hud
@onready var theme = $theme
@onready var pause_menu = $UI/pause_menu
@onready var tutorial_nodes = $UI/tutorial
@onready var tutorial_text = $UI/tutorial/dialog/_/_2/tutorial_text
@onready var game_over = $UI/game_over
@onready var win_menu = $UI/win_menu

var show_upgrades := false
var upgrade_tentacle_count := 1
var upgrade_speed_count := 1
var upgrade_durability_count := 1
var upgrade_damage_count := 1
var bottom_hud_initial_pos : Vector2
var news_playing := false
var play_tutorial := true

var news = {
	12 : "ALIEN SPOTTED IN DOWNTOWN WITH BIG EYES... CUTE BUT DEADLY!",
	50 : "TANKS DEPLOYED... STAY INSIDE AND LOCK YOUR DOORS!",
	200 : "JETS IN AIR... SURELY THE ALIEN WON'T GROW MUCH BIGGER!",
	1000 : "NASA DEPLOYS EXPERIMENTAL LASER SATELLITES!",
	2000 : "UN CALLS ON NATIONS WITH NUCLEAR WEAPONS!",
	5000 : "TOTAL CHAOS... NUCLEAR WEAPONS FIRE AT WILL!",
	10000 : "ALIEN CAUSING INTENSE GRAVITATIONAL EFFECTS ON PLANET!",
}

var news_i = 0

var tutorial = [
	"Welcome to glork simulator!",
	"The goal of the game is to consume everything until you're big enough to eat the whole planet!",
	"W,A,S,D to move and mouse to look around. You'll automatically eat close by targets, so move towards them!",
	"As you consume you get mass, which acts as your money, size, and health.",
	"The game is over once you hit 15k!", 
	"Over here are achievements, which give you boosts of mass. You should do these!",
	"Press and hold E to open the upgrade menu, and click on icons to buy.",
	"Quantity gives you more tentacles for eating.",
	"Speed makes you move and eat faster.",
	"Durability reduces incoming damage to your mass.",
	"Damage increases the damage you deal to enemies.",
	"Be sure to not spend too much, otherwise you'll have low health!",
	"Thanks for playing!"
]

var tutorial_i := 0

func _on_tutorial_next_pressed():
	tutorial_i += 1
	
	if tutorial_i >= tutorial.size():
		play_tutorial = false
		Utils.paused = false
		tutorial_nodes.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		return
	
	if tutorial_i >= 6 and tutorial_i <= 11:
		upgrade_hud.show()
	else:
		upgrade_hud.hide()
	
	tutorial_text.text = tutorial[tutorial_i]
	
	for c in tutorial_nodes.get_children():
		if c.name == str(tutorial_i) or c.name == "dialog":
			c.show()
		else:
			c.hide()

func _ready():
	play_tutorial = Utils.tutorial
	
	news_timer.timeout.connect(func():
		news_hud.hide()
		news_playing = false)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	bottom_hud_initial_pos = bottom_hud.global_position
	news_hud.hide()
	pause_menu.hide()
	upgrade_hud.hide()
	bottom_hud.hide()
	tutorial_nodes.hide()
	game_over.hide()

func _input(e : InputEvent):
	if e.is_action_pressed("pause"):
		Utils.paused = !Utils.paused
		
		if Utils.paused:
			pause_menu.show()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			pause_menu.hide()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif e.is_action_pressed("upgrade_menu"):
		show_upgrades = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif e.is_action_released("upgrade_menu"):
		show_upgrades = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _play_news():
	bottom_hud.show()
	news_playing = true
	bottom_hud.position = Vector2(bottom_hud_initial_pos.x + 5000, bottom_hud_initial_pos.y)
	news_hud.show()
	news_timer.start()
	news_audio.play()
	news_body.text = news[news.keys()[news_i]]
	news_i += 1

var tutorial_delay : float = 0

func _process(delta):
	if Utils.game_over:
		Utils.paused = true
		game_over.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Utils.game_win:
		win_menu.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if play_tutorial and tutorial_i < tutorial.size() and tutorial_delay >= 0.35:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Utils.paused = true
		tutorial_nodes.show()
		return

	# need to add a delay for some reason
	tutorial_delay += delta
	
	if news_playing:
		AudioServer.set_bus_volume_db(2, lerpf(AudioServer.get_bus_volume_db(2), -30.0, delta))
	else:
		AudioServer.set_bus_volume_db(2, lerpf(AudioServer.get_bus_volume_db(2), 0, delta))
	
	bottom_hud.position = lerp(bottom_hud.position, bottom_hud_initial_pos, delta * 3)
	
	if news_i < news.size() and news.keys()[news_i] <= player.mass_max:
		_play_news()
	
	if show_upgrades:
		upgrade_hud.show()
	else:
		upgrade_hud.hide()
	
	$UI/_/health_parent/health_container/mass_text.text = "$ %d / $ %d" % [player.mass, 15000]

func _on_upgrade_tentacles_gui_input(e : InputEvent):
	var price = 10 * pow(upgrade_tentacle_count, 2)
	var price_new = 10 * pow(upgrade_tentacle_count + 1, 2)
	
	if e.is_action_pressed("click"):
		if player.upgrade_tentacles(price):
			upgrade_tentacle_count += 1
			$UI/upgrade_hud/_/_/_/upgrade_tentacles/bg/quantity.text = "%d" % upgrade_tentacle_count
			$UI/upgrade_hud/_/_/_/upgrade_tentacles/price.text = "$ %d" % price_new

func _on_upgrade_speed_gui_input(e : InputEvent):
	var price = 10 * pow(upgrade_speed_count, 2)
	var price_new = 10 * pow(upgrade_speed_count + 1, 2)
	
	if e.is_action_pressed("click"):
		if player.upgrade_speed(price):
			upgrade_speed_count += 1
			$UI/upgrade_hud/_/_/_/upgrade_speed/bg/quantity.text = "%d" % upgrade_speed_count
			$UI/upgrade_hud/_/_/_/upgrade_speed/price.text = "$ %d" % price_new

func _on_upgrade_durability_gui_input(e : InputEvent):
	var price = 10 * pow(upgrade_durability_count, 2)
	var price_new = 10 * pow(upgrade_durability_count + 1, 2)
	
	if e.is_action_pressed("click"):
		if player.upgrade_durability(price):
			upgrade_durability_count += 1
			$UI/upgrade_hud/_/_/_/upgrade_durability/bg/quantity.text = "%d" % upgrade_durability_count
			$UI/upgrade_hud/_/_/_/upgrade_durability/price.text = "$ %d" % price_new

func _on_upgrade_damage_gui_input(e : InputEvent):
	var price = 10 * pow(upgrade_damage_count, 2)
	var price_new = 10 * pow(upgrade_damage_count + 1, 2)
	
	if e.is_action_pressed("click"):
		if player.upgrade_damage(price):
			upgrade_damage_count += 1
			$UI/upgrade_hud/_/_/_/upgrade_damage/bg/quantity.text = "%d" % upgrade_damage_count
			$UI/upgrade_hud/_/_/_/upgrade_damage/price.text = "$ %d" % price_new

func _on_retry_pressed():
	Utils.paused = false
	Utils.game_over = false
	Utils.game_win = false
	get_tree().change_scene_to_file("res://game.tscn")


