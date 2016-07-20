# FIXME: still work in progress

puts "Info: Running script [info script]\n"

# Time unit in TSMC CL025G process is nanosecond.
#

set core_clk_period      3.5
set master_io_clk_period 2.35
# aka io master frequency
set out_io_clk_period    [expr $master_io_clk_period]

# because of DDR, the input clocks are half the frequency and the corresponding 
# logic runs at half the frequency but there is nothing to say that we would
# not run the input clocks a bit faster. so for now at least, we will make sure
# the logic times at the same clock period

set in_io_clk_period [expr $out_io_clk_period ]

# tecnically the token clock period should be a fraction, like 1/8 of this
# period. but resets or bugs could make these signals to glitch faster than
# that.  so we keep it at IO_IN_CLK_PERIOD fixme: add assertion into verilog to
# detect this glitching
#
set in_token_clk_period [expr $in_io_clk_period]

set max_in_io_skew_percent 2.5
set max_in_io_skew_time    [expr ($max_in_io_skew_percent * $in_io_clk_period) / 100.0]
set max_out_io_skew_percent 2.5
set max_out_io_skew_time   [expr ($max_out_io_skew_percent * $out_io_clk_period) / 100.0]

# say that reset gets 50% of the clock cycle to propagate inside the chip.
set max_async_reset_percent 50
set max_async_reset_delay   [expr ((100-$max_async_reset_percent) * $core_clk_period) / 100.0]

set core_clk_uncertainty    0.0
set out_io_clk_uncertainty  0.0
set in_io_clk_uncertainty   0.0
set token_clk_uncertainty   0.0
set master_io_clk_uncertainty 0.0

# Current design to Synopsys Design Constraints (SDC).
set sdc_current_design [current_design]

# Set clock to IO pad input
set core_clk_port      [get_ports p_misc_L_i[3]]
set master_io_clk_port [get_ports p_PLL_CLK_i]

set sdi_A_sclk_port    [get_ports p_sdi_sclk_i[0]]
set sdi_B_sclk_port    [get_ports p_sdi_sclk_i[1]]
set sdi_C_sclk_port    [get_ports p_sdi_sclk_i[2]]
set sdi_D_sclk_port    [get_ports p_sdi_sclk_i[3]]

set sdo_A_sclk_port [get_ports p_sdo_sclk_o[0]]
set sdo_B_sclk_port [get_ports p_sdo_sclk_o[1]]
set sdo_C_sclk_port [get_ports p_sdo_sclk_o[2]]
set sdo_D_sclk_port [get_ports p_sdo_sclk_o[3]]

set sdo_A_token_clk_port [get_ports p_sdo_token_i[0]]
set sdo_B_token_clk_port [get_ports p_sdo_token_i[1]]
set sdo_C_token_clk_port [get_ports p_sdo_token_i[2]]
set sdo_D_token_clk_port [get_ports p_sdo_token_i[3]]


echo "\nConstrain design [get_attribute $sdc_current_design full_name] timing with the following settings:\n"
echo "Parameter                             Value"
echo "-----------------------               -------------------"
echo "Core main clock period                $core_clk_period ns"
echo "Out IO clock period                   $out_io_clk_period ns"
echo "In IO clock period                    $in_io_clk_period ns"
echo "Max allowed on-chip in  IO skew (%)   $max_in_io_skew_percent %"
echo "Max allowed on-chip in  IO skew       $max_in_io_skew_time ns"
echo "Max allowed on-chip out IO skew (%)   $max_out_io_skew_percent %"
echo "Max allowed on-chip out IO skew       $max_out_io_skew_time ns"
echo "Core main clock uncertainty           $core_clk_uncertainty ns"
echo "Out IO clock uncertainty              $out_io_clk_uncertainty ns"
echo "In  IO clock uncertainty              $in_io_clk_uncertainty ns"
echo "-----------------------               -------------------\n"


# Set clock to IO pad output, for example:
# if {[sizeof_collection [get_pins clk_1_p_i/C]] != 0} {
#   set core_clk_port [get_pins clk_1_p_i/C]
#   echo "BSG-Info: SDC assuming clock port: 'clk_1_p_i/C' of [get_attribute [current_design] full_name]"
# } else {
#   echo "BSG-Error: SDC does NOT find a clock port of [get_attribute [current_design] full_name]"
# }

# according to design compiler, we need this option to support the -add flag of create_clock
set_app_var timing_enable_multiple_clocks_per_reg true


