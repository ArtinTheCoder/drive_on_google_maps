extends Node2D
var lat = 45.4215
var lng = -75.6972
var zoom = 17
var api_key = GMap.api_key
var url = "https://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=%d&size=640x640&maptype=satellite&key=%s" % [lat, lng, zoom, api_key]

func _ready() -> void:
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_map_loaded)
	http.request(url)

func _on_map_loaded(result, code, headers, body):
	var img = Image.new()
	img.load_png_from_buffer(body)
	var tex = ImageTexture.create_from_image(img)
	$MapSprite.texture = tex
