extends Node2D


func update_shadow(shadow, animation, frame, pos):
	match shadow:
		"player":
			$Shadows/PlayerShadow.global_position = pos
			$Shadows/PlayerShadow.animation = animation
			$Shadows/PlayerShadow.frame = frame
		"companion":
			$Shadows/CompanionShadow.global_position = pos
			$Shadows/CompanionShadow.animation = animation
			$Shadows/CompanionShadow.frame = frame
