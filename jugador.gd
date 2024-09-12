extends CharacterBody3D

const SPEED = 5
const JUMP_VELOCITY = 5.5
@onready var camera_3d = $Camera3D
@onready var character = $GDbotSkin

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	character._set_walk_run_blending(0.75)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera_3d.rotate_x(-event.relative.y * .005)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, -PI/4, PI/4)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.y > 0:
			character.jump()
		else:
			character.fall()

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()

	# Only rotate if there's movement
	if direction.length() > 0:
		# Rotate the character to face the direction of movement
		look_at(global_transform.origin + direction * delta, Vector3.UP)
		## Suavizar la rotación del personaje en la dirección del movimiento.
		#var target_rotation = direction.angle_to(Vector3.FORWARD)
		#rotation.y = lerp_angle(rotation.y, target_rotation, 2.0 * delta)

		# Apply movement
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		if is_on_floor():
			character.walk()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if velocity == Vector3.ZERO:
		character.idle()
	
	move_and_slide()