# Creates a clock object and defines its waveform in the current design.
# create_clock -period $CLK_PERIOD -name $CLK_NAME $core_clk_port
#
create_clock -period $core_clk_period   -name core_clk   $core_clk_port

create_clock -period $in_io_clk_period  -name sdi_A_sclk $sdi_A_sclk_port
create_clock -period $in_io_clk_period  -name sdi_B_sclk $sdi_B_sclk_port
create_clock -period $in_io_clk_period  -name sdi_C_sclk $sdi_C_sclk_port
create_clock -period $in_io_clk_period  -name sdi_D_sclk $sdi_D_sclk_port

# these should be treated as clocks
create_clock -period $in_token_clk_period  -name sdo_A_token_clk $sdo_A_token_clk_port
create_clock -period $in_token_clk_period  -name sdo_B_token_clk $sdo_B_token_clk_port
create_clock -period $in_token_clk_period  -name sdo_C_token_clk $sdo_C_token_clk_port
create_clock -period $in_token_clk_period  -name sdo_D_token_clk $sdo_D_token_clk_port

create_clock -period $master_io_clk_period  -name master_io_clk $master_io_clk_port


# we declare these clocks as being asynchronous
# note this disables all timing checks between groups
# so you really need to be sure this is what you want!
#
set_clock_groups -asynchronous  \
    -group {sdi_A_sclk}         \
    -group {sdi_B_sclk}         \
    -group {sdi_C_sclk}         \
    -group {sdi_D_sclk}         \
    -group {core_clk}           \
    -group {master_io_clk}      \
    -group {sdo_A_token_clk}    \
    -group {sdo_B_token_clk}    \
    -group {sdo_C_token_clk}    \
    -group {sdo_D_token_clk}

##################################################################################
#
# CDC checks
#
# we follow the advice of www.zimmerdesignservices.com/no_mans_land_20130328.pdf
#
# oddly, for this to work, we need to clone all of the clocks involved.
#
# we tried instead of doing this, just adding a max_delay path between paths
# but it causes a lot of warnings to be issued. this approach nicely groups
# these paths together.
#


# we set the cdc delay to be the minimimum of the clock periods involved, to be conservative.
# alternatively, we could try to hunt down all of the paths and explicitly label all of them
# but that adds a greater risk of error. none of these paths should be particularly critical.
#
# we care about:
#      1. the sending clock domain for gray code bit skew and
#      2. the receiving clock domain for delay through 2-port rams.
#
# we care less about:
#      1. path from reset signal in master_io_clk domain wired to token_reset
#         going into token ctr, since this signal is supposed to be asserted
#         for many cycles before and after the strobe of the token clock.
#         nonetheless, we restrict the timing of this path.
#
set cdc_delay [lindex [lsort -real [list $core_clk_period $in_token_clk_period $in_io_clk_period $master_io_clk_period]] 0]

echo "BSG-INFO: Constraining clock crossing paths to $cdc_delay (ns)."

create_clock -name sdi_A_sclk_cdc    -period [get_attribute [get_clocks sdi_A_sclk] period]        $sdi_A_sclk_port -add
create_clock -name sdi_B_sclk_cdc    -period [get_attribute [get_clocks sdi_B_sclk] period]        $sdi_B_sclk_port -add
create_clock -name sdi_C_sclk_cdc    -period [get_attribute [get_clocks sdi_C_sclk] period]        $sdi_C_sclk_port -add
create_clock -name sdi_D_sclk_cdc    -period [get_attribute [get_clocks sdi_D_sclk] period]        $sdi_D_sclk_port -add

create_clock -name master_io_clk_cdc -period [get_attribute [get_clocks master_io_clk] period]     $master_io_clk_port -add
create_clock -name core_clk_cdc      -period [get_attribute [get_clocks core_clk]      period]     $core_clk_port      -add

create_clock -name sdo_A_token_clk_cdc    -period [get_attribute [get_clocks sdo_A_token_clk] period]    $sdo_A_token_clk_port -add
create_clock -name sdo_B_token_clk_cdc    -period [get_attribute [get_clocks sdo_B_token_clk] period]    $sdo_B_token_clk_port -add
create_clock -name sdo_C_token_clk_cdc    -period [get_attribute [get_clocks sdo_C_token_clk] period]    $sdo_C_token_clk_port -add
create_clock -name sdo_D_token_clk_cdc    -period [get_attribute [get_clocks sdo_D_token_clk] period]    $sdo_D_token_clk_port -add


# these are redundant, I guess
remove_propagated_clock [get_clocks *_cdc]

