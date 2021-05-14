extends Panel

#script which handles displaying the slop geometry and relevant details
#For now, assume that el. 0 is center of the container
#making sure to scale things correctly will be interesting, camera to control zoom?

# Called when the node enters the scene tree for the first time.
func _ready():
	SearchCircular.surface_search_temp = $surface_search_temp
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
