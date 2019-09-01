
remove_individual_pin_constraints
remove_block_pin_constraints

### Just make sure that other layers are not used.

set_block_pin_constraints -allowed_layers { C4 C5 K1 K2 K3 K4 }

# Master instance of the BP tile mibs
set master_tile "rof1_0__tile"

# Useful numbers for the master tile
set tile_llx    [lindex [get_attribute [get_cell -hier $master_tile] boundary_bbox] 0 0]
set tile_lly    [lindex [get_attribute [get_cell -hier $master_tile] boundary_bbox] 0 1]
set tile_width  [get_attribute [get_cell -hier $master_tile] width]
set tile_height [get_attribute [get_cell -hier $master_tile] height]
set tile_left   $tile_llx
set tile_right  [expr $tile_llx+$tile_width]
set tile_bottom $tile_lly
set tile_top    [expr $tile_lly+$tile_height]

### East/West Pins

set tile_req_pins_o       [get_pins -hier $master_tile/* -filter "name=~lce_req_link_o*"]
set tile_req_pins_i       [get_pins -hier $master_tile/* -filter "name=~lce_req_link_i*"]
set tile_cmd_pins_o       [get_pins -hier $master_tile/* -filter "name=~lce_cmd_link_o*"]
set tile_cmd_pins_i       [get_pins -hier $master_tile/* -filter "name=~lce_cmd_link_i*"]
set tile_data_cmd_pins_o  [get_pins -hier $master_tile/* -filter "name=~lce_data_cmd_link_o*"]
set tile_data_cmd_pins_i  [get_pins -hier $master_tile/* -filter "name=~lce_data_cmd_link_i*"]
set tile_resp_pins_o      [get_pins -hier $master_tile/* -filter "name=~lce_resp_link_o*"]
set tile_resp_pins_i      [get_pins -hier $master_tile/* -filter "name=~lce_resp_link_i*"]
set tile_data_resp_pins_o [get_pins -hier $master_tile/* -filter "name=~lce_data_resp_link_o*"]
set tile_data_resp_pins_i [get_pins -hier $master_tile/* -filter "name=~lce_data_resp_link_i*"]

set tile_req_pin_len       [expr [sizeof_collection $tile_req_pins_o] / 2]
set tile_req_pin_len       [expr [sizeof_collection $tile_req_pins_i] / 2]
set tile_cmd_pin_len       [expr [sizeof_collection $tile_cmd_pins_o] / 2]
set tile_cmd_pin_len       [expr [sizeof_collection $tile_cmd_pins_i] / 2]
set tile_data_cmd_pin_len  [expr [sizeof_collection $tile_data_cmd_pins_o] / 2]
set tile_data_cmd_pin_len  [expr [sizeof_collection $tile_data_cmd_pins_i] / 2]
set tile_resp_pin_len      [expr [sizeof_collection $tile_resp_pins_o] / 2]
set tile_resp_pin_len      [expr [sizeof_collection $tile_resp_pins_i] / 2]
set tile_data_resp_pin_len [expr [sizeof_collection $tile_data_resp_pins_o] / 2]
set tile_data_resp_pin_len [expr [sizeof_collection $tile_data_resp_pins_i] / 2]

set tile_req_pins_o_E       [index_collection $tile_req_pins_o       0 [expr $tile_req_pin_len-1]]
set tile_req_pins_i_E       [index_collection $tile_req_pins_i       0 [expr $tile_req_pin_len-1]]
set tile_cmd_pins_o_E       [index_collection $tile_cmd_pins_o       0 [expr $tile_cmd_pin_len-1]]
set tile_cmd_pins_i_E       [index_collection $tile_cmd_pins_i       0 [expr $tile_cmd_pin_len-1]]
set tile_data_cmd_pins_o_E  [index_collection $tile_data_cmd_pins_o  0 [expr $tile_data_cmd_pin_len-1]]
set tile_data_cmd_pins_i_E  [index_collection $tile_data_cmd_pins_i  0 [expr $tile_data_cmd_pin_len-1]]
set tile_resp_pins_o_E      [index_collection $tile_resp_pins_o      0 [expr $tile_resp_pin_len-1]]
set tile_resp_pins_i_E      [index_collection $tile_resp_pins_i      0 [expr $tile_resp_pin_len-1]]
set tile_data_resp_pins_o_E [index_collection $tile_data_resp_pins_o 0 [expr $tile_data_resp_pin_len-1]]
set tile_data_resp_pins_i_E [index_collection $tile_data_resp_pins_i 0 [expr $tile_data_resp_pin_len-1]]

set tile_req_pins_o_W       [index_collection $tile_req_pins_o       $tile_req_pin_len       end]
set tile_req_pins_i_W       [index_collection $tile_req_pins_i       $tile_req_pin_len       end]
set tile_cmd_pins_o_W       [index_collection $tile_cmd_pins_o       $tile_cmd_pin_len       end]
set tile_cmd_pins_i_W       [index_collection $tile_cmd_pins_i       $tile_cmd_pin_len       end]
set tile_data_cmd_pins_o_W  [index_collection $tile_data_cmd_pins_o  $tile_data_cmd_pin_len  end]
set tile_data_cmd_pins_i_W  [index_collection $tile_data_cmd_pins_i  $tile_data_cmd_pin_len  end]
set tile_resp_pins_o_W      [index_collection $tile_resp_pins_o      $tile_resp_pin_len      end]
set tile_resp_pins_i_W      [index_collection $tile_resp_pins_i      $tile_resp_pin_len      end]
set tile_data_resp_pins_o_W [index_collection $tile_data_resp_pins_o $tile_data_resp_pin_len end]
set tile_data_resp_pins_i_W [index_collection $tile_data_resp_pins_i $tile_data_resp_pin_len end]

# 0.04 = tile_height to track spacing
# 0.08*12 = 12 tracks of space
set start_y [expr 0.04 + 0.08*40]
set last_loc [bsg_pins_line_constraint $tile_req_pins_i_E  "C4" right $start_y               $master_tile $tile_req_pins_o_W  1 0]
set last_loc [bsg_pins_line_constraint $tile_req_pins_o_E  "C4" right [expr $last_loc+0.160] $master_tile $tile_req_pins_i_W  1 0]
set last_loc [bsg_pins_line_constraint $tile_resp_pins_i_E "C4" right [expr $last_loc+0.160] $master_tile $tile_resp_pins_o_W 1 0]
set last_loc [bsg_pins_line_constraint $tile_resp_pins_o_E "C4" right [expr $last_loc+0.160] $master_tile $tile_resp_pins_i_W 1 0]

set start_y [expr 0.104 + 0.128*40]
set last_loc [bsg_pins_line_constraint $tile_cmd_pins_i_E      "K1" right $start_y               $master_tile $tile_cmd_pins_o_W      1 0]
set last_loc [bsg_pins_line_constraint $tile_cmd_pins_o_E      "K1" right [expr $last_loc+0.256] $master_tile $tile_cmd_pins_i_W      1 0]
set last_loc [bsg_pins_line_constraint $tile_data_cmd_pins_i_E "K1" right [expr $last_loc+0.256] $master_tile $tile_data_cmd_pins_o_W 1 0]
set last_loc [bsg_pins_line_constraint $tile_data_cmd_pins_o_E "K1" right [expr $last_loc+0.256] $master_tile $tile_data_cmd_pins_i_W 1 0]

set start_y [expr 0.104 + 0.128*40]
set last_loc [bsg_pins_line_constraint $tile_data_resp_pins_i_E "K3" right $start_y               $master_tile $tile_data_resp_pins_o_W 1 0]
set last_loc [bsg_pins_line_constraint $tile_data_resp_pins_o_E "K3" right [expr $last_loc+0.256] $master_tile $tile_data_resp_pins_i_W 1 0]

### North Pins

set                  cmd_i_resp_o_pins [get_pins -hier $master_tile/* -filter "name=~cmd_link_i*"]
append_to_collection cmd_i_resp_o_pins [get_pins -hier $master_tile/* -filter "name=~resp_link_o*"]

set start_x [expr 0.160 * 740]
set last_loc [bsg_pins_line_constraint $cmd_i_resp_o_pins "C5" top $start_x $master_tile {} 2 0]

set                  cmd_o_resp_i_pins [get_pins -hier $master_tile/* -filter "name=~cmd_link_o*"]
append_to_collection cmd_o_resp_i_pins [get_pins -hier $master_tile/* -filter "name=~resp_link_i*"]

set start_x [expr 0.160 * 2990]
set last_loc [bsg_pins_line_constraint $cmd_o_resp_i_pins "C5" top $start_x $master_tile {} 2 0]

################################################################################
###
### MISC Pins. Slow signals in the center on the top
###

set                  misc_pins [get_pins -hier $master_tile/* -filter "name=~clk_i"]
append_to_collection misc_pins [get_pins -hier $master_tile/* -filter "name=~reset_i"]
append_to_collection misc_pins [get_pins -hier $master_tile/* -filter "name=~proc_cfg_i*"]
append_to_collection misc_pins [get_pins -hier $master_tile/* -filter "name=~cfg*"]
append_to_collection misc_pins [get_pins -hier $master_tile/* -filter "name=~my*"]
append_to_collection misc_pins [get_pins -hier $master_tile/* -filter "name=~*cord*"]
append_to_collection misc_pins [get_pins -hier $master_tile/* -filter "name=~*int_i*"]

set start_x [expr 0.160 * 1790]
set last_loc [bsg_pins_line_constraint $misc_pins "C5" top $start_x $master_tile {} 2 0]

