extends PanelContainer

@export var enabled_checkbox: CheckBox
@export var settings_container: PanelContainer

@export var animated_checkbox: CheckBox
@export var frame_spiner_container: HBoxContainer
@export var frames_container: VBoxContainer


func _ready() -> void:
  enabled_checkbox.toggled.connect(_toggle_settings_container_visibility)
  _toggle_settings_container_visibility(false)


  animated_checkbox.toggled.connect(_toggle_animatable)
  _toggle_animatable(false)

func _toggle_settings_container_visibility(toggled_on: bool) -> void:
  settings_container.visible = toggled_on


func _toggle_animatable(toggled_on: bool) -> void:
  frames_container.visible = toggled_on
  frame_spiner_container.visible = !toggled_on
