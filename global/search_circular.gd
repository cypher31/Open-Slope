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
	var segment_termination : Line2D = Line2D.new()
	var segment_initial_points : PoolVector2Array = segment_initial.get_points()
	
	segment_termination.set_points([initiation_point.position,termination_point.position]) #segment start point & end
	var segment_termination_points = segment_termination.get_points()
	
	var segment_initial_center_point : Vector2 = _calculate_segment_mid_point(segment_initial)
	var segment_termination_center_point : Vector2 = _calculate_segment_mid_point(segment_termination)
	
	var segment_initial_slope_x = segment_initial_points[1].x - segment_initial_points[0].x
	var segment_initial_slope_y = segment_initial_points[1].y - segment_initial_points[0].y
	var segment_initial_slope : Vector2 = Vector2(segment_initial_slope_x, segment_initial_slope_y)
	
	var segment_termination_slope_x = segment_termination_points[1].x - segment_termination_points[0].x
	var segment_termination_slope_y = segment_termination_points[1].y - segment_termination_points[0].y
	var segment_termination_slope : Vector2 = Vector2(segment_termination_slope_x, segment_termination_slope_y)
	
	var segment_initial_perpendicular_slope : Vector2 = segment_initial_slope * - 1
	var segement_termination_perpendicular_slope :Vector2 = segment_termination_slope * - 1
	
	var segment_perpendicular_initial : Line2D
	var segment_perpendicular_termination : Line2D
	
	var segment_perpendicular_initial_start : Vector2 = segment_initial_center_point
	var segment_perpendicular_termination_start : Vector2 = segment_termination_center_point
	
#	var x_point_initial : float = 5000 #the point where the perpendicular segment is ending
#	var x_point_termination : float = 0
#	var y_point_initial : float = (segment_initial_slope.y / segment_initial_slope.x)
#	var y_point_termination : float
	
	#I think the problem here is that the vector2 is just a point and it needs to be a full line??
	var segment_perpendicular_initial_end : Vector2 = segment_perpendicular_initial_start * 1000
	var segment_perpendicular_termination_end : Vector2 = segment_perpendicular_termination_start * (-1000)
	
	var circle_center_point = Geometry.segment_intersects_segment_2d(segment_perpendicular_initial_start, segment_perpendicular_initial_end,segment_perpendicular_termination_start, segment_perpendicular_termination_end)
#	print(segment_initial_center_point)
#	print(segment_termination_center_point)
	print(circle_center_point)
	return theta_increment
	

func _calculate_segment_mid_point(segment_initial):
	var mid_point : Vector2
	var segment_points = segment_initial.get_points()
	
	var x_average = (segment_points[0].x + segment_points[1].x) / 2
	var y_average = (segment_points[0].y + segment_points[1].y) / 2
	mid_point = Vector2(x_average, y_average)
	
	return mid_point
