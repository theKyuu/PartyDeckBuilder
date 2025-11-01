class_name RunStartup
extends Resource

enum Type {NEW_RUN, CONTINUED_RUN}

@export var type: Type
@export var player_team: TeamStats
@export var starting_character: CharacterStats #May or may not be needed?
