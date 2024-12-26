extends CardData
class_name VesselBound

func copy():
	var new = VesselBound.new()
	new.assign(self)
	return new
	
func on_card_drawn(args: EventArgs):
	args.turn_manager.energy -= 1
