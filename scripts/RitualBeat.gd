extends Sprite2D
class_name RitualBeat

var beat_at = 0 # 0 - 360
var required_invocation = ""
# for missing
var invocation_grace_range = 14 
# 0 - miss, 1-10 = % distance within grace_range (10 = on point)
var invocation_grade = 0

var active = true
var reached = false
var invoked = false


func setup(beat, requirement):
	print("Setting up %s %s" % [beat, requirement])
	beat_at = beat
	
	if requirement == "summoning_right" or requirement == "summoning_d":
			rotation = deg_to_rad(90)
	elif requirement == "summoning_down" or requirement == "summoning_s":
			rotation = deg_to_rad(180)
	elif requirement == "summoning_left" or requirement == "summoning_a":
			rotation = deg_to_rad(270)
	
	if requirement == "summoning_w" or requirement == "summoning_d" or \
	requirement == "summoning_s" or requirement == "summoning_a":
		self_modulate = Color.REBECCA_PURPLE
	
	required_invocation = requirement

func fizzle():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "self_modulate", Color(self_modulate, 0.3), 1.0)

func on_invoked():
	invoked = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", scale * 1.25, 1.0).set_trans(Tween.TRANS_ELASTIC)

func requires(invocation):
	print("Incoming(%s) => Has(%s)" % [invocation, required_invocation])
	return required_invocation == invocation or required_invocation == "any"
