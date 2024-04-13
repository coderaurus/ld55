extends Node2D
class_name Main

@onready var cursor: InvocationCursor = $Cursor
@onready var circle: InvocationCircle = $Circle
@onready var invocations_group = $Invocations
@onready var mark_scene = preload("res://scene/mark.tscn")
@onready var ritual_beat_scene = preload("res://scene/ritual_beat.tscn")

var invocation_beats

func _ready():
	cursor.path_complete.connect(on_invocation_circle_complete)
	circle.circle_ready.connect(on_circle_ready)
	_generate_invocation_beats()
	circle.setup(cursor)

func on_invoke(invocation):
	var spawn_point = cursor.global_position
	var mark = mark_scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	invocations_group.add_child(mark)
	mark.global_position = spawn_point
	if not circle.circle_complete():
		var next:RitualBeat = circle.get_next_invocation()
		var distance = next.global_position.distance_to(spawn_point)
		if distance <= next.invocation_grace_range:
			print("HIT (%s/%s)" % [distance, next.invocation_grace_range])
			next.on_invoked()
		else:
			print("MISS (%s/%s)" % [distance, next.invocation_grace_range])

func on_circle_ready(path, global_origin):
	cursor.setup(path, global_origin)
	
func on_invocation_circle_complete():
	print("Path complete")

func _generate_invocation_beats():
	# amount of invocations per circle
	var invocations = 10
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
		
		var beat_scene:RitualBeat = ritual_beat_scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
		beat_scene.name = "RitualBeat%s" % (i+1)
		beat_scene.setup(beat)
		
		circle.add_child(beat_scene)