# remove all internal paths from concern; these should already be timed
foreach_in_collection cdc_clk [get_clocks *_cdc] {
    set_false_path -from [get_clock $cdc_clk] -to [get_clock $cdc_clk]
}

# make cdc clocks physically exclusive from all others
set_clock_groups -physically_exclusive -group [remove_from_collection [get_clocks *] [get_clocks *_cdc]] -group [get_clocks *_cdc]




# impose a delay of one cycle delay for paths from sdi clocks to core
foreach_in_collection cdc_clk [get_clocks *_cdc] {
    set_max_delay $cdc_delay -from $cdc_clk
    set_min_delay 0 -from $cdc_clk
}

#set ssi_fifo [get_pins "guts/comm_link/channel[0].ssi/baf/mem_reg*/Q"]

# foreach_in_collection obj $ssi_fifo {
#     echo [get_object_name $obj]
# }

# limit delay going through async fifo ports
# (see BSG Source Synchronous I/O document)
#
# mbt: I have confirmed that these do indeed limit the delay.
# however they cause the following warning to be emitted:
#
# Warning: Breaking the timing path through pin 'guts/comm_link_channel_0__ssi_baf_mem_reg_0__17_/Q'
#      due to user timing constraints.
#
# fixme; we should try a "report_timing -from XXX" for each of these pins without these assertions
# to confirm that we are not blowing away anything important.
#

# dont touch all of the flops involved in the synchronizers
# note that this prevents these flops from being converted into
# flip flops so we need to something about this later.

# FIXME
# foreach_in_collection obj [get_cells -hier *bsg_sync1_flop_r*] {
#     echo "dont_touching" [get_object_name $obj]
#     set_dont_touch $obj
# }

# foreach_in_collection obj [get_cells -hier *bsg_sync2_flop_r*] {
#     echo "dont_touching" [get_object_name $obj]
#     set_dont_touch $obj
# }

# foreach_in_collection obj [get_cells -hier *bsg_launch_flop_r*] {
#     echo "dont_touching" [get_object_name $obj]
#     set_dont_touch $obj
# }

# from the perspective of the timing tool, these are not clocks

#create_clock -period $out_io_clk_period -name sdo_A_sclk $sdo_A_sclk_port
#create_clock -period $out_io_clk_period -name sdo_B_sclk $sdo_B_sclk_port
#create_clock -period $out_io_clk_period -name sdo_C_sclk $sdo_C_sclk_port
#create_clock -period $out_io_clk_period -name sdo_D_sclk $sdo_D_sclk_port

# Specifies the uncertainty (skew) of the specified clock networks.
# set_clock_uncertainty $CLK_SKEW [get_clocks $CLK_NAME]
#
set_clock_uncertainty $core_clk_uncertainty       [get_clocks core_clk]
set_clock_uncertainty $master_io_clk_uncertainty  [get_clocks master_io_clk]
set_clock_uncertainty $in_io_clk_uncertainty [get_clocks sdi_A_sclk]
set_clock_uncertainty $in_io_clk_uncertainty [get_clocks sdi_B_sclk]
set_clock_uncertainty $in_io_clk_uncertainty [get_clocks sdi_C_sclk]
set_clock_uncertainty $in_io_clk_uncertainty [get_clocks sdi_D_sclk]

set_clock_uncertainty $token_clk_uncertainty [get_clocks sdo_A_token_clk]
set_clock_uncertainty $token_clk_uncertainty [get_clocks sdo_B_token_clk]
set_clock_uncertainty $token_clk_uncertainty [get_clocks sdo_C_token_clk]
set_clock_uncertainty $token_clk_uncertainty [get_clocks sdo_D_token_clk]

#set_clock_uncertainty $core_clk_uncertainty [get_clocks sdo_A_sclk]
#set_clock_uncertainty $core_clk_uncertainty [get_clocks sdo_B_sclk]
#set_clock_uncertainty $core_clk_uncertainty [get_clocks sdo_C_sclk]
#set_clock_uncertainty $core_clk_uncertainty [get_clocks sdo_D_sclk]

# Standard cells
set_min_library slow.db -min_version fast.db
set_operating_conditions -min_library fast -min fast -max_library slow -max slow

# IO cells
set_min_library tpz873gezwc.db -min_version tpz873gezbc.db
set_operating_conditions -min_library tpz873gezbc -min BCCOM -max_library tpz873gezwc -max WCCOM

