extends Control

const BUILD_NUMBER := "zaodworld-stop01-v1"

@onready var build_number: Label = %BuildNumber
@onready var status: Label = %Status
@onready var log_viewer: RichTextLabel = %LogViewer


func _ready() -> void:
	build_number.text = "Build: %s" % BUILD_NUMBER
	status.text = "Runtime ready"
	_append_log("Zaod World start screen initialized")
	_append_log("Platform: %s" % OS.get_name())
	_append_log("Build: %s" % BUILD_NUMBER)


func _append_log(message: String) -> void:
	var timestamp := Time.get_datetime_string_from_system(true)
	log_viewer.add_text("[%s] %s\n" % [timestamp, message])
