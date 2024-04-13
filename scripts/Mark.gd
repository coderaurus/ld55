extends Sprite2D
class_name InvocationMark

func _ready():
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "scale", scale * 2, 2)
	tween.parallel().tween_property(self, "self_modulate", Color.TRANSPARENT, 2)
	tween.tween_callback(queue_free)
