extends Resource
class_name GroundMaterial ## Used to define a material that makes up terrain.


@export
var name:String ## The name of the material

@export
var hardness:float ## The hardness of the material. This determines required strength to damage the material.

@export
var has_gravity: bool ## Does the material obey gravity when separated?

func _init(_name: String, _hardness: float = 1.0, _has_gravity: bool = false):
	name = _name
	hardness = _hardness
	has_gravity = _has_gravity
	
