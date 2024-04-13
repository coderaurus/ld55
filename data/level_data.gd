extends Resource
class_name LevelData

@export var circles: Array[Resource]
@export var circles_active: int

func _init(p_circles: Array[Resource] = [], p_circles_active = 1):
	circles = p_circles
	circles_active = p_circles_active
