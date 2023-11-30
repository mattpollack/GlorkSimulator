extends Label


func _on_timer_label_run_time(time):
	
	print("Time received:", time)
	
	var mils = fmod(time, 1) * 1000
	var secs = fmod(time, 60)
	var mins = fmod(time, 60 * 60) / 60
	var hr = fmod(fmod(time, 3600 * 60) / 3600, 24)
	
	var time_passed = "%02d : %02d : %02d : %03d" % [hr, mins, secs, mils]
	text = "Final Time: " + time_passed
	pass # Replace with function body.
