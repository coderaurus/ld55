extends Resource
class_name InvocationCircleData

@export_range(3,50)  var invocations: int
@export var cursor_speed: int
@export var uses_arrows: bool # either arrows or WASD

func _init(p_invocations = 3, p_cursor_speed = 100, p_uses_arrows = true):
	invocations = p_invocations
	cursor_speed = p_cursor_speed
	uses_arrows = p_uses_arrows
