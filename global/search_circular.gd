extends Node

var angle_counter_clockwise_limit : int = 45 #degrees
var angle_clockwise_limit : int = 5 #degrees; should be 5 degree from surface geometry eventually

var segment_length : int = 50 #length of chords which make up the circle

var termination_left : Position2D #left most termination point
var termination_right : Position2D #right most termination point

var surface_search_temp : Node2D #node that will hold the surfaces to check they fall within parameters

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize() #generate the random seed
	
	#attach signals
	Utility.connect("termination_assign", self, "_assign_termination_variables")
	pass # Replace with function body.


func _generate_initial_segment(initiation_point : Position2D):
	var theta : float #initial angle of the first segment
	
	theta = _calculate_segment_initial_angle(angle_counter_clockwise_limit, angle_clockwise_limit)
	
	var segment : Line2D = Line2D.new()
	var start_point : Vector2 = initiation_point.position
	var end_point : Vector2 = _calculate_next_segment_point(start_point, theta, segment_length) + start_point
	var points_pool : PoolVector2Array = [start_point, end_point]
	
	segment.points = points_pool
	segment.width = 1
	
	surface_search_temp.add_child(segment)
	
	#calculate theta_min and theta_max that will be used for next segments
	var theta_min : float = _calculate_theta_increment(termination_left, segment, initiation_point)
	var theta_max : float = _calculate_theta_increment(termination_right, segment, initiation_point)
	return
	
	
func _calculate_segment_initial_angle(ccwl, cwl):
	var theta : float #initial angle for segment
	var random_num : float = randf() #randum number between 0 & 1
	
	theta = cwl + (ccwl - cwl) * pow(random_num, 2)
	
	return theta
	
	
func _assign_termination_variables(termination_point):
	if termination_point.get_name() == "termination_left":
		termination_left = termination_point
	elif termination_point.get_name() == "termination_right":
		termination_right = termination_point
	return


func _calculate_next_segment_point(start_point : Vector2, theta : float, segment_length : int):
	var end_point : Vector2
	
	end_point.x = segment_length * cos(deg2rad(theta))
	end_point.y = segment_length * sin(deg2rad(theta))
	return end_point
	
	
func _calculate_theta_increment(termination_point : Position2D, segment_initial : Line2D, initiation_point : Position2D):
	#calculate center point of segment_initial
	#calculate center point of line connecting initiation point and termination point
	#draw a line perpindicular to each segment starting from the calculated centers and check where they intercept
	#the distance from the intersection point to the initiation point is the radius of the circle
	var theta_increment : float #max or min depending on inputs
	return theta_increment
