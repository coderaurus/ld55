extends Sprite2D
class_name RitualBeat

var beat_at = 0 # 0 - 360
var required_invocation = ""
# for missing
var invocation_grace_range = 10 
# 0 - miss, 1-10 = % distance within grace_range (10 = on point)
var invocation_grade = 0

var active = true
var reached = false
var invoked = false

func setup(beat):
	beat_at = beat

func fizzle():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "self_modulate", Color(self_modulate, 0.3), 1.0)

func on_invoked():
	invoked = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", scale * 1.25, 1.0).set_trans(Tween.TRANS_ELASTIC)
