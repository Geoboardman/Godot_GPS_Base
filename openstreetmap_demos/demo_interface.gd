extends CanvasLayer

func _ready():
	pass

func _physics_process(_delta):
	$FPS.text = "%d FPS" % Performance.get_monitor(Performance.TIME_FPS)

func _on_BackToMenu_pressed():
	if get_tree().change_scene("res://openstreetmap_demos/menu.tscn") != OK:
		 print ("An unexpected error occured when trying to switch to the demos/menu scene")
