extends Node

# Env file should like this: API_KEY="secert_api_key_here"

var env = {}

func _enter_tree() -> void:
	load_env(".env")

func load_env(path: String):
	if not FileAccess.file_exists(path):
		printerr("Env file not found :(")
		return

	var file = FileAccess.open(path, FileAccess.READ)
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line.contains("="):
			var parts = line.split("=")
			env[parts[0]] = parts[1].replace("\"", "")
