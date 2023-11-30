extends Label

signal runTime(value)

var time = 0
var timer_on = false
var tutorial_i = 0
var tutorial_pannels = 13
var isPaused = false

func _ready() -> void:
	timer_on = false
	pass

func _process(delta):
	
	if Utils.game_over:
		triggerStop()
	
	if Utils.game_win:
		triggerStop()
	
	
	if(timer_on and !isPaused ):
		time +=delta
	
	var mils = fmod(time,1)*1000
	var secs = fmod(time,60)
	var mins = fmod(time,60*60)/60
	var hr = fmod(fmod(time,3600 * 60)/3600,24)
		
	var time_passed = "%02d : %02d : %02d : %03d" % [hr, mins,secs,mils]
	text = time_passed# + " : " + var2str(time)
	
	pass


#Game win/over retry button
func _on_retry_pressed():
	triggerRestart()
	pass # Replace with function body.

func triggerStop():
	if(timer_on):
		timer_on = false
		emit_signal("runTime",time)
	pass
	
func triggerStart():
	if(!timer_on):
		timer_on = true
		emit_signal("runTime",time)
	pass

func triggerRestart():
	time = 0
	emit_signal("runTime",time)
	pass

#Button pressed when tutorial pannels are shown
func _on_next_pressed():
	tutorial_i += 1
	
	if tutorial_i >= tutorial_pannels:
		triggerStart()
	else:
		triggerStop()
		
func _input(e: InputEvent):
	if e.is_action_pressed("pause"):
		isPaused = !isPaused

func getTimeValue():
	return time
