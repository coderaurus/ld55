extends Node2D
class_name Level

@onready var circle_scene = preload("res://scene/circle.tscn")

signal on_ready

var data: LevelData
var current_circle = 0

var cursor
var circle

var parent: Main

func _ready():
	parent = get_parent()

func load_data(p_data: Resource):
	current_circle = 0
	data = p_data as LevelData
	
	if circle != null:
		_unload_circle()
	
	_load_circle(data.circles[current_circle])

func _load_circle(circle_data: Resource):
	if circle != null:
		_unload_circle()
	
	var new_circle: InvocationCircle = circle_scene.instantiate()
	add_child(new_circle)
	circle = new_circle
	cursor = circle.cursor
	
	cursor.path_complete.connect(parent.on_invocation_circle_complete)
	circle.circle_invoked.connect(on_circle_invoke)
	circle.circle_ready.connect(on_circle_ready)
	circle.beat_fizzle.connect(parent.on_beat_fizzle)
	_generate_invocation_beats()
	circle.setup(circle_data)

func _generate_invocation_beats():
	print("Circle %s of %s" % [current_circle+1, data.circles.size()])
	print("Circle Data #%s: %s %s %s" % [current_circle, data.circles[current_circle].invocations, \
		data.circles[current_circle].cursor_speed, data.circles[current_circle].uses_arrows])
	# amount of invocations per circle
	var invocations = data.circles[current_circle].invocations
	var invocations_at = []
	var current_deg = 0
	var step_range = 360/invocations
	var min_range = -10
	var max_range = 15
	var proximity_threshold = 10
	for i in invocations:
		current_deg += step_range + randi_range(min_range, max_range)
		var beat = current_deg
		if invocations_at.size() > 0:
			var last_invocation = invocations_at.size()-1 
			if beat - invocations_at[last_invocation] <= proximity_threshold:
				current_deg = clampi(beat + 10, 10, 350)
				beat = current_deg
				# at the end and cannot include the last one
				if beat - invocations_at[last_invocation] <= proximity_threshold:
					break
		beat = clampi(beat, 10, 350)
		invocations_at.append(beat)
		
		var beat_scene:RitualBeat = parent.ritual_beat_scene.instantiate()
		beat_scene.name = "RitualBeat%s" % (i+1)
		beat_scene.setup(beat)
		
		circle.add_child(beat_scene)

func on_circle_ready(path, global_origin):
	cursor.setup(path, global_origin)

func on_circle_invoke():
	if current_circle < data.circles.size():
		current_circle += 1

func _unload_circle():
	cursor.path_complete.disconnect(parent.on_invocation_circle_complete)
	circle.circle_invoked.disconnect(on_circle_invoke)
	circle.circle_ready.disconnect(on_circle_ready)
	circle.beat_fizzle.disconnect(parent.on_beat_fizzle)
	circle.queue_free()
	circle = null

func is_level_complete():
	return current_circle == data.circles.size()

func load_next_circle():
	_unload_circle()
	_load_circle(data.circles[current_circle])

func activate():
	cursor.activate()
