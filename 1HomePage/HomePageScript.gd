extends Control

var scene_path = ""
var color_rect_node = null
var start_game_button = null
var load_game_button = null
var gallery_button = null

func _ready():
	start_game_button = $ButtonContainer/StartGameButton
	load_game_button = $ButtonContainer/LoadGameButton
	gallery_button = $ButtonContainer/GalleryButton
	
	start_game_button.connect("pressed", self, "_on_Button_pressed", ["res://2StartGamePage/StartGamePage.tscn", start_game_button])
	load_game_button.connect("pressed", self, "_on_Button_pressed", ["res://3LoadGamePage/LoadGamePage.tscn", load_game_button])
	gallery_button.connect("pressed", self, "_on_Button_pressed", ["res://4GalleryPage/GalleryPage.tscn", gallery_button])

	color_rect_node = $Transition
	color_rect_node.get_node("AnimationPlayer").connect("animation_finished", self, "_on_FadeIn_animation_finished")


func _on_Button_pressed(path, button):
	scene_path = path
	button.get_node("AnimationPlayer").play("Flash")  # Play flash animation
	color_rect_node.get_node("AnimationPlayer").play("FadeIn")


func _on_FadeIn_animation_finished(animation_name):
	if animation_name != "FadeIn":
		return

	var new_scene = load(scene_path).instance()
	var current_scene = get_tree().current_scene

	if current_scene:
		current_scene.queue_free()
		
	get_tree().root.add_child(new_scene)  # Add new scene to Scene Tree
	color_rect_node.get_node("AnimationPlayer").play("FadeOut")
	get_tree().current_scene = new_scene  # Set the new scene as the current scene





