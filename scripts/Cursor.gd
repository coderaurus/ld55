extends Sprite2D
class_name InvocationCursor

@export var speed = 100

var points: Array[Vector2] = []
var current_point = 0
var moving = false
var origin_point

signal path_complete

func setup(p, origin):
	origin_point = origin
	points = p
	global_position = origin + points[0]

func _process(delta):
	if moving and current_point == points.size():
		moving = false
		path_complete.emit()
	
	if not moving:
		return
	
	#print("Moving towards: %s" % (points[current_point]))
	position = position.move_toward(points[current_point], speed * delta)
	
	if position.distance_to(points[current_point]) <= 2:
		current_point += 1

func activate():
	moving = true
