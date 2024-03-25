extends Camera3D

const SPEED = 1

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	# Camera rotation
	if event is InputEventMouseMotion:
		rotation.x += -event.relative.y / 400
		rotation.y += -event.relative.x / 400
	
	# Quit game
	if event is InputEventKey and event.keycode == KEY_ESCAPE: get_tree().quit()

func _physics_process(_delta: float) -> void:
	var input_direction = Vector2(Input.get_axis("strafe_left", "strafe_right"), Input.get_axis("move_forward", "move_backward"))
	var direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	position.x += direction.x * SPEED
	position.z += direction.z * SPEED
	
	if Input.is_action_pressed("sneak"):
		position.y -= SPEED
	elif Input.is_action_pressed("jump"):
		position.y += SPEED
