class_name Decision
extends Node

enum Types {
	IDLE, 		# Do nothing
	MOVE, 		# Reach a Vector2 destination
	PURSUE, 	# Follow another unit (usually enemy)
	COVER, 		# Move to a certain Cover object
	ATTACK}		# Attack a certain Unit

## The main property of the Decision object.
var type : Types = Types.IDLE 	

## The target, required for all decisions except for IDLE.  Can be Vector2 or can be Node
var target = null

## How "convinced" the decision is. Should be between 0 and 1 (default is 1).
var weight : float = 1	
