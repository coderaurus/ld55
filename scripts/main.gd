extends Node2D
class_name Main

@onready var invocations_group = $Invocations
@onready var mark_scene = preload("res://scene/mark.tscn")
@onready var ritual_beat_scene = preload("res://scene/ritual_beat.tscn")
@onready var follower_scene = preload("res://scene/follower.tscn")
@onready var splash_particle_scene = preload("res://scene/splash_particles.tscn")
@onready var level: Level = $Level
@onready var summoner: Summoner = $Summoner
@onready var followersGroup: Followers = $Followers

@export_group("Scoring")
@export var hit_score = 10
@export var brilliant_score = 20
@export var fizzle_score = 3
@export var miss_score = 0.5

@export_category("Titan")
@export var base_power_per_level = 30
@export var multiplier_per_level = 1.1

var level_data: Array[Resource] = []

var speed_modifier = 1
var score_modifier = 1

var current_level = 0
var invocation_beats

var circle_misses = 0
var circle_fizzles = 0
var circle_hits = 0
var circle_brilliants = 0
var cumulated_followers = 0

var followers = 0
var days_left = 10

var power_per_follower = 10
var summoning_power = 0
var titan_total_power = 0
var titan_defeated = false

signal beat_hit
signal beat_miss
signal beat_wrong

func _ready():
	if not beat_hit.is_connected($UI.on_beat_hit):
		beat_hit.connect($UI.on_beat_hit)
		beat_miss.connect($UI.on_beat_miss)
		beat_wrong.connect($UI.on_beat_wrong)
		
		beat_hit.connect(summoner.on_beat_hit)
		beat_miss.connect(summoner.on_beat_miss)
		beat_wrong.connect(summoner.on_beat_miss)
	
	level_data = _generate_level_data()
	setup(false)
	MusicManager.play_song("track_one")
	
	MusicManager.additional_track.volume_db = MusicManager.MUTE_DB
	MusicManager.play_song("track_two", true)

func setup(auto_start = true):
	$UI.reset()
	followers = 0
	
	for c in followersGroup.get_children():
		c.queue_free()
	current_level = 0
	days_left = level_data.size()
	var power_multiplier = multiplier_per_level
	titan_total_power = 0
	for i in days_left:
		var power = base_power_per_level * power_multiplier
		power_multiplier *= multiplier_per_level
		titan_total_power += power
	print("Titan power at (multiplier %s): %s" % [power_multiplier, titan_total_power])
	
	_load_next_level(auto_start)

func on_invoke(invocation):
	var spawn_point = level.cursor.global_position
	var mark = mark_scene.instantiate()
	invocations_group.add_child(mark)
	mark.global_position = spawn_point
	if not level.circle.circle_complete():
		var next:RitualBeat = level.circle.get_next_invocation()
		var distance = next.global_position.distance_to(spawn_point)
		if not next.invoked and distance <= next.invocation_grace_range and next.requires(invocation):
			add_splash(mark.global_position, true)
			#print("HIT (%s/%s)" % [distance, next.invocation_grace_range])
			next.on_invoked()
			var accuracy = 1 - distance / next.invocation_grace_range
			
			circle_hits += 1
			if accuracy >= 0.75:
				circle_brilliants += 1
			beat_hit.emit(accuracy, level.circle.global_position + Vector2.LEFT * 64)
			SoundManager.sound("invocation", randf_range(0.8, 1.2))
			
		if not next.invoked and distance <= next.invocation_grace_range and not next.requires(invocation):
			add_splash(mark.global_position)
			circle_misses += 1
			beat_wrong.emit(0, level.circle.global_position + Vector2.LEFT * 64)
			SoundManager.sound("failure", 1.5)
			#print("MISS (%s/%s)" % [distance, next.invocation_grace_range])
		elif not next.invoked:
			add_splash(mark.global_position)
			circle_misses += 1
			var off_shoot = distance - next.invocation_grace_range
			beat_miss.emit(off_shoot, level.circle.global_position + Vector2.LEFT * 64)
			SoundManager.sound("failure", 1.5)
			#print("MISS (%s/%s)" % [distance, next.invocation_grace_range])

func on_circle_ready(path, global_origin):
	#level.cursor.setup(path, global_origin)
	pass
	
func on_invocation_circle_complete():
	level.circle.circle_invoked.emit()
	
	var scores = (circle_hits * hit_score * score_modifier) + (circle_brilliants * brilliant_score * 0.5 * score_modifier)
	scores -= roundi(circle_misses * miss_score) # spammed misses
	scores -= roundi(circle_fizzles * fizzle_score) # fizzles
	
	var new_followers = scores / 100.0
	print("circle hits: %s | brilliant hits: %s | misses: %s | score total: %s" %\
	[circle_hits, circle_brilliants, circle_misses, scores])
	# give some slack for the first level
	if current_level == 0 and new_followers > 0.2:
		new_followers = 1.0
	new_followers = roundi(new_followers)
	
	cumulated_followers += new_followers
	#print("Path complete")
	$Trace.stop()
	followersGroup.add_follower(new_followers)
	if level.is_level_complete():
		followers += cumulated_followers
		
		summoner.lower_hands()
		MusicManager.fade_out(false, true)
		current_level += 1
		print("Level complete with %s new followers" % new_followers)
		days_left -= 1
		_group_scatter()
		await get_tree().create_timer(0.5).timeout
		$UI.on_level_complete(circle_hits, circle_brilliants, new_followers, circle_fizzles, followers, days_left)
	else:
		level.load_next_circle()
		if not level.cursor.moving:
			level.cursor.moving = true

