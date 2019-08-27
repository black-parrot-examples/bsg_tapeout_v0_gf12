set core_height 2500
set core_width 2500

set master_tile "rof1_0__tile"
set tile_llx [lindex [get_attribute [get_cell -hier $master_tile] boundary_bbox] 0 0]
set tile_lly [lindex [get_attribute [get_cell -hier $master_tile] boundary_bbox] 0 1]
set tile_width [get_attribute [get_cell -hier $master_tile] width]
set tile_height [get_attribute [get_cell -hier $master_tile] height]

#set end_tile "rof1_3__tile"
#set end_tile_llx [lindex [get_attribute [get_cell -hier $end_tile] boundary_bbox] 0 0]
#set end_tile_lly [lindex [get_attribute [get_cell -hier $end_tile] boundary_bbox] 0 1]
#set end_tile_width [get_attribute [get_cell -hier $end_tile] width]
#set end_tile_height [get_attribute [get_cell -hier $end_tile] height]

set tile_left $tile_llx
set tile_right [expr $tile_llx+$tile_width]
set tile_bottom $tile_lly
set tile_top [expr $tile_lly+$tile_height]

set channel_width 5
set channel_height 5

set keepout_margin_x 2
set keepout_margin_y 2
set keepout_margins [list $keepout_margin_x $keepout_margin_y $keepout_margin_x $keepout_margin_y]

## BSG chip bounds
#set io_margin 20
#set io_bound_name "io_bound"
#set io_bound_llx [expr $tile_llx]
#set io_bound_lly [expr $tile_top + $io_margin]
## Hack because there's not a full row
#set io_bound_urx [expr $core_width + 200]
##set io_bound_urx [expr $end_tile_llx + $end_tile_width]
#set io_bound_ury [expr $tile_top + 55*$channel_height - $io_margin]
#
#set io_cells [get_cells -hier -filter "full_name!~*tile*"]
#set io_bound [create_bound -type soft -name $io_bound_name -boundary [list [list $io_bound_llx $io_bound_lly] [list $io_bound_urx $io_bound_ury]]]
#add_to_bound $io_bound_name $io_cells

## BP Tile bounds
current_design bp_tile

set icache_data_mems [get_cells -design bp_tile -hier -filter "ref_name=~gf14_* && full_name=~*/icache/data_mems_*"]
set icache_data_ma [create_macro_array \
  -num_rows 4 \
  -num_cols 2 \
  -align bottom \
  -horizontal_channel_height [expr 2*$keepout_margin_y] \
  -vertical_channel_width [expr 2*$keepout_margin_x] \
  -orientation FN \
  $icache_data_mems]

create_keepout_margin -type hard -outer $keepout_margins $icache_data_mems

set_macro_relative_location \
  -target_object $icache_data_ma \
  -target_corner bl \
  -target_orientation R0 \
  -anchor_corner bl \
  -offset [list 0 0]

set icache_tag_mems [get_cells -design bp_tile -hier -filter "ref_name=~gf14_* && full_name=~*/icache/tag_mem*"]
set icache_tag_ma [create_macro_array \
  -num_rows 2 \
  -num_cols 1 \
  -align bottom \
  -horizontal_channel_height [expr 2*$keepout_margin_y] \
  -vertical_channel_width [expr 2*$keepout_margin_x] \
  -orientation FN \
  $icache_tag_mems]

create_keepout_margin -type hard -outer $keepout_margins $icache_tag_mems

set icache_tag_margin 5
set_macro_relative_location \
  -target_object $icache_tag_ma \
  -target_corner bl \
  -target_orientation R0 \
  -anchor_object $icache_data_ma \
  -anchor_corner br \
  -offset [list $icache_tag_margin 0]

set dcache_data_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*/dcache/data_mem_*"]
set dcache_data_ma [create_macro_array \
  -num_rows 4 \
  -num_cols 2 \
  -align bottom \
  -horizontal_channel_height [expr 2*$keepout_margin_y] \
  -vertical_channel_width [expr 2*$keepout_margin_x] \
  -orientation N \
  $dcache_data_mems]

create_keepout_margin -type hard -outer $keepout_margins $dcache_data_mems

set_macro_relative_location \
  -target_object $dcache_data_ma \
  -target_corner br \
  -target_orientation R0 \
  -anchor_corner br \
  -offset [list 0 0]

