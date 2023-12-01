extends RichTextLabel

@onready var demo = $UI/demo

# Called when the node enters the scene tree for the first time.
func _ready():
	if(demo):
		text = "Debug Mode On"
	else:
		text = ""
	pass # Replace with function body.

