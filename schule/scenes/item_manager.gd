extends Node

var rescources = [] # alles an zeugs 
var itemsInWorld = [] # das was wirklich in der Welt spawnt

func _ready(): 
	LoadRescource()
	
	
func LoadRescource(): #  fügt alle items in den rescource Array
	var path  = "res://Items/Rescources/"
	var dir = DirAccess.open(path)
	dir.open(path)
	dir.list_dir_begin()
	while true: 
		var file_name = dir.get_next()
		if file_name == "": # wenn wir durch alle files durch sind wird die schleife beendet
			break	
		elif file_name.ends_with(".tscn"): #nur um sicher zu gehen, dass nur scenes ins array geschmissen werden 
			rescources.append(load(path + "/" + file_name))
	dir.list_dir_end()
