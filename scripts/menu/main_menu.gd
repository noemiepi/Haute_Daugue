extends Control


# -------------------------
#        MAIN
# -------------------------

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/cinematic/cinematic_begin.tscn")
	$SoundManager.play_click_sound()


func _on_config_button_pressed() -> void:
	$Background/MainGroup.visible = false
	$Background/OptionGroup/OptionMenu/CanvasLayer.visible = true
	$SoundManager.play_click_sound()

func _on_leave_button_pressed() -> void:
	$SoundManager.play_click_sound()
	get_tree().quit()


func _on_credits_button_pressed() -> void:
	$SoundManager.play_click_sound()
	$Background/MainGroup.visible = false
	$Background/CreditsGroup.visible = true

# -------------------------
#        CREDITS
# -------------------------

func _on_back_button_pressed() -> void:
	$SoundManager.play_click_sound()
	$Background/MainGroup.visible = true
	$Background/CreditsGroup.visible = false

# -------------------------
#        OPTIONS
# -------------------------


func _on_option_menu_window_close() -> void:
	$SoundManager.play_click_sound()
	$Background/MainGroup.visible = true
