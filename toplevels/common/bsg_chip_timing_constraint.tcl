#-------------------------------------------------------------------------------
# University of California, San Diego - Bespoke Systems Group
#-------------------------------------------------------------------------------
# File: bsg_chip_timing_constraint.tcl
#
# Authors: Michael Taylor
#          Chun Zhao
#          Luis Vega
#
# Usage example:
#
# source $::env(BSG_DESIGNS_DIR)/toplevels/common/bsg_chip_timing_constraint.tcl
#
# bsg_chip_timing_constraint -package ucsd_bsg_332 \
#                            -core_clk_port [get_ports p_misc_L_i[3]] \
#                            -core_clk_name core_clk \
#                            -core_clk_period 3.5 \
#                            -master_io_clk_port [get_ports p_PLL_CLK_i] \
#                            -master_io_clk_name master_io_clk \
#                            -master_io_clk_period 2.35
#
# Notes:
#
#  1. Global variables are defined using "variable" instead of "global" because
#     of http://wiki.tcl.tk/1177. For example, core_clk_period is a global
#     variable and it's defined as:
#
#       variable core_clk_period $bsg_core_clk_period
#
#  2. Current global variables, that can be accessed by other scripts, are:
#     * core_clk_name
#     * core_clk_period
#     * master_io_clk_name
#     * master_io_clk_period
#     * sdo_A_output_ports
#     * sdo_B_output_ports
#     * sdo_C_output_ports
#     * sdo_D_output_ports
#
#-------------------------------------------------------------------------------

