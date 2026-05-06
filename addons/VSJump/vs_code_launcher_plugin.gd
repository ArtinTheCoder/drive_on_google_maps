@tool
extends EditorPlugin

var button: Button

func _enter_tree():
	button = Button.new()
	
	button.text = "VS Code"
	button.flat = true 
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND 
	
	button.pressed.connect(_on_button_pressed)
	
	add_control_to_container(CONTAINER_TOOLBAR, button)

func _exit_tree():
	if button:
		remove_control_from_container(CONTAINER_TOOLBAR, button)
		button.queue_free()

func _on_button_pressed():
	var project_path = ProjectSettings.globalize_path("res://")
	var os_name = OS.get_name()
	
	var result = -1
	
	if os_name == "Windows":
		result = OS.execute("cmd", ["/c", "code", "."], [], false)
		
	elif os_name == "macOS":
		result = OS.execute("code", ["."], [], false)
		
	else: 
		result = OS.execute("code", ["."], [], false)
	
	if result != 0:
		push_error("Failed to open VS Code. Make sure VS Code is installed and 'code' is in your Path.")
