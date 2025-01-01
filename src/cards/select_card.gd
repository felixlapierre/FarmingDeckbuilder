extends Control

class_name SelectCard

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
var tooltip: Tooltip
var display_only = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CardBase = preload("res://src/cards/card_base.tscn")

func disable_cancel():
	$SelectContainer/Header/CloseButton.visible = false

func do_card_display(cards_input, prompt_text):
	$SelectContainer/Header/CloseButton.text = "Close"
	display_only = true
	do_card_pick(cards_input, prompt_text)

func do_card_pick(cards_input, prompt_text):
	cards = cards_input
	$SelectContainer/Header/PromptLabel.text = prompt_text
	state = SelectState.Selecting
	$SelectContainer.visible = true
	$ConfirmContainer.visible = false
	for card in cards:
		var display_card = CardBase.instantiate()
		display_card.tooltip = tooltip
		display_card.state = Enums.CardState.InShop
		display_card.set_card_info(card)
		if !display_only:
			display_card.on_clicked.connect(on_card_selected)
		$SelectContainer/Scroll/CardContainer.add_child(display_card)
		$ConfirmContainer/ConfirmVbox/EnhanceLabel.visible = enhance != null

func do_enhance_pick(cards_input, p_enhance: Enhance, prompt_text):
	cards = []
	enhance = p_enhance
	# Filter for cards the enhance applies to
	for card in cards_input:
		if enhance.is_card_eligible(card):
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
			$SelectContainer/Scroll/CardContainer.remove_child(card)
			$SelectContainer.visible = false
			$ConfirmContainer/ConfirmVbox/ConfirmCards.add_child(card)
			$ConfirmContainer.visible = true
			if enhance != null:
				var enhanced_card = card.card_info.apply_enhance(enhance)
				var display_card = CardBase.instantiate()
				display_card.tooltip = tooltip
				display_card.state = Enums.CardState.InShop
				display_card.set_card_info(enhanced_card)
				$ConfirmContainer/ConfirmVbox/ConfirmCards.add_child(display_card)
			pass

func _on_confirm_button_pressed() -> void:
	for child in $SelectContainer/Scroll/CardContainer.get_children():
		$SelectContainer/Scroll/CardContainer.remove_child(child)
		
	var card = $ConfirmContainer/ConfirmVbox/ConfirmCards.get_child(0)
	select_callback.call(card.card_info)
	for child in $ConfirmContainer/ConfirmVbox/ConfirmCards.get_children():
		$ConfirmContainer/ConfirmVbox/ConfirmCards.remove_child(child)
	enhance = null

func _on_cancel_button_pressed() -> void:
	state = SelectState.Selecting
	var card = $ConfirmContainer/ConfirmVbox/ConfirmCards.get_child(0)
	for child in $ConfirmContainer/ConfirmVbox/ConfirmCards.get_children():
		$ConfirmContainer/ConfirmVbox/ConfirmCards.remove_child(child)
	$SelectContainer/Scroll/CardContainer.add_child(card)
	$SelectContainer/Scroll/CardContainer.move_child(card, card_selected_index)
	card.on_clicked.connect(on_card_selected)
	$SelectContainer.visible = true
	$ConfirmContainer.visible = false


func _on_close_button_pressed() -> void:
	for child in $SelectContainer/Scroll/CardContainer.get_children():
		$SelectContainer/Scroll/CardContainer.remove_child(child)
	select_cancelled.emit()
	enhance = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		if state == SelectState.Confirming:
			_on_cancel_button_pressed()
		elif state == SelectState.Selecting:
			_on_close_button_pressed()

func set_close_button_text(text: String):
	$SelectContainer/Header/CloseButton.text = text
