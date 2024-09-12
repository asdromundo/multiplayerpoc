extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var camera_mount = $CameraMount
@onready var character = $GDbotSkin
@export var camera_sensibility : float = 1.0
var camera_speed = camera_sensibility * .005

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	character._set_walk_run_blending(0.75)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * camera_speed)
		camera_mount.rotate_x(-event.relative.y * camera_speed)
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, -PI/8, PI/4)

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
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		character.look_at(position - direction)
		
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
