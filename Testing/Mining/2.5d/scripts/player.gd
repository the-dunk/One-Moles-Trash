extends CharacterBody3D

@export var camera_distance_threshold: float = 10.0

@onready var anim_tree = $AnimationTree
@export var move_speed: float = 10.0
@onready var player_camera: Camera3D = $CameraCenter/PlayerCamera
@onready var camera_target: Node3D = $CameraCenter
@export var tool_pivot: Node3D

@onready var model: Node3D = $mole
var cursor_plane: Plane

func _ready():
	# Detach the camera from the player so that we can handle movement more smoothly
	player_camera.reparent.call_deferred(get_tree().root)
	
	# Create a plane that faces the front, we use this to raycast mouse position onto for tool rotation
	cursor_plane = Plane(Vector3(0.0,0.0,-1.0))
	pass

func get_input():
	# Get player movement direction-- we don't care about gravity
	var input_direction = Input.get_vector("MOVE_LEFT", "MOVE_RIGHT", "MOVE_FORWARD", "MOVE_BACKWARD")
	velocity = Vector3(input_direction.x, -input_direction.y, 0.0)
	# Assign the animation between idle and walking to the velocity
	anim_tree.set("parameters/Mainrun/blend_position", abs(velocity.x))
	
	# Give it speed
	velocity *= move_speed
	# TODO add velocity according to mouse direction if mining
	
	pass
	
	
func _physics_process(delta):
	get_input()
	move_and_slide()
	pass
	
func _process(delta):
	var cam_distance = (player_camera.global_position - global_position).length()
	if(cam_distance > camera_distance_threshold):
		move_camera(delta, cam_distance)
		
	rotate_tool(delta)
	


func move_camera(delta, cam_distance: float) -> void: ## Allows camera to smoothly follow the player.
	# Lerp toward the camera target. The further away, the faster.
	player_camera.global_position = lerp(player_camera.global_position, camera_target.global_position, delta * sqrt(0.5* cam_distance))
	pass
	
func rotate_tool(delta): ## Rotates the tool's pivot location to look at the mouse position on-screen. Lets the player drill according to mouse position.
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
	tool_pivot.look_at(intersect)
	pass
