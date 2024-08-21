class_name Enums

enum CursorShape {
	Square,
	Line,
	Elbow,
	Fill
}

enum TileState {
	Empty,
	Destroyed,
	Growing,
	Mature,
	Structure,
	Blighted,
	Inactive
}

enum CardState {
	InHand,
	InPlay,
	InMouse,
	FocusInHand,
	MoveDrawnCardToHand,
	ReOrganiseHand,
	MoveToDiscard,
	InShop
}
