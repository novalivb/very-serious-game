class_name VolumeSlider extends Slider

@export var bus : String

var busIndex : int

func _ready() -> void:
	busIndex = AudioServer.get_bus_index(bus)
	var bus_volume = AudioServer.get_bus_volume_linear(busIndex)
	value_changed.connect(_on_value_changed)
	value = bus_to_bar(bus_volume)
	
func bus_to_bar(bus_value : float) -> float:
	return bus_value * max_value
	
func bar_to_bus(bar_value : float) -> float:
	return bar_value / max_value


func _on_value_changed(value_ : float):
	AudioServer.set_bus_volume_linear(busIndex, bar_to_bus(value_))
