
remove_individual_pin_constraints
remove_block_pin_constraints

set layers {C4 C5 K1 K2 K3 K4}

set_block_pin_constraints -allowed_layers $layers

#### Chip ports
# Set all chip ports to top
set chip_sides {2}
set chip_ports [get_ports]
set_individual_pin_constraints -sides $chip_sides -ports $chip_ports -allowed_layers $layers

#### Tile pins
# Grab all of the pins in the tile
set master_tile "rof1_0__tile"
set tile_llx [lindex [get_attribute [get_cell -hier $master_tile] boundary_bbox] 0 0]
set tile_lly [lindex [get_attribute [get_cell -hier $master_tile] boundary_bbox] 0 1]
set tile_width [get_attribute [get_cell -hier $master_tile] width]
set tile_height [get_attribute [get_cell -hier $master_tile] height]

set tile_left $tile_llx
set tile_right [expr $tile_llx+$tile_width]
set tile_bottom $tile_lly
set tile_top [expr $tile_lly+$tile_height]

set tile_req_pins_o [get_pins -hier $master_tile/* -filter "name=~lce_req_link_o*"]
set tile_req_pin_len [expr [sizeof_collection $tile_req_pins_o] / 2]
set tile_req_pins_o_E [index_collection $tile_req_pins_o 0 [expr $tile_req_pin_len-1]]
set tile_req_pins_o_W [index_collection $tile_req_pins_o $tile_req_pin_len end]

set tile_req_pins_i [get_pins -hier $master_tile/* -filter "name=~lce_req_link_i*"]
set tile_req_pin_len [expr [sizeof_collection $tile_req_pins_i] / 2]
set tile_req_pins_i_E [index_collection $tile_req_pins_i 0 [expr $tile_req_pin_len-1]]
set tile_req_pins_i_W [index_collection $tile_req_pins_i $tile_req_pin_len end]

set tile_cmd_pins_o [get_pins -hier $master_tile/* -filter "name=~lce_cmd_link_o*"]
set tile_cmd_pin_len [expr [sizeof_collection $tile_cmd_pins_o] / 2]
set tile_cmd_pins_o_E [index_collection $tile_cmd_pins_o 0 [expr $tile_cmd_pin_len-1]]
set tile_cmd_pins_o_W [index_collection $tile_cmd_pins_o $tile_cmd_pin_len end]

set tile_cmd_pins_i [get_pins -hier $master_tile/* -filter "name=~lce_cmd_link_i*"]
set tile_cmd_pin_len [expr [sizeof_collection $tile_cmd_pins_i] / 2]
set tile_cmd_pins_i_E [index_collection $tile_cmd_pins_i 0 [expr $tile_cmd_pin_len-1]]
set tile_cmd_pins_i_W [index_collection $tile_cmd_pins_i $tile_cmd_pin_len end]

set tile_data_cmd_pins_o [get_pins -hier $master_tile/* -filter "name=~lce_data_cmd_link_o*"]
set tile_data_cmd_pin_len [expr [sizeof_collection $tile_data_cmd_pins_o] / 2]
set tile_data_cmd_pins_o_E [index_collection $tile_data_cmd_pins_o 0 [expr $tile_data_cmd_pin_len-1]]
set tile_data_cmd_pins_o_W [index_collection $tile_data_cmd_pins_o $tile_data_cmd_pin_len end]

set tile_data_cmd_pins_i [get_pins -hier $master_tile/* -filter "name=~lce_data_cmd_link_i*"]
set tile_data_cmd_pin_len [expr [sizeof_collection $tile_data_cmd_pins_i] / 2]
set tile_data_cmd_pins_i_E [index_collection $tile_data_cmd_pins_i 0 [expr $tile_data_cmd_pin_len-1]]
set tile_data_cmd_pins_i_W [index_collection $tile_data_cmd_pins_i $tile_data_cmd_pin_len end]

set tile_resp_pins_o [get_pins -hier $master_tile/* -filter "name=~lce_resp_link_o*"]
set tile_resp_pin_len [expr [sizeof_collection $tile_resp_pins_o] / 2]
set tile_resp_pins_o_E [index_collection $tile_resp_pins_o 0 [expr $tile_resp_pin_len-1]]
set tile_resp_pins_o_W [index_collection $tile_resp_pins_o $tile_resp_pin_len end]

set tile_resp_pins_i [get_pins -hier $master_tile/* -filter "name=~lce_resp_link_i*"]
set tile_resp_pin_len [expr [sizeof_collection $tile_resp_pins_i] / 2]
set tile_resp_pins_i_E [index_collection $tile_resp_pins_i 0 [expr $tile_resp_pin_len-1]]
set tile_resp_pins_i_W [index_collection $tile_resp_pins_i $tile_resp_pin_len end]

set tile_data_resp_pins_o [get_pins -hier $master_tile/* -filter "name=~lce_data_resp_link_o*"]
set tile_data_resp_pin_len [expr [sizeof_collection $tile_data_resp_pins_o] / 2]
set tile_data_resp_pins_o_E [index_collection $tile_data_resp_pins_o 0 [expr $tile_data_resp_pin_len-1]]
set tile_data_resp_pins_o_W [index_collection $tile_data_resp_pins_o $tile_data_resp_pin_len end]

set tile_data_resp_pins_i [get_pins -hier $master_tile/* -filter "name=~lce_data_resp_link_i*"]
set tile_data_resp_pin_len [expr [sizeof_collection $tile_data_resp_pins_i] / 2]
set tile_data_resp_pins_i_E [index_collection $tile_data_resp_pins_i 0 [expr $tile_data_resp_pin_len-1]]
set tile_data_resp_pins_i_W [index_collection $tile_data_resp_pins_i $tile_data_resp_pin_len end]

set clk_pins [get_pins -hier $master_tile/* -filter "name=~clk_i"]
set rst_pins [get_pins -hier $master_tile/* -filter "name=~reset_i"]
set mem_pins [get_pins -hier $master_tile/* -filter "name=~mem*"]
set mem_pin_len [sizeof_collection $mem_pins]
set proc_pins [get_pins -hier $master_tile/* -filter "name=~proc_cfg_i*"]
set cfg_pins [get_pins -hier $master_tile/* -filter "name=~cfg*"]
set cord_pins [get_pins -hier $master_tile/* -filter "name=~my*"]
set int_pins [get_pins -hier $master_tile/* -filter "name=~*int_i*"]

set misc_pins $clk_pins
append_to_collection misc_pins $rst_pins
append_to_collection misc_pins $proc_pins
append_to_collection misc_pins $cfg_pins
append_to_collection misc_pins $cord_pins
append_to_collection misc_pins $int_pins
set misc_pin_len [sizeof_collection $misc_pins]

# Lengths of various requests:
#   REQ       = 123
#   CMD       = 64
#   DATA_CMD  = 134
#   RESP      = 52
#   DATA_RESP = 143
#
#   Therefore, we combine REQ + RESP and CMD + DATA_CMD, so that we fit in the 3 hlayers

# Place pins
# NOTE: possibly it makes sense to swizzle based on signal integrity 
# C pins are 2 tracks (2*0.80) apart
# K pins are 1 track (1*0.128) apart
set layers {C4 C5 K1 K2 K3 K4}
set hlayers {C4 K1 K3}
set vlayers {C5 K2 K4}
set cspace .160
set kspace [expr .256]

# 0.04 = tile_height to track spacing
# 0.08*12 = 12 tracks of space
set start_y [expr $tile_height - 0.04 - 0.08*40]
set layer "C4"
for {set i 0} {$i < $tile_req_pin_len} {incr i} {
  set real_y [expr $tile_lly + $start_y]
  set_individual_pin_constraints -pins [index_collection $tile_req_pins_i_E $i] -allowed_layers "${layer}" -location "${tile_right} ${real_y}"
  set_individual_pin_constraints -pins [index_collection $tile_req_pins_o_W $i] -allowed_layers "${layer}" -location "${tile_left}  ${real_y}"
  set start_y [expr $start_y - 2*$cspace]

  set real_y [expr $tile_lly + $start_y]
  set_individual_pin_constraints -pins [index_collection $tile_req_pins_o_E $i] -allowed_layers "${layer}" -location "${tile_right} ${real_y}"
  set_individual_pin_constraints -pins [index_collection $tile_req_pins_i_W $i] -allowed_layers "${layer}" -location "${tile_left}  ${real_y}"
  set start_y [expr $start_y - 2*$cspace]
}
for {set i 0} {$i < $tile_resp_pin_len} {incr i} {
  set real_y [expr $tile_lly + $start_y]
  set_individual_pin_constraints -pins [index_collection $tile_resp_pins_i_E $i] -allowed_layers "${layer}" -location "${tile_right} ${real_y}"
  set_individual_pin_constraints -pins [index_collection $tile_resp_pins_o_W $i] -allowed_layers "${layer}" -location "${tile_left}  ${real_y}"
  set start_y [expr $start_y - 2*$cspace]

  set real_y [expr $tile_lly + $start_y]
  set_individual_pin_constraints -pins [index_collection $tile_resp_pins_o_E $i] -allowed_layers "${layer}" -location "${tile_right} ${real_y}"
  set_individual_pin_constraints -pins [index_collection $tile_resp_pins_i_W $i] -allowed_layers "${layer}" -location "${tile_left}  ${real_y}"
  set start_y [expr $start_y - 2*$cspace]
}

set start_y [expr $tile_height - 0.104 - 0.128*40]
set layer "K1"
for {set i 0} {$i < $tile_cmd_pin_len} {incr i} {
  set real_y [expr $tile_lly + $start_y]
  set_individual_pin_constraints -pins [index_collection $tile_cmd_pins_i_E $i] -allowed_layers "${layer}" -location "${tile_right} ${real_y}"
  set_individual_pin_constraints -pins [index_collection $tile_cmd_pins_o_W $i] -allowed_layers "${layer}" -location "${tile_left}  ${real_y}"
  set start_y [expr $start_y - 2*$kspace]

  set real_y [expr $tile_lly + $start_y]
  set_individual_pin_constraints -pins [index_collection $tile_cmd_pins_o_E $i] -allowed_layers "${layer}" -location "${tile_right} ${real_y}"
  set_individual_pin_constraints -pins [index_collection $tile_cmd_pins_i_W $i] -allowed_layers "${layer}" -location "${tile_left}  ${real_y}"
  set start_y [expr $start_y - 2*$kspace]
}
for {set i 0} {$i < $tile_data_cmd_pin_len} {incr i} {
  set real_y [expr $tile_lly + $start_y]
  set_individual_pin_constraints -pins [index_collection $tile_data_cmd_pins_i_E $i] -allowed_layers "${layer}" -location "${tile_right} ${real_y}"
  set_individual_pin_constraints -pins [index_collection $tile_data_cmd_pins_o_W $i] -allowed_layers "${layer}" -location "${tile_left}  ${real_y}"
  set start_y [expr $start_y - 2*$kspace]

  set real_y [expr $tile_lly + $start_y]
  set_individual_pin_constraints -pins [index_collection $tile_data_cmd_pins_o_E $i] -allowed_layers "${layer}" -location "${tile_right} ${real_y}"
  set_individual_pin_constraints -pins [index_collection $tile_data_cmd_pins_i_W $i] -allowed_layers "${layer}" -location "${tile_left}  ${real_y}"
  set start_y [expr $start_y - 2*$kspace]
}

set start_y [expr $tile_height - 0.104 - 0.128*40]
set layer "K3"
for {set i 0} {$i < $tile_data_resp_pin_len} {incr i} {
  set real_y [expr $tile_lly + $start_y]
  set_individual_pin_constraints -pins [index_collection $tile_data_resp_pins_i_E $i] -allowed_layers "${layer}" -location "${tile_right} ${real_y}"
  set_individual_pin_constraints -pins [index_collection $tile_data_resp_pins_o_W $i] -allowed_layers "${layer}" -location "${tile_left}  ${real_y}"
  set start_y [expr $start_y - 2*$kspace]

  set real_y [expr $tile_lly + $start_y]
  set_individual_pin_constraints -pins [index_collection $tile_data_resp_pins_o_E $i] -allowed_layers "${layer}" -location "${tile_right} ${real_y}"
  set_individual_pin_constraints -pins [index_collection $tile_data_resp_pins_i_W $i] -allowed_layers "${layer}" -location "${tile_left}  ${real_y}"
  set start_y [expr $start_y - 2*$kspace]
}

## Mem pin routing
set layer "K2"
set count 0
set start_x [expr 0.128*43]
for {set i 0} {$i < [expr $mem_pin_len/4] } {incr i} {
  set real_x [expr $tile_llx + $start_x]
  set_individual_pin_constraints -pins [index_collection $mem_pins $i] -allowed_layers "${layer}" -location "${real_x} ${tile_top}"
  set start_x [expr $start_x + 2*$kspace]

  incr count
  if {$count == 12} {
    set start_x [expr $start_x + 2.5*$kspace]
  }
  if {$count == 24} {
    set start_x [expr $start_x + 2*$kspace]
    set count 0
  }
}
set start_x [expr $tile_width - 0.128*43]
for {set i [expr $mem_pin_len/4]} {$i < [expr $mem_pin_len/2] } {incr i} {
  set real_x [expr $tile_llx + $start_x]
  set_individual_pin_constraints -pins [index_collection $mem_pins $i] -allowed_layers "${layer}" -location "${real_x} ${tile_top}"
  set start_x [expr $start_x - 2*$kspace]

  incr count
  if {$count == 12} {
    set start_x [expr $start_x - 2.5*$kspace]
  }
  if {$count == 24} {
    set start_x [expr $start_x - 2*$kspace]
    set count 0
  }
}

set layer "C5"
set count 0
set start_x [expr $tile_width - 0.80*20.5]
for {set i [expr $mem_pin_len/2]} {$i < [expr 3*$mem_pin_len/4] } {incr i} {
  set real_x [expr $tile_llx + $start_x]
  set_individual_pin_constraints -pins [index_collection $mem_pins $i] -allowed_layers "${layer}" -location "${real_x} ${tile_top}"
  set start_x [expr $start_x - 2*$cspace]

  incr count
  if {$count == 6} {
    set start_x [expr $start_x - 9*$cspace]
    set count 0
  }
}
for {set i 0} {$i < [expr $misc_pin_len/2+15]} {incr i} {
  set real_x [expr $tile_llx + $start_x]
  set_individual_pin_constraints -pins [index_collection $misc_pins $i] -allowed_layers "${layer}" -location "${real_x} ${tile_top}"
  set start_x [expr $start_x - 2*$cspace]

  incr count
  if {$count == 6} {
    set start_x [expr $start_x - 9*$cspace]
    set count 0
  }
}

set layer "C5"
set count 0
set start_x [expr 0.80*20]
for {set i [expr 3*$mem_pin_len/4]} {$i < $mem_pin_len } {incr i} {
  set real_x [expr $tile_llx + $start_x]
  set_individual_pin_constraints -pins [index_collection $mem_pins $i] -allowed_layers "${layer}" -location "${real_x} ${tile_top}"
  set start_x [expr $start_x + 2*$cspace]

  incr count
  if {$count == 6} {
    set start_x [expr $start_x + 9*$cspace]
    set count 0
  }
}
for {set i [expr $misc_pin_len/2-15]} {$i < $misc_pin_len} {incr i} {
  set real_x [expr $tile_llx + $start_x]
  set_individual_pin_constraints -pins [index_collection $misc_pins $i] -allowed_layers "${layer}" -location "${real_x} ${tile_top}"
  set start_x [expr $start_x + 2*$cspace]

  incr count
  if {$count == 6} {
    set start_x [expr $start_x + 9*$cspace]
    set count 0
  }
}

