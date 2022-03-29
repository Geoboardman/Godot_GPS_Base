extends MarginContainer

func _on_Button_pressed(path):
	if get_tree().change_scene(path) != OK:
		 print ("An unexpected error occured when trying to switch to the %s scene", path)
