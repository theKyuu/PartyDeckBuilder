class_name TeamSpriteContainer
extends Control

@export var team_sprites: Array[Texture]

@onready var spot_1: TextureRect = $Spot1
@onready var spot_2: TextureRect = $Spot2
@onready var spot_3: TextureRect = $Spot3
@onready var spot_4: TextureRect = $Spot4
@onready var spot_5: TextureRect = $Spot5

const MEDIUM = Vector2(300, 250)
const LARGE = Vector2(300, 300)

func _ready() -> void:
	team_sprites = []
	for spot: TextureRect in get_children():
		spot.texture = null

func set_team_layout() -> void:
	match team_sprites.size():
		0:
			return
		1:
			spot_3.texture = team_sprites[0]
			custom_minimum_size = MEDIUM
		2:
			spot_1.texture = team_sprites[0]
			spot_3.texture = team_sprites[1]
			custom_minimum_size = MEDIUM
		3:
			spot_1.texture = team_sprites[0]
			spot_2.texture = team_sprites[1]
			spot_3.texture = team_sprites[2]
			custom_minimum_size = MEDIUM
		4:
			spot_1.texture = team_sprites[0]
			spot_2.texture = team_sprites[1]
			spot_4.texture = team_sprites[2]
			spot_5.texture = team_sprites[3]
			custom_minimum_size = LARGE
		5:
			spot_1.texture = team_sprites[0]
			spot_2.texture = team_sprites[1]
			spot_3.texture = team_sprites[2]
			spot_4.texture = team_sprites[3]
			spot_5.texture = team_sprites[4]
			custom_minimum_size = LARGE
		_:
			return