# SRAMs
# set_min_library rGenSRAM_tag_slow_syn.db -min_version rGenSRAM_tag_fast_syn.db
# set_operating_conditions -max_library ./frontend/rGenSRAM_tag_slow_syn.db:rGenSRAM_tag -max slow \
#                          -min_library ./frontend/rGenSRAM_tag_fast_syn.db:rGenSRAM_tag -min fast
# #
# set_min_library rGenSRAM_w38b_bit_slow_syn.db -min_version rGenSRAM_w38b_bit_fast_syn.db
# set_operating_conditions -max_library ./frontend/rGenSRAM_w38b_bit_slow_syn.db:rGenSRAM_w38b_bit -max slow \
#                          -min_library ./frontend/rGenSRAM_w38b_bit_fast_syn.db:rGenSRAM_w38b_bit -min fast
# #
# set_min_library rGenSRAM_w3b_bit_slow_syn.db -min_version rGenSRAM_w3b_bit_fast_syn.db
# set_operating_conditions -max_library ./frontend/rGenSRAM_w3b_bit_slow_syn.db:rGenSRAM_w3b_bit -max slow \
#                          -min_library ./frontend/rGenSRAM_w3b_bit_fast_syn.db:rGenSRAM_w3b_bit -min fast
# #
# set_min_library rGenSRAM_w64b_byte_slow_syn.db -min_version rGenSRAM_w64b_byte_fast_syn.db
# set_operating_conditions -max_library ./frontend/rGenSRAM_w64b_byte_slow_syn.db:rGenSRAM_w64b_byte -max slow \
#                          -min_library ./frontend/rGenSRAM_w64b_byte_fast_syn.db:rGenSRAM_w64b_byte -min fast
# #
# set_min_library rGenSRAM_w64b_word_slow_syn.db -min_version rGenSRAM_w64b_word_fast_syn.db
# set_operating_conditions -max_library ./frontend/rGenSRAM_w64b_word_slow_syn.db:rGenSRAM_w64b_word -max slow \
#                          -min_library ./frontend/rGenSRAM_w64b_word_fast_syn.db:rGenSRAM_w64b_word -min fast

# # RFs
# set_min_library rGenRF_1R1W_128x66_slow_syn.db -min_version rGenRF_1R1W_128x66_fast@0C_syn.db
# set_operating_conditions -max_library ./frontend/rGenRF_1R1W_128x66_slow_syn.db:rGenRF_1R1W_128x66 -max slow \
#                          -min_library ./frontend/rGenRF_1R1W_128x66_fast@0C_syn.db:rGenRF_1R1W_128x66 -min fast

puts "Info: Library setup information:"
list_libs

# Get channel ports
set sdi_A_input_ports [add_to_collection [get_ports "p_sdi_A_data_i*"] [get_ports "p_sdi_ncmd_i*[0]"] ]
set sdi_B_input_ports [add_to_collection [get_ports "p_sdi_B_data_i*"] [get_ports "p_sdi_ncmd_i*[1]"] ]
set sdi_C_input_ports [add_to_collection [get_ports "p_sdi_C_data_i*"] [get_ports "p_sdi_ncmd_i*[2]"] ]
set sdi_D_input_ports [add_to_collection [get_ports "p_sdi_D_data_i*"] [get_ports "p_sdi_ncmd_i*[3]"] ]

set sdo_A_output_ports [add_to_collection [get_ports "p_sdo_A_data_o*"] [get_ports "p_sdo_ncmd_o[0]"]]
set sdo_B_output_ports [add_to_collection [get_ports "p_sdo_B_data_o*"] [get_ports "p_sdo_ncmd_o[1]"]]
set sdo_C_output_ports [add_to_collection [get_ports "p_sdo_C_data_o*"] [get_ports "p_sdo_ncmd_o[2]"]]
set sdo_D_output_ports [add_to_collection [get_ports "p_sdo_D_data_o*"] [get_ports "p_sdo_ncmd_o[3]"]]

# bound the delay on the reset signal to something reasonable
# fixme: check this.

set_input_delay -clock core_clk  $max_async_reset_delay [get_ports p_reset_i]

# TODO: token ports need special constraints.

#
# Sets input delay on pins or input ports relative to a clock signal.
# Note, since our inputs are DDR, we have to define min and max
# for both edges of the clock.
#
# See p. 14 of this document:
#   http://www.zimmerdesignservices.com/working-with-ddrs-in-primetime.pdf
#

