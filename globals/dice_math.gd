extends Node


func is_valid_assignment(dice, slots):
	
	var local_dice = dice.duplicate()
	var local_slots = slots.duplicate() 
	
	# Sort slots by range size (smallest range first for optimization)
	local_slots.sort_custom(self._compare_slot_ranges)
	return _backtrack(local_dice, local_slots)

# Helper function to compare slot range sizes
func _compare_slot_ranges(a, b):
	return (a[1] - a[0]) - (b[1] - b[0])

func _backtrack(dice, slots):
	# If all slots are satisfied, return true
	if slots.is_empty():
		return true
	
	# Take the first slot
	var slot = slots.pop_front()
	var new_slots = slots.duplicate()  # Work with a copy of slots
	
	for i in range(dice.size()):
		var die = dice[i]
		# Check if die satisfies the slot
		if die >= slot[0] and die <= slot[1]:
			var new_dice = dice.duplicate()
			print("debug, dice are ", new_dice, "good dice is index ", i)
			new_dice.erase(new_dice[i])  # Remove the die from the available dice
			print("and calling backtrack with ", new_dice)
			
			# Recursively check remaining slots with remaining dice
			if _backtrack(new_dice, new_slots):
				return true  # Valid solution found
	
	return false  # No valid solution for this branch
