extends CharacterBody3D


const SPEED = 10.0
const JUMP_VELOCITY = 10
enum shoulder_position {RIGHT, LEFT}

@export var shoulder_offset = 0.2


@export var look_sensitivity_horizontal = 1
@export var look_sensitivity_vertical = 1
@export var inverse_vertical = 1
@export var shoulder: shoulder_position = shoulder_position.RIGHT

@export var tool_reach: float = 5.0
@export var tool_starting_radius: float = 0.1
@export var tool_max_radius: float = 2.0
@export var tool_speed: float = 3.0

var current_radius = tool_starting_radius

@onready var camera_joint: Node3D = $Joint
@onready var hands: Node3D = $Hands

@onready var pointer: Node3D = $Pointer

@export var world_voxels: VoxelTerrain

@export var tool_equipped: bool = true

var switching_shoulders: bool = true


var is_mining: bool = false

var targeted_position: Vector3
var targeted_voxel: VoxelRaycastResult

var voxel_tool : VoxelTool

func _ready() -> void:
	if(world_voxels):
		voxel_tool = world_voxels.get_voxel_tool()
		voxel_tool.mode = VoxelTool.MODE_REMOVE
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	look_sensitivity_horizontal = look_sensitivity_horizontal / 1000.0
	look_sensitivity_vertical = look_sensitivity_vertical / 1000.0
	pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
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

	move_and_slide()

func _process(delta: float) -> void:
	if(switching_shoulders):
		switch_shoulder(delta)
	
	if(world_voxels and not is_mining):
		var space = get_world_3d().direct_space_state
		var raycast_query = PhysicsRayQueryParameters3D.create(hands.global_position, hands.global_position - (hands.global_basis.z * tool_reach))
		var smooth_raycast = space.intersect_ray(raycast_query)
		var raycast_from_hands = voxel_tool.raycast(hands.global_position, -hands.global_basis.z ,tool_reach)
		if(raycast_from_hands != null):
			targeted_voxel = raycast_from_hands
			targeted_position = targeted_voxel.position
		else:
			targeted_voxel = null
			pointer.visible = false
		if(smooth_raycast):
			pointer.global_position = smooth_raycast.position
			pointer.visible = true
		
			
			
		pass
	
	if(world_voxels and is_mining):
		pointer.global_position = targeted_position
		voxel_tool.do_sphere(targeted_position, current_radius)
		current_radius += (delta * tool_speed)
		current_radius = clampf(current_radius, tool_starting_radius, tool_max_radius)
		if(current_radius == tool_max_radius):
			is_mining = false
		pass
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var relative = event.relative 
		rotate_y(-relative.x * look_sensitivity_horizontal)
		camera_joint.rotation.x = clampf(camera_joint.rotation.x + (relative.y * look_sensitivity_vertical * -inverse_vertical), -1.0, 1.0)
		hands.rotation.x = camera_joint.rotation.x
	else:
		if event.is_action_pressed("MENU"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			
		elif event.is_action_pressed("MINE"):
			if(targeted_voxel != null):
				is_mining = true
		elif event.is_action_released("MINE"):
			is_mining = false
			current_radius = tool_starting_radius
			pass
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
