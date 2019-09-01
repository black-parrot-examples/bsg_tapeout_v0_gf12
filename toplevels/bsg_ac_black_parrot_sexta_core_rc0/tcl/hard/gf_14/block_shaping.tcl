set core_width 2500
set core_height 2500

# Number of blackparrot tiles
set num_bp_tiles 16
set tile_rows 4
set tile_cols 4

set channel_width 5
set channel_height 35
set tile_width [round_up_to_nearest [expr $core_width/4 - 10*$channel_width] [unit_width]]
#set tile_height [round_up_to_nearest [expr $core_height/7 - 10*$channel_height] [unit_height]]
set tile_height [round_up_to_nearest 320.000 [unit_height]]

# Manual swizzle. There's a clever way to do this, but I'll leave it to leetcode
set bp_tile_cells [list]
foreach {i} {15 14 13 12 8 9 10 11 7 6 5 4 0 1 2 3} {
  append_to_collection bp_tile_cells [get_cells -hier rof1_${i}__tile]
}

bsg_create_block_array_grid $bp_tile_cells \
  -grid mib_placement_grid \
  -relative_to core \
  -x [expr 15*$channel_width] \
  -y [expr $channel_height] \
  -rows $tile_rows \
  -cols $tile_cols \
  -min_channel [list $channel_width $channel_height] \
  -width $tile_width \
  -height $tile_height

# Flip the tiles that we want flipped
foreach {i} {15 14 13 12 7 6 5 4} {
  move_objects -rotate_by MY -delta {3.36 0} [get_cells -hier rof1_${i}__tile]
}

