extends Control


@export var texture_scale: float = 15.0
@export var spritesheet_texture_scale: float = 9.0

@export_group("Nodes", "node_")
@export var node_add_layer_button: Button
@export var node_file_dialog: FileDialog
@export var node_layer_container: VBoxContainer
@export var node_sprite_container: Control
@export var node_color_picker: ColorPicker
@export var node_spritesheet_settings: SpritesheetSettings


@export var layer_scene: PackedScene
@export var layer_selected_style: StyleBoxFlat


var spritesheet_toggled: bool
var hframes: int
var vframes: int
var selected_layer: Layer

func _ready() -> void:
	node_add_layer_button.pressed.connect(node_file_dialog.popup_file_dialog)
  
  node_spritesheet_settings.spritesheet_toggled.connect(_spritesheet_toggled)
  node_spritesheet_settings.col_row_updated.connect(_update_cols_rows.bind(true))
  node_spritesheet_settings.frame_index_changed.connect(_update_sprite_frame)
  
func _update_sprite_frame(frame_index: int) -> void:
  for sprite: Sprite2D in node_sprite_container.get_children():
    sprite.frame = frame_index
  
  
func _spritesheet_toggled(toggled_on: bool, _hframes: int, _vframes: int) -> void:
  spritesheet_toggled = toggled_on
  hframes = _hframes
  vframes = _vframes
  if toggled_on:
    _update_cols_rows(hframes, vframes, toggled_on)
  else:
    _update_cols_rows(1, 1, toggled_on)
  _update_sprite_frame(0)


func _scale_texture(sprite: Sprite2D, scale_amount: float) -> void:
  sprite.scale = Vector2(scale_amount, scale_amount)


func _update_cols_rows(hframes: int, vframes: int, toggled_on: bool) -> void:
  for sprite: Sprite2D in node_sprite_container.get_children():
    sprite.hframes = hframes
    sprite.vframes = vframes
    if toggled_on:
      _scale_texture(sprite, spritesheet_texture_scale)
    else:
      _scale_texture(sprite, texture_scale)


  
func on_layer_pressed(layer: Layer) -> void:
	var layers: Array[Node] = get_tree().get_nodes_in_group("Layer")

	for child_layer: Layer in layers:
		child_layer.remove_theme_stylebox_override("panel")

	layer.add_theme_stylebox_override("panel", layer_selected_style)
	selected_layer = layer

	node_color_picker.color = selected_layer.color

func arrange_layer(layer: Layer, direction: int) -> void:
	assert(direction == -1 || direction == 1 || direction == 0)

	if direction == 1 && layer.get_index() != 0:
		print("moving layer up")
		node_layer_container.move_child(layer, layer.get_index() - 1)
		node_sprite_container.move_child(layer.node_sprite, layer.node_sprite.get_index() + 1)

	elif direction == -1 && layer.get_index() != node_layer_container.get_child_count() - 1:
		print("moving layer down")
		node_layer_container.move_child(layer, layer.get_index() + 1)
		node_sprite_container.move_child(layer.node_sprite, layer.node_sprite.get_index() - 1)

	elif direction == 0:
		print("moving layer to first")
		node_layer_container.move_child(layer, 0)
		node_sprite_container.move_child(layer.node_sprite, node_sprite_container.get_child_count() - 1)


func _on_file_dialog_files_selected(paths: PackedStringArray) -> void:
  for path: String in paths:
    var sprite: Sprite2D = Sprite2D.new()
    sprite.texture = load(path)

		var layer: Layer = layer_scene.instantiate()
		layer.node_up_layer.pressed.connect(arrange_layer.bind(layer, 1))
		layer.gui_input.connect(func(event: InputEventMouse) -> void:
			if !event.is_pressed(): return
			on_layer_pressed(layer)
		)
		layer.node_down_layer.pressed.connect(arrange_layer.bind(layer, -1))
		layer.node_name_label.text = path.get_file().get_slice(".", 0)
		layer.node_sprite = sprite
	
	
		node_layer_container.add_child(layer)
		node_sprite_container.add_child(sprite)
		arrange_layer(layer, 0)

  _spritesheet_toggled(spritesheet_toggled, hframes, vframes)


func _on_color_picker_color_changed(color: Color) -> void:
	if !selected_layer: return

	selected_layer.color = color
