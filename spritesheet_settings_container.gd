extends PanelContainer
class_name SpritesheetSettings

@export var enabled_checkbox: CheckBox
@export var settings_container: PanelContainer

@export var animated_checkbox: CheckBox
@export var frame_spiner_container: HBoxContainer
@export var frames_container: VBoxContainer

@export var add_frame_button: Button
@export var frame_number_component: PackedScene


@export var frame_spinner: SpinBox

@export var cols_spinner: SpinBox
@export var rows_spinner: SpinBox

signal spritesheet_toggled
signal animatable_toggled
signal frame_index_changed
signal col_row_updated

func _ready() -> void:
  enabled_checkbox.toggled.connect(_toggle_settings_container_visibility)
  _toggle_settings_container_visibility(false)


  animated_checkbox.toggled.connect(_toggle_animatable)
  _toggle_animatable(false)

  add_frame_button.pressed.connect(_add_frame)
  _add_frame()

  _assign_frame_numbers()
  
  cols_spinner.value_changed.connect(_col_row_updated)
  rows_spinner.value_changed.connect(_col_row_updated)

  frame_spinner.value_changed.connect(frame_index_changed.emit)


func _col_row_updated(_value: int) -> void:
  col_row_updated.emit(cols_spinner.value, rows_spinner.value)

func _toggle_settings_container_visibility(toggled_on: bool) -> void:
  settings_container.visible = toggled_on
  spritesheet_toggled.emit(toggled_on, cols_spinner.value, rows_spinner.value)

func _toggle_animatable(toggled_on: bool) -> void:
  frames_container.visible = toggled_on
  frame_spiner_container.visible = !toggled_on
  animatable_toggled.emit(toggled_on)


func _add_frame() -> void:
  var frame_component: FrameNumberComponent = frame_number_component.instantiate() as FrameNumberComponent
  frame_component.delete_button.pressed.connect(_delete_frame.bind(frame_component))

  
  frames_container.add_child(frame_component)
  frames_container.move_child(add_frame_button, -1)
  _assign_frame_numbers()

func _delete_frame(frame: FrameNumberComponent) -> void:
  if frames_container.get_child_count() > 2:
    frame.queue_free.call_deferred()
  await get_tree().process_frame
  _assign_frame_numbers.call_deferred()

func _assign_frame_numbers() -> void:
  for child: Control in frames_container.get_children():
    if child is Button: continue
    child.label.text = "Frame " + str(child.get_index() + 1)
