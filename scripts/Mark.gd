extends Sprite2D
class_name InvocationMark

func _ready():
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "scale", scale * 2, 1.5).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "self_modulate", Color.TRANSPARENT, 1.5).set_ease(Tween.EASE_OUT)
	tween.tween_callback(queue_free)
