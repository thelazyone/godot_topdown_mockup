extends Control

@onready var CardScene = preload("res://Card.tscn")

var card_titles = [] 	# Strings array
var cards = []			# All instantiated cards.

const margin = 20
const spacing = 10

func _ready():
	
	# Temp titles, will be set from the game node
	card_titles = ["Card 1", "Card 2", "Card 3"]
	display_cards(card_titles)

func display_cards(titles: Array):
	
	clear_cards()
	cards = []
	var card_size = Vector2(150, 250)
	var total_width = (card_size.x + spacing) * titles.size() - margin
	var start_x = margin

	for i in range(titles.size()):
		var card_title = titles[i]
		var card = CardScene.instantiate()
		card.size = card_size
		var offscreen_y = -card_size.y * 0.8
		card.position = Vector2(start_x + i * (card_size.x + spacing), offscreen_y)
		print("DEBUG: ", card.position)
		card.set_title(card_title)
		add_child(card)
		cards.append(card)
		
		# Ensure the card can receive mouse input
		card.mouse_filter = Control.MouseFilter.MOUSE_FILTER_PASS
		card.z_index = i

func clear_cards():
	for card in cards:
		card.queue_free()
	cards.clear()
