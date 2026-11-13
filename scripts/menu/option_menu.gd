extends Control

signal window_close

# Audio Bus indices
@onready var master_bus_id = AudioServer.get_bus_index("Master")
@onready var music_bus_id = AudioServer.get_bus_index("Music")
@onready var sound_effect_bus_id = AudioServer.get_bus_index("Sound Effect")

# UI References
@onready var master_slider: HSlider = $CanvasLayer/Panel/AudioControlGroup/VBoxContainer/GridContainer/MasterSlider
@onready var music_slider: HSlider = $CanvasLayer/Panel/AudioControlGroup/VBoxContainer/GridContainer/MusicSlider
@onready var sound_effect_slider: HSlider = $CanvasLayer/Panel/AudioControlGroup/VBoxContainer/GridContainer/SoundEffectSlider

func _ready() -> void:
	$CanvasLayer.visible = false
	
	# Synchronize sliders with current audio levels when opening the menu
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus_id)) * 100.0
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus_id)) * 100.0
	sound_effect_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sound_effect_bus_id)) * 100.0
	
	# Connect signals manually to be safe
	master_slider.value_changed.connect(_on_master_value_changed)
	music_slider.value_changed.connect(_on_music_value_changed)
	sound_effect_slider.value_changed.connect(_on_sfx_value_changed)

# -----------------
# SIGNAL CALLBACKS
# -----------------

func _on_master_value_changed(value: float) -> void:
	set_bus_volume(master_bus_id, value)

func _on_music_value_changed(value: float) -> void:
	set_bus_volume(music_bus_id, value)

func _on_sfx_value_changed(value: float) -> void:
	set_bus_volume(sound_effect_bus_id, value)

# -----------------
# 	LOGIC
# -----------------

func set_bus_volume(bus_index: int, value: float) -> void:
	var normalized_value = value / 100.0

	var volume_db = linear_to_db(normalized_value)
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	
	# Mute the bus if volume is very low to avoid background hiss
	if value < 0.01:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)

# -----------------
# NAVIGATION
# -----------------


func _on_back_button_pressed() -> void:
	$SoundManager.play_click_sound()
	$CanvasLayer.visible = false
	window_close.emit()
