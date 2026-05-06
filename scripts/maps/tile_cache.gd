extends Node

const CACHE_DIR = "user://tile_cache/"

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(CACHE_DIR)

func get_cache_path(tile_coord: Vector2i, zoom: int) -> String:
	return CACHE_DIR + "%d_%d_%d.jpg" % [zoom, tile_coord.x, tile_coord.y]

func has_tile(tile_coord: Vector2i, zoom: int) -> bool:
	return FileAccess.file_exists(get_cache_path(tile_coord, zoom))

func save_tile(tile_coord: Vector2i, zoom: int, body: PackedByteArray) -> void:
	var path = get_cache_path(tile_coord, zoom)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(body)

func load_tile(tile_coord: Vector2i, zoom: int) -> ImageTexture:
	var img = Image.load_from_file(get_cache_path(tile_coord, zoom))
	return ImageTexture.create_from_image(img)
