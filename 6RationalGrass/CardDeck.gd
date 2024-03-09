extends Spatial

var config = [] # Config array
var card_per_row = 9 # The number of cards in a row
var card_deck = null # Display the cards
var pivot = round(card_per_row / 2) # The position of the central card
var ctrl_pressed = false # Ctrl -> Speed-up function
var speed_modifier = 1.0 
var isAnimating = false # Detect if it is animating
var isLogicRunning = false # Detect if the logic is running

onready var camera_node = $Camera
onready var background_node = get_parent().get_node("RationalGrass")
onready var card_tween = $CardTween
onready var camera_tween = $CameraTween
onready var flip_tween = $CardFlipTween


func _ready():
	config = load_config("res://6RationalGrass/.cardConfig.txt")
	$LeftTrigger.connect("gui_input", self, "_on_card_clicked", ["Left"])
	$MiddleTrigger.connect("gui_input", self, "_on_card_clicked", ["Middle"])
	$RightTrigger.connect("gui_input", self, "_on_card_clicked", ["Right"])
	$LeftTrigger.connect("mouse_entered", self, "_on_mouse_hover", ["Left"])
	$LeftTrigger.connect("mouse_exited", self, "_on_mouse_unhover", ["Left"])
	$MiddleTrigger.connect("mouse_entered", self, "_on_mouse_hover", ["Middle"])
	$MiddleTrigger.connect("mouse_exited", self, "_on_mouse_unhover", ["Middle"])
	$RightTrigger.connect("mouse_entered", self, "_on_mouse_hover", ["Right"])
	$RightTrigger.connect("mouse_exited", self, "_on_mouse_unhover", ["Right"])

	arrangement()
		

func arrangement():	
	# Speed up or not
	if ctrl_pressed:
		speed_modifier = 2.0
	else:
		speed_modifier = 1.0
		
	# Refresh the hover effects
	$MiddleTrigger.visible = false
	$MiddleTrigger.visible = true
	$LeftTrigger.visible = false
	if pivot != 0:
		$LeftTrigger.visible = true # In case the pivot is out of bound
	$RightTrigger.visible = false
	if pivot != card_per_row - 1:
		$RightTrigger.visible = true # Same as above

	# Create row holders and cards in a new CardDeck
	card_deck = Spatial.new()
	card_deck.name = "CardDeck"
	self.add_child(card_deck)
	
	for i in range(6):
		var row_holder = Spatial.new()
		row_holder.name = "RowHolder" + str(i)
		card_deck.add_child(row_holder)
		
		var y = 0.125 * i
		var z = 2.0 - 0.2 * i
		
		for j in range(card_per_row):
			# Put the card into the correct position
			var card = MeshInstance.new()
			card.set_mesh(QuadMesh.new())
			card.scale = Vector3(0.5, 0.8, 1)
			
			var material = SpatialMaterial.new()
			material.albedo_texture = load("res://Universal UI/Card/card_" + str(config[i][j]) + ".png")
			
			# Change the card's transparency
			material.set_feature(0, true)
			material.albedo_color.a = 1.0 - 0.2 * i
			card.set_surface_material(0, material)

			var x = -0.625 * round((card_per_row - 1) / 2) + j * 0.625
			card.translation = Vector3(x, y, z)
			
			card.name = "Card" + str(i) + str(j)
			row_holder.add_child(card)


func logic_detection():
	var card = get_node("CardDeck/RowHolder0/Card0" + str(pivot))
	
	if config[0][pivot] == '00':
		flip_tween.interpolate_property(card, "rotation_degrees:y", 0, 90, 0.5, Tween.EASE_IN_OUT)
		flip_tween.start()
		yield(flip_tween, "tween_all_completed")
		
		var new_material = SpatialMaterial.new()
		new_material.albedo_texture = load("res://Universal UI/Card/card_01.png")
		card.set_surface_material(0, new_material)
		
		flip_tween.interpolate_property(card, "rotation_degrees:y", 90, 180, 0.5, Tween.EASE_IN_OUT)
		flip_tween.start()
		yield(flip_tween, "tween_all_completed")

