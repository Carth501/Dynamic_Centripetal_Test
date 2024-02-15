extends AnimatableBody3D

var rotational_velocity : float = 1.824

func _physics_process(delta):
	rotate(Vector3.FORWARD, rotational_velocity * delta)
