extends Node2D

signal symbol_invoked

func _ready():
	symbol_invoked.connect(get_parent().on_invoke)

func _process(delta):
	# MAP possible keys for summoning
	if Input.is_action_just_pressed("summoning_space"):
		symbol_invoked.emit("summoning_space")
