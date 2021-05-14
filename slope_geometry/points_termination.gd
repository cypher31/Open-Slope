extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var children : Array = get_children()
	
	for child in children:
		Utility.emit_signal("termination_assign", child) #this signal is sent to the search_circular script
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
