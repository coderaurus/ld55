extends CanvasLayer

@onready var beat_hit_text_scene = preload("res://scene/ui/beat_hit_text.tscn")
@onready var good_ending_image = preload("res://gfx/ending_good.png")
@onready var bad_ending_image = preload("res://gfx/ending_bad.png")

signal count_down_completed

var parent: Main

func _ready():
	parent = get_parent()
	count_down_completed.connect(parent.start_level)
	$Downtime/Options/Normal.pressed.connect(parent.next_level.bind("normal"))
	$Downtime/Options/Prowess.pressed.connect(parent.next_level.bind("prowess"))
	$Downtime/Options/Focus.pressed.connect(parent.next_level.bind("focus"))
	$Downtime/Options/Teach.pressed.connect(parent.next_level.bind("teach"))
	$Downtime/Options/Summon.pressed.connect(parent.next_level.bind("summon"))
	
	$Start/Button.grab_focus()

func _process(delta):
	$Progress/Follower.text = "Followers: %s" % parent.followers
	$Progress/Days.text = "%s days left" % parent.days_left


func on_beat_hit(accuracy, pos):
	print("Hit at %s" % pos)
	#print("Accuracy %s" % accuracy)
	var message = "Good"
	var text_color = Color.ORANGE
	if accuracy >= 0.75:
		message = "Brilliant"
		text_color = Color.CORAL
	
	var text_scene: BeatHitText = beat_hit_text_scene.instantiate()
	add_child(text_scene)
	#text_scene.position = Vector2(690, 360)
	pos.x = randi_range(pos.x - 32, pos.x + 32)
	pos.y = randi_range(pos.y - 32, pos.y + 32)
	text_scene.position = pos
	text_scene.pop(message, text_color)
	
func on_beat_miss(distance, pos: Vector2):
	print("Miss at %s" % pos)
	var message = "Miss"
	var text_color = Color.WHITE
	if distance >= 45:
		message = "..."
	
	var text_scene: BeatHitText = beat_hit_text_scene.instantiate()
	$Beats.add_child(text_scene)
	
	#text_scene.global_position = Vector2(690, 360)
	pos.x = randi_range(pos.x - 32, pos.x + 32)
	pos.y = randi_range(pos.y - 32, pos.y + 32)
	text_scene.position = pos
	text_scene.pop(message, text_color)

func on_beat_wrong(distance, pos: Vector2):
	print("Wrong at %s" % pos)
	var message = "Wrong"
	var text_color = Color.DARK_RED
	
	var text_scene: BeatHitText = beat_hit_text_scene.instantiate()
	$Beats.add_child(text_scene)
	
	#text_scene.global_position = Vector2(690, 360)
	pos.x = randi_range(pos.x - 32, pos.x + 32)
	pos.y = randi_range(pos.y - 32, pos.y + 32)
	text_scene.position = pos
	text_scene.pop(message, text_color)

func on_level_complete(hits, brilliants, followers, fizzles, total_followers, days_left):
	$Progress/Days.text = "%s days left" % days_left
	$Progress/Follower.text = "%s followers" % total_followers
	
	$Report.show()
	$Report/Results/Hits.text = "Total hits: %s" % hits
	await get_tree().create_timer(0.1)
	$Report/Results/Brilliants.text = "Brilliant hits: %s" % brilliants
	await get_tree().create_timer(0.1)
	$Report/Results/Fizzles.text = "Inactivations: %s" % fizzles
	await get_tree().create_timer(0.1)
	$Report/Results/Followers.text = "No new followers..."
	if followers > 0:
		$Report/Results/Followers.text = "+%s follower(s)" % followers
	
	
	
	$Downtime.visible = true
	
	if days_left == 0:
		$Downtime/Options/Normal.disabled = true
		$Downtime/Options/Prowess.disabled = true
		$Downtime/Options/Focus.disabled = true
		$Downtime/Options/Teach.disabled = true
		$Downtime/Options/Normal/Label.self_modulate = Color.DARK_SLATE_GRAY
		$Downtime/Options/Prowess/Label.self_modulate = Color.DARK_SLATE_GRAY
		$Downtime/Options/Focus/Label.self_modulate = Color.DARK_SLATE_GRAY
		$Downtime/Options/Teach/Label.self_modulate = Color.DARK_SLATE_GRAY
		$Downtime/Options/Blank.visible = false
	else:
		$Downtime/Options/Normal.disabled = false
		$Downtime/Options/Prowess.disabled = false
		$Downtime/Options/Focus.disabled = false
		$Downtime/Options/Teach.disabled = false
		$Downtime/Options/Normal/Label.self_modulate = Color.WHITE
		$Downtime/Options/Prowess/Label.self_modulate = Color.WHITE
		$Downtime/Options/Focus/Label.self_modulate = Color.WHITE
		$Downtime/Options/Teach/Label.self_modulate = Color.WHITE
		$Downtime/Options/Blank.visible = true

func hide_report():
	$Report.hide()

func hide_down_time():
	$Downtime.hide()

func show_summoning(did_win = false):
	var lose_msg = "Regardless of your valiant efforts, the TITAN owerpowered your summon. You lose."
	var win_msg = "The mighty beast FISH flushed TITAN down the volcano! You win!"
	$Summoning/Outcome.text = lose_msg
	$Summoning/Image.texture = bad_ending_image
	if did_win:
		$Summoning/Outcome.text = win_msg
		$Summoning/Image.texture = good_ending_image
	
	$Summoning.show()

func show_skipped_day(new_followers):
	$SkipDay/Text2.text = "You spent your day teaching others
gaining %s new follower(s)." % new_followers
	$SkipDay.show()

func _on_continue_pressed():
	$SkipDay.hide()
	start_count_down()

func _on_replay_pressed():
	parent.reset()
	$Summoning.hide()

func pop_beat_message(message, c = Color.WHITE):
	var pos = Vector2(690, 360) + Vector2.LEFT * 96
	var text_scene: BeatHitText = beat_hit_text_scene.instantiate()
	$Beats.add_child(text_scene)
	#text_scene.position = Vector2(690, 360)
	pos.x = randi_range(pos.x - 32, pos.x + 32)
	pos.y = randi_range(pos.y - 32, pos.y + 32)
	text_scene.position = pos
	text_scene.pop(message, c)

func start_count_down():
	parent.group_up()
	parent.summoner.raise_hands()
	await get_tree().create_timer(0.5).timeout
	pop_beat_message("Ready..")
	await get_tree().create_timer(2.0).timeout
	pop_beat_message("SUMMON!")
	count_down_completed.emit()

func _on_start_pressed():
	$Start.hide()
	parent.level.show()
	start_count_down()

func change_modifiers():
	if parent.speed_modifier != 1.0:
		$Modifiers/Speed.text = "Speed x%s" % parent.speed_modifier
	if parent.score_modifier != 1.0:
		$Modifiers/FollowerGain.text = "Follows x%s" % parent.score_modifier

func toggle_pause(paused):
	if not paused:
		$Paused.show()
	else:
		$Paused.hide()

func reset():
	$Modifiers/FollowerGain.text = ""
	$Modifiers/Speed.text = ""
	
	$Report/Results/Hits.text = ""
	$Report/Results/Brilliants.text = ""
	$Report/Results/Fizzles.text = ""
	$Report/Results/Followers.text = ""
