extends Node

@export var anchor_lat: float = 45.4215
@export var anchor_lng: float = -75.6972
@export var zoom: int = 17

const TILE_SIZE = 256

func world_to_latlng(world_pos: Vector2) -> Vector2:
	var anchor_tile_x = lng_to_tile_x(anchor_lng, zoom)
	var anchor_tile_y = lat_to_tile_y(anchor_lat, zoom)

	var tile_x = anchor_tile_x + (world_pos.x / TILE_SIZE)
	var tile_y = anchor_tile_y + (world_pos.y / TILE_SIZE)

	var out_lng = tile_x / pow(2, zoom) * 360.0 - 180.0
	var n = PI - 2.0 * PI * tile_y / pow(2, zoom)
	var out_lat = rad_to_deg(atan(sinh(n)))

	return Vector2(out_lat, out_lng)

func lng_to_tile_x(p_lng: float, p_zoom: int) -> float:
	return (p_lng + 180.0) / 360.0 * pow(2, p_zoom)

func lat_to_tile_y(p_lat: float, p_zoom: int) -> float:
	return (1.0 - log(tan(deg_to_rad(p_lat)) + 1.0 / cos(deg_to_rad(p_lat))) / PI) / 2.0 * pow(2, p_zoom)
