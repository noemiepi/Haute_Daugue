extends Control

var can_pause: bool = true

func _ready() -> void:
	$CanvasLayer.visible = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel") and can_pause:
		$SoundManager.play_click_sound()
		get_tree().paused = !get_tree().paused
		$CanvasLayer.visible = get_tree().paused


func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	$SoundManager.play_click_sound()
	$CanvasLayer.visible = false


func _on_config_button_pressed() -> void:
	$SoundManager.play_click_sound()
	$CanvasLayer.visible = false
	$OptionMenu/CanvasLayer.visible = true
	can_pause = false


func _on_main_menu_button_pressed() -> void:
	$SoundManager.play_click_sound()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")


func _on_option_menu_window_close() -> void:
	$SoundManager.play_click_sound()
	$CanvasLayer.visible = true
	can_pause = true
