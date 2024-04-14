extends Sprite2D

var bounds: Vector2 = Vector2(690, 520)
var is_new = true
var is_on_left = true

func appear():
	if is_new:
		is_new = false
	var pos = Vector2(0, 0)
	pos.y = bounds.y + randi_range(0, 64)
	if not is_on_left:
		pos.x = randi_range(900, 1264)
	else:
		pos.x = randi_range(32, 380)
	
	if pos.x < global_position.x:
		flip_h = true
	else:
		flip_h = false
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", pos, randf_range(0.9, 1.5)).set_ease(Tween.EASE_OUT)

func disappear():
	if is_new:
		is_new = false
		return
	
	var pos = Vector2(0, 0)
	pos.y = bounds.y + randi_range(64, 96)
	
	if is_on_left:
		pos.x = -128
	else:
		pos.x += 1418
	
	if pos.x < global_position.x:
		flip_h = true
	else:
		flip_h = false
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", pos, randf_range(1.0, 1.75)).set_ease(Tween.EASE_IN)
