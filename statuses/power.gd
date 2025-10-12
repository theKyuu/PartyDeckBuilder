class_name PowerStatus
extends Status


func initialize_status(target: Node) -> void:
	status_changed.connect(_on_status_changed)
	_on_status_changed()

func _on_status_changed() -> void:
	print("Power status: +%s damage" % stacks)
