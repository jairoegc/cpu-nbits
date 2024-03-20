check_lvs
gui_change_highlight -remove -all_colors
gui_set_layout_layer_visibility -toggle [get_layers -filter {mask_name == metal7} -quiet]
change_selection [get_shapes -of_objects [get_nets mem_inst/net430]]
gui_set_highlight_options -current_color yellow
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -start SplitTool
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -drag {{248.513 249.398} {248.668 249.298}} -scale 0.0055
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -reset
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -start SplitTool
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -drag {{247.609 249.412} {247.769 249.354}} -scale 0.0028
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -drag {{247.598 249.420} {247.764 249.312}} -scale 0.0028
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.703 249.362} -scale 0.0028
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.631 249.390} -scale 0.0028
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -reset
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -start SplitTool
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -drag {{247.617 249.644} {247.772 249.639}} -scale 0.0028
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.703 249.628} -scale 0.0028
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.703 249.628} -scale 0.0028
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -drag {{247.778 249.631} {247.598 249.689}} -scale 0.0028
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -reset
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -start SplitTool
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -drag {{247.575 248.807} {247.776 248.796}} -scale 0.0014
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.690 248.797} -scale 0.0014
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.690 248.797} -scale 0.0014
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -drag {{247.622 248.800} {247.774 248.736}} -scale 0.0014
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.698 248.776} -scale 0.0014
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -drag {{247.646 248.823} {247.788 248.755}} -scale 0.0014
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.622 248.805} -scale 0.0014
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.773 248.802} -scale 0.0014
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -reset
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -start StretchTool
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -drag {{247.604 248.785} {247.799 248.757}} -scale 0.0056
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.726 248.785} -scale 0.0056
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.620 248.773} -scale 0.0056
snap_objects
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -drag {{247.598 248.751} {247.799 248.718}} -scale 0.0056
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.765 248.757} -scale 0.0056
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.570 248.751} -scale 0.0056
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.698 248.924} -scale 0.0014
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.738 248.929} -scale 0.0014
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -reset
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -start SplitTool
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -drag {{247.325 249.421} {247.438 249.428}} -scale 0.0007
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.401 249.417} -scale 0.0007
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.401 249.417} -scale 0.0007
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.365 249.414} -scale 0.0007
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.418 249.413} -scale 0.0007
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -drag {{247.332 249.401} {247.430 249.380}} -scale 0.0007
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.412 249.384} -scale 0.0007
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.408 249.384} -scale 0.0007
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.392 249.383} -scale 0.0007
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.392 249.383} -scale 0.0007
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -reset
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -start StretchTool
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.692 247.842} -scale 0.0056
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.703 247.032} -scale 0.0056
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -apply
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -reset
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -start CopyTool
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {248.397 250.438} -scale 0.0112
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {248.218 247.196} -scale 0.0112
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -reset
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -start CopyTool
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {248.592 250.441} -scale 0.0056
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {248.603 247.092} -scale 0.0056
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -reset
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -start SplitTool
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -drag {{248.531 248.535} {248.693 248.495}} -scale 0.0056
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {248.614 248.512} -scale 0.0056
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -reset
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -drag {{247.597 248.518} {247.770 248.484}} -scale 0.0056
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -drag {{247.737 248.434} {247.630 248.440}} -scale 0.0056
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.569 248.440} -scale 0.0056
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -reset
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -reset
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -start SplitTool
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -drag {{247.591 248.881} {247.800 248.845}} -scale 0.0014
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -reset
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -start StretchTool
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.674 248.960} -scale 0.0056
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.685 248.339} -scale 0.0056
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -reset
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -start StretchTool
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.730 248.898} -scale 0.0056
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -reset
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -reset
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -start StretchTool
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.708 248.881} -scale 0.0056
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point {247.691 249.698} -scale 0.0056
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -reset
check_lvs