func on_beat_fizzle():
	circle_fizzles += 1


func on_level_ready(lvl):
	#print("Level ready, loading data(%s circles)" % [level_data[current_level].circles.size()])
	#for c: InvocationCircleData in level_data[current_level].circles:
		#print("Invos: %s" % c.invocations)
		#print("Speed: %s" % c.cursor_speed)
		#print("Arrows?: %s" % c.uses_arrows)
		
	level.load_data(level_data[current_level])

func _load_next_level(auto_start = true):
	print("Reseeting hits on level load")
	circle_brilliants = 0
	circle_hits = 0
	circle_fizzles = 0
	cumulated_followers = 0
	
	level.load_data(level_data[current_level])
	$Trace.target = level.cursor
	
	if auto_start:
		$UI.start_count_down()

func next_level(modifier = "normal"):
	SoundManager.sound("select")
	$UI.hide_report()
	var skip_day = false
	var summoning = false
	var new_followers = 0
	
	
	match modifier:
		"prowess":
			score_modifier += 0.1
			speed_modifier += 0.1
			$UI.change_modifiers()
		"focus":
			score_modifier -= 0.1
			speed_modifier -= 0.1
			$UI.change_modifiers()
		"teach":
			new_followers = clampi(followers * 1.2, 1, 999999) - followers
			new_followers = clampi(new_followers, 1, 99999)
			followers += new_followers
			skip_day = true
		"summon":
			summoning = true
	
	followersGroup.add_follower(new_followers)
	
	$UI.hide_down_time()
		
	if summoning:
		summoner.lower_hands()
		print("Summoing with %s followers" % followers)
		
		_determine_outcome()
		group_up()
		
		level.circle.hide()
		$Trace.hide()
		
		await get_tree().create_timer(2.5).timeout
		$UI.show_summoning(titan_defeated)
	elif not skip_day:
		_load_next_level()
	else:
		_load_next_level(false)
		$UI.show_skipped_day(new_followers)

func _determine_outcome():
	summoning_power = followers * power_per_follower
	titan_defeated = summoning_power >= titan_total_power
	print("Summoning: %s Titan: %s" % [summoning_power, titan_total_power])

func reset():
	setup()

func start_level():
	$UI.hide_report()
	MusicManager.fade_in(true)
	level.activate()

func group_up():
	followersGroup.group_appear()

func _group_scatter():
	followersGroup.group_disappear()

func add_splash(pos, is_hit = false):
	var splash:SplashParticle = splash_particle_scene.instantiate()
	$Invocations.add_child(splash)
	splash.global_position = pos
	if is_hit:
		splash.emit(24, 60, 20)
	else:
		splash.emit(8, 50, 25)

func toggle_pause():
	level.cursor.moving = !level.cursor.moving
	$UI.toggle_pause(level.cursor.moving)

func _generate_level_data():
	var data: Array[Resource] = [
		LevelData.new( # LV 1
			[
				InvocationCircleData.new(3, 110),
				InvocationCircleData.new(4, 110),
			]
		),
		#LevelData.new( # LV 2
			#[
				#InvocationCircleData.new(4, 110),
				#InvocationCircleData.new(5, 115),
				#InvocationCircleData.new(5, 115),
			#]
		#),
		#LevelData.new( # LV 3
			#[
				#InvocationCircleData.new(4, 120),
				#InvocationCircleData.new(5, 120),
				#InvocationCircleData.new(5, 120),
			#]
		#),
		#LevelData.new( # LV 4
			#[
				#InvocationCircleData.new(4, 120),
				#InvocationCircleData.new(6, 110),
				#InvocationCircleData.new(4, 120),
			#]
		#),
		#LevelData.new( # LV 5
			#[
				#InvocationCircleData.new(4, 125, true, 1.0),
				#InvocationCircleData.new(3, 125, true, 1.0),
				#InvocationCircleData.new(4, 125, true, 1.0),
			#]
		#),
		#LevelData.new( # LV 6
			#[
				#InvocationCircleData.new(3, 150, true, 1.0),
				#InvocationCircleData.new(5, 150, true, 0.25),
				#InvocationCircleData.new(6, 150, true, 0.25),
			#]
		#),
		#LevelData.new( # LV 7
			#[
				#InvocationCircleData.new(4, 155),
				#InvocationCircleData.new(6, 155, true, 1.0),
				#InvocationCircleData.new(4, 155, true, 1.0),
				#InvocationCircleData.new(6, 155),
			#]
		#),
		#LevelData.new( # LV 8
			#[
				#InvocationCircleData.new(5, 165, true, 0.30),
				#InvocationCircleData.new(5, 165, true, 0.45),
				#InvocationCircleData.new(6, 165, true, 0.30),
				#InvocationCircleData.new(6, 165, true, 0.45),
			#]
		#),
		#LevelData.new( # LV 9
			#[
				#InvocationCircleData.new(6, 175, true, 0.33),
				#InvocationCircleData.new(6, 175, true, 0.33),
				#InvocationCircleData.new(6, 175, true, 0.33),
				#InvocationCircleData.new(7, 175, true, 0.33),
			#]
		#),
		#LevelData.new( # LV 10
			#[
				#InvocationCircleData.new(10, 180, true, 0.5),
				#InvocationCircleData.new(8, 185, true, 0.5),
				#InvocationCircleData.new(7, 190, true, 0.5),
				#InvocationCircleData.new(8, 200, true, 0.5),
			#]
		#),
	]
	return data
