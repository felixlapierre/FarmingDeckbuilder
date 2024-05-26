
#Seed: [Type, Name, Cost, Yield, Time, Size, Text, Texture]
const DATA = {
	"Carrot" :
		{
			"type": "SEED",
			"name": "Carrot",
			"cost": 1,
			"yield": 3,
			"time": 3,
			"size": 9,
			"text": "",
			"texture": 1,
			"effects": {}
		},
	"Pumpkin" :
		{ 
			"type": "SEED",
			"name": "Pumpkin",
			"cost": 1,
			"yield": 15,
			"time": 3,
			"size": 1,
			"text": "",
			"texture": 4,
			"effects": {}
		},
	"Blueberry" :
		{
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
			
		},
	"Scythe": 
		{
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
		}
}
