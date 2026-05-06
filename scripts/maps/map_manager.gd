extends Control

@export var zoom = 20


@onready var world_to_cords: Node = $WorldToCords
@onready var cord_to_tile_num: Node = $CordToTileNum

var lat = 45.4215
var lng = -75.6972

const TILE_SIZE = 256
const CHUNK_RADIUS = 2 # 5x5 grid around player

var loaded_chunks = {}
var current_center_tile = Vector2i(-9999, 9999)

func _process(_delta: float) -> void:
	if not Global.player:
		return
	
	var lat_lng = world_to_cords.world_to_latlng(Global.player.position)
	var tile = cord_to_tile_num.deg2num(lat_lng.x, lat_lng.y, zoom)
	
	if tile != current_center_tile:
		current_center_tile = tile
		update_chunks(tile)

func update_chunks(center: Vector2i) -> void:
	for x in range(-CHUNK_RADIUS, CHUNK_RADIUS + 1):
		for y in range(-CHUNK_RADIUS, CHUNK_RADIUS + 1):
			var tile_coord = center + Vector2i(x, y)
			
			if not loaded_chunks.has(tile_coord):
				load_chunk(tile_coord)

	for coord in loaded_chunks.keys():
		if abs(coord.x - center.x) > CHUNK_RADIUS + 1 or abs(coord.y - center.y) > CHUNK_RADIUS + 1:
			loaded_chunks[coord].queue_free()
			loaded_chunks.erase(coord)

func load_chunk(tile_coord: Vector2i) -> void:
	var url = "https://maps.googleapis.com/maps/api/staticmap?center=%s&zoom=%d&size=256x256&maptype=satellite&key=%s" % [
		tile_coord_to_latlng_string(tile_coord),
		zoom,
		GMap.api_key
	]

	var http = HTTPRequest.new()
	
	add_child(http)
	http.request_completed.connect(func(result, code, headers, body):
		_on_chunk_loaded(result, code, body, tile_coord, http)
	)
	
	http.request(url)
	loaded_chunks[tile_coord] = null  
	
func _on_chunk_loaded(result, code, body, tile_coord: Vector2i, http: HTTPRequest) -> void:
	http.queue_free()
	
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		print("chunk failed, code: ", code)
		loaded_chunks.erase(tile_coord)
		return

	var anchor_tile = cord_to_tile_num.deg2num(lat, lng, zoom)  

	var img = Image.new()
	img.load_png_from_buffer(body)
	
	var tex = ImageTexture.create_from_image(img)
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
