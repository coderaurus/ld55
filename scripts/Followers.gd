extends Node2D
class_name Followers

@onready var follower_scene = preload("res://scene/follower.tscn")

func group_appear():
	var group = get_children()
	for c in group:
		c.appear()

func group_disappear():
	var group = get_children()
	for c in group:
		c.disappear()

func add_follower(amount = 1):
	for i in amount:
		var side_x = [-128, 1408]
		var side = randi_range(0,1)
		var pos = Vector2(side_x[side], 520)
		var f = follower_scene.instantiate()
		if side == 1:
			f.is_on_left = false
		add_child(f)
		f.global_position = pos