set dcache_tag_mems [get_cells -design bp_tile -hier -filter "ref_name=~gf14_* && full_name=~*/dcache/tag_mem*"]
set dcache_tag_ma [create_macro_array \
  -num_rows 2 \
  -num_cols 1 \
  -align bottom \
  -horizontal_channel_height [expr 2*$keepout_margin_y] \
  -vertical_channel_width [expr 2*$keepout_margin_x] \
  -orientation N \
  $dcache_tag_mems]

create_keepout_margin -type hard -outer $keepout_margins $dcache_tag_mems

set dcache_tag_margin 5
set_macro_relative_location \
  -target_object $dcache_tag_ma \
  -target_corner br \
  -target_orientation R0 \
  -anchor_object $dcache_data_ma \
  -anchor_corner bl \
  -offset [list -$dcache_tag_margin 0]

set directory_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*bp_cce/directory/directory/*"]
set directory_mem_height [get_attribute -objects [index_collection $directory_mems 0] -name height]
set directory_mem_width [get_attribute -objects [index_collection $directory_mems 0] -name width]
set directory_ma [create_macro_array \
  -num_rows 1 \
  -num_cols 4 \
  -align bottom \
  -horizontal_channel_height [expr 2*$keepout_margin_y] \
  -vertical_channel_width [expr 2*$keepout_margin_x] \
  -orientation [list N N FN FN] \
  $directory_mems]

# Should put this in the middle by relative location
set_macro_relative_location \
  -target_object $directory_ma \
  -target_corner tl \
  -target_orientation R0 \
  -anchor_corner tl \
  -offset [list [expr $tile_width/2 - 2*$directory_mem_width] 0]

create_keepout_margin -type hard -outer $keepout_margins $directory_mems

set cce_instr_ram [get_cells -design bp_tile -hier -filter "ref_name=~gf14_* && full_name=~*/bp_cce/*inst_ram*"]
set cce_instr_width [get_attribute -objects $cce_instr_ram -name width]
set cce_instr_height [get_attribute -objects $cce_instr_ram -name height]
set_macro_relative_location \
  -target_object $cce_instr_ram \
  -target_corner tl \
  -target_orientation MY \
  -anchor_object $directory_ma \
  -anchor_corner bl \
  -offset [list $keepout_margin_x [expr -$keepout_margin_y]]

create_keepout_margin -type hard -outer $keepout_margins $cce_instr_ram

set icache_stat_mem [get_cells -design bp_tile -hier -filter "ref_name=~gf14_* && full_name=~*/icache/stat_mem/*"]
set icache_stat_margin 5
set_macro_relative_location \
  -target_object $icache_stat_mem \
  -target_corner bl \
  -target_orientation MY \
  -anchor_object $icache_tag_ma \
  -anchor_corner br \
  -offset [list $icache_stat_margin $keepout_margin_y]

create_keepout_margin -type hard -outer $keepout_margins $icache_stat_mem

set btb_mem [get_cells -design bp_tile -hier -filter "ref_name=~gf14_* && full_name=~*/btb/*"]
set_macro_relative_location \
  -target_object $btb_mem \
  -target_corner br \
  -target_orientation R0 \
  -anchor_corner br \
  -offset [list [expr -$tile_width/2-$keepout_margin_x] $keepout_margin_y]

create_keepout_margin -type hard -outer $keepout_margins $btb_mem

set dcache_stat_mem [get_cells -design bp_tile -hier -filter "ref_name=~gf14_* && full_name=~*/dcache/stat_mem*"]
set dcache_stat_margin 5
set_macro_relative_location \
  -target_object $dcache_stat_mem \
  -target_corner br \
  -target_orientation R0 \
  -anchor_object $dcache_tag_ma \
  -anchor_corner bl \
  -offset [list -$dcache_stat_margin $keepout_margin_y]

create_keepout_margin -type hard -outer $keepout_margins $dcache_stat_mem

set int_regfile_mems [get_cells -design bp_tile -hier -filter "ref_name=~gf14_* && full_name=~*/int_regfile/*"]
set int_regfile_ma [create_macro_array \
  -num_rows 2 \
  -num_cols 1 \
  -align left \
  -horizontal_channel_height [expr 2*$keepout_margin_y] \
  -vertical_channel_width [expr 2*$keepout_margin_x] \
  -orientation FN \
  $int_regfile_mems]

set_macro_relative_location \
  -target_object $int_regfile_ma \
  -target_corner bl \
  -target_orientation R0 \
  -anchor_corner bl \
  -offset [list [expr $tile_width/2] 0]

create_keepout_margin -type hard -outer $keepout_margins $int_regfile_mems

current_design bsg_chip
