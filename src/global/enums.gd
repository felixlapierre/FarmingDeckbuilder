class_name Enums

enum CursorShape {
	Smart,
	Square,
	Line,
	Elbow
}

enum TileState {
	Empty,
	Growing,
	Mature,
	Structure,
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

enum AnimOn {
	Mouse,
	Tiles,
	Center
}
