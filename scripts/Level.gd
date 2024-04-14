extends Node2D
class_name Level

@onready var circle_scene = preload("res://scene/circle.tscn")

signal on_ready

var data: LevelData
var current_circle = 0

var cursor
var circle
var preview

var parent: Main
var active = false

var invocation_inputs = ["summoning_up", "summoning_right", "summoning_down","summoning_left"]
var invocation_inputs_secondary = ["summoning_w", "summoning_d", "summoning_s","summoning_a"]

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
	parent.get_node("Trace").setup(cursor)
	
	cursor.path_complete.connect(parent.on_invocation_circle_complete)
	circle.circle_invoked.connect(on_circle_invoke)
	circle.circle_ready.connect(on_circle_ready)
	circle.beat_fizzle.connect(parent.on_beat_fizzle)
	_generate_invocation_beats(circle, circle_data)
	circle.setup(circle_data)
	
	if preview != null:
		preview.hide()
		preview.deactivate()
	
	if data.circles.size() > current_circle + 1:
		new_circle = circle_scene.instantiate()
		add_child(new_circle)
		preview = new_circle
		_generate_invocation_beats(preview, data.circles[current_circle+1])
		preview.setup(data.circles[current_circle+1], true)

func _generate_invocation_beats(circle: InvocationCircle, data:InvocationCircleData):
	# amount of invocations per circle
	var invocations = data.invocations
	var invocations_at = []
	var current_deg = 0
	var step_range = 360/invocations
	var min_range = -10
	var max_range = 15
	var proximity_threshold = 30
	for i in invocations:
		if i == 0:
			current_deg += step_range + randi_range(0, max_range)
		else:
			current_deg += step_range + randi_range(min_range, max_range)
		
		var too_close = false
		var beat = current_deg
		beat = clampi(beat, 15, 340)
		if invocations_at.size() > 0:
			var last_invocation = invocations_at.size()-1 
			var distance_between_last_two = beat - invocations_at[last_invocation]
			if  distance_between_last_two <= proximity_threshold:
				current_deg = clampi(beat + proximity_threshold, 15, 340)
				beat = current_deg
				# at the end and cannot include the last one
				distance_between_last_two = beat - invocations_at[last_invocation]
				if distance_between_last_two <= proximity_threshold\
				or beat >= 340:
					too_close = true
		elif beat >= 340:
			too_close = true
		
		if too_close:
			break
		
		
		invocations_at.append(beat)
		
		var selected_invocation_index = wrapi(randi_range(0, 100) + randi_range(0, 100), 0, 3)
		var selected_invocation = invocation_inputs[selected_invocation_index]
		
		if data.has_wasd and randf() <= data.wasd_chance:
			selected_invocation = invocation_inputs_secondary[selected_invocation_index]
		
		var beat_scene:RitualBeat = parent.ritual_beat_scene.instantiate()
		beat_scene.name = "RitualBeat%s" % (i+1)
		beat_scene.setup(beat, selected_invocation)
		
		circle.add_child(beat_scene)

func on_circle_ready(path, global_origin):
	cursor.setup(path, global_origin)

func on_circle_invoke():
	var cirlces = data.circles.size()
	if current_circle < cirlces:
		current_circle += 1

func _unload_circle():
	cursor.path_complete.disconnect(parent.on_invocation_circle_complete)
	circle.circle_invoked.disconnect(on_circle_invoke)
	circle.circle_ready.disconnect(on_circle_ready)
	circle.beat_fizzle.disconnect(parent.on_beat_fizzle)
	circle.queue_free()
	circle = null

func is_level_complete():
	var is_complete = current_circle == data.circles.size()
	if is_complete:
		active = false
	
	return is_complete

func load_next_circle():
	_unload_circle()
	_load_circle(data.circles[current_circle])
	

func activate():
	active = true
	cursor.activate()
