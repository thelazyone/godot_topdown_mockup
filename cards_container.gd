extends Control

@onready var CardScene = preload("res://card.tscn")

var local_cards_data = [] 
var cards = []			# All instantiated cards.
var cards_counter = 0 # counting the spent cards.
var active_card_index = -1

const margin = 20
const spacing = 10

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	display_cards(LevelData.level_cards)

func set_active_card_index(index : int):
	active_card_index = index
	display_cards()
	
func get_card_at_index(index: int) -> CardData:
	if cards.size() <= index:
		return CardData.new() # TODO should be an error instead!
	return cards[index]
	
func set_card_active(index: int, active: bool):
	if cards.size() <= index:
		return
	cards[index].is_active = active
	
func set_card_spent(index: int, active: bool):
	if cards.size() <= index:
		return
	cards[index].is_spent = active

func display_cards(cards_data: Array = []):
	
	clear_cards()
	cards = []
	if !cards_data.is_empty():
		local_cards_data = cards_data
	var card_size = Vector2(150, 250)
	var total_width = (card_size.x + spacing) * local_cards_data.size() - margin
	var start_x = margin

	for i in range(local_cards_data.size()):
		var card = CardScene.instantiate()
		card.size = card_size
		var offscreen_y = -card_size.y * 0.8
		if i == active_card_index:
			offscreen_y += 40
		card.position = Vector2(start_x + i * (card_size.x + spacing), offscreen_y)
		card.set_content(local_cards_data[i])
		add_child(card)
		cards.append(card)
		
		# Ensure the card can receive mouse input
		card.mouse_filter = Control.MouseFilter.MOUSE_FILTER_PASS
		card.z_index = i

func clear_cards():
	for card in cards:
		card.queue_free()
	cards.clear()
