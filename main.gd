extends Control


var texture_scale: float = 15.0
var spritesheet_texture_scale: float = 9.0

@export_group("Nodes", "node_")
@export var node_add_layer_button: Button
@export var node_file_dialog: FileDialog
@export var node_layer_container: VBoxContainer
@export var node_sprite_container: Control
@export var node_color_picker: ColorPicker
@export var node_spritesheet_settings: SpritesheetSettings
@export var node_sprite_settings: SpriteSettings
@export var node_import_type_modal: Window
@export var node_scale_spin: SpinBox

@export var layer_scene: PackedScene
@export var layer_selected_style: StyleBoxFlat


var is_sprite: bool = true

var selected_layer: Layer

func _ready() -> void:
  node_add_layer_button.pressed.connect(_on_add_layer_pressed)
  node_scale_spin.value_changed.connect(_on_scale_changed)

func _on_scale_changed(value: float) -> void:
  if selected_layer.node_sprite && selected_layer.node_sprite.scale.x != value:
    selected_layer.node_sprite.scale = Vector2(value, value)
  
func _on_add_layer_pressed() -> void:
  node_import_type_modal.show()
  node_import_type_modal.popup_centered()

  ## 0 for sprite, 1 for spritesheet
  var type: int = await node_import_type_modal.type_selected
  is_sprite = type == 0
  node_file_dialog.popup_centered()

  
func _update_sprite_frame(frame_index: int) -> void:
  for sprite: Sprite2D in node_sprite_container.get_children():
    sprite.frame = frame_index
  


func _scale_sprite(sprite: Node2D) -> void:
  if sprite is Sprite2D:
    sprite.scale = Vector2(texture_scale, texture_scale)
  else:
    sprite.scale = Vector2(spritesheet_texture_scale, spritesheet_texture_scale)
    
func on_layer_pressed(layer: Layer) -> void:
  var layers: Array[Node] = get_tree().get_nodes_in_group("Layer")

  for child_layer: Layer in layers:
    child_layer.remove_theme_stylebox_override("panel")

  layer.add_theme_stylebox_override("panel", layer_selected_style)
  selected_layer = layer
  _update_settings(layer.type)
  node_color_picker.color = selected_layer.color

func _update_settings(type: int) -> void:
  print(type)
  if type == 0:
    node_sprite_settings.show()
    node_spritesheet_settings.hide() 
  else:
    node_spritesheet_settings.show() 
    node_sprite_settings.hide()
  
  node_scale_spin.value = selected_layer.node_sprite.scale.x


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
    _add_layer(path)
  on_layer_pressed(node_layer_container.get_child(0))



func _add_layer(sprite_path: String) -> void:
  var sprite: Node2D
  if is_sprite:
    sprite = Sprite2D.new()
    sprite.texture = load(sprite_path)
  else:
    var sprite_frames: SpriteFrames = SpriteFrames.new()
    sprite_frames.add_frame("default", load(sprite_path))
    sprite = AnimatedSprite2D.new()
    sprite.sprite_frames = sprite_frames

  
  _scale_sprite(sprite)

  var layer: Layer = layer_scene.instantiate()
  layer.node_up_layer.pressed.connect(arrange_layer.bind(layer, 1))
  layer.gui_input.connect(func(event: InputEventMouse) -> void:
    if !event.is_pressed(): return

    on_layer_pressed(layer)
  )
  layer.node_down_layer.pressed.connect(arrange_layer.bind(layer, -1))
  layer.node_name_label.text = sprite_path.get_file().get_slice(".", 0)
  layer.node_sprite = sprite
  
  node_layer_container.add_child(layer)
  node_sprite_container.add_child(sprite)
  arrange_layer(layer, 0)


func _on_color_picker_color_changed(color: Color) -> void:
  if !selected_layer: return

  selected_layer.color = color
