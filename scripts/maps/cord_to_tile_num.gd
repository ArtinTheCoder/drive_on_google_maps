extends Node

func deg2num(lat_deg: float, lon_deg: float, zoom: int) -> Vector2i:
	var lat_rad = deg_to_rad(lat_deg)
	var n = 1 << zoom

	var xtile = int((lon_deg + 180.0) / 360.0 * n)
	var ytile = int((1.0 - asinh(tan(lat_rad)) / PI) / 2.0 * n)

	return Vector2i(xtile, ytile)
