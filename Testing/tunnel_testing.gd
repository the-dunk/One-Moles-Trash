extends CharacterBody3D


const SPEED = 10.0
const JUMP_VELOCITY = 10
enum shoulder_position {RIGHT, LEFT}

@export var shoulder_offset = 0.2


@export var look_sensitivity_horizontal = 1
@export var look_sensitivity_vertical = 1
@export var inverse_vertical = 1
@export var shoulder: shoulder_position = shoulder_position.RIGHT


@onready var camera_joint: Node3D = $Joint

@onready var pointer: Node3D = $Pointer

@export var world_voxels: VoxelTerrain

@export var tool_equipped: bool = true

var switching_shoulders: bool = true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	look_sensitivity_horizontal = look_sensitivity_horizontal / 1000.0
	look_sensitivity_vertical = look_sensitivity_vertical / 1000.0
	pass

func _physics_process(delta: float) -> void:
	# Add the gravity.

	if Input.is_action_just_pressed("LOWER"):
		velocity.y = -JUMP_VELOCITY
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("MOVE_LEFT", "MOVE_RIGHT", "MOVE_FORWARD", "MOVE_BACKWARD")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		

	move_and_slide()

func _process(delta: float) -> void:
	if(switching_shoulders):
		switch_shoulder(delta)
	
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var relative = event.relative 
		rotate_y(-relative.x * look_sensitivity_horizontal)
		camera_joint.rotation.x = clampf(camera_joint.rotation.x + (relative.y * look_sensitivity_vertical * -inverse_vertical), -1.0, 1.0)
	else:
		if event.is_action_pressed("MENU"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		if event.is_action_pressed("SWITCH_SHOULDER"):
			switching_shoulders = true
			if (shoulder == shoulder_position.RIGHT):
				shoulder = shoulder_position.LEFT
			else:
				shoulder = shoulder_position.RIGHT
	pass
	
	
func switch_shoulder(d: float) -> void:
	d = d * 30.0
	if(shoulder == shoulder_position.RIGHT):
		camera_joint.position = camera_joint.position.move_toward(Vector3.RIGHT * shoulder_offset, d)
		if(camera_joint.position.distance_squared_to(Vector3.RIGHT * shoulder_offset) < 0.5):
			camera_joint.position = Vector3.RIGHT * shoulder_offset
			switching_shoulders = false
	if(shoulder == shoulder_position.LEFT):
		camera_joint.position = camera_joint.position.move_toward(Vector3.LEFT * shoulder_offset, d)
		if(camera_joint.position.distance_squared_to(Vector3.LEFT * shoulder_offset) < 0.5):
			camera_joint.position = Vector3.LEFT * shoulder_offset
			switching_shoulders = false
	print(camera_joint.position)
	pass
