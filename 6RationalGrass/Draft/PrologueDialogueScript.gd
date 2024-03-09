extends Node

class DialogueLine:
	var silhouette : String
	var sprite : String
	var name_tag : String
	var background : String
	var text_box : String
	var dialogue : String

var dialogue_lines : Array = []
var current_line : int = 0

var old_silhouette : String = "null.png"
var old_sprite : String = "null.png"
var old_name_tag : String = "null.png"
var old_text_box : String = "null.png"
var old_background : String = "res://Universal UI/Dialogue/Bedroom.png"

var silhouette_node : Sprite
var sprite_node : Sprite
var name_tag_node : Sprite
var background_node : Sprite
var text_box_node: Sprite
var text_node : RichTextLabel
 
var timer : Timer
var dialogue_history := []
var is_in_history : bool = false
var is_space_pressed: bool = false


var silhouette_dictionary = {
	"null": "null.png",
	"x": "res://Universal UI/Dialogue/XSilhouette.png",
	"cheng": "res://Universal UI/Dialogue/ChengSilhouette.png",
}

var sprite_dictionary = {
	"null": "null.png",
	"x": "res://Universal UI/Dialogue/X.png",
	"claudia": "res://Universal UI/Dialogue/Claudia.png",
	"terri": "res://Universal UI/Dialogue/Terri.png", 
}

var name_tag_dictionary = {
	"null": "null.png",
	"x": "res://Universal UI/Dialogue/XNameTag.png",
	"cheng": "res://Universal UI/Dialogue/ChengNameTag.png",
	"claudia": "res://Universal UI/Dialogue/ClaudiaNameTag.png",
	"terri": "res://Universal UI/Dialogue/TerriNameTag.png",
}

var background_dictionary = {
	"null": "null.png",
	"bedroom": "res://Universal UI/Dialogue/Bedroom.png",
}

var text_box_dictionary = {
	"null": "null.png",
	"x": "res://Universal UI/Dialogue/TextBox.png",
	
}

var name_dictionary = {
	"res://Universal UI/Dialogue/XNameTag.png": "X",
	"null.png": "Narrator",
	"res://Universal UI/Dialogue/ChengNameTag.png": "Cheng",
	"res://Universal UI/Dialogue/ClaudiaNameTag.png": "Claudia",
	"res://Universal UI/Dialogue/TerriNameTag.png": "Terri",
	
}


func _ready():
	get_node("DialogueHistory").hide()
	silhouette_node = get_node("Silhouette")
	sprite_node = get_node("Sprite")
	name_tag_node = get_node("NameTag")
	background_node = get_node("Background")
	text_box_node = get_node("TextBox")
	text_node = get_node("Text")
	timer = Timer.new()
	timer.wait_time = 0.05
	timer.one_shot = false
# warning-ignore:return_value_discarded
	timer.connect("timeout", self, "_on_timer_timeout")
	add_child(timer)
	
	_load_dialogue()


func _load_dialogue():
	var config = ConfigFile.new()
	var error = config.load("res://5Prologue/Dialogue.txt")
	
	if error == OK:
		for section in config.get_sections():
			var dialogue_line = DialogueLine.new()
			dialogue_line.silhouette = silhouette_dictionary[config.get_value(section, "silhouette")]
			dialogue_line.sprite = sprite_dictionary[config.get_value(section, "sprite")]
			dialogue_line.name_tag = name_tag_dictionary[config.get_value(section, "name_tag")]
			dialogue_line.text_box = text_box_dictionary[config.get_value(section, "text_box")]
			dialogue_line.background = background_dictionary[config.get_value(section, "background")]
			dialogue_line.dialogue = config.get_value(section, "dialogue")
			dialogue_lines.append(dialogue_line)
	else:
		print("Failed to load dialogue file")


