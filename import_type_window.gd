extends Window
class_name ImportTypeWindow


@export var sprite_button: Button
@export var spritesheet_button: Button

signal type_selected

func _ready() -> void:
  close_requested.connect(_close_requested)

  sprite_button.pressed.connect(_type_selected.bind(0))
  spritesheet_button.pressed.connect(_type_selected.bind(1))

func _close_requested() -> void:
  hide()

func _type_selected(type: int) -> void:
  type_selected.emit(type)
  _close_requested()