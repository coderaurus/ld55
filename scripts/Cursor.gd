extends Sprite2D
class_name InvocationCursor

@export var speed = 100
@export var frame_rotation_interval = 0.5

var points: Array[Vector2] = []
var current_point = 0
var moving = false
var origin_point
var current_interval = 0

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
	
	current_interval += delta
	if current_interval >= frame_rotation_interval:
		_rotate_sprite()
		current_interval = 0

func activate():
	moving = true


func _rotate_sprite():
	var degrees = [-90, 0, 90, 180]
	var rotating = randi_range(0, degrees.size()-1)
	rotate(deg_to_rad(degrees[rotating]))
