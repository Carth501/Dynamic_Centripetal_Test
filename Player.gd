extends CharacterBody3D

@export var up_vector_display : Label
@export var camera_pivot : Node3D
@export var camera : Camera3D
@export var speed := 2.0
@export var jump_speed := 8.0
var mouse_sensitivity := 0.002

# This project assumes that the axis of rotation is the z axis.
# This version of the project has the larger system doing the true rotation
# It is more reliant on the physics system, for better (a bunch of math is
# not being repeated) and worse (everything is in motion, with the exception of
# the stuff that looks to be moving the fastest).

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(_delta):
	# This is used to orient subjective "up"
	var up_vector = Vector3(0, 0, position.z) - position
	if(up_vector == Vector3.ZERO):
		var drift = slight_drift()
		velocity = drift
		up_vector = drift
	up_vector_display.text = str(up_vector)
	# set_up_direction is used to detect the relative "floor"
	set_up_direction(up_vector)
	# deciding the angle to "up", based entirely off the x and y axis.
	var angle = Vector2(position.x, position.y).angle()
	# the character body technically always faces along the long axis.
	set_rotation(Vector3(0, 0, angle + deg_to_rad(90)))
	apply_controls()
	up_vector_display.text += str("\nis_on_floor ", is_on_floor())
	move_and_slide()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("click") && Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# fps code based on https://kidscancode.org/godot_recipes/4.x/3d/basic_fps/
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clampf(camera.rotation.x, -deg_to_rad(85), deg_to_rad(80))

func apply_controls():
	# more code based on https://kidscancode.org/godot_recipes/4.x/3d/basic_fps/
	if(is_on_floor()):
		var input = Input.get_vector("left", "right", "forward", "backward")
		var movement_dir = basis * camera_pivot.basis * Vector3(input.x, 0, input.y)
		up_vector_display.text += str("\n", movement_dir)
		velocity.x = movement_dir.x * speed
		velocity.y = movement_dir.y * speed
		velocity.z = movement_dir.z * speed
		if Input.is_action_just_pressed("jump"):
			jump()
	else:
		up_vector_display.text += str("\n", Vector3.ZERO)

func jump():
	# using the camera piviot basis or this characterbody basis is identical
	var jump_dir = basis * Vector3(0, jump_speed, 0)
	# again, we need to account for motion on both the x and y axis
	velocity.x += jump_dir.x
	velocity.y += jump_dir.y

func slight_drift() -> Vector3:
	print("slight drift")
	# In case the player is ever at 0, 0, 0 exactly
	# we create some slight drift.
	var rnd = RandomNumberGenerator.new()
	rnd.randomize()
	return Vector3(rnd.randfn(), rnd.randfn(), 0)
