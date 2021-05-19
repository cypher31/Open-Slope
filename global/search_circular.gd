extends Node

var angle_counter_clockwise_limit : int = 45 #degrees
var angle_clockwise_limit : int = 5 #degrees; should be 5 degree from surface geometry eventually

var segment_length : int = 8 #length of chords which make up the circle

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
	var theta_left_termination : float = _calculate_theta_increment(termination_left, segment, initiation_point)
	var theta_right_termination : float = _calculate_theta_increment(termination_right, segment, initiation_point)
	
	var theta_trial : float = rand_range(theta_right_termination, theta_left_termination)
	
	_generate_circular_surface(theta_trial, segment, segment_length, 1)
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
	
	segment_termination.set_points([segment_initial.get_points()[1],termination_point.position]) #segment start point & end
	var segment_termination_points = segment_termination.get_points()
	
	var segment_initial_center_point : Vector2 = _calculate_segment_mid_point(segment_initial)
	var segment_termination_center_point : Vector2 = _calculate_segment_mid_point(segment_termination)
	
	#debug
#	surface_search_temp.add_child(segment_termination) #show the two termination segments
#	segment_termination.set_width(1)
	##debug

	var delta_perpendicular_initial : Vector2 = _calculate_perpendicular_segment(segment_initial)
	var delta_perpendicular_termination : Vector2 = _calculate_perpendicular_segment(segment_termination)
	
	var perpendicular_initial_segment_start : Vector2 = segment_initial_center_point
	var perpendicular_initial_segment_end : Vector2 = segment_initial_center_point + delta_perpendicular_initial * -500
	
	var perpendicular_termination_segment_start : Vector2 = segment_termination_center_point
	var perpendicular_termination_segment_end : Vector2 = segment_termination_center_point + delta_perpendicular_termination* -500
	
	var segment_perpendicular_initial : Line2D = Line2D.new()
	var segment_perpendicular_termination : Line2D = Line2D.new()
	
	segment_perpendicular_initial.set_points([perpendicular_initial_segment_start, perpendicular_initial_segment_end])
	segment_perpendicular_termination.set_points([perpendicular_termination_segment_start,perpendicular_termination_segment_end])
	
	var segment_perpendicular_initial_points = segment_perpendicular_initial.points
	var segment_perpendicular_termination_points = segment_perpendicular_termination.points
	
	segment_perpendicular_initial.set_points([segment_perpendicular_initial_points[0],segment_perpendicular_initial_points[1]])
	segment_perpendicular_termination.set_points([segment_perpendicular_termination_points[0],segment_perpendicular_termination_points[1]])
	
	var circle_center_point = Geometry.segment_intersects_segment_2d(segment_perpendicular_initial_points[0],segment_perpendicular_initial_points[1],segment_perpendicular_termination_points[0],segment_perpendicular_termination_points[1])

	#debug
#	surface_search_temp.add_child(segment_perpendicular_initial)
#	surface_search_temp.add_child(segment_perpendicular_termination)
#
#	segment_perpendicular_initial.set_width(1)
#	segment_perpendicular_termination.set_width(1)
	##debug
	
	var initiation_point_position : Vector2 = initiation_point.position
	var circle_radius : float = initiation_point_position.distance_to(circle_center_point)
	var initial_segment_length : float = segment_initial_points[0].distance_to(segment_initial_points[1])
	
	theta_increment = 2 * asin(initial_segment_length / (2 * circle_radius))
#	print(rad2deg(theta_increment))
	return rad2deg(theta_increment)
	

func _calculate_segment_mid_point(segment_initial):
	var mid_point : Vector2
	var segment_points = segment_initial.get_points()
	
	var x_average = (segment_points[0].x + segment_points[1].x) / 2
	var y_average = (segment_points[0].y + segment_points[1].y) / 2
	mid_point = Vector2(x_average, y_average)
	
	return mid_point


func _calculate_perpendicular_segment(segment : Line2D):
	#the perpendicular vector of (x,y) is (-y,x)
	var segment_start : Vector2 = segment.get_points()[0]
	var segment_end : Vector2 = segment.get_points()[1]
	
	var delta_x : float = segment_end.x - segment_start.x
	var delta_y : float = segment_end.y - segment_start.y
	
	var delta_perpendicular : Vector2 = Vector2(-delta_y, delta_x)
	return delta_perpendicular
	
	
func _generate_circular_surface(theta_angle : float, segment : Line2D, segment_length : int, segment_num : int):
	var start_x : float = segment.points[1].x
	var start_y : float = segment.points[1].y
	
	#ANGLE NEEDS TO BE RELATIVE TO THE ANGLE OF HTE INITIAL SEGMENT!!!
	var end_x : float = segment_length * cos(deg2rad(-theta_angle * segment_num)) + start_x
	var end_y : float = segment_length * sin(deg2rad(-theta_angle * segment_num)) + start_y
	
	var coords_start : Vector2 = Vector2(start_x, start_y)
	var coords_end : Vector2 = Vector2(end_x, end_y)
	
	var segment_new : Line2D = Line2D.new()
	
	surface_search_temp.add_child(segment_new)
	segment_new.set_points([coords_start, coords_end])
	segment_new.set_width(1)
	
	var point_check : Vector2 = Vector2(start_x, end_x)
	
	var dict_temp = {"point_check" : point_check, "segment_new" : segment_new}
	
	if start_x - end_x > 0 || end_y < 150:
		print(surface_search_temp.get_child_count())
	else:
		_generate_circular_surface(theta_angle, segment_new, segment_length, segment_num + 1)
#		print(surface_search_temp.get_child_count())
	return dict_temp
