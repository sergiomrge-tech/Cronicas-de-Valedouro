extends SceneTree

func _initialize() -> void:
	call_deferred("_verify")

func _verify() -> void:
	await process_frame
	var driver: String = RenderingServer.get_current_rendering_driver_name()
	var method: String = RenderingServer.get_current_rendering_method()
	print("DX12_RUNTIME driver=%s method=%s" % [driver,method])
	if driver != "d3d12":
		push_error("Esperado driver d3d12 no Windows, recebido: "+driver)
		quit(1)
		return
	if method != "mobile":
		push_error("Esperado renderer mobile no Windows, recebido: "+method)
		quit(1)
		return
	print("cartoon_dx12_runtime_v040: PASS")
	quit(0)
