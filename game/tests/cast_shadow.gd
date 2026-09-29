extends SceneTree
const REGR = preload("res://scripts/reg001_render.gd")
const CAST = preload("res://scripts/cast_shadow.gd")
const MODELED = preload("res://scripts/modeled_assets.gd")

func _initialize() -> void:
	# regras: tudo que tem altura projeta sombra; rasteiros, água, interior e relevo (sombra assada) não
	for asset in ["nat_tree_pine", "nat_cactus_tall", "str_watchtower_stone", "str_windmill", "str_barn", "nat_well_stone", "nat_tent_small", "city_fountain", "city_lamp_post_a", "APP:city_wall", "APP:city_tree_green", "APP:city_roof_red", "dg_portcullis", "nat_statue_guardian", "nat_altar_ancient"]:
		assert(REGR.casts_shadow(asset), "deveria projetar sombra: " + asset)
	for asset in ["nat_decal_grass_a", "ter_water_glint", "str_crop_wheat", "nat_flowers_meadow", "int_bed", "nat_plateau_ice_m", "nat_ridge_rock_a", "nat_wall_cliff_sand_a", "nat_cliff_end_ice_ap", "nat_hill_wide_earth", "APP:city_floor_clean", "APP:city_house_door"]:
		assert(not REGR.casts_shadow(asset), "não deveria projetar sombra em tempo real: " + asset)
	# a luz vem de cima-esquerda: a sombra cai para a direita e para baixo
	assert(CAST.SHEAR_X > 0.0 and CAST.SHEAR_Y > 0.0)
	# todo asset modelado de altura relevante e fora das exceções projeta sombra (nenhum ficou esquecido)
	var missing: Array = []
	for id_value in MODELED.entries().keys():
		var id: String = str(id_value)
		var e: Dictionary = MODELED.entry(id)
		var foot: Array = e["foot"]
		var height: float = float(foot[1]) * float(e["draw_scale"])
		if height >= 60.0 and not REGR.casts_shadow(id) and not (id.begins_with("nat_plateau_") or id.begins_with("nat_ridge_") or id.begins_with("nat_wall_cliff_") or id.begins_with("nat_cliff_") or id.begins_with("nat_hill_") or id.begins_with("int_") or id.begins_with("ter_") or id.begins_with("str_dock") or id.begins_with("str_boat") or id.begins_with("nat_waterfall") or id.begins_with("nat_dune") or id.begins_with("nat_rock_pillars") or id.begins_with("fx_") or id.begins_with("str_crop") or id.begins_with("fau_") or id.begins_with("npc_")):
			missing.append(id)
	assert(missing.is_empty(), "assets altos sem sombra projetada: " + str(missing))
	print("CAST SHADOW PASS: regras de sombra projetada, direção da luz e cobertura de assets altos")
	quit()
