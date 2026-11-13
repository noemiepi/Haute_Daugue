extends CollisionShape2D
@onready var collision_shape_2d: CollisionShape2D = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.player_detected()
		call_deferred("_disable_collision")

func _disable_collision() -> void:
	collision_shape_2d.disabled = true
