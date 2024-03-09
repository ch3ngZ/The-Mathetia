extends Node2D

var CardBack = preload("res://Universal UI/Card/CardBack.png")
var FieldCard = preload("res://Universal UI/Card/FieldCard.png")

var card_distance = 300  # The distance between cards
var card_vertical_distance = 40  # The distance between rows
var fade_out_ratio = 0.25  # How much the opacity decreases for each row
var max_rows_displayed = 5  # Maximum number of rows to be displayed
var config = []  # This will hold the entire configuration
var queue = []  # This will hold the next rows to be displayed

func _ready():
	config = load_config("res://6RationalGrass/.cardConfig.txt")
	queue = config.slice(0, max_rows_displayed - 1)
	layout_cards()


func load_config(filename):
	var file = File.new()
	if file.file_exists(filename):
		file.open(filename, File.READ)
		var data = []
		while !file.eof_reached():
			var line = file.get_line().split(",")
			data.append(line)
		file.close()
		return data
	else:
		print("Config file not found!")
		return null


func layout_cards():
	# Clear existing rows
	for i in range(max_rows_displayed):
		if has_node("RowHolder" + str(i)):
			remove_child(get_node("RowHolder" + str(i)))

	# Create rows
	for i in range(len(queue)):
		var row_holder = Node2D.new()  # Create a new RowHolder
		row_holder.name = "RowHolder" + str(i)
		add_child(row_holder)

		# Add AnimationPlayer
		var animation_player = AnimationPlayer.new()
		row_holder.add_child(animation_player)

		# Add animation (You can replace this with editor-created animations)
		# create_animations(animation_player)
		
		var row = queue[i]
		
		for j in range(0, len(row)):
			var card = Area2D.new()  # Create a new Area2D node
			var sprite = Sprite.new()
			var texture
			
			if row[j] == '00':
				texture = CardBack  # Set the texture to CardBack
			elif row[j] == '01':
				texture = FieldCard  # Set the texture to FieldCard
			

			sprite.texture = texture
			card.add_child(sprite)
			
			var card_size = texture.get_size()
			var x_offset = 1600 / len(row) + j * card_distance
			var y_offset = 450 - i * card_vertical_distance

			card.position = Vector2(x_offset, y_offset)  # Adjust the position
			var opacity = max(1 - i * fade_out_ratio, 0)  # Calculate the opacity, but don't let it go below 0
			sprite.modulate = Color(1, 1, 1, opacity)  # Set the opacity

			# Add a collision shape to the card
			var collision_shape = CollisionShape2D.new()
			var rectangle_shape = RectangleShape2D.new()
			rectangle_shape.extents = card_size / 2
			collision_shape.shape = rectangle_shape
			card.add_child(collision_shape)
			
			row_holder.add_child(card)
			
			# Enable input processing after the card has been added to the scene tree
			card.set_process_input(true)
			card.connect("input_event", self, "_on_Card_pressed", [i])


func _on_Card_pressed(node, event, viewport, row):
	if node.is_inside_tree() and event is InputEventMouseButton and event.pressed:
		queue.pop_front()
		if max_rows_displayed + row < len(config):
			queue.push_back(config[max_rows_displayed + row])
		layout_cards()

