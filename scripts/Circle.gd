extends Line2D
class_name InvocationCircle

signal circle_ready
signal beat_fizzle
signal circle_invoked

@onready var cursor: InvocationCursor = $Cursor
var next_invocation = 0
var active = false
# Called when the node enters the scene tree for the first time.
func setup(data: Resource):
	data = data as InvocationCircleData
	var dots: Array[Vector2] = []
	for i in 360:
		var x = -sin(deg_to_rad(i)) * 200
		var y = cos(deg_to_rad(i)) * 200
		var new_point = Vector2(x, y)
		dots.append(new_point)
	points = dots
	
	for child in get_children():
		if child.name == "Cursor":
			continue
		
		child = child as RitualBeat
		var x = -sin(deg_to_rad(child.beat_at)) * 200
		var y = cos(deg_to_rad(child.beat_at)) * 200
		var new_point = Vector2(x, y)
		child.global_position = global_position + new_point
	
	circle_ready.emit(dots, global_position)
	
	cursor.speed = data.cursor_speed
	active = true

func get_next_invocation():
	return get_child(next_invocation + 1)

func _process(delta):
	if next_invocation < get_child_count() - 1:
		var next: RitualBeat = get_next_invocation()
		var distance = cursor.global_position.distance_to(next.global_position)
		if distance <= next.invocation_grace_range and not next.reached:
			next.reached = true
		elif distance >= next.invocation_grace_range and next.reached:
			if not next.invoked:
				beat_fizzle.emit()
				next.fizzle()
			
			next_invocation += 1
			print("Moving to next invocation (%s)" % next_invocation)
			if circle_complete():
				circle_invoked.emit()

func circle_complete():
	return next_invocation == get_child_count() - 1
