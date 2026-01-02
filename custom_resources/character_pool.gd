class_name CharacterPool
extends Resource

@export var pool: Array[CharacterStats]

var total_rng_weight: float

func get_all_characters_of_rarity(rarity: CharacterStats.Rarity) -> Array[CharacterStats]:
	return pool.filter(
		func(character: CharacterStats):
			return character.rarity == rarity
	)

func setup_rng_weights() -> void:
	total_rng_weight = 0
	for character: CharacterStats in get_all_characters_of_rarity(CharacterStats.Rarity.COMMON):
		total_rng_weight += 1.5
		character.rng_cumulative_weight = total_rng_weight
	for character: CharacterStats in get_all_characters_of_rarity(CharacterStats.Rarity.UNCOMMON):
		total_rng_weight += 1.0
		character.rng_cumulative_weight = total_rng_weight

func get_random_character() -> CharacterStats:
	var roll: float = RNG.random_float_range(0.0, total_rng_weight)
	
	for character: CharacterStats in pool:
		if character.rng_cumulative_weight > roll:
			return character
	
	return null
