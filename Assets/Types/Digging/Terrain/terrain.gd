extends Resource


class_name Terrain ## Defines the properties of a terrain or region.

@export var name: String ## Name of the terrain

@export_range (0.0, 5.0, 0.5) var difficulty_rating: float  ## Used to display the difficulty rating to the player, does not actually impact the difficulty
