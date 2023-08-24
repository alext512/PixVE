class_name NumberedLabelButton extends Button
var number = 0 # STARTS WITH 1

func _init(number : int) -> void:  #STARTS FROM 1,1
	self.number = number

func get_number():
	return number

func set_number(number):
	self.number = number
