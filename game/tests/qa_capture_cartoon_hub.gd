extends SceneTree

const HUB = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")

func _initialize() -> void:
    call_deferred("capture")

func capture() -> void:
    var hub: Node = HUB.instantiate()
    root.add_child(hub)
    await process_frame
    await process_frame
    await process_frame
    var output_dir: String = "user://ci_output_cartoon"
    if OS.get_cmdline_user_args().size() > 0:
        output_dir = OS.get_cmdline_user_args()[0]
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
    var hero: Node2D = hub.get_node("WorldObjects/Player")
    var shots: Array[Dictionary] = [
        {"name":"01_praca_central", "pos":Region.world_from_hub(Vector2(1150,970))},
        {"name":"02_castelo_valedouro", "pos":Region.world_from_hub(Vector2(1150,690))},
        {"name":"03_servicos_cidade", "pos":Region.world_from_hub(Vector2(1150,940))},
        {"name":"04_portao_sul", "pos":Region.world_from_hub(Vector2(1150,1370))},
        {"name":"05_campos_do_vale", "pos":Region.world_from_hub(Vector2(1150,1870))},
        {"name":"06_fazenda_e_combates", "pos":Region.world_from_hub(Vector2(980,2070))},
        {"name":"07_estrada_sul_expandida", "pos":Vector2(Region.SOUTH_ROAD_X,Region.HUB_RECT.end.y+2500.0)},
        {"name":"08_cinturao_exploracao", "pos":Vector2(Region.SOUTH_ROAD_X-1800.0,Region.HUB_RECT.end.y+4300.0)}
    ]
    for shot: Dictionary in shots:
        hero.position = shot["pos"] as Vector2
        await process_frame
        await process_frame
        await process_frame
        var image: Image = root.get_texture().get_image()
        var out: String = "%s/%s.png" % [output_dir, str(shot["name"])]
        var err: Error = image.save_png(ProjectSettings.globalize_path(out))
        assert(err == OK)
        print("CARTOON_CAPTURED ", out)
    quit(0)
