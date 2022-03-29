extends Control

var singleton

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.get_name() == "android":
		if get_tree().connect("on_request_permission_result", self, "result") != OK:
			print("Error connecting to on_request_permission_result")
		if(OS.request_permissions()):
			result("", true)

func result(_permission, granted):
	if granted:
		if Engine.has_singleton("LocationPlugin"):
			singleton = Engine.get_singleton("LocationPlugin")
			singleton.connect("onLocationUpdates", self, "gotLocationUpdate")
			singleton.connect("onLastKnownLocation", self, "gotLastKnown")
			singleton.connect("onLocationError", self, "gotLocationError")
			singleton.startLocationUpdates(6000, 10000)

func gotLocationUpdate(locData):
	updateUserInterface(locData)
	
func gotLastKnown(locData):
	updateUserInterface(locData)
	
func gotLocationError(error, message):
	print("Error getting location %s %s", error, message)
	pass

func updateUserInterface(locData):
	$Values/longitudeValue.text = str(locData.longitude)
	$Values/latitudeValue.text = str(locData.latitude)
	$Values/accuracyValue.text = str(locData.accuracy)
	$Values/verticalAccuracyMetersValue.text = str(locData.verticalAccuracyMeters)
	$Values/altitudeValue.text = str(locData.altitude)
	$Values/speedValue.text = str(locData.speed)
	$Values/timeValue.text = str(locData.time)	

func _on_Button_button_down():
	singleton.getLastKnowLocation()
