extends Label
class_name BeatHitText

func pop(txt, c = Color.WHITE):
	text = txt
	self_modulate = c
	
	var tween = get_tree().create_tween()
	var upper_rect = get_rect().position
	tween.tween_property(self, "self_modulate", c, 0.4).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "position", position + Vector2.UP * 12, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "scale", scale * 1.5, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", position, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "self_modulate", Color(c, 0), 0.5).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)
