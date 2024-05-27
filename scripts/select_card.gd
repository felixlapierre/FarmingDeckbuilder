extends Control

var CardBase
var cards = []

enum SelectState {
	Selecting,
	Confirming
}
var state = SelectState.Selecting
var card_selected_index

signal card_selected
signal select_cancelled

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CardBase = preload("res://scenes/card_base.tscn")

func do_card_pick(cards_input, prompt_text):
	cards = cards_input
	$SelectContainer/Header/PromptLabel.text = prompt_text
	state = SelectState.Selecting
	$SelectContainer.visible = true
	$ConfirmContainer.visible = false
	for card in cards:
		var display_card = CardBase.instantiate()
		display_card.state = CardState.InShop
		display_card.set_card_info(card)
		display_card.on_clicked.connect(on_card_selected)
		$SelectContainer/CardContainer.add_child(display_card)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_card_selected(card):
	match state:
		SelectState.Selecting:
			state = SelectState.Confirming
			card_selected_index = card.get_index()
			$SelectContainer/CardContainer.remove_child(card)
			$SelectContainer.visible = false
			$ConfirmContainer/ConfirmVbox.add_child(card)
			$ConfirmContainer/ConfirmVbox.move_child(card, 1)
			$ConfirmContainer.visible = true
			pass
		SelectState.Confirming:
			card_selected.emit(card)
			pass

func _on_confirm_button_pressed() -> void:
	for child in $SelectContainer/CardContainer.get_children():
		$SelectContainer/CardContainer.remove_child(child)
	var card = $ConfirmContainer/ConfirmVbox.get_child(1)
	card_selected.emit(card)
	$ConfirmContainer/ConfirmVbox.remove_child(card)

func _on_cancel_button_pressed() -> void:
	state = SelectState.Selecting
	var card = $ConfirmContainer/ConfirmVbox.get_child(1)
	$ConfirmContainer/ConfirmVbox.remove_child(card)
	$SelectContainer/CardContainer.add_child(card)
	$SelectContainer/CardContainer.move_child(card, card_selected_index)
	$SelectContainer.visible = true
	$ConfirmContainer.visible = false


func _on_close_button_pressed() -> void:
	for child in $SelectContainer/CardContainer.get_children():
		$SelectContainer/CardContainer.remove_child(child)
	select_cancelled.emit()
