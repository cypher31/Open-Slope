extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("button_down", self, "_run_analysis")
	pass # Replace with function body.

func _run_analysis():
	Utility.emit_signal("start_analysis") #points_initiation listening
	return
