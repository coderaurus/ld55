extends Node2D

signal symbol_invoked

var parent: Main

func _ready():
	parent = get_parent()
	symbol_invoked.connect(parent.on_invoke)

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		parent.toggle_pause()
	
	if Input.is_action_just_pressed("ui_toggle_music"):
		var toggle_both_tracks = parent.level.active
		if toggle_both_tracks:
			MusicManager.toggle()
		else:
			MusicManager.toggle(true, 0)
	
	if Input.is_action_just_pressed("ui_toggle_sound"):
		SoundManager.toggle()
	
	if not parent.level.cursor.moving:
		return
	# MAP possible keys for summoning
	if Input.is_action_just_pressed("summoning_up"):
		symbol_invoked.emit("summoning_up")
	elif Input.is_action_just_pressed("summoning_w"):
		symbol_invoked.emit("summoning_w")
	elif Input.is_action_just_pressed("summoning_right"):
		symbol_invoked.emit("summoning_right")
	elif Input.is_action_just_pressed("summoning_d"):
		symbol_invoked.emit("summoning_d")
	elif Input.is_action_just_pressed("summoning_down"):
		symbol_invoked.emit("summoning_down")
	elif Input.is_action_just_pressed("summoning_s"):
		symbol_invoked.emit("summoning_s")
	elif Input.is_action_just_pressed("summoning_left"):
		symbol_invoked.emit("summoning_left")
	elif Input.is_action_just_pressed("summoning_a"):
		symbol_invoked.emit("summoning_a")
