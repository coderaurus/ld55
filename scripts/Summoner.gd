extends Node2D
class_name Summoner

@onready var body = $Body
@onready var right_hand = $RightHand
@onready var left_hand = $LeftHand

var tween: Tween
var right_hand_pos_origin 
var left_hand_pos_origin

func _ready():
	right_hand_pos_origin = $RightHand.global_position + Vector2.UP * 300
	left_hand_pos_origin = $LeftHand.global_position + Vector2.UP * 300

func lower_hands():
	if tween != null and tween.is_running():
		tween.custom_step(25)
	tween = get_tree().create_tween()
	
	right_hand.frame = 0
	left_hand.frame = 0
	
	tween.tween_property(right_hand, "global_position", right_hand_pos_origin + Vector2.DOWN * 300, 0.3)
	tween.parallel().tween_property(left_hand, "global_position", left_hand_pos_origin + Vector2.DOWN * 300, 0.3)

func raise_hands():
	if tween != null and tween.is_running():
		tween.custom_step(25)
	tween = get_tree().create_tween()
	
	tween.tween_property(right_hand, "global_position", right_hand_pos_origin, 0.3)
	tween.parallel().tween_property(left_hand, "global_position", left_hand_pos_origin, 0.2)

func on_beat_hit(distance = 0, pos = Vector2.ZERO):
	_change_hand_signs()

func on_beat_miss(distance = 0, pos = Vector2.ZERO):
	_change_hand_signs(true)

func _change_hand_signs(failed = false):
	var chosen_sign = randi_range(0, 2)
	if chosen_sign == right_hand.frame:
		chosen_sign = wrapi(chosen_sign + 1, 0, 2)
	
	var right_hand_pos = right_hand_pos_origin + Vector2.LEFT * 64
	var right_hand_pos_closed = right_hand_pos_origin + Vector2.RIGHT * 48
	var left_hand_pos = left_hand_pos_origin + Vector2.RIGHT * 64
	var left_hand_pos_closed = left_hand_pos_origin + Vector2.LEFT * 48
		
	var durations = [0.5, 0.0, 0.3, 0.2]
	
	if tween != null and tween.is_running():
		tween.custom_step(10)
	
	tween = get_tree().create_tween()
	# hands apart
	tween.tween_property(right_hand, "global_position", right_hand_pos, durations[0])\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(left_hand, "global_position", left_hand_pos, durations[0])\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	
	if failed:
		# cast
		tween.tween_property(right_hand, "global_position", right_hand_pos_origin, durations[2])\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.5)
		tween.parallel().tween_property(left_hand, "global_position", left_hand_pos_origin, durations[2])\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.5)
		tween.tween_property(right_hand, "global_position", right_hand_pos_origin, durations[2])\
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN).set_delay(0.5)
		tween.parallel().tween_property(left_hand, "global_position", left_hand_pos_origin, durations[2])\
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN).set_delay(0.5)
	else:
		# cast
		tween.tween_property(right_hand, "global_position", right_hand_pos_closed, durations[2])\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(left_hand, "global_position", left_hand_pos_closed, durations[2])\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		# signs
		tween.parallel().tween_property(right_hand, "frame", chosen_sign, durations[1])\
		.set_delay(durations[2]*0.4)
		tween.parallel().tween_property(left_hand, "frame", chosen_sign, durations[1])\
		.set_delay(durations[2]*0.4)
		# retract
		tween.tween_property(right_hand, "global_position", right_hand_pos_origin, durations[3])
		tween.parallel().tween_property(left_hand, "global_position", left_hand_pos_origin, durations[3])
