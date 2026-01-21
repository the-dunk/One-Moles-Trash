extends CharacterBody2D

# Base move speed
@export var speed: float = 400.0
# Speed provided by a given tool (applied when digging)
@export var tool_speed: float = 400.0

@onready var ground: Node2D

func _ready():
	ground = get_tree().root.get_node("Ground")

func get_input():
	var input_direction = Input.get_vector("MOVE_LEFT", "MOVE_RIGHT", "MOVE_FORWARD", "MOVE_BACKWARD")
	

	if(Input.is_action_pressed("MINE")):
		input_direction = global_position.direction_to(get_global_mouse_position())
	
	velocity = input_direction * speed
	pass

func _physics_process(delta):
	get_input()
	move_and_slide()
	pass

func _process(delta):
	$Tool.look_at(get_global_mouse_position())
	pass




func _unhandled_input(event):
	pass
