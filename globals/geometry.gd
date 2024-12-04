extends Node2D

func wrap_angle(angle) -> float:
	return fmod(angle + 3*PI, 2*PI) - 3*PI
	
func angle_diff(angle1, angle2) -> float:
	return fmod(fmod(angle1, 2 * PI) - fmod(angle2, 2 * PI) + 3 * PI, 2 * PI) - PI
