#-------------------------------------------------------------------------------
# bsg_tag timing constraints
#
#-------------------------------------------------------------------------------

#
# "bsg_tag" (aka bsg tag)
#
# bsg_tag connects to the two oscillators, and two ds's
#

proc bsg_tag_clock_create { bsg_tag_clk_name bsg_tag_port bsg_tag_period uncertainty_percent } {
    create_clock -period $bsg_tag_period -name $bsg_tag_clk_name $bsg_tag_port
    set_clock_uncertainty  [expr ($uncertainty_percent * $bsg_tag_period)    / 100.0] [get_clocks $bsg_tag_clk_name]
}

#
# invoked by clients of bsg_tag to set up CDC
#

proc bsg_tag_add_client_cdc_timing_constraints { bsg_tag_clk_name other_clk_name } {

    # declare BSG_TAG and the other domain asynchronous to each other
    set_clock_groups -asynchronous -group $bsg_tag_clk_name -group $other_clk_name

    # CDC crossing assertions
    #

    set suffix "_cdc"

    set bsg_tag_clk_name_cdc $bsg_tag_clk_name$suffix
    set other_clk_name_cdc $other_clk_name$suffix

    set bsg_tag_period  [get_attribute [get_clocks $bsg_tag_clk_name] period]
    set other_period [get_attribute [get_clocks $other_clk_name] period]

    # CDC delay should be less than fastest cycle time
    set bsg_tag_cdc_delay [lindex [lsort -real [list $bsg_tag_period $other_period]] 0]

    # create bsg_tag cdc clock if it is not already created
    if {[sizeof_collection [get_clocks $bsg_tag_clk_name_cdc]]==0} {
        echo "Ignore above warning."
        create_clock -name $bsg_tag_clk_name_cdc \
            -period $bsg_tag_period \
            -add  [get_attribute $bsg_tag_clk_name sources]
    }

    create_clock -name $other_clk_name_cdc \
        -period $other_period \
        -add  [get_attribute  $other_clk_name sources]

    remove_propagated_clock $bsg_tag_clk_name_cdc
    remove_propagated_clock $other_clk_name_cdc

    set_false_path -from $bsg_tag_clk_name_cdc  -to $bsg_tag_clk_name_cdc
    set_false_path -from $other_clk_name_cdc -to $other_clk_name_cdc

    # make cdc clocks physically exclusive from all others
    set_clock_groups -physically_exclusive \
        -group [remove_from_collection [get_clocks *] [list $bsg_tag_clk_name_cdc $other_clk_name_cdc ]]\
        -group [list $bsg_tag_clk_name_cdc $other_clk_name_cdc ]

    # add delays to CDC clocks
    set_max_delay $bsg_tag_cdc_delay -from $bsg_tag_clk_name_cdc -to $other_clk_name_cdc
    set_min_delay 0 -from $bsg_tag_clk_name_cdc -to $other_clk_name_cdc

    set_max_delay $bsg_tag_cdc_delay -from $other_clk_name_cdc -to $bsg_tag_clk_name_cdc
    set_min_delay 0 -from $other_clk_name_cdc -to $bsg_tag_clk_name_cdc
}


