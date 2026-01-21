@icon("res://Assets/Types/Digging/Tool/tool.png")
extends Node3D

class_name Tool ## Defines a tool object with required parameters. Additionally, a Tool should have a Node3D child that contains the model and MeshInstance3D children containing the dig areas.



@export var move_speed: float ## Determines the speed that the player will move while mining with this tool-- 0 ensures the tool does not cause movement.
@export_range(0.0, 100.0) var strength: float ## Determines the overall strength of the tool. Higher strength tools can damage stronger materials, but can quickly damage items.
@export_range(0.0, 100.0) var precision: float ## Determines how much control the player has over dig speed and radius.
@export var min_dig_shape: VoxelMeshSDF ## Determines the smallest area that the tool can dig. Lerps to max_dig_shape determined by selected precision.
@export var max_dig_shape: VoxelMeshSDF ## Determines the largest area that the tool can dig. Lerps to min_dig_shape determined by selected precision.
var true_dig_shape: VoxelMeshSDF ## The calculated dig shape from the other dig shapes
func _init(_move_speed: float = 0.0, _strength: float = 0.0, _precision: float = 50.0):
	strength = _strength
	precision = _precision
	true_dig_shape = VoxelMeshSDF.new()
	

func _ready():
	true_dig_shape = min_dig_shape
	
	

	
	
