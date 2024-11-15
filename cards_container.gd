extends Control

@onready var CardScene = preload("res://Card.tscn")

var cards = []			# All instantiated cards.

const margin = 20
const spacing = 10

func _ready():
	# Temp titles, will be set from the game node
	display_cards(LevelData.level_cards)

func display_cards(cards_data: Array):
	
	clear_cards()
	cards = []
	var card_size = Vector2(150, 250)
	var total_width = (card_size.x + spacing) * cards_data.size() - margin
	var start_x = margin

	for i in range(cards_data.size()):
		var card = CardScene.instantiate()
		card.size = card_size
		var offscreen_y = -card_size.y * 0.8
		card.position = Vector2(start_x + i * (card_size.x + spacing), offscreen_y)
		card.set_content(cards_data[i])
		add_child(card)
		cards.append(card)
		
		# Ensure the card can receive mouse input
		card.mouse_filter = Control.MouseFilter.MOUSE_FILTER_PASS
		card.z_index = i

func clear_cards():
	for card in cards:
		card.queue_free()
	cards.clear()
