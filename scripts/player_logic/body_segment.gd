extends Node2D

var follow_target: Node2D = null
var spacing: float = 32.0

func _process(_delta: float) -> void:
	pass
	#if follow_target == null:
		#return
	#var dist = global_position.distance_to(follow_target.global_position)
	#if dist > spacing:
		#global_position = follow_target.global_position \
			#+ (global_position - follow_target.global_position).normalized() * spacing
