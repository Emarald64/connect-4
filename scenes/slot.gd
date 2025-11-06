class_name Slot

var filled:=false
var red:=false

@warning_ignore("shadowed_variable")
func _init(filled:=false,red:=false) -> void:
	self.filled=filled
	self.red=red

func duplicate() -> Slot:
	return Slot.new(filled,red)
