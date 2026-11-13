extends Node2D

@onready var collision_detected: CollisionShape2D = $Visual/Area2D/CollisionDetected
@onready var button: AnimatedSprite2D = $Visual/ButtonAnimatedSprite2D


@export_group("Item Inside")
@export var has_sausage: bool = false
@export var has_golden_sausage: bool = false
@export var has_stick: bool = false

var is_player_near: bool = false
var player_ref: Node2D = null


func _ready() -> void:
	$CanvasLayer.visible = false
	$Visual/ButtonAnimatedSprite2D.visible = false

func _input(event: InputEvent) -> void:
	# Logic for interaction input
	if event.is_action_pressed("interact") and is_player_near:
		var current_player = player_ref
		call_deferred("_disable_button_visibility")
		call_deferred("_disable_collision")
		$CanvasLayer.visible = true
		
		if has_sausage:
			if current_player and current_player.has_method("_search_bush"):
				current_player._search_bush("sausage")

			$CanvasLayer/Sprites/SausageSprite.visible = true
			$CanvasLayer/Texts/SausageFound.visible = true
			$Sounds/SausageFound.play()
			
			await get_tree().create_timer(2.0).timeout
			$CanvasLayer/Sprites/SausageSprite.visible = false
			$CanvasLayer/Texts/SausageFound.visible = false
			
			if current_player and current_player.has_method("_search_bush_finish"):
				current_player._search_bush_finish()
			
		elif has_golden_sausage:
			if current_player and current_player.has_method("_search_bush"):
				current_player._search_bush("golden_sausage")

			$CanvasLayer/Sprites/GoldenSausage.visible = true
			$CanvasLayer/Texts/GoldenSausageFound.visible = true
			$Sounds/GoldenSausageFound.play()
			
			await get_tree().create_timer(2.0).timeout
			$CanvasLayer/Sprites/GoldenSausage.visible = false
			$CanvasLayer/Texts/GoldenSausageFound.visible = false
			
			if current_player and current_player.has_method("_search_bush_finish"):
				current_player._search_bush_finish()
			
		elif has_stick:
			if current_player and current_player.has_method("_search_bush"):
				current_player._search_bush("stick")

			$CanvasLayer/Sprites/Stick.visible = true
			$CanvasLayer/Texts/StickFound.visible = true
			$Sounds/StickFound.play()
			
			await get_tree().create_timer(2.0).timeout
			$CanvasLayer/Sprites/Stick.visible = false
			$CanvasLayer/Texts/StickFound.visible = false
			
			if current_player and current_player.has_method("_search_bush_finish"):
				current_player._search_bush_finish()
		
		$CanvasLayer.visible = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Detect if player is near
		is_player_near = true
		player_ref = body

		# Show the button
		if is_player_near:
			call_deferred("_enable_button_visibility")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_near = false
		player_ref = null
		call_deferred("_disable_button_visibility")

func _disable_collision() -> void:
	collision_detected.disabled = true
	
func _enable_button_visibility() -> void:
	button.visible = true

func _disable_button_visibility() -> void:
	button.visible = false
