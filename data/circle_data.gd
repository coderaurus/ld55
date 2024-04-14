extends Resource
class_name InvocationCircleData

@export_range(3,50)  var invocations: int
@export var cursor_speed: int
@export var has_wasd: bool # chance to have WASD as well
@export var wasd_chance: float # percent for WASD

func _init(p_invocations = 3, p_cursor_speed = 100, p_has_wasd = false, p_chance = 0.0):
	invocations = p_invocations
	cursor_speed = p_cursor_speed
	has_wasd = p_has_wasd
	wasd_chance = p_chance
