class_name MapGenerator
extends Node

const X_DIST := 100
const Y_DIST := 100
const PLACEMENT_RANDOMNESS := 5
const ROWS := 15
const COLUMNS := 7
const PATHS := 6
const FIGHT_ROOM_WEIGHT := 10.0
const TRAINING_ROOM_WEIGHT := 2.5
const EVENT_ROOM_WEIGHT := 4.0

@export var battle_stats_pool: BattleStatsPool

var random_room_type_weights = {
	Room.Type.FIGHT: 0.0,
	Room.Type.TRAINING: 0.0,
	Room.Type.EVENT: 0.0,
}

var random_room_type_total_weight := 0
var map_data: Array[Array]

# Not using the seed-based RNG here as map is generated upon run start
# May have to revisit if we add more floors in the future, depending on how/when it's done! 
func generate_map() -> Array[Array]:
	map_data = _generate_initial_grid()
	var starting_points := _get_random_starting_points()
	
	for j in starting_points:
		var current_j := j
		for i in ROWS - 1:
			current_j = _setup_connection(i, current_j)
	
	battle_stats_pool.setup()
	
	_setup_boss_room()
	_setup_random_room_weights()
	_setup_room_types()
	
	return map_data

func _setup_connection(i: int, j: int) -> int:
	var next_room: Room
	var current_room := map_data[i][j] as Room
	
	while not next_room or _would_cross_existing_path(i, j, next_room):
		var random_j := clampi(randi_range(j - 1, j + 1), 0, COLUMNS - 1)
		next_room = map_data[i + 1][random_j]
	
	current_room.next_rooms.append(next_room)
	
	return next_room.column

func _would_cross_existing_path(i: int, j: int, room: Room) -> bool:
	var left_neighbour: Room
	var right_neighbour: Room
	
	# if j == 0, there's no left neighbour
	if j > 0:
		left_neighbour = map_data[i][j - 1]
	# if j == COLUMNS - 1, there's no right neighbour
	if j < COLUMNS - 1:
		right_neighbour = map_data[i][j + 1]
		
	# Can't cross in right dir if right neighbour goes left
	if right_neighbour and room.column > j :
		for next_room: Room in right_neighbour.next_rooms:
			if next_room.column < room.column:
				return true
	
	# Can't cross in left dir if left neighbour goes to right
	if left_neighbour and room.column < j:
		for next_room: Room in left_neighbour.next_rooms:
			if next_room.column > room.column:
				return true
	
	return false

func _generate_initial_grid() -> Array[Array]:
	var result: Array[Array] = []
	
	for i in ROWS:
		var adjacent_rooms: Array[Room] = []
		
		for j in COLUMNS:
			var current_room := Room.new()
			var offset := Vector2(randf(), randf()) * PLACEMENT_RANDOMNESS
			current_room.position = Vector2(j * X_DIST, i * -Y_DIST) + offset
			current_room.row = i
			current_room.column = j
			current_room.next_rooms = []
			
			#Boss room has a non-random Y, also further from the rest
			if i == ROWS - 1:
				current_room.position.y = (i + 1) * -Y_DIST
			
			adjacent_rooms.append(current_room)
		
		result.append(adjacent_rooms)
	
	return result

func _get_random_starting_points() -> Array[int]:
	var y_coordinates: Array[int]
	var unique_points: int = 0
	
	while unique_points < 2:
		unique_points = 0
		y_coordinates = []
		
		for i in PATHS:
			var starting_point := randi_range(0, COLUMNS - 1)
			if not y_coordinates.has(starting_point):
				unique_points += 1
			
			y_coordinates.append(starting_point)
		
	return y_coordinates

func _setup_boss_room() -> void:
	var middle := floori(COLUMNS * 0.5)
	var boss_room := map_data[ROWS - 1][middle] as Room
	
	for j in COLUMNS:
		var current_room = map_data[ROWS - 2][j] as Room
		if current_room.next_rooms:
			current_room.next_rooms = [] as Array[Room]
			current_room.next_rooms.append(boss_room)
	
	boss_room.type = Room.Type.BOSS
	boss_room.battle_stats = battle_stats_pool.get_random_battle_for_tier(2)

func _setup_random_room_weights() -> void:
	random_room_type_weights[Room.Type.FIGHT] = FIGHT_ROOM_WEIGHT
	random_room_type_weights[Room.Type.TRAINING] = FIGHT_ROOM_WEIGHT + TRAINING_ROOM_WEIGHT
	random_room_type_weights[Room.Type.EVENT] = FIGHT_ROOM_WEIGHT + TRAINING_ROOM_WEIGHT + EVENT_ROOM_WEIGHT
	
	random_room_type_total_weight = random_room_type_weights[Room.Type.EVENT]

func _setup_room_types() -> void:
	# First row is always a fight
	for room: Room in map_data[0]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.FIGHT
			room.battle_stats = battle_stats_pool.get_random_battle_for_tier(0)
	
	# Second row is always a character
	for room: Room in map_data[1]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.CHARACTER
			
	# Tenth row is always a character
	for room: Room in map_data[9]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.CHARACTER
			
	# last row before boss is always a training hall(?)
	for room: Room in map_data[ROWS - 2]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.TRAINING
	
	# all other rooms
	for current_row in map_data:
		for room: Room in current_row:
			for next_room: Room in room.next_rooms:
				if next_room.type == Room.Type.NOT_ASSIGNED:
					_set_room_randomly(next_room)

func _set_room_randomly(room_to_set: Room) -> void:
	# Room restrictions, possibly subject to change!
	var training_below_4 := true
	var consecutive_training := true
	var consecutive_event := true
	var training_on_third_last := true
	
	var type_candidate: Room.Type
	
	while training_below_4 or consecutive_training or consecutive_event or training_on_third_last:
		type_candidate = _get_random_room_type_by_weight()
		
		var is_training := type_candidate == Room.Type.TRAINING
		var has_training_parent := _room_has_parent_of_type(room_to_set, Room.Type.TRAINING)
		var is_event := type_candidate == Room.Type.EVENT
		var has_event_parent := _room_has_parent_of_type(room_to_set, Room.Type.EVENT)
		
		training_below_4 = is_training and room_to_set.row < 3
		consecutive_training = is_training and has_training_parent
		consecutive_event = is_event and has_event_parent
		training_on_third_last = is_training and room_to_set.row == ROWS - 3
		
	room_to_set.type = type_candidate
	
	if type_candidate == Room.Type.FIGHT:
		var fight_tier := 0
		if room_to_set.row > 2:
			fight_tier = 1
		
		room_to_set.battle_stats = battle_stats_pool.get_random_battle_for_tier(fight_tier)

func _room_has_parent_of_type(room: Room, type: Room.Type) -> bool:
	var parents: Array[Room] = []
	# left parent
	if room.column > 0 and room.row > 0:
		var parent_candidate := map_data[room.row - 1][room.column - 1] as Room
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	# parent below
	if room.row > 0:
		var parent_candidate := map_data[room.row - 1][room.column] as Room
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	# right parent
	if room.column < COLUMNS - 1 and room.row > 0:
		var parent_candidate := map_data[room.row - 1][room.column + 1] as Room
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	
	for parent: Room in parents:
		if parent.type == type:
			return true
	
	return false

func _get_random_room_type_by_weight() -> Room.Type:
	var roll := randf_range(0.0, random_room_type_total_weight)
	
	for type: Room.Type in random_room_type_weights:
		if random_room_type_weights[type] > roll:
			return type
	
	return Room.Type.FIGHT
