extends Control

@export var zoom = 10

@onready var world_to_cords: Node = $WorldToCords
@onready var cord_to_tile_num: Node = $CordToTileNum
@onready var tile_cache: Node = $TileCache

var lat = 45.4215
var lng = -75.6972

const TILE_SIZE = 256
const LOAD_TRIGGER_RADIUS = 1
const UNLOAD_RADIUS = 5 

var chunk_radius = 3 # 7x7 grid around player
var loaded_chunks = {}
var current_center_tile = Vector2i(-9999, 9999)

var anchor_tile: Vector2i  

func _ready() -> void:
	anchor_tile = cord_to_tile_num.deg2num(lat, lng, zoom)
	
	chunk_radius = 5 # make it big at the start so then the player wounldn't see any empty spots
	
	await get_tree().create_timer(0.15).timeout # wait for player to be ready
	
	if Global.player:
		var lat_lng = world_to_cords.world_to_latlng(Global.player.position)
		var tile = cord_to_tile_num.deg2num(lat_lng.x, lat_lng.y, zoom)
		current_center_tile = tile
		update_chunks(tile)
		
	chunk_radius = 2
	
func _process(_delta: float) -> void:
	if not Global.player:
		return
	
	var lat_lng = world_to_cords.world_to_latlng(Global.player.position)
	var tile = cord_to_tile_num.deg2num(lat_lng.x, lat_lng.y, zoom)
	
	var diff = (tile - current_center_tile).abs()
	if diff.x >= LOAD_TRIGGER_RADIUS or diff.y >= LOAD_TRIGGER_RADIUS:
		current_center_tile = tile
		update_chunks(tile)

func update_chunks(center: Vector2i) -> void:
	for x in range(-chunk_radius, chunk_radius + 1):
		for y in range(-chunk_radius, chunk_radius + 1):
			var tile_coord = center + Vector2i(x, y)
			
			if not loaded_chunks.has(tile_coord):
				load_chunk(tile_coord)

	for coord in loaded_chunks.keys():
		if loaded_chunks[coord] == null:
			continue
			
		if abs(coord.x - center.x) > UNLOAD_RADIUS or abs(coord.y - center.y) > UNLOAD_RADIUS:
			loaded_chunks[coord].queue_free()
			loaded_chunks.erase(coord)
			
func load_chunk(tile_coord: Vector2i) -> void:
	loaded_chunks[tile_coord] = null

	# serve from cache if have
	if tile_cache.has_tile(tile_coord, zoom):
		var tex = tile_cache.load_tile(tile_coord, zoom)
		_spawn_chunk_sprite(tex, tile_coord)
		return

	# otherwise get from api
	var url = "https://api.mapbox.com/styles/v1/mapbox/satellite-v9/tiles/256/%d/%d/%d?access_token=%s" % [zoom, tile_coord.x, tile_coord.y, GMap.api_key]

	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(result, code, headers, body):
		_on_chunk_loaded(result, code, body, tile_coord, http)
	)
	http.request(url)

func _on_chunk_loaded(result, code, body, tile_coord: Vector2i, http: HTTPRequest) -> void:
	http.queue_free()
	
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		print("chunk failed, code: ", code)
		loaded_chunks.erase(tile_coord)
		return
	
#	test the image before saving
	var img = Image.new()
	var err = img.load_jpg_from_buffer(body)
	if err != OK:
		print("bad image data for tile: ", tile_coord)
		loaded_chunks.erase(tile_coord)
		return
		
	# save to cache before spawning
	tile_cache.save_tile(tile_coord, zoom, body)
	var tex = ImageTexture.create_from_image(img)
	_spawn_chunk_sprite(tex, tile_coord)

func _spawn_chunk_sprite(tex: ImageTexture, tile_coord: Vector2i) -> void:
	var sprite = Sprite2D.new()
	sprite.texture = tex
	sprite.centered = false
	sprite.position = Vector2(
		(tile_coord.x - anchor_tile.x) * TILE_SIZE,
		(tile_coord.y - anchor_tile.y) * TILE_SIZE
	)
	add_child(sprite)
	loaded_chunks[tile_coord] = sprite
	
func tile_coord_to_latlng_string(tile_coord: Vector2i) -> String:
	var n = pow(2, zoom)
	var out_lng = tile_coord.x / n * 360.0 - 180.0
	
	var lat_rad = atan(sinh(PI * (1 - 2.0 * tile_coord.y / n)))
	var out_lat = rad_to_deg(lat_rad)
	
	return "%f,%f" % [out_lat, out_lng]
