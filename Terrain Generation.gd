extends GridMap

enum WorldType {
	DEFAULT,
	FLAT,
	AMPLIFIED,
	LARGE_BIOMES,
	SINGLE_BIOME,
	DEBUG
}

@export var world_type: WorldType 

const CHUNK_SIZE = 32
const CHUNK_HEIGHT = 256
const WATER_LEVEL = 0
const MOUNTAIN_HEIGHT = 32
const RENDER_DISTANCE = 3

var world_seed = randi()

var terrain := FastNoiseLite.new()
var height := FastNoiseLite.new()
var caves := FastNoiseLite.new()

@export var player: Node3D

var last_loaded_chunk_position: Vector3i

const block_types = {
	"air": {
		"id": -1
	},
	"bedrock": {
		"id": 0
	},
	"stone": {
		"id": 1
	},
	"grass": {
		"id": 2
	},
	"water": {
		"id": 3
	}
}

class Block:
	var id: int

func _ready() -> void:
	height.seed = world_seed
	caves.fractal_type = FastNoiseLite.FRACTAL_PING_PONG
	#_generate_chunk(Vector3i.ZERO)

func _process(_delta: float) -> void:
	var chunk_position := _calculate_chunk_position(player.global_position)
	
	if last_loaded_chunk_position:
		if chunk_position != last_loaded_chunk_position:
			last_loaded_chunk_position = chunk_position
			_generate_chunk(chunk_position)
	else:
		last_loaded_chunk_position = chunk_position
		_generate_chunk(chunk_position)

func _generate_chunk(target_position: Vector3i) -> void:
	for x in _chunk_range(target_position.x):
		for z in _chunk_range(target_position.z):
			for y in _chunk_range(target_position.y):
				match world_type:
					WorldType.DEFAULT:
						var item: int = -1
						
						var height_noise = height.get_noise_2d(x, z) * MOUNTAIN_HEIGHT
						var cave_noise = caves.get_noise_3d(x, y, z)
						
						if height_noise > y: item = 1
						
						if y <= WATER_LEVEL and item == -1: item = block_types.water.id
						
						#if cave_noise < 0: item = -1
						
						set_cell_item(Vector3i(x, y, z), item)
					WorldType.FLAT:
						var item: int = -1
						match y:
							0: item = 2
							-1: item = 1
							-2: item = 0
						set_cell_item(Vector3i(x, y, z), item)

func _chunk_range(offset: int) -> Array:
	return range(offset - CHUNK_SIZE / 2, offset + CHUNK_SIZE / 2)

func _calculate_chunk_position(player_position: Vector3) -> Vector3i:
	return Vector3i(
		snappedi(player_position.x, CHUNK_SIZE),
		snappedi(player_position.y, CHUNK_SIZE),
		snappedi(player_position.z, CHUNK_SIZE),
	)