proc bsg_chip_ucsd_bsg_332_timing_constraint {bsg_core_clk_port \
                                              bsg_core_clk_name \
                                              bsg_core_clk_period \
                                              bsg_master_io_clk_port \
                                              bsg_master_io_clk_name \
                                              bsg_master_io_clk_period} {

  puts "INFO\[BSG\]: begin bsg_chip_ucsd_bsg_332_timing_constraint function in script [info script]\n"

  # set core_clk_period and master_io_clk_period as global
  variable core_clk_period $bsg_core_clk_period
  variable master_io_clk_period $bsg_master_io_clk_period

  # aka io master frequency
  set out_io_clk_period $master_io_clk_period

  # because of DDR, the input clocks are half the frequency and the corresponding
  # logic runs at half the frequency but there is nothing to say that we would
  # not run the input clocks a bit faster. so for now at least, we will make sure
  # the logic times at the same clock period
  set in_io_clk_period $out_io_clk_period

  # tecnically the token clock period should be a fraction, like 1/8 of this
  # period. but resets or bugs could make these signals to glitch faster than
  # that.  so we keep it at IO_IN_CLK_PERIOD fixme: add assertion into verilog to
  # detect this glitching
  set in_token_clk_period [expr $in_io_clk_period]

  set max_in_io_skew_percent 2.5
  set max_in_io_skew_time [expr ($max_in_io_skew_percent * $in_io_clk_period) / 100.0]

  set max_out_io_skew_percent 2.5
  set max_out_io_skew_time [expr ($max_out_io_skew_percent * $out_io_clk_period) / 100.0]

  # say that reset gets 50% of the clock cycle to propagate inside the chip.
  set max_async_reset_percent 50
  set max_async_reset_delay [expr ((100-$max_async_reset_percent) * $core_clk_period) / 100.0]

  # clock uncertainty

  set clock_uncertainty_percent 0

  set core_clk_uncertainty      [expr ($clock_uncertainty_percent * $core_clk_period) / 100.0]
  set out_io_clk_uncertainty    [expr ($clock_uncertainty_percent * $out_io_clk_period) / 100.0]
  set in_io_clk_uncertainty     [expr ($clock_uncertainty_percent * $in_io_clk_period) / 100.0]
  set token_clk_uncertainty     [expr ($clock_uncertainty_percent * $in_token_clk_period) / 100.0]
  set master_io_clk_uncertainty [expr ($clock_uncertainty_percent * $master_io_clk_period) / 100.0]

  # Current design to Synopsys Design Constraints (SDC).
  set sdc_current_design [current_design]

  # input channel clock
  set sdi_A_sclk_port [get_ports p_sdi_sclk_i[0]]
  set sdi_B_sclk_port [get_ports p_sdi_sclk_i[1]]
  set sdi_C_sclk_port [get_ports p_sdi_sclk_i[2]]
  set sdi_D_sclk_port [get_ports p_sdi_sclk_i[3]]

  # output channel clock
  set sdo_A_sclk_port [get_ports p_sdo_sclk_o[0]]
  set sdo_B_sclk_port [get_ports p_sdo_sclk_o[1]]
  set sdo_C_sclk_port [get_ports p_sdo_sclk_o[2]]
  set sdo_D_sclk_port [get_ports p_sdo_sclk_o[3]]

  # input token
  set sdo_A_token_clk_port [get_ports p_sdo_token_i[0]]
  set sdo_B_token_clk_port [get_ports p_sdo_token_i[1]]
  set sdo_C_token_clk_port [get_ports p_sdo_token_i[2]]
  set sdo_D_token_clk_port [get_ports p_sdo_token_i[3]]

  # print parameters
  puts "\nConstrain design [get_attribute $sdc_current_design full_name] timing with the following settings:\n"
  puts "Parameter                             Value"
  puts "-----------------------               -------------------"
  puts "Core main clock period                $core_clk_period ns"
  puts "Out IO clock period                   $out_io_clk_period ns"
  puts "In IO clock period                    $in_io_clk_period ns"
  puts "Max allowed on-chip in  IO skew (%)   $max_in_io_skew_percent %"
  puts "Max allowed on-chip in  IO skew       $max_in_io_skew_time ns"
  puts "Max allowed on-chip out IO skew (%)   $max_out_io_skew_percent %"
  puts "Max allowed on-chip out IO skew       $max_out_io_skew_time ns"
  puts "Core main clock uncertainty           $core_clk_uncertainty ns"
  puts "Out IO clock uncertainty              $out_io_clk_uncertainty ns"
  puts "In  IO clock uncertainty              $in_io_clk_uncertainty ns"
  puts "-----------------------               -------------------\n"

  # according to design compiler, we need this option to support the -add flag of create_clock
  set_app_var timing_enable_multiple_clocks_per_reg true

  # creates a clock object and defines its waveform in the current design.
  # create_clock -period $CLK_PERIOD -name $CLK_NAME $CLK_PORT

  variable $bsg_core_clk_name

  create_clock -period $core_clk_period \
               -name $bsg_core_clk_name \
               $bsg_core_clk_port

  variable $bsg_master_io_clk_name

  create_clock -period $master_io_clk_period \
               -name $bsg_master_io_clk_name \
               $bsg_master_io_clk_port

  create_clock -period $in_io_clk_period -name sdi_A_sclk $sdi_A_sclk_port
  create_clock -period $in_io_clk_period -name sdi_B_sclk $sdi_B_sclk_port
  create_clock -period $in_io_clk_period -name sdi_C_sclk $sdi_C_sclk_port
  create_clock -period $in_io_clk_period -name sdi_D_sclk $sdi_D_sclk_port

  # tokens should be treated as clocks
  create_clock -period $in_token_clk_period -name sdo_A_token_clk $sdo_A_token_clk_port
  create_clock -period $in_token_clk_period -name sdo_B_token_clk $sdo_B_token_clk_port
  create_clock -period $in_token_clk_period -name sdo_C_token_clk $sdo_C_token_clk_port
  create_clock -period $in_token_clk_period -name sdo_D_token_clk $sdo_D_token_clk_port

  # we declare these clocks as being asynchronous
  # note this disables all timing checks between groups
  # so you really need to be sure this is what you want!
  set_clock_groups -asynchronous  \
    -group $bsg_core_clk_name \
    -group $bsg_master_io_clk_name \
    -group {sdi_A_sclk} \
    -group {sdi_B_sclk} \
    -group {sdi_C_sclk} \
    -group {sdi_D_sclk} \
    -group {sdo_A_token_clk} \
    -group {sdo_B_token_clk} \
    -group {sdo_C_token_clk} \
    -group {sdo_D_token_clk}

  #----------------------------------------------------------------------------
  # CDC checks
  #
  # we follow the advice www.zimmerdesignservices.com/no_mans_land_20130328.pdf
  #
  # oddly, for this to work, we need to clone all of the clocks involved.
  #
  # we tried instead of doing this, just adding a max_delay path between paths
  # but it causes a lot of warnings to be issued. this approach nicely groups
  # these paths together.
  #
  # we set the cdc delay to be the minimimum of the clock periods involved, to
  # be conservative. Alternatively, we could try to hunt down all of the paths
  # and explicitly label all of them but that adds a greater risk of error.
  # none of these paths should be particularly critical.
  #
  # we care about:
  #   1. the sending clock domain for gray code bit skew and
  #   2. the receiving clock domain for delay through 2-port rams.
  #
  # we care less about:
  #   1. path from reset signal in master_io_clk domain wired to token_reset
  #      going into token ctr, since this signal is supposed to be asserted
  #      for many cycles before and after the strobe of the token clock.
  #      nonetheless, we restrict the timing of this path.
  #----------------------------------------------------------------------------

  set cdc_delay [lindex [lsort -real [list $core_clk_period \
                                           $in_token_clk_period \
                                           $in_io_clk_period \
                                           $master_io_clk_period]] 0]

  puts "INFO\[BSG\]: Constraining clock crossing paths to $cdc_delay (ns)."

  create_clock -name core_clk_cdc \
               -period [get_attribute [get_clocks $bsg_core_clk_name] period] \
               -add $bsg_core_clk_port

  create_clock -name master_io_clk_cdc \
               -period [get_attribute [get_clocks $bsg_master_io_clk_name] period] \
               -add $bsg_master_io_clk_port

  create_clock -name sdi_A_sclk_cdc \
               -period [get_attribute [get_clocks sdi_A_sclk] period] \
               -add $sdi_A_sclk_port

  create_clock -name sdi_B_sclk_cdc \
               -period [get_attribute [get_clocks sdi_B_sclk] period] \
               -add $sdi_B_sclk_port

  create_clock -name sdi_C_sclk_cdc \
               -period [get_attribute [get_clocks sdi_C_sclk] period] \
               -add $sdi_C_sclk_port

  create_clock -name sdi_D_sclk_cdc \
               -period [get_attribute [get_clocks sdi_D_sclk] period] \
               -add $sdi_D_sclk_port

  create_clock -name sdo_A_token_clk_cdc \
               -period [get_attribute [get_clocks sdo_A_token_clk] period] \
               -add $sdo_A_token_clk_port

  create_clock -name sdo_B_token_clk_cdc \
               -period [get_attribute [get_clocks sdo_B_token_clk] period] \
               -add $sdo_B_token_clk_port

  create_clock -name sdo_C_token_clk_cdc \
               -period [get_attribute [get_clocks sdo_C_token_clk] period] \
               -add $sdo_C_token_clk_port

  create_clock -name sdo_D_token_clk_cdc \
               -period [get_attribute [get_clocks sdo_D_token_clk] period] \
               -add $sdo_D_token_clk_port

  # these are redundant, I guess
  remove_propagated_clock [get_clocks *_cdc]

  # remove all internal paths from concern; these should already be timed
  foreach_in_collection cdc_clk [get_clocks *_cdc] {
    set_false_path -from [get_clock $cdc_clk] -to [get_clock $cdc_clk]
  }

  # make cdc clocks physically exclusive from all others
  set_clock_groups -physically_exclusive \
                   -group [remove_from_collection [get_clocks *] [get_clocks *_cdc]] \
                   -group [get_clocks *_cdc]

  # impose a delay of one cycle delay for paths from sdi clocks to core
  foreach_in_collection cdc_clk [get_clocks *_cdc] {

    set_max_delay $cdc_delay -from $cdc_clk \
                             -to [remove_from_collection [get_clocks *_cdc] $cdc_clk]

    set_min_delay 0 -from $cdc_clk [remove_from_collection [get_clocks *_cdc] $cdc_clk]

  }

  # clock uncertainty

  set_clock_uncertainty $core_clk_uncertainty [get_clocks $bsg_core_clk_name]
  set_clock_uncertainty $master_io_clk_uncertainty [get_clocks $bsg_master_io_clk_name]

  set_clock_uncertainty $in_io_clk_uncertainty [get_clocks sdi_A_sclk]
  set_clock_uncertainty $in_io_clk_uncertainty [get_clocks sdi_B_sclk]
  set_clock_uncertainty $in_io_clk_uncertainty [get_clocks sdi_C_sclk]
  set_clock_uncertainty $in_io_clk_uncertainty [get_clocks sdi_D_sclk]

  set_clock_uncertainty $token_clk_uncertainty [get_clocks sdo_A_token_clk]
  set_clock_uncertainty $token_clk_uncertainty [get_clocks sdo_B_token_clk]
  set_clock_uncertainty $token_clk_uncertainty [get_clocks sdo_C_token_clk]
  set_clock_uncertainty $token_clk_uncertainty [get_clocks sdo_D_token_clk]

  puts "INFO\[BSG\]: Library setup information:"
  list_libs

  # get channel ports

  set sdi_A_input_ports [add_to_collection [get_ports "p_sdi_A_data_i*"] [get_ports "p_sdi_ncmd_i*[0]"]]
  set sdi_B_input_ports [add_to_collection [get_ports "p_sdi_B_data_i*"] [get_ports "p_sdi_ncmd_i*[1]"]]
  set sdi_C_input_ports [add_to_collection [get_ports "p_sdi_C_data_i*"] [get_ports "p_sdi_ncmd_i*[2]"]]
  set sdi_D_input_ports [add_to_collection [get_ports "p_sdi_D_data_i*"] [get_ports "p_sdi_ncmd_i*[3]"]]

  # declare outputs globally
  variable sdo_A_output_ports [add_to_collection [get_ports "p_sdo_A_data_o*"] [get_ports "p_sdo_ncmd_o[0]"]]
  variable sdo_B_output_ports [add_to_collection [get_ports "p_sdo_B_data_o*"] [get_ports "p_sdo_ncmd_o[1]"]]
  variable sdo_C_output_ports [add_to_collection [get_ports "p_sdo_C_data_o*"] [get_ports "p_sdo_ncmd_o[2]"]]
  variable sdo_D_output_ports [add_to_collection [get_ports "p_sdo_D_data_o*"] [get_ports "p_sdo_ncmd_o[3]"]]

  # bound the delay on the reset signal to something reasonable
  set_input_delay -clock $bsg_core_clk_name $max_async_reset_delay [get_ports p_reset_i]

  # TODO: token ports need special constraints.

  # sets input delay on pins or input ports relative to a clock signal.
  # note, since our inputs are ddr, we have to define min and max
  # for both edges of the clock.
  #
  # See p. 14 of this document:
  # http://www.zimmerdesignservices.com/working-with-ddrs-in-primetime.pdf

  set_input_delay -clock sdi_A_sclk -min $max_in_io_skew_time $sdi_A_input_ports
  set_input_delay -clock sdi_B_sclk -min $max_in_io_skew_time $sdi_B_input_ports
  set_input_delay -clock sdi_C_sclk -min $max_in_io_skew_time $sdi_C_input_ports
  set_input_delay -clock sdi_D_sclk -min $max_in_io_skew_time $sdi_D_input_ports

  set_input_delay -add_delay \
                  -clock_fall \
                  -clock sdi_A_sclk \
                  -min $max_in_io_skew_time $sdi_A_input_ports

  set_input_delay -add_delay \
                  -clock_fall \
                  -clock sdi_B_sclk \
                  -min $max_in_io_skew_time $sdi_B_input_ports

  set_input_delay -add_delay \
                  -clock_fall \
                  -clock sdi_C_sclk \
                  -min $max_in_io_skew_time $sdi_C_input_ports

  set_input_delay -add_delay \
                  -clock_fall \
                  -clock sdi_D_sclk \
                  -min $max_in_io_skew_time $sdi_D_input_ports

  set_input_delay -add_delay \
                  -clock sdi_A_sclk \
                  -max [expr ($in_io_clk_period / 2) - $max_in_io_skew_time] $sdi_A_input_ports

  set_input_delay -add_delay \
                  -clock sdi_B_sclk \
                  -max [expr ($in_io_clk_period / 2) - $max_in_io_skew_time] $sdi_B_input_ports

  set_input_delay -add_delay \
                  -clock sdi_C_sclk \
                  -max [expr ($in_io_clk_period / 2) - $max_in_io_skew_time] $sdi_C_input_ports

  set_input_delay -add_delay \
                  -clock sdi_D_sclk \
                  -max [expr ($in_io_clk_period / 2) - $max_in_io_skew_time] $sdi_D_input_ports

  set_input_delay -add_delay \
                  -clock_fall \
                  -clock sdi_A_sclk \
                  -max [expr ($in_io_clk_period / 2) - $max_in_io_skew_time] $sdi_A_input_ports

  set_input_delay -add_delay \
                  -clock_fall \
                  -clock sdi_B_sclk \
                  -max [expr ($in_io_clk_period / 2) - $max_in_io_skew_time] $sdi_B_input_ports

  set_input_delay -add_delay \
                  -clock_fall \
                  -clock sdi_C_sclk \
                  -max [expr ($in_io_clk_period / 2) - $max_in_io_skew_time] $sdi_C_input_ports

  set_input_delay -add_delay \
                  -clock_fall \
                  -clock sdi_D_sclk \
                  -max [expr ($in_io_clk_period / 2) - $max_in_io_skew_time] $sdi_D_input_ports

  report_clocks [get_clocks *]

  # set_multicycle_path is used according to the following synopsys document
  # called "Overcoming the Default Behavior of the set_data_check Command"
  # the document ID is 024664

  foreach_in_collection obj $sdo_A_output_ports {

    set_data_check -from [get_ports "p_sdo_sclk_o[0]"] \
                   -to $obj \
                   -setup [expr (($out_io_clk_period/2) - $max_out_io_skew_time)]

    set_data_check -from [get_ports "p_sdo_sclk_o[0]"] \
                   -to $obj \
                   -hold [expr (($out_io_clk_period/2) - $max_out_io_skew_time)]

    set_multicycle_path -start 2 -to $obj

  }

  foreach_in_collection obj $sdo_B_output_ports {

    set_data_check -from [get_ports "p_sdo_sclk_o[1]"] \
                   -to $obj \
                   -setup [expr (($out_io_clk_period/2) - $max_out_io_skew_time)]

    set_data_check -from [get_ports "p_sdo_sclk_o[1]"] \
                   -to $obj \
                   -hold  [expr (($out_io_clk_period/2) - $max_out_io_skew_time)]

    set_multicycle_path -start 2 -to $obj

  }

  foreach_in_collection obj $sdo_C_output_ports {

    set_data_check -from [get_ports "p_sdo_sclk_o[2]"] \
                   -to $obj \
                   -setup [expr (($out_io_clk_period/2) - $max_out_io_skew_time)]

    set_data_check -from [get_ports "p_sdo_sclk_o[2]"] \
                   -to $obj \
                   -hold  [expr (($out_io_clk_period/2) - $max_out_io_skew_time)]

    set_multicycle_path -start 2 -to $obj

  }

  foreach_in_collection obj $sdo_D_output_ports {

    set_data_check -from [get_ports "p_sdo_sclk_o[3]"] \
                   -to $obj \
                   -setup [expr (($out_io_clk_period/2) - $max_out_io_skew_time)]

    set_data_check -from [get_ports "p_sdo_sclk_o[3]"] \
                   -to $obj \
                   -hold  [expr (($out_io_clk_period/2) - $max_out_io_skew_time)]

    set_multicycle_path -start 2 -to $obj

  }

  # create path groups
  #
  # separating these paths can help improve optimization in each group independently.
  #
  # during compile each timing path is placed into a path group associated with
  # that path's "capturing" clock. DC then optimizes each path group in turn,
  # starting with the critical path in each group.
  #
  # Reg_to_reg path groups are automatically created, named the same as their
  # related (end-point) clock object names, by default.

  set ports_clock_root [filter_collection [get_attribute [get_clocks] sources] object_class==port]

  group_path -name input_to_reg \
             -from [remove_from_collection [all_inputs] ${ports_clock_root}]

  group_path -name reg_to_output -to [all_outputs]

  group_path -name feedthrough \
             -from [remove_from_collection [all_inputs] ${ports_clock_root}] \
             -to [all_outputs]

  # it is much easier for the physical design tool to fix a small number of
  # violations through savvy placement, compared to having to handle a large
  # number of violations.

  # prioritizing path groups
  # the overall cost function is sigmasum(negative_slack * weight) of all
  # path groups.

  puts "INFO\[BSG\]: end bsg_chip_ucsd_bsg_332_timing_constraint function in script [info script]\n"

}

