extends RefCounted

## Left, top, right, bottom insets in viewport pixels, with a minimum
## so controls never sit flush against the screen edge.


static func get_margins(node: Node) -> Vector4:
	var viewport := node.get_viewport()
	var visible := viewport.get_visible_rect().size
	var minimum := Vector4(28, 18, 28, 18)
	var window_size := DisplayServer.window_get_size()
	if window_size.x <= 0 or window_size.y <= 0 or visible.x <= 0.0 or visible.y <= 0.0:
		return minimum
	var safe := DisplayServer.get_display_safe_area()
	var scale_x := visible.x / float(window_size.x)
	var scale_y := visible.y / float(window_size.y)
	var right := float(window_size.x - safe.position.x - safe.size.x)
	var bottom := float(window_size.y - safe.position.y - safe.size.y)
	return Vector4(
		maxf(minimum.x, safe.position.x * scale_x),
		maxf(minimum.y, safe.position.y * scale_y),
		maxf(minimum.z, right * scale_x),
		maxf(minimum.w, bottom * scale_y)
	)