func animate_rows(type):
	isAnimating = true
	var row_holders = []
	# Collect all row holders
	for i in range(6):
		row_holders.append(get_node("CardDeck/RowHolder" + str(i)))
	
	# Animate the first row holder differently
	var first_row = row_holders[0]
	var first_start_pos = first_row.translation
	var first_end_pos = Vector3(first_start_pos.x, first_start_pos.y - 0.2, first_start_pos.z + 0.2)

	# Translation animation for the first row
	card_tween.interpolate_property(first_row, "translation", first_start_pos, first_end_pos, 0.3 / speed_modifier, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	
	# Opacity animation for the first row
	for node in first_row.get_children():
		if node is MeshInstance:
			var material = node.get_surface_material(0)
			card_tween.interpolate_property(material, "albedo_color:a", 1.0, 0.0, 0.3 / speed_modifier, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	
	# Animate the rest rows
	for i in range(1, 6):
		var row = row_holders[i]
		var start_pos = row.translation
		var end_pos = Vector3(start_pos.x, start_pos.y - 0.125, start_pos.z + 0.2)
		
		# Translation animation
		card_tween.interpolate_property(row, "translation", start_pos, end_pos, 0.3 / speed_modifier, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
		
		# Opacity animation
		for node in row.get_children():
			if node is MeshInstance:
				var material = node.get_surface_material(0)
				var start_opacity = material.albedo_color.a
				card_tween.interpolate_property(material, "albedo_color:a", start_opacity, start_opacity + 0.2, 0.3 / speed_modifier, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
				
	# Start all animations	
	if type != "Middle":
		if type == "Left":
			move_camera("Left")
			pivot -= 1

		elif type == "Right":
			move_camera("Right")
			pivot += 1	
		
		yield(camera_tween, "tween_all_completed")

	logic_detection()

	card_tween.start()
	yield(card_tween, "tween_all_completed")
	
	# Remove the first row from config and add it to the config
	config.append(config[0])
	config.pop_front()
	
	# Delete the CardDeck
	card_deck.queue_free()
	yield(get_tree().create_timer(0.0), "timeout")

	isAnimating = false
	arrangement()


func _on_card_clicked(event, direction):
	if isAnimating or isLogicRunning:
		return
	
	if event is InputEventMouseButton and event.pressed:
		if direction == "Middle":
			animate_rows("Middle")

		if direction == "Left":
			animate_rows("Left")
			
		elif direction == "Right":
			animate_rows("Right")
			

func move_camera(direction):
	var start_pos = $Camera.translation
	var end_pos = start_pos
	
	if direction == "Left":
		end_pos = Vector3(start_pos.x - 0.625, start_pos.y, start_pos.z)

	elif direction == "Right":
		end_pos = Vector3(start_pos.x + 0.625, start_pos.y, start_pos.z)
		
	camera_tween.interpolate_property(camera_node, "translation", start_pos, end_pos, 0.3 / speed_modifier, Tween.EASE_IN)
	# camera_tween.interpolate_property(background_node, "translation", start_pos, end_pos, 0.3 / speed_modifier, Tween.EASE_IN)
	camera_tween.start()


func _on_mouse_hover(direction):
	var card_index = pivot
	if direction == "Left":
		card_index = pivot - 1
	elif direction == "Right":
		card_index = pivot + 1

	var row_holder = get_node("CardDeck/RowHolder0")
	var target_card = row_holder.get_child(card_index)
	if target_card and target_card is MeshInstance:
		var material = target_card.get_surface_material(0)
		material.albedo_color = Color(1, 1, 0.5, 1) # Yellow
		target_card.set_surface_material(0, material)


func _on_mouse_unhover(direction):
	var card_index = pivot
	if direction == "Left":
		card_index = pivot - 1
	elif direction == "Right":
		card_index = pivot + 1

	var row_holder = get_node("CardDeck/RowHolder0")
	var target_card = row_holder.get_child(card_index)
	if target_card and target_card is MeshInstance:
		var material = target_card.get_surface_material(0)
		material.albedo_color = Color(1, 1, 1, 1) # White
		target_card.set_surface_material(0, material)


func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_CONTROL:
			ctrl_pressed = event.pressed


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

