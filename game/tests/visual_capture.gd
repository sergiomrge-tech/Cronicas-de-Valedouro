extends SceneTree
const WORLD = preload("res://scripts/world_map.gd")
var game: Node2D

func _initialize() -> void:
    call_deferred("capture_all")

func capture_all() -> void:
    if FileAccess.file_exists("user://valedouro_v1.json"):
        DirAccess.remove_absolute(ProjectSettings.globalize_path("user://valedouro_v1.json"))
    game = load("res://scenes/Main.tscn").instantiate()
    root.add_child(game)
    await process_frame
    await process_frame
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://ci_output"))
    var spots: Array[Dictionary] = [
        {"name":"01_vila", "zone":"cidade", "pos":WORLD.TOWN + Vector2(884,696)},
        {"name":"02_floresta_oeste", "zone":"cidade", "pos":Vector2(300,900)},
        {"name":"03_campos_sul", "zone":"cidade", "pos":Vector2(500,2000)},
        {"name":"04_vale_sul", "zone":"cidade", "pos":Vector2(1400,2000)},
        {"name":"05_ponte_rio", "zone":"cidade", "pos":Vector2(WORLD.river_x(1250.0),1250)},
        {"name":"06_gelo", "zone":"cidade", "pos":Vector2(2700,250)},
        {"name":"07_deserto", "zone":"cidade", "pos":Vector2(2700,1900)},
        {"name":"08_bosque_instancia", "zone":"floresta", "pos":Vector2(1000,750)}
    ]
    for spot: Dictionary in spots:
        game.zone = str(spot["zone"])
        game.player = spot["pos"] as Vector2
        game.map_visible = false
        game.queue_redraw()
        await process_frame
        await process_frame
        await process_frame
        var image: Image = root.get_texture().get_image()
        var out: String = ProjectSettings.globalize_path("res://ci_output/%s.png" % str(spot["name"]))
        var err: Error = image.save_png(out)
        assert(err == OK)
        print("CAPTURED ", out)
    quit(0)
