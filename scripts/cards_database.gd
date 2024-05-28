
#Seed: [Type, Name, Cost, Yield, Time, Size, Text, Texture]
const DATA = {
	"Carrot" : {
		"type": "SEED",
		"name": "Carrot",
		"rarity": "common",
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
		"rarity": "common",
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
		"rarity": "common",
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
		"rarity": "common",
		"cost": 1,
		"size": 9,
		"text": "Harvest 9 tiles",
		"texture": "res://assets/custom/Scythe.png",
		"targets": ["Mature"],
		"effects": [
			{
				"name": "harvest"
			}
		]
	}, "Gather": {
		"type": "ACTION",
		"name": "Gather",
		"rarity": "common",
		"cost": 0,
		"size": 3,
		"text": "Harvest 3 tiles",
		"texture": "res://assets/custom/Scythe.png",
		"targets": ["Mature"],
		"effects": [
			{
				"name": "harvest"
			}
		]
	}, "Radish": {
		"type": "SEED",
		"name": "Radish",
		"rarity": "common",
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
		"rarity": "common",
		"cost": 2,
		"yield": 30,
		"time": 5,
		"size": 4,
		"text": "",
		"texture": 7,
		"effects": {}
	}, "Honey Melon": {
		"type": "SEED",
		"name": "Honey Melon",
		"rarity": "rare",
		"cost": 1,
		"size": 1,
		"yield": 100,
		"time": 10,
		"text": "",
		"texture": 0,
		"effects": {}
	}, "Bamboo": {
		"type": "SEED",
		"name": "Bamboo",
		"rarity": "rare",
		"cost": 0,
		"yield": 1,
		"time": 1,
		"size": 9,
		"text": "",
		"texture": 2,
		"effects": {}
	}, "Potato": {
		"type": "SEED",
		"name": "Potato",
		"rarity": "common",
		"cost": 1,
		"yield": 4,
		"size": 6,
		"time": 2,
		"text": "",
		"texture": 8,
		"effects": {}
	}, "Conjure Raincloud": {
		"type": "ACTION",
		"name": "Conjure Raincloud",
		"rarity": "rare",
		"cost": 1,
		"size": 9,
		"text": "Irrigate 9 tiles \nfor 3 weeks",
		"texture": "res://assets/custom/Raincloud.png",
		"targets": ["Empty", "Mature", "Growing"],
		"effects": [
			{
				"name": "irrigate",
				"duration": 3
			}
		]
	}, "Time Bubble": {
		"type": "ACTION",
		"name": "Time Bubble",
		"rarity": "rare",
		"cost": 0,
		"size": 6,
		"text": "Grow 4 tiles by \n1 week",
		"texture": "res://assets/custom/TimeBubble.png",
		"targets": ["Growing"],
		"effects": [
			{
				"name": "grow"
			}
		]
	}, "Little Friend": {
		"type": "ACTION",
		"name": "Little Friend",
		"rarity": "rare",
		"cost": 2,
		"size": -1,
		"text": "Harvest the entire \nfarm",
		"texture": "res://assets/custom/LittleHelper.png",
		"targets": ["Mature"],
		"effects": [
			{
				"name": "harvest"
			}
		]
	},
	"Sprinkler": {
		"name": "Sprinkler",
		"type": "STRUCTURE",
		"rarity": "rare",
		"texture": "res://assets/custom/Sprinkler.png",
		"cost": 1,
		"size": 1,
		"text": "Irrigates 8\nadjacent tiles at\nthe start of the\nturn",
		"effects": [
			{
				"name": "irrigate",
				"range": "adjacent",
				"time": "week_start"
			}
		]
	},
	"Harvester": {
		"name": "Harvester",
		"type": "STRUCTURE",
		"rarity": "rare",
		"texture": "res://assets/custom/Harvester.png",
		"cost": 1,
		"size": 1,
		"text": "Harvests 8 adjacent\ntiles at the end of\nthe week",
		"effects": [
			{
				"name": "harvest",
				"range": "adjacent",
				"time": "week_start"
			}
		]
	}
}
