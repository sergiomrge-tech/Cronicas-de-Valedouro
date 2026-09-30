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
    hub.camera.position_smoothing_enabled = false
    var shots: Array[Dictionary] = [
        {"name":"01_praca_central", "pos":Region.world_from_hub(Vector2(1150,970))},
        {"name":"02_castelo_valedouro", "pos":Region.world_from_hub(Vector2(1150,690))},
        {"name":"03_servicos_cidade", "pos":Region.world_from_hub(Vector2(1150,940))},
        {"name":"04_portao_sul", "pos":Region.world_from_hub(Vector2(1150,1370))},
        {"name":"05_campos_do_vale", "pos":Region.world_from_hub(Vector2(1150,1870))},
        {"name":"06_fazenda_e_combates", "pos":Region.world_from_hub(Vector2(980,2070))},
        {"name":"07_estrada_sul_expandida", "pos":Vector2(Region.SOUTH_ROAD_X,Region.HUB_RECT.end.y+2500.0)},
        {"name":"08_cinturao_exploracao", "pos":Vector2(Region.SOUTH_ROAD_X-1800.0,Region.HUB_RECT.end.y+4300.0)},
        {"name":"09_posto_da_estrada", "pos":Vector2(Region.SOUTH_ROAD_X-330.0,Region.HUB_RECT.end.y+1350.0)},
        {"name":"10_ruinas_caminho_antigo", "pos":Vector2(Region.SOUTH_ROAD_X+1950.0,Region.HUB_RECT.end.y+4100.0)},
        {"name":"11_ruinas_primeiro_vento", "pos":Vector2(Region.SOUTH_ROAD_X-620.0,Region.HUB_RECT.position.y-1800.0)},
        {"name":"12_clareira_do_alfa", "pos":Vector2(Region.SOUTH_ROAD_X+760.0,Region.HUB_RECT.position.y-2950.0)},
        {"name":"13_mina_do_eco", "pos":Vector2(Region.SOUTH_ROAD_X-980.0,Region.HUB_RECT.position.y-4100.0)},
        {"name":"14_arquivo_seis_coroas", "pos":Vector2(Region.SOUTH_ROAD_X+940.0,Region.HUB_RECT.position.y-5350.0)},
        {"name":"15_guardiao_do_eco", "pos":Vector2(Region.SOUTH_ROAD_X-980.0,Region.HUB_RECT.position.y-4460.0)}
    ]
    for shot: Dictionary in shots:
        hero.position = shot["pos"] as Vector2
        hub.world_stream._refresh(true)
        await process_frame
        await process_frame
        await process_frame
        await process_frame
        await process_frame
        var image: Image = root.get_texture().get_image()
        var out: String = "%s/%s.png" % [output_dir, str(shot["name"])]
        var err: Error = image.save_png(ProjectSettings.globalize_path(out))
        assert(err == OK)
        print("CARTOON_CAPTURED ", out)
    quit(0)
