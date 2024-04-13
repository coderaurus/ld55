extends Node2D

signal symbol_invoked

var parent: Main

func _ready():
	parent = get_parent()
	symbol_invoked.connect(get_parent().on_invoke)

func _process(delta):
	if not parent.level.cursor.moving:
		return
	
	# MAP possible keys for summoning
	if Input.is_action_just_pressed("summoning_space"):
		symbol_invoked.emit("summoning_space")