set_input_delay -clock sdi_A_sclk -min                        $max_in_io_skew_time  $sdi_A_input_ports
set_input_delay -clock sdi_B_sclk -min                        $max_in_io_skew_time  $sdi_B_input_ports
set_input_delay -clock sdi_C_sclk -min                        $max_in_io_skew_time  $sdi_C_input_ports
set_input_delay -clock sdi_D_sclk -min                        $max_in_io_skew_time  $sdi_D_input_ports

set_input_delay -clock sdi_A_sclk -min                        $max_in_io_skew_time  $sdi_A_input_ports -add_delay -clock_fall
set_input_delay -clock sdi_B_sclk -min                        $max_in_io_skew_time  $sdi_B_input_ports -add_delay -clock_fall
set_input_delay -clock sdi_C_sclk -min                        $max_in_io_skew_time  $sdi_C_input_ports -add_delay -clock_fall
set_input_delay -clock sdi_D_sclk -min                        $max_in_io_skew_time  $sdi_D_input_ports -add_delay -clock_fall

set_input_delay -clock sdi_A_sclk -max [expr ($in_io_clk_period / 2) - $max_in_io_skew_time] $sdi_A_input_ports -add_delay
set_input_delay -clock sdi_B_sclk -max [expr ($in_io_clk_period / 2) - $max_in_io_skew_time] $sdi_B_input_ports -add_delay
set_input_delay -clock sdi_C_sclk -max [expr ($in_io_clk_period / 2) - $max_in_io_skew_time] $sdi_C_input_ports -add_delay
set_input_delay -clock sdi_D_sclk -max [expr ($in_io_clk_period / 2) - $max_in_io_skew_time] $sdi_D_input_ports -add_delay

set_input_delay -clock sdi_A_sclk -max [expr ($in_io_clk_period / 2) - $max_in_io_skew_time] $sdi_A_input_ports -add_delay -clock_fall
set_input_delay -clock sdi_B_sclk -max [expr ($in_io_clk_period / 2) - $max_in_io_skew_time] $sdi_B_input_ports -add_delay -clock_fall
set_input_delay -clock sdi_C_sclk -max [expr ($in_io_clk_period / 2) - $max_in_io_skew_time] $sdi_C_input_ports -add_delay -clock_fall
set_input_delay -clock sdi_D_sclk -max [expr ($in_io_clk_period / 2) - $max_in_io_skew_time] $sdi_D_input_ports -add_delay -clock_fall

report_clocks [get_clocks *]

# fixme: no particular delay is necessary for the token signal; it is a clock. there is no signal it is relative to?
#

# sets output delay on output channel pins. this should be very low, because they are all registered.
# fixme: we actually want to a large value here.
# fixme: also, for the clock signals, they are negedge launched, do we need special rules for them as well?
#

# set_output_delay -clock master_io_clk                     $max_out_io_skew_time  $sdo_A_output_ports
# set_output_delay -clock master_io_clk                     $max_out_io_skew_time  $sdo_B_output_ports
# set_output_delay -clock master_io_clk                     $max_out_io_skew_time  $sdo_C_output_ports
# set_output_delay -clock master_io_clk                     $max_out_io_skew_time  $sdo_D_output_ports

# # set output delay on token signals. this should be extremely low, because they are all registered.
# set_output_delay -clock sdi_A_sclk                        $max_out_io_skew_time  [get_ports "p_sdi_token_o[0]"]
# set_output_delay -clock sdi_B_sclk                        $max_out_io_skew_time  [get_ports "p_sdi_token_o[1]"]
# set_output_delay -clock sdi_C_sclk                        $max_out_io_skew_time  [get_ports "p_sdi_token_o[2]"]
# set_output_delay -clock sdi_D_sclk                        $max_out_io_skew_time  [get_ports "p_sdi_token_o[3]"]

# create reference clocks
create_generated_clock -name sdo_A_sclk_output -source $master_io_clk_port -divide_by 1 [get_ports "p_sdo_sclk_o[0]"]
create_generated_clock -name sdo_B_sclk_output -source $master_io_clk_port -divide_by 1 [get_ports "p_sdo_sclk_o[1]"]
create_generated_clock -name sdo_C_sclk_output -source $master_io_clk_port -divide_by 1 [get_ports "p_sdo_sclk_o[2]"]
create_generated_clock -name sdo_D_sclk_output -source $master_io_clk_port -divide_by 1 [get_ports "p_sdo_sclk_o[3]"]

