extends Sprite2D

var bounds: Vector2 = Vector2(690, 360)

func _ready():
	appear()

func appear():
	var pos = Vector2(0, 0)
	pos.y = bounds.y + randi_range(0, 96)
	pos.x = randi_range(16, 1264)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", pos, 1.0).set_ease(Tween.EASE_OUT)
	
	tween.tween_callback(disappear).set_delay(1.0)

func disappear():
	var pos = Vector2(0, 0)
	pos.y = bounds.y + randi_range(0, 96)
	
	if randf() > 0.5:
		pos.x = -96
	else:
		pos.x += 1376
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", pos, 1.5).set_ease(Tween.EASE_IN)
	
	tween.tween_callback(appear).set_delay(1.0)
