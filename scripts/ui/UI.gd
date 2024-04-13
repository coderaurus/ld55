extends CanvasLayer

@onready var beat_hit_text_scene = preload("res://scene/ui/beat_hit_text.tscn")


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
	add_child(text_scene)
	#text_scene.global_position = Vector2(690, 360)
	pos.x = randi_range(pos.x - 32, pos.x + 32)
	pos.y = randi_range(pos.y - 32, pos.y + 32)
	text_scene.position = pos
	text_scene.pop(message, text_color)