# we match the delay of the clock line but allow for a little more delay
# mbt fixme: should put hold times here, especially if the data checks are not working
set_output_delay -clock sdo_A_sclk_output [expr - $max_out_io_skew_time] $sdo_A_output_ports
set_output_delay -clock sdo_B_sclk_output [expr - $max_out_io_skew_time] $sdo_B_output_ports
set_output_delay -clock sdo_C_sclk_output [expr - $max_out_io_skew_time] $sdo_C_output_ports
set_output_delay -clock sdo_D_sclk_output [expr - $max_out_io_skew_time] $sdo_D_output_ports

# these should trivially be obeyed since they are self paths; but this gets rid of the timing assertion
# on the clock lines
set_output_delay -clock sdo_A_sclk_output [expr - $max_out_io_skew_time] [get_ports "p_sdo_sclk_o[0]"]
set_output_delay -clock sdo_B_sclk_output [expr - $max_out_io_skew_time] [get_ports "p_sdo_sclk_o[1]"]
set_output_delay -clock sdo_C_sclk_output [expr - $max_out_io_skew_time] [get_ports "p_sdo_sclk_o[2]"]
set_output_delay -clock sdo_D_sclk_output [expr - $max_out_io_skew_time] [get_ports "p_sdo_sclk_o[3]"]

# these are the data checks. 
# fixme verify: do these actually do anything? bsg_chip.mapped.data_check.max.timing.rpt says "no paths" 

foreach_in_collection obj $sdo_A_output_ports {
  set_data_check -from [get_ports "p_sdo_sclk_o[0]"] -to $obj -setup [expr -(($out_io_clk_period/2) - $max_out_io_skew_time)]
  set_data_check -from [get_ports "p_sdo_sclk_o[0]"] -to $obj -hold  [expr -(($out_io_clk_period/2) - $max_out_io_skew_time)]
}

foreach_in_collection obj $sdo_B_output_ports {
  set_data_check -from [get_ports "p_sdo_sclk_o[1]"] -to $obj -setup [expr -(($out_io_clk_period/2) - $max_out_io_skew_time)]
  set_data_check -from [get_ports "p_sdo_sclk_o[1]"] -to $obj -hold  [expr -(($out_io_clk_period/2) - $max_out_io_skew_time)]
}

foreach_in_collection obj $sdo_C_output_ports {
  set_data_check -from [get_ports "p_sdo_sclk_o[2]"] -to $obj -setup [expr -(($out_io_clk_period/2) - $max_out_io_skew_time)]
  set_data_check -from [get_ports "p_sdo_sclk_o[2]"] -to $obj -hold  [expr -(($out_io_clk_period/2) - $max_out_io_skew_time)]
}

foreach_in_collection obj $sdo_D_output_ports {
  set_data_check -from [get_ports "p_sdo_sclk_o[3]"] -to $obj -setup [expr -(($out_io_clk_period/2) - $max_out_io_skew_time)]
  set_data_check -from [get_ports "p_sdo_sclk_o[3]"] -to $obj -hold  [expr -(($out_io_clk_period/2) - $max_out_io_skew_time)]
}


#set_output_delay -clock sdo_A_sclk -max [expr $out_io_clk_period - $max_in_io_skew_time] $sdo_A_output_ports
#set_output_delay -clock sdo_B_sclk -max [expr $out_io_clk_period - $max_in_io_skew_time] $sdo_B_output_ports
#set_output_delay -clock sdo_C_sclk -max [expr $out_io_clk_period - $max_in_io_skew_time] $sdo_C_output_ports
#set_output_delay -clock sdo_D_sclk -max [expr $out_io_clk_period - $max_in_io_skew_time] $sdo_D_output_ports

# Sets the load attribute on the specified ports and nets.
# set_load ...

# Create path groups
#
# Separating these paths can help improve optimization in each group independently.
#
# During compile each timing path is placed into a path group associated with
# that path's "capturing" clock. DC then optimizes each path group in turn,
# starting with the critical path in each group.
#
# Reg_to_reg path groups are automatically created, named the same as their
# related (end-point) clock object names, by default.
set ports_clock_root [filter_collection [get_attribute [get_clocks] sources] object_class==port]
group_path -name input_to_reg  -from [remove_from_collection [all_inputs] ${ports_clock_root}]
group_path -name reg_to_output -to [all_outputs]
group_path -name feedthrough   -from [remove_from_collection [all_inputs] ${ports_clock_root}] -to [all_outputs]

# It is much easier for the physical design tool to fix a small number of violations through savvy placement, compared to having to handle a large number of violations.
#
# Prioritizing path groups
# The overall cost function is SigmaSum(negative_slack * weight) of all path groups.

puts "Info: Completed script [info script]\n"
