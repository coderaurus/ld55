extends Line2D
class_name InvocationCircle

signal circle_ready
signal beat_fizzle
signal circle_invoked


@onready var preview_beat_texture = preload("res://gfx/preview_beat.png")
@onready var cursor: InvocationCursor = $Cursor

var next_invocation = 0
var main: Main
var active = false
var is_preview = false

func _ready():
	main = get_tree().current_scene

func setup(data: Resource, is_lookup = false):
	var radius = 200
	if is_lookup:
		radius = 230
		is_preview = true
		width = 4
		default_color = Color("#42a459")
	
	data = data as InvocationCircleData
	var dots: Array[Vector2] = []
	for i in 360:
		var x = -sin(deg_to_rad(i)) * radius
		var y = cos(deg_to_rad(i)) * radius
		var new_point = Vector2(x, y)
		dots.append(new_point)
	points = dots
	
	for child in get_children():
		if child.name == "Cursor":
			if is_lookup:
				child.queue_free()
			continue
		
		child = child as RitualBeat
		var x = -sin(deg_to_rad(child.beat_at)) * radius
		var y = cos(deg_to_rad(child.beat_at)) * radius
		var new_point = Vector2(x, y)
		child.global_position = global_position + new_point
		
		if is_lookup:
			child.texture = preview_beat_texture
			child.hframes = 1
			child.vframes = 1
			child.frame_coords = Vector2.ZERO
	
	if not is_lookup:
		circle_ready.emit(dots, global_position)
		cursor.speed = data.cursor_speed * main.speed_modifier
	
	active = true

func get_next_invocation():
	return get_child(next_invocation + 1)

func _process(delta):
	if not active or is_preview:
		return
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
			#print("Moving to next invocation (%s)" % next_invocation)
			#if circle_complete():
				#circle_invoked.emit()

func circle_complete():
	return next_invocation == get_child_count() - 1

func deactivate(destroy = true):
	active = false
	if destroy:
		await get_tree().process_frame
		queue_free()
