"""

class_name RowHolder extends Node2D

var separation
signal card_clicked(card, card_type)

var CardBack = preload("res://Universal UI/Card/CardBack.png")
var FieldCard = preload("res://Universal UI/Card/FieldCard.png")


func set_separation(new_separation):
	separation = new_separation


func layout_row(row_config):
	for column in range(-4, 5): # From left to right, 4 cards on each side
			
			# Create a card and its texture
			var card = Card.new()
			
			# Identify its texture
			var card_code = row_config[column + 4]
			var texture
			if card_code == '00':
				texture = CardBack
			elif card_code == '01':
				texture = FieldCard
				
			sprite.texture = texture
			
			# Apply the position, texture, opacity and scale
			card.position = Vector2(x, y)
			card.add_child(sprite)
			card.scale = Vector2(scale_factors[row], scale_factors[row])
			
			
			# Add collision shape, input handling, etc.
			var collision_shape = CollisionShape2D.new()
			var rectangle_shape = RectangleShape2D.new()
			rectangle_shape.extents = card.scale / 2
			collision_shape.shape = rectangle_shape
			card.add_child(collision_shape)
			# Sprite click function & Area2D click function also work
			
			# Limit to only 3 cards in the middle and connect each to a different animationPlayer
	
			if row == 0:
				# Connect the mouse_entered and mouse_exited signals
				card.connect("mouse_entered", self, "_on_card_mouse_enter", [card])
				card.connect("mouse_exited", self, "_on_card_mouse_exit", [card])

				# Connect the input_event signal
				if column == 0:
					card.connect("input_event", self, "_on_card_clicked", [card, "middle_card"])
				elif column == -1:
					card.connect("input_event", self, "_on_card_clicked", [card, "left_card"])
				elif column == 1:
					card.connect("input_event", self, "_on_card_clicked", [card, "right_card"])


			# Add to the row holder
			add_child(card)
			modulate = Color(1, 1, 1, opacity_factors[row])


"""
