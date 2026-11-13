extends Node2D

@onready var collision_1: CollisionShape2D = $DetectionZone/Collision1
@onready var button: AnimatedSprite2D = $ButtonInteract


var is_player_near: bool = false
var player_ref: Node2D = null


func _ready() -> void:
	button.visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and is_player_near:
		call_deferred("_disable_button_visibility")
		call_deferred("_disable_collision")
		
		if player_ref.has_method("player_win"):
			player_ref.player_win()

func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Detect if player is near
		is_player_near = true
		player_ref = body

		# Show the button
		if is_player_near:
			call_deferred("_enable_button_visibility")

func _on_detection_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_near = false
		player_ref = null
		call_deferred("_disable_button_visibility")

func _disable_collision() -> void:
	collision_1.disabled = true
	
func _enable_button_visibility() -> void:
	button.visible = true

func _disable_button_visibility() -> void:
	button.visible = false
