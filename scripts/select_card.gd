extends Control

var CardBase
var cards = []

enum SelectState {
	Selecting,
	Confirming
}
var state = SelectState.Selecting
var card_selected_index
var enhance: Enhance

signal select_cancelled

var select_callback: Callable

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

func do_enhance_pick(cards_input, p_enhance: Enhance, prompt_text):
	cards = []
	enhance = p_enhance
	# Filter for cards the enhance applies to
	for card in cards_input:
		if enhance.targets.has(card.type):
			cards.append(card)
	do_card_pick(cards, prompt_text)
	enhance = p_enhance

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
			$ConfirmContainer/ConfirmVbox/ConfirmCards.add_child(card)
			$ConfirmContainer.visible = true
			if enhance != null:
				var enhanced_card = card.card_info.apply_enhance(enhance)
				var display_card = CardBase.instantiate()
				display_card.state = CardState.InShop
				display_card.set_card_info(enhanced_card)
				$ConfirmContainer/ConfirmVbox/ConfirmCards.add_child(display_card)
			pass

func _on_confirm_button_pressed() -> void:
	for child in $SelectContainer/CardContainer.get_children():
		$SelectContainer/CardContainer.remove_child(child)
		
	var card = $ConfirmContainer/ConfirmVbox/ConfirmCards.get_child(0)
	select_callback.call(card.card_info)
	for child in $ConfirmContainer/ConfirmVbox/ConfirmCards.get_children():
		$ConfirmContainer/ConfirmVbox/ConfirmCards.remove_child(child)

func _on_cancel_button_pressed() -> void:
	state = SelectState.Selecting
	var card = $ConfirmContainer/ConfirmVbox.get_child(0)
	for child in $ConfirmContainer/ConfirmVbox/ConfirmCards.get_children():
		$ConfirmContainer/ConfirmVbox/ConfirmCards.remove_child(child)
	$SelectContainer/CardContainer.add_child(card)
	$SelectContainer/CardContainer.move_child(card, card_selected_index)
	$SelectContainer.visible = true
	$ConfirmContainer.visible = false


func _on_close_button_pressed() -> void:
	for child in $SelectContainer/CardContainer.get_children():
		$SelectContainer/CardContainer.remove_child(child)
	select_cancelled.emit()
