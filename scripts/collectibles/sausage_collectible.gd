extends Area2D

@onready var collision_shape_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var button_sprite_2d: AnimatedSprite2D = $ButtonAnimatedSprite2D

@onready var animated_hotdog: AnimatedSprite2D = $Sprites/HotDogAnimated
@onready var sausage1: Sprite2D = $Sprites/Sausage1

var collectible_sprite = null

var is_player_near: bool = false
var player_ref: Node2D = null

signal sausage_consumed(zoom_factor: float, sausage_node: Area2D)

func _ready() -> void:
	animated_hotdog.visible = false
	sausage1.visible = false
	
	collectible_sprite = $Sprites.get_child(randi() % $Sprites.get_child_count())
	collectible_sprite.visible = true
	collectible_sprite.name = "collectible_sprite"


func _input(event: InputEvent) -> void:
	# Logic for interaction input
	if event.is_action_pressed("interact") and is_player_near:
		call_deferred("_disable_button_visibility")
		call_deferred("_disable_collision")

		sausage_consumed.emit(1.5, self)

# ----------------------------------------
# Detect when player get in the collision
# ----------------------------------------

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Detect if player is near
		is_player_near = true
		player_ref = body

		# Show the button
		if is_player_near:
			call_deferred("_enable_button_visibility")
		
		# Connect the zoom to the player
		if !sausage_consumed.is_connected(body.anim_eat_sausage):
			sausage_consumed.connect(body.anim_eat_sausage)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_near = false
		player_ref = null
		call_deferred("_disable_button_visibility")

# ---------------
# Deferred call
# ---------------

func _disable_collision() -> void:
	collision_shape_2d.disabled = true
	
func _enable_button_visibility() -> void:
	button_sprite_2d.visible = true

func _disable_button_visibility() -> void:
	button_sprite_2d.visible = false
