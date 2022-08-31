extends Node

var singleton
signal locationUpdate
signal lastKnownLocation
signal locationError

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.get_name() == "Android":
		get_tree().connect("on_request_permission_result", self, "result")
		if(OS.request_permissions()):
			result("", true)

func result(permission, granted):
	print("connect gps signals")
	if granted:
		print("granted")
		if Engine.has_singleton("LocationPlugin"):
			print("engine has location plug")
			singleton = Engine.get_singleton("LocationPlugin")
			singleton.connect("onLocationUpdates", self, "gotLocationUpdate")
			singleton.connect("onLastKnownLocation", self, "gotLastKnown")
			singleton.connect("onLocationError", self, "gotLocationError")
			singleton.startLocationUpdates(6000, 10000)

func gotLocationUpdate(locData):
	emit_signal("locationUpdate", locData)
	
func gotLastKnown(locData):
	emit_signal("lastKnownLocation", locData)
	
func gotLocationError(error, message):
	emit_signal("locationError", error, message)


func _on_GetGPS_button_down():
	singleton.gotLastKnown()
