extends Node2D

var can_exit: bool = false

func _ready() -> void:
	$Sprite2D4.visible = false
	$Scene.visible = false
	$Player/UI/CanvasLayer/Icon.visible = false
	$Player/UI/CanvasLayer/GoldenSausage.visible = false
	$Player/UI/CanvasLayer/Score.visible = false
	$Player/UI/CanvasLayer/Timer.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and can_exit:
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/cinematic/cinematic_begin.tscn")

func _on_area_2d_body_entered(body: Node2D) -> void:
	$Player.can_move = false
	await get_tree().create_timer(1.0).timeout
	$Scene.visible = true
	$Laught.play()
	can_exit = true


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$Sprite2D4.visible = true

func _on_area_2d_2_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		$Sprite2D4.visible = false