proc bsg_chip_timing_constraint {args} {

  parse_proc_arguments -args $args pargs

  set bsg_package $pargs(-package)
  set bsg_core_clk_port $pargs(-core_clk_port)
  set bsg_core_clk_name $pargs(-core_clk_name)
  set bsg_core_clk_period $pargs(-core_clk_period)
  set bsg_master_io_clk_port $pargs(-master_io_clk_port)
  set bsg_master_io_clk_name $pargs(-master_io_clk_name)
  set bsg_master_io_clk_period $pargs(-master_io_clk_period)

  if {$bsg_package != "ucsd_bsg_332" || $bsg_core_clk_period <= 0 || $bsg_master_io_clk_period <=0} {
    puts "ERROR\[BSG\]: Either you have the wrong package or one clock period is less or equal to zero"
    return
  } else {
    bsg_chip_ucsd_bsg_332_timing_constraint $bsg_core_clk_port \
                                            $bsg_core_clk_name \
                                            $bsg_core_clk_period \
                                            $bsg_master_io_clk_port \
                                            $bsg_master_io_clk_name \
                                            $bsg_master_io_clk_period
  }

}

define_proc_attributes bsg_chip_timing_constraint \
  -info "bsg_chip timing constraint" \
  -define_args {
  {-package  "bsg package used, i.e. ucsd_bsg_332" package string required}
  {-core_clk_port "core clock port, i.e \[get_ports p_misc_L_i\[3\]\]" core_clk_port string required}
  {-core_clk_name "core clock name, i.e core_clk" core_clk_name string required}
  {-core_clk_period "core clock period in tech-time-unit, i.e 3.5" core_clk_period float required}
  {-master_io_clk_port "master io clock port, i.e. \[get_ports p_PLL_CLK_i\]" master_io_clk_port string required}
  {-master_io_clk_name "master io clock name, i.e. master_io_clk" master_io_clk_name string required}
  {-master_io_clk_period "master io clock period in tech-time-unit, i.e. 2.35" master_io_clk_period float required}
}
