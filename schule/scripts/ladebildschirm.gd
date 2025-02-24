extends Control

# Referenzen zu den Knoten in der Szene
@onready var world_list : VBoxContainer = $ScrollContainer/VBoxContainer  # Korrekte Zuweisung
@onready var world_details = $WorldDetails  # Details-Panel für die ausgewählte Welt
@onready var delete_button = $WorldDetails/DeleteButton  # Der Button zum Löschen der Welt

var worlds = []  # Liste der gespeicherten Welten
var selected_world = null  # Die aktuell ausgewählte Welt
var last_click_time = 0  # Zeit des letzten Klicks
const DOUBLE_CLICK_TIME = 0.3  # Zeit in Sekunden für Doppelklick-Erkennung


func _ready():
	world_list = $ScrollContainer/VBoxContainer
	if world_list:
		load_worlds()
	else:
		print("Error: world_list not found!")
		return

	if worlds.size() == 0:
		create_default_world()

# Lädt alle gespeicherten Welten und zeigt sie in der UI an
func load_worlds():
	if world_list:
		world_list.clear()
	worlds = get_saved_worlds()
	for world in worlds:
		var button = Button.new()
		button.text = world.name + " - " + world.playtime
		button.connect("pressed", Callable(self, "_on_world_button_pressed").bind(world, button))
		world_list.add_child(button)

func create_default_world():
	var default_world = WorldResource.new()
	default_world.name = "Neue Welt"
	default_world.playtime = "0 Stunden"
	save_world(default_world)
	load_worlds()
var last_clicked_button = null

func _on_world_button_pressed(world, button):
	var current_time = Time.get_ticks_msec() / 1000.0
	if button == last_clicked_button and current_time - last_click_time < DOUBLE_CLICK_TIME:
		open_world(world)
	else:
		selected_world = world
		last_clicked_button = button
		last_click_time = current_time
		world_details.visible = true
		delete_button.connect("pressed", Callable(self, "_on_delete_world").bind(world))

func _on_world_selected(world, button):
 var current_time = Time.get_ticks_msec() / 1000.0  # Aktuelle Zeit in Sekunden

 if selected_world == world and current_time - last_click_time < DOUBLE_CLICK_TIME:
  open_world(world)  # Wenn ja, öffne die Welt
  return
	
selected_world = world  # Setzt die aktuell ausgewählte Welt
last_click_time = current_time  # Speichert die Zeit des Klicks
world_details.visible = true  # Zeigt das Detail-Pane für die ausgewählte Welt
delete_button.connect("pressed", Callable(self, "_on_delete_world").bind(world))  # Verbindet den Löschen-Button mit der Lösch-Funktion

# Funktion zum Öffnen einer Welt (Hier wird die Logik zum Laden einer Welt eingefügt)
func open_world(world):
	print("Lade Welt: " + world.name)  # Gibt eine Nachricht im Debug aus
	# Hier Code zum Laden der Welt einfügen

# Wird aufgerufen, wenn der Benutzer eine Welt löschen möchte
func _on_delete_world(world):
	print("Lösche Welt: " + world.name)  # Gibt eine Nachricht im Debug aus
	delete_world_files(world)  # Ruft die Funktion zum Löschen der Dateien der Welt auf
	load_worlds()  # Aktualisiert die Anzeige der Welten in der UI

# Lädt alle gespeicherten Welten aus dem Verzeichnis "user://welten/"
func get_saved_worlds():
	var saved_worlds = []  # Liste für die gespeicherten Welten
	var dir = DirAccess.open("user://welten/")  # Öffnet den Ordner "welten"
	if dir and dir.list_dir_begin():  # Überprüft, ob der Ordner geöffnet wurde
		var file_name = dir.get_next()  # Liest den ersten Dateinamen im Ordner
		while file_name != "":  # Solange es noch Dateien gibt
			if file_name.ends_with(".tres"):  # Überprüft, ob es sich um eine .tres-Datei handelt
				var world_res = ResourceLoader.load("user://welten/" + file_name)  # Lädt die Ressource der Welt
				if world_res is WorldResource:  # Überprüft, ob die geladene Ressource eine gültige WorldResource ist
					saved_worlds.append(world_res)  # Fügt die Welt der Liste hinzu
			file_name = dir.get_next()  # Liest den nächsten Dateinamen
	return saved_worlds  # Gibt die Liste der gespeicherten Welten zurück

# Funktion zum Speichern einer neuen Welt
func save_world(world: WorldResource):
	var path = "user://welten/" + world.name + ".tres"
	var error = ResourceSaver.save(world, path)
	if error != OK:
		print("Fehler beim Speichern der Welt: ", error)

func delete_world_files(world):
	var path = "user://welten/" + world.name + ".tres"
	if DirAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("Welt " + world.name + " gelöscht!")
	else:
		print("Datei nicht gefunden: " + path)
