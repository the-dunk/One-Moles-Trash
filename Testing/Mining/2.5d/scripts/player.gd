extends CharacterBody3D

@export var camera_distance_threshold: float = 10.0

@onready var anim_tree = $AnimationTree
@export var move_speed: float = 10.0

@onready var player_camera: Camera3D = $CameraCenter/PlayerCamera
@onready var camera_target: Node3D = $CameraCenter

@export var tool: Tool

@export var tool_pivot: Node3D
@export var world_voxels: VoxelTerrain

@onready var model: Node3D = $mole
var cursor_plane: Plane

var voxel_tool: VoxelTool

func _ready():
	# Detach the camera from the player so that we can handle movement more smoothly
	player_camera.reparent.call_deferred(get_tree().root)
	
	# Create a plane that faces the front, we use this to raycast mouse position onto for tool rotation
	cursor_plane = Plane(Vector3(0.0,0.0,1.0))
	cursor_plane.d = global_position.z
	
	if(world_voxels):
		voxel_tool = world_voxels.get_voxel_tool()
		voxel_tool.mode = VoxelTool.MODE_REMOVE
		
	pass

func get_input(delta):
	# Get player movement direction-- we don't care about gravity
	var input_direction = Input.get_vector("MOVE_LEFT", "MOVE_RIGHT", "MOVE_FORWARD", "MOVE_BACKWARD")
	velocity = Vector3(input_direction.x, -input_direction.y, 0.0)
	# Assign the animation between idle and walking to the velocity
	
	# Give it speed
	velocity *= move_speed
	# TODO add velocity according to mouse direction if mining
	var intersect = rotate_tool(delta)
	
	if(Input.is_action_pressed("MINE")):
		if(tool.move_speed != 0.0):
			velocity = tool.move_speed * global_position.direction_to(intersect)
		handle_mining(delta)
		
	velocity.z = 0.0
	anim_tree.set("parameters/Mainrun/blend_position", abs(velocity.x))

	pass
	
	
func _physics_process(delta):
	get_input(delta)
	move_and_slide()
	
	pass
	
func _process(delta):
	var cam_distance = (player_camera.global_position - global_position).length()
	if(cam_distance > camera_distance_threshold):
		move_camera(delta, cam_distance)
		
	
	


func move_camera(delta, cam_distance: float) -> void: ## Allows camera to smoothly follow the player.
	# Lerp toward the camera target. The further away, the faster.
	player_camera.global_position = lerp(player_camera.global_position, camera_target.global_position, delta * sqrt(0.5* cam_distance))
	pass
	
func rotate_tool(delta) -> Vector3: ## Rotates the tool's pivot location to look at the mouse position on-screen. Lets the player drill according to mouse position. Returns the location of the intersect for reuse
	var mouse_pos = player_camera.get_viewport().get_mouse_position()
	var from = player_camera.project_ray_origin(mouse_pos)
	var to = player_camera.project_ray_normal(mouse_pos)
	
	var intersect = cursor_plane.intersects_ray(from, to)
	
	# If the mouse is on the left side of the character, flip the rotation, flip back if on the right side.
	# TODO make rotations consistent across the board
	if(global_position.x - intersect.x > 0):
		model.rotation_degrees.y = -90.0
	else:
		model.rotation_degrees.y = 90.0
		pass
		
	# Point at the intersect
	tool_pivot.look_at(intersect, Vector3.UP, true)
	return intersect
	pass

func handle_mining(delta) -> void:
	voxel_tool.do_mesh(tool.true_dig_shape, tool.global_transform, 0.5)
	pass
