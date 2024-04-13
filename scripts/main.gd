extends Node2D
class_name Main

@onready var invocations_group = $Invocations
@onready var mark_scene = preload("res://scene/mark.tscn")
@onready var ritual_beat_scene = preload("res://scene/ritual_beat.tscn")
@onready var level: Level = $Level

@export_group("Scoring")
@export var hit_score = 10
@export var brilliant_score = 20
@export var fizzle_score = 3
@export var miss_score = 0.5

var level_data: Array[Resource] = []

var current_level = 0
var invocation_beats

var circle_misses = 0
var circle_fizzles = 0
var circle_hits = 0
var circle_brilliants = 0

var followers = 0
var days = 10

signal beat_hit
signal beat_miss

func _ready():
	level_data = _generate_level_data()
	
	beat_hit.connect($UI.on_beat_hit)
	beat_miss.connect($UI.on_beat_miss)
	level.load_data(level_data[current_level])
	

func on_invoke(invocation):
	var spawn_point = level.cursor.global_position
	var mark = mark_scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	invocations_group.add_child(mark)
	mark.global_position = spawn_point
	if not level.circle.circle_complete():
		var next:RitualBeat = level.circle.get_next_invocation()
		var distance = next.global_position.distance_to(spawn_point)
		if distance <= next.invocation_grace_range:
			print("HIT (%s/%s)" % [distance, next.invocation_grace_range])
			next.on_invoked()
			var accuracy = 1 - distance / next.invocation_grace_range
			
			circle_hits += 1
			if accuracy >= 0.75:
				circle_brilliants += 1
			beat_hit.emit(accuracy, level.circle.global_position + Vector2.LEFT * 32)
		else:
			circle_misses += 1
			var off_shoot = distance - next.invocation_grace_range
			beat_miss.emit(off_shoot, level.circle.global_position + Vector2.LEFT * 32)
			print("MISS (%s/%s)" % [distance, next.invocation_grace_range])

func on_circle_ready(path, global_origin):
	#level.cursor.setup(path, global_origin)
	pass
	
func on_invocation_circle_complete():
	var scores = (circle_hits * hit_score) + (circle_brilliants * brilliant_score)
	scores -= roundi(level.circle.next_invocation - circle_misses * miss_score) # spammed misses
	scores -= roundi(circle_fizzles * fizzle_score) # fizzles
	var new_followers = scores/ 100
	new_followers = roundi(new_followers)
	followers += new_followers
	
	print("Path complete")
	
	if level.is_level_complete():
		current_level += 1
		print("Level complete")
		days -= 1
		$UI.on_level_complete(circle_hits, circle_brilliants, new_followers, circle_fizzles, followers, days)
		await get_tree().create_timer(2.0).timeout
		if current_level < level_data.size():
			level.load_data(level_data[current_level])
	else:
		level.load_next_circle()

func on_beat_fizzle():
	circle_fizzles += 1


func on_level_ready(lvl):
	print("Level ready, loading data(%s circles)" % [level_data[current_level].circles.size()])
	for c: InvocationCircleData in level_data[current_level].circles:
		print("Invos: %s" % c.invocations)
		print("Speed: %s" % c.cursor_speed)
		print("Arrows?: %s" % c.uses_arrows)
		
	level.load_data(level_data[current_level])

func _load_next_level():
	pass


func _generate_level_data():
	var data: Array[Resource] = [
		LevelData.new(
			[
				InvocationCircleData.new(),
				InvocationCircleData.new(4, 200),
			]
		),
		LevelData.new(
			[
				InvocationCircleData.new(5),
				InvocationCircleData.new(8, 200),
			]
		)
	]
	return data
