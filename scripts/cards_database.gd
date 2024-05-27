
#Seed: [Type, Name, Cost, Yield, Time, Size, Text, Texture]
const DATA = {
	"Carrot" : {
		"type": "SEED",
		"name": "Carrot",
		"cost": 1,
		"yield": 3,
		"time": 3,
		"size": 9,
		"text": "",
		"texture": 1,
		"effects": {}
	}, "Pumpkin" : { 
		"type": "SEED",
		"name": "Pumpkin",
		"cost": 1,
		"yield": 15,
		"time": 3,
		"size": 1,
		"text": "",
		"texture": 4,
		"effects": {}
	}, "Blueberry" : {
		"type": "SEED", 
		"name": "Blueberry",
		"cost": 1,
		"yield": 3,
		"time": 3,
		"size": 3, 
		"text": "Recurring",
		"texture": 3,
		"effects": {
			"recurring": {
				"progress": 1.0
			}
		}
	}, "Scythe": {
		"type": "ACTION",
		"name": "Scythe",
		"cost": 1,
		"size": 9,
		"text": "Harvest 9 tiles",
		"texture": "res://assets/custom/Scythe.png",
		"targets": ["Mature"],
		"actions": [
			{
				"name": "harvest"
			}
		]
	}, "Gather": {
		"type": "ACTION",
		"name": "Gather",
		"cost": 0,
		"size": 3,
		"text": "Harvest 3 tiles",
		"texture": "res://assets/custom/Scythe.png",
		"targets": ["Mature"],
		"actions": [
			{
				"name": "harvest"
			}
		]
	}, "Radish": {
		"type": "SEED",
		"name": "Radish",
		"cost": 1,
		"yield": "4",
		"time": 1,
		"size": 2,
		"text": "",
		"texture": 6,
		"effects": {}
	}, "Cactus": {
		"type": "SEED",
		"name": "Cactus",
		"cost": 2,
		"yield": 30,
		"time": 5,
		"size": 4,
		"text": "",
		"texture": 7,
		"effects": {}
	}, "Conjure Raincloud": {
		"type": "ACTION",
		"name": "Conjure Raincloud",
		"cost": 1,
		"size": 9,
		"text": "Irrigate 9 tiles \nfor 3 weeks",
		"texture": "res://assets/custom/Raincloud.png",
		"targets": ["Empty", "Mature", "Growing"],
		"actions": [
			{
				"name": "irrigate",
				"duration": 3
			}
		]
	}, "Time Bubble": {
		"type": "ACTION",
		"name": "Time Bubble",
		"cost": 0,
		"size": 4,
		"text": "Grow 4 tiles by \n1 week",
		"texture": "res://assets/custom/TimeBubble.png",
		"targets": ["Growing"],
		"actions": [
			{
				"name": "grow"
			}
		]
	}, "Little Friend": {
		"type": "ACTION",
		"name": "Little Friend",
		"cost": 2,
		"size": -1,
		"text": "Harvest the entire \nfarm",
		"texture": "res://assets/custom/LittleHelper.png",
		"targets": ["Mature"],
		"actions": [
			{
				"name": "harvest"
			}
		]
	}
}

const SHOP = {
	"Carrot": {
		"type": "CARD",
		"weight": 0.5,
		"min_cost": 10,
		"max_cost": 30
	},
	"Pumpkin": {
		"type": "CARD",
		"weight": 0.5,
		"min_cost": 10,
		"max_cost": 30
	},
	"Blueberry": {
		"type": "CARD",
		"weight": 0.5,
		"min_cost": 10,
		"max_cost": 30
	},
	"Scythe": {
		"type": "CARD",
		"weight": 1,
		"min_cost": 10,
		"max_cost": 30
	},
	"Gather": {
		"type": "CARD",
		"weight": 1,
		"min_cost": 10,
		"max_cost": 30
	},
	"Radish": {
		"type": "CARD",
		"weight": 0.8,
		"min_cost": 15,
		"max_cost": 35
	},
	"Cactus": {
		"type": "CARD",
		"weight": 0.8,
		"min_cost": 15,
		"max_cost": 35
	},
	"Conjure Raincloud": {
		"type": "CARD",
		"weight": 3,
		"min_cost": 30,
		"max_cost": 50
	},
	"Time Bubble": {
		"type": "CARD",
		"weight": 3,
		"min_cost": 20,
		"max_cost": 40
	},
	"Little Friend": {
		"type": "CARD",
		"weight": 3,
		"min_cost": 30,
		"max_cost": 40
	}
}
