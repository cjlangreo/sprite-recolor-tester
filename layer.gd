extends PanelContainer
class_name Layer


const BLUE_COLOR: Color = Color(0.0, 0.576, 1.0)
const RED_COLOR: Color = Color(1.0, 0.157, 0.0)


var node_sprite: Node2D
var type: int:
  get:
    return 0 if node_sprite is Sprite2D else 1

@export_group("Nodes", "node_")
@export var node_up_layer: Button
@export var node_down_layer: Button
@export var node_close_layer: Button
@export var node_name_label: Label
@export var node_color_rect: ColorRect

@onready var color: Color = Color.WHITE:
  set(value):
    color = value
    node_sprite.material.set_shader_parameter("color", color)
    node_color_rect.color = color

@export var selected_style: StyleBoxFlat
@export var shader: Shader

func _ready() -> void:
  node_sprite.material = ShaderMaterial.new()
  node_sprite.material.shader = shader
  node_close_layer.pressed.connect(remove_layer)


func remove_layer() -> void:
   node_sprite.call_deferred("queue_free")
   call_deferred("queue_free")