func display_next_line():
	if current_line < dialogue_lines.size():
		var line = dialogue_lines[current_line]
		# Change the silhouette 
		if line.silhouette != old_silhouette:
			var silhouette_animation_player = silhouette_node.get_node("AnimationPlayer")
			if line.silhouette == "null.png":
				old_silhouette = line.silhouette
				silhouette_animation_player.play("SilhouetteOut")
			else:
				if old_silhouette != "null.png":
					silhouette_animation_player.play("SilhouetteOut")
				silhouette_node.texture = load(line.silhouette)
				old_silhouette = line.silhouette
				silhouette_animation_player.play("SilhouetteIn")


		# Change the sprite
		if line.sprite != old_sprite:
			var sprite_animation_player = sprite_node.get_node("AnimationPlayer")
			if line.sprite == "null.png":
				old_sprite = line.sprite
				sprite_animation_player.play("SpriteOut")
			else:
				if old_sprite != "null.png":
					sprite_animation_player.play("SpriteOut")
				sprite_node.texture = load(line.sprite)
				old_sprite = line.sprite
				sprite_animation_player.play("SpriteIn")


		# Change the name tag
		if line.name_tag != old_name_tag:
			var name_tag_animation_player = name_tag_node.get_node("AnimationPlayer")
			if line.name_tag == "null.png":
				old_name_tag = line.name_tag
				name_tag_animation_player.play("NameTagOut")
			else:
				if old_name_tag != "null.png":
					name_tag_animation_player.play("NameTagOut")
				name_tag_node.texture = load(line.name_tag)
				old_name_tag = line.name_tag
				name_tag_animation_player.play("NameTagIn")


		# Change the background
		if line.background != old_background:
			var background_animation_player = background_node.get_node("AnimationPlayer")
			if line.background == "null.png":
				old_background = line.background
				background_animation_player.play("BackgroundOut")
			else:
				if old_background != "null.png":
					background_animation_player.play("BackgroundOut")
				background_node.texture = load(line.background)
				old_background = line.background
				background_animation_player.play("BackgroundIn")


		# Change the text box
		if line.text_box != old_text_box:
			var text_box_animation_player = text_box_node.get_node("AnimationPlayer")
			if line.text_box == "null.png":
				old_text_box = line.text_box
				text_box_animation_player.play("TextBoxOut")
			else:
				if old_text_box != "null.png":
					text_box_animation_player.play("TextBoxOut")
				text_box_node.texture = load(line.text_box)
				old_text_box = line.text_box
				text_box_animation_player.play("TextBoxIn")
			
		text_node.bbcode_text = line.dialogue
		var text_animation_player = get_node("Text/AnimationPlayer")
		text_animation_player.play("DisplayText")
		
		dialogue_history.append("[" + name_dictionary[line.name_tag] + "]" + "\n" + line.dialogue + "\n")		
		current_line += 1
		

func _on_timer_timeout():
	display_next_line()
	
	
func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == BUTTON_LEFT:
			if is_in_history or is_space_pressed:
				return
			display_next_line()
			
		if event.button_index == BUTTON_WHEEL_UP:
			if is_in_history or is_space_pressed:
				return
			# Show the dialogue history - Scroll up
			get_node("DialogueHistory/ScrollContainer/RichTextLabel").bbcode_text = PoolStringArray(dialogue_history).join("\n")
			get_node("DialogueHistory/HistoryRect/AnimationPlayer").play("historyRectIn")
			get_node("DialogueHistory").show()
			is_in_history = true
			
		elif event.button_index == BUTTON_RIGHT:
			# hide the dialogue history - Right click
			get_node("DialogueHistory/HistoryRect/AnimationPlayer").play("historyRectOut")
			yield(get_node("DialogueHistory/HistoryRect/AnimationPlayer"), "animation_finished")
			get_node("DialogueHistory").hide()
			is_in_history = false


	if event is InputEventKey:
		if event.is_pressed() and event.scancode == KEY_ENTER:
			if is_in_history or is_space_pressed:
				return
			display_next_line()
			
		if event.scancode == KEY_CONTROL:
			if event.is_pressed():
				timer.start()
			else:
				timer.stop()
		
		if event.scancode == KEY_SPACE:
			if event.is_pressed():
				if is_space_pressed:
					get_node("NameTag").show()
					get_node("TextBox").show()
					get_node("Text").show()
					is_space_pressed = false
				else:
					get_node("NameTag").hide()
					get_node("TextBox").hide()
					get_node("Text").hide()
					is_space_pressed = true

