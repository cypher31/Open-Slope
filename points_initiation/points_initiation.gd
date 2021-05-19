extends Position2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Utility.connect("start_analysis", self, "_generate_search_circular")
	pass # Replace with function body
	
	
func _generate_search_circular():
	for i in range(0, 500):
		SearchCircular._generate_initial_segment(self)
	return
