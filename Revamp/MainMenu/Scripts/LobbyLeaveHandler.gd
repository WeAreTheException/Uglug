extends Node
class_name LobbyLeaveHandler

signal leave_requested
signal leave_completed


func leave_lobby() -> void:
	leave_requested.emit()

	GDSync.lobby_leave()

	leave_completed.emit()
