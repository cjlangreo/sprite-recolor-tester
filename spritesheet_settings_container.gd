extends PanelContainer


@export var enabled_checkbox: CheckBox
@export var settings_container: PanelContainer


func _ready() -> void:
  enabled_checkbox.toggled.connect(_toggle_settings_container_visibility)
  _toggle_settings_container_visibility(!enabled_checkbox.toggle_mode)


func _toggle_settings_container_visibility(toggled_on: bool) -> void:
  settings_container.visible = toggled_on