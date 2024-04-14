extends CPUParticles2D
class_name SplashParticle

func emit(p_amount = 12, p_velocity=35, damp = 7):
	direction = Vector2(randi_range(-1, 1), randi_range(-1, 1))
	amount = p_amount
	initial_velocity_max = p_velocity
	initial_velocity_min = p_velocity/2
	emitting = true
