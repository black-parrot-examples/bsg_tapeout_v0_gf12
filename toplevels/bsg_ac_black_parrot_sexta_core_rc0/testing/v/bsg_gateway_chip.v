`timescale 1ps/1ps

`ifndef BLACKPARROT_CLK_PERIOD
  `define BLACKPARROT_CLK_PERIOD 5000.0
`endif

`ifndef IO_MASTER_CLK_PERIOD
  `define IO_MASTER_CLK_PERIOD 5000.0
`endif

`ifndef ROUTER_CLK_PERIOD
  `define ROUTER_CLK_PERIOD 5000.0
`endif

`ifndef TAG_CLK_PERIOD
  `define TAG_CLK_PERIOD 10000.0
`endif

module bsg_gateway_chip

`include "bsg_defines.v"
import bp_common_pkg::*;
import bp_common_aviary_pkg::*;
import bp_be_pkg::*;
import bp_be_rv64_pkg::*;
import bp_cce_pkg::*;
import bp_cfg_link_pkg::*;

import bsg_tag_pkg::*;
import bsg_chip_pkg::*;


`include "bsg_pinout_inverted.v"

  `declare_bsg_ready_and_link_sif_s(ct_width_gp, bsg_ready_and_link_sif_s);

  // Control clock generator output signal
  assign p_sel_0_o = 1'b0;
  assign p_sel_1_o = 1'b0;

  //////////////////////////////////////////////////
  //
  // Waveform Dump
  //

  initial
    begin
      $vcdpluson;
      $vcdplusmemon;
      $vcdplusautoflushon;
    end

  //////////////////////////////////////////////////
  //
  // Nonsynth Clock Generator(s)
  //

  logic blackparrot_clk;
  assign p_clk_A_o = blackparrot_clk;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`BLACKPARROT_CLK_PERIOD)) blackparrot_clk_gen (.o(blackparrot_clk));

  logic io_master_clk;
  assign p_clk_B_o = io_master_clk;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`IO_MASTER_CLK_PERIOD)) io_master_clk_gen (.o(io_master_clk));

  logic router_clk;
  assign p_clk_C_o = router_clk;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`ROUTER_CLK_PERIOD)) router_clk_gen (.o(router_clk));

  logic tag_clk;
  assign p_bsg_tag_clk_o = tag_clk;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`TAG_CLK_PERIOD)) tag_clk_gen (.o(tag_clk));

  //////////////////////////////////////////////////
  //
  // Nonsynth Reset Generator(s)
  //

  logic tag_reset;
  bsg_nonsynth_reset_gen #(.num_clocks_p(1),.reset_cycles_lo_p(10),.reset_cycles_hi_p(5))
    tag_reset_gen
      (.clk_i(tag_clk)
      ,.async_reset_o(tag_reset)
      );

  //////////////////////////////////////////////////
  //
  // BSG Tag Track Replay
  //

  localparam tag_trace_rom_addr_width_lp = 32;
  localparam tag_trace_rom_data_width_lp = 26;

  logic [tag_trace_rom_addr_width_lp-1:0] rom_addr_li;
  logic [tag_trace_rom_data_width_lp-1:0] rom_data_lo;

  logic [1:0] tag_trace_en_r_lo;
  logic       tag_trace_done_lo;

  // TAG TRACE ROM
  bsg_tag_boot_rom #(.width_p( tag_trace_rom_data_width_lp )
                    ,.addr_width_p( tag_trace_rom_addr_width_lp )
                    )
    tag_trace_rom
      (.addr_i( rom_addr_li )
      ,.data_o( rom_data_lo )
      );

  // TAG TRACE REPLAY
  bsg_tag_trace_replay #(.rom_addr_width_p( tag_trace_rom_addr_width_lp )
                        ,.rom_data_width_p( tag_trace_rom_data_width_lp )
                        ,.num_masters_p( 2 )
                        ,.num_clients_p( tag_num_clients_gp )
                        ,.max_payload_width_p( tag_max_payload_width_gp )
                        )
    tag_trace_replay
      (.clk_i   ( p_bsg_tag_clk_o )
      ,.reset_i ( tag_reset    )
      ,.en_i    ( 1'b1            )

      ,.rom_addr_o( rom_addr_li )
      ,.rom_data_i( rom_data_lo )

      ,.valid_i ( 1'b0 )
      ,.data_i  ( '0 )
      ,.ready_o ()

      ,.valid_o    ()
      ,.en_r_o     ( tag_trace_en_r_lo )
      ,.tag_data_o ( p_bsg_tag_data_o )
      ,.yumi_i     ( 1'b1 )

      ,.done_o  ( tag_trace_done_lo )
      ,.error_o ()
      ) ;

  assign p_bsg_tag_en_o = tag_trace_en_r_lo[0];

  //////////////////////////////////////////////////
  //
  // BSG Tag Master Instance (Copied from ASIC)
  //

  // All tag lines from the btm
  bsg_tag_s [tag_num_clients_gp-1:0] tag_lines_lo;

  // // Tag lines for clock generators
  // bsg_tag_s       async_reset_tag_lines_lo;
  // bsg_tag_s [2:0] osc_tag_lines_lo;
  // bsg_tag_s [2:0] osc_trigger_tag_lines_lo;
  // bsg_tag_s [2:0] ds_tag_lines_lo;
  // bsg_tag_s [2:0] sel_tag_lines_lo;
  
  bsg_tag_s [bp_num_router_gp-1:0] router_core_tag_lines_lo;

  // assign async_reset_tag_lines_lo = tag_lines_lo[0];
  // assign osc_tag_lines_lo         = tag_lines_lo[3:1];
  // assign osc_trigger_tag_lines_lo = tag_lines_lo[6:4];
  // assign ds_tag_lines_lo          = tag_lines_lo[9:7];
  // assign sel_tag_lines_lo         = tag_lines_lo[12:10];

  // Tag lines for io complex
  wire bsg_tag_s prev_link_io_tag_lines_lo   = tag_lines_lo[13];
  wire bsg_tag_s prev_link_core_tag_lines_lo = tag_lines_lo[14];
  wire bsg_tag_s prev_ct_core_tag_lines_lo   = tag_lines_lo[15];
  wire bsg_tag_s next_link_io_tag_lines_lo   = tag_lines_lo[16];
  wire bsg_tag_s next_link_core_tag_lines_lo = tag_lines_lo[17];
  wire bsg_tag_s next_ct_core_tag_lines_lo   = tag_lines_lo[18];
  assign router_core_tag_lines_lo            = tag_lines_lo[19+:bp_num_router_gp];
  wire bsg_tag_s cfg_tag_line_lo             = tag_lines_lo[tag_num_clients_gp-2];
  wire bsg_tag_s bp_core_tag_line_lo         = tag_lines_lo[tag_num_clients_gp-1];

  // BSG tag master instance
  bsg_tag_master #(.els_p( tag_num_clients_gp )
                  ,.lg_width_p( tag_lg_max_payload_width_gp )
                  )
    btm
      (.clk_i      ( p_bsg_tag_clk_o )
      ,.data_i     ( tag_trace_en_r_lo[1] ? p_bsg_tag_data_o : 1'b0 )
      ,.en_i       ( 1'b1 )
      ,.clients_r_o( tag_lines_lo )
      );

  //////////////////////////////////////////////////
  //
  // BSG Tag Client Instance (Copied from ASIC)
  //

  // Tag payload for blackparrot control signals
  typedef struct packed { 
      logic reset;
      logic [wh_cord_width_gp-1:0] cord;
  } bp_tag_payload_s;

  // Tag payload for blackparrot control signals
  bp_tag_payload_s bp_tag_data_lo;
  logic            bp_tag_new_data_lo;

  bsg_tag_client #(.width_p( $bits(bp_tag_payload_s) ), .default_p( 0 ))
    btc_blackparrot
      (.bsg_tag_i     ( bp_core_tag_line_lo )
      ,.recv_clk_i    ( blackparrot_clk )
      ,.recv_reset_i  ( 1'b0 )
      ,.recv_new_r_o  ( bp_tag_new_data_lo )
      ,.recv_data_r_o ( bp_tag_data_lo )
      );

  // Tag payload for blackparrot config loader control signals
  bp_tag_payload_s cfg_tag_data_lo;
  logic            cfg_tag_new_data_lo;

  bsg_tag_client #(.width_p( $bits(bp_tag_payload_s) ), .default_p( 0 ))
    btc_cfg
      (.bsg_tag_i     ( cfg_tag_line_lo )
      ,.recv_clk_i    ( blackparrot_clk )
      ,.recv_reset_i  ( 1'b0 )
      ,.recv_new_r_o  ( cfg_tag_new_data_lo )
      ,.recv_data_r_o ( cfg_tag_data_lo )
      );

  //////////////////////////////////////////////////
  //
  // Commlink Swizzle
  //

  logic       ci_clk_li;
  logic       ci_v_li;
  logic [8:0] ci_data_li;
  logic       ci_tkn_lo;

  logic       co_clk_lo;
  logic       co_v_lo;
  logic [8:0] co_data_lo;
  logic       co_tkn_li;

  logic       ci2_clk_li;
  logic       ci2_v_li;
  logic [8:0] ci2_data_li;
  logic       ci2_tkn_lo;

  logic       co2_clk_lo;
  logic       co2_v_lo;
  logic [8:0] co2_data_lo;
  logic       co2_tkn_li;

  bsg_chip_swizzle_adapter
    swizzle
      (.port_ci_clk_i   (p_ci_clk_i)
      ,.port_ci_v_i     (p_ci_v_i)
      ,.port_ci_data_i  ({p_ci_8_i, p_ci_7_i, p_ci_6_i, p_ci_5_i, p_ci_4_i, p_ci_3_i, p_ci_2_i, p_ci_1_i, p_ci_0_i})
      ,.port_ci_tkn_o   (p_ci_tkn_o)

      ,.port_ci2_clk_o  (p_ci2_clk_o)
      ,.port_ci2_v_o    (p_ci2_v_o)
      ,.port_ci2_data_o ({p_ci2_8_o, p_ci2_7_o, p_ci2_6_o, p_ci2_5_o, p_ci2_4_o, p_ci2_3_o, p_ci2_2_o, p_ci2_1_o, p_ci2_0_o})
      ,.port_ci2_tkn_i  (p_ci2_tkn_i)

      ,.port_co_clk_i   (p_co_clk_i)
      ,.port_co_v_i     (p_co_v_i)
      ,.port_co_data_i  ({p_co_8_i, p_co_7_i, p_co_6_i, p_co_5_i, p_co_4_i, p_co_3_i, p_co_2_i, p_co_1_i, p_co_0_i})
      ,.port_co_tkn_o   (p_co_tkn_o)

      ,.port_co2_clk_o  (p_co2_clk_o)
      ,.port_co2_v_o    (p_co2_v_o)
      ,.port_co2_data_o ({p_co2_8_o, p_co2_7_o, p_co2_6_o, p_co2_5_o, p_co2_4_o, p_co2_3_o, p_co2_2_o, p_co2_1_o, p_co2_0_o})
      ,.port_co2_tkn_i  (p_co2_tkn_i)

      ,.guts_ci_clk_o  (ci_clk_li)
      ,.guts_ci_v_o    (ci_v_li)
      ,.guts_ci_data_o (ci_data_li)
      ,.guts_ci_tkn_i  (ci_tkn_lo)

      ,.guts_co_clk_i  (co_clk_lo)
      ,.guts_co_v_i    (co_v_lo)
      ,.guts_co_data_i (co_data_lo)
      ,.guts_co_tkn_o  (co_tkn_li)

      ,.guts_ci2_clk_o (ci2_clk_li)
      ,.guts_ci2_v_o   (ci2_v_li)
      ,.guts_ci2_data_o(ci2_data_li)
      ,.guts_ci2_tkn_i (ci2_tkn_lo)

      ,.guts_co2_clk_i (co2_clk_lo)
      ,.guts_co2_v_i   (co2_v_lo)
      ,.guts_co2_data_i(co2_data_lo)
      ,.guts_co2_tkn_o (co2_tkn_li)
      );

  //////////////////////////////////////////////////
  //
  // BSG Chip IO Complex
  //

  logic                        router_reset_lo;
  logic [wh_cord_width_gp-1:0] router_cord_lo;

  bsg_ready_and_link_sif_s [ct_num_in_gp-1:0] rtr_links_li;
  bsg_ready_and_link_sif_s [ct_num_in_gp-1:0] rtr_links_lo;

  bsg_chip_io_complex #(.num_router_groups_p( 1 )

                       ,.link_width_p( link_width_gp )
                       ,.link_channel_width_p( link_channel_width_gp )
                       ,.link_num_channels_p( link_num_channels_gp )
                       ,.link_lg_fifo_depth_p( link_lg_fifo_depth_gp )
                       ,.link_lg_credit_to_token_decimation_p( link_lg_credit_to_token_decimation_gp )

                       ,.ct_width_p( ct_width_gp )
                       ,.ct_num_in_p( ct_num_in_gp )
                       ,.ct_remote_credits_p( ct_remote_credits_gp )
                       ,.ct_use_pseudo_large_fifo_p( ct_use_pseudo_large_fifo_gp )
                       ,.ct_lg_credit_decimation_p( ct_lg_credit_decimation_gp )

                       ,.wh_cord_markers_pos_p({wh_cord_markers_pos_b_gp, wh_cord_markers_pos_a_gp})
                       ,.wh_len_width_p( wh_len_width_gp )
                       )
    io_complex
      (.core_clk_i ( router_clk )
      ,.io_clk_i   ( io_master_clk )

      ,.prev_link_io_tag_lines_i( prev_link_io_tag_lines_lo )
      ,.prev_link_core_tag_lines_i( prev_link_core_tag_lines_lo )
      ,.prev_ct_core_tag_lines_i( prev_ct_core_tag_lines_lo )
      
      ,.next_link_io_tag_lines_i( next_link_io_tag_lines_lo )
      ,.next_link_core_tag_lines_i( next_link_core_tag_lines_lo )
      ,.next_ct_core_tag_lines_i( next_ct_core_tag_lines_lo )

      ,.rtr_core_tag_lines_i( router_core_tag_lines_lo[0] )
      
      ,.ci_clk_i  ( ci_clk_li )
      ,.ci_v_i    ( ci_v_li )
      ,.ci_data_i ( ci_data_li[link_channel_width_gp-1:0] )
      ,.ci_tkn_o  ( ci_tkn_lo )

      ,.co_clk_o  ( co_clk_lo )
      ,.co_v_o    ( co_v_lo )
      ,.co_data_o ( co_data_lo[link_channel_width_gp-1:0] )
      ,.co_tkn_i  ( co_tkn_li )

      ,.ci2_clk_i  ( ci2_clk_li )
      ,.ci2_v_i    ( ci2_v_li )
      ,.ci2_data_i ( ci2_data_li[link_channel_width_gp-1:0] )
      ,.ci2_tkn_o  ( ci2_tkn_lo )

      ,.co2_clk_o  ( co2_clk_lo )
      ,.co2_v_o    ( co2_v_lo )
      ,.co2_data_o ( co2_data_lo[link_channel_width_gp-1:0] )
      ,.co2_tkn_i  ( co2_tkn_li )
      
      ,.rtr_links_i ( rtr_links_li )
      ,.rtr_links_o ( rtr_links_lo )

      ,.rtr_reset_o ( router_reset_lo )
      ,.rtr_cord_o  ( router_cord_lo  )
      );

  //////////////////////////////////////////////////
  //
  // BP Config Loader
  //
  bsg_ready_and_link_sif_s gw_master_link_li, gw_master_link_lo;
  bsg_ready_and_link_sif_s gw_client_link_li, gw_client_link_lo;

  // Hardcoded based on bp_cfg = sexta
  `declare_bp_me_if(39, 512, 32, 8, 116);
  bp_cce_mem_data_cmd_s cfg_data_cmd_lo;
  logic                 cfg_data_cmd_v_lo, cfg_data_cmd_yumi_li;
  bp_mem_cce_resp_s     cfg_resp_li;
  logic                 cfg_resp_v_li, cfg_resp_ready_lo;
  bp_cce_mmio_cfg_loader
   #(.cfg_p(bp_cfg_gp)
     ,.inst_width_p(`bp_cce_inst_width)
     ,.inst_ram_addr_width_p(`BSG_SAFE_CLOG2(256))
     ,.inst_ram_els_p(256)
     ,.skip_ram_init_p(0)
     )
   cfg_loader
    (.clk_i(blackparrot_clk)
     ,.reset_i(bp_tag_data_lo.reset | ~tag_trace_done_lo )

     ,.mem_data_cmd_o(cfg_data_cmd_lo)
     ,.mem_data_cmd_v_o(cfg_data_cmd_v_lo)
     ,.mem_data_cmd_yumi_i(cfg_data_cmd_yumi_li)

     ,.mem_resp_i(cfg_resp_li)
     ,.mem_resp_v_i(cfg_resp_v_li)
     ,.mem_resp_ready_o(cfg_resp_ready_lo)
     );

  bp_me_cce_to_wormhole_link_master
   #(.cfg_p(bp_cfg_gp)
     ,.x_cord_width_p(wh_cord_width_gp-1)
     ,.y_cord_width_p(1)
     )
   master_link
    (.clk_i(blackparrot_clk)
     ,.reset_i(bp_tag_data_lo.reset | ~tag_trace_done_lo )


     ,.mem_cmd_i('0)
     ,.mem_cmd_v_i('0)
     ,.mem_cmd_yumi_o()

     ,.mem_data_cmd_i(cfg_data_cmd_lo)
     ,.mem_data_cmd_v_i(cfg_data_cmd_v_lo)
     ,.mem_data_cmd_yumi_o(cfg_data_cmd_yumi_li)

     ,.mem_resp_o(cfg_resp_li)
     ,.mem_resp_v_o(cfg_resp_v_li)
     ,.mem_resp_ready_i(cfg_resp_ready_lo)

     ,.mem_data_resp_o()
     ,.mem_data_resp_v_o()
     ,.mem_data_resp_ready_i('0)

     ,.my_x_i(bp_tag_data_lo.cord[0+:7])
     ,.my_y_i('0)

     ,.mem_cmd_dest_x_i('0)
     ,.mem_cmd_dest_y_i('0)

     ,.mem_data_cmd_dest_x_i(cfg_tag_data_lo.cord[0+:7])
     ,.mem_data_cmd_dest_y_i('0)

     ,.link_i(gw_master_link_li)
     ,.link_o(gw_master_link_lo)
     );

  bp_cce_mem_cmd_s           host_cmd_li;
  logic                      host_cmd_v_li, host_cmd_yumi_lo;
  bp_cce_mem_data_cmd_s      host_data_cmd_li;
  logic                      host_data_cmd_v_li, host_data_cmd_yumi_lo;
  bp_mem_cce_resp_s          host_resp_lo;
  logic                      host_resp_v_lo, host_resp_ready_li;
  bp_mem_cce_data_resp_s     host_data_resp_lo;
  logic                      host_data_resp_v_lo, host_data_resp_ready_li;
  logic [bp_num_core_gp-1:0] program_finish_lo;
  bp_nonsynth_host
   #(.cfg_p(bp_cfg_gp))
   host_mmio
    (.clk_i(blackparrot_clk)
     ,.reset_i(bp_tag_data_lo.reset | ~tag_trace_done_lo)
     
     ,.mem_data_cmd_i(host_data_cmd_li)
     ,.mem_data_cmd_v_i(host_data_cmd_v_li)
     ,.mem_data_cmd_yumi_o(host_data_cmd_yumi_lo)

     ,.mem_resp_o(host_resp_lo)
     ,.mem_resp_v_o(host_resp_v_lo)
     ,.mem_resp_ready_i(host_resp_ready_li)

     ,.program_finish_o(program_finish_lo)
     );
  assign host_cmd_yumi_lo    = '0;
  assign host_data_resp_v_lo = '0;
  assign host_data_resp_lo   = '0;

  bp_cce_mem_cmd_s       dram_cmd_li;
  logic                  dram_cmd_v_li, dram_cmd_yumi_lo;
  bp_cce_mem_data_cmd_s  dram_data_cmd_li;
  logic                  dram_data_cmd_v_li, dram_data_cmd_yumi_lo;
  bp_mem_cce_resp_s      dram_resp_lo;
  logic                  dram_resp_v_lo, dram_resp_ready_li;
  bp_mem_cce_data_resp_s dram_data_resp_lo;
  logic                  dram_data_resp_v_lo, dram_data_resp_ready_li;
  bp_mem_dramsim2
   #(.mem_id_p(0)
     ,.clock_period_in_ps_p(`BLACKPARROT_CLK_PERIOD)
     ,.prog_name_p("prog.mem")
     ,.dram_cfg_p("dram_ch.ini")
     ,.dram_sys_cfg_p("dram_sys.ini")
     ,.dram_capacity_p(16384)
     ,.num_lce_p(32)
     ,.num_cce_p(16)
     ,.paddr_width_p(39)
     ,.lce_assoc_p(8)
     ,.block_size_in_bytes_p(512/8)
     ,.lce_sets_p(64)
     ,.lce_req_data_width_p(64)
     )
   mem
    (.clk_i(blackparrot_clk)
     ,.reset_i(bp_tag_data_lo.reset | ~tag_trace_done_lo)

     ,.mem_cmd_i(dram_cmd_li)
     ,.mem_cmd_v_i(dram_cmd_v_li)
     ,.mem_cmd_yumi_o(dram_cmd_yumi_lo)

     ,.mem_data_cmd_i(dram_data_cmd_li)
     ,.mem_data_cmd_v_i(dram_data_cmd_v_li)
     ,.mem_data_cmd_yumi_o(dram_data_cmd_yumi_lo)

     ,.mem_resp_o(dram_resp_lo)
     ,.mem_resp_v_o(dram_resp_v_lo)
     ,.mem_resp_ready_i(dram_resp_ready_li)

     ,.mem_data_resp_o(dram_data_resp_lo)
     ,.mem_data_resp_v_o(dram_data_resp_v_lo)
     ,.mem_data_resp_ready_i(dram_data_resp_ready_li)
     );

  bp_cce_mem_cmd_s       mem_cmd_lo;
  logic                  mem_cmd_v_lo, mem_cmd_yumi_li;
  bp_cce_mem_data_cmd_s  mem_data_cmd_lo;
  logic                  mem_data_cmd_v_lo, mem_data_cmd_yumi_li;
  bp_mem_cce_resp_s      mem_resp_li;
  logic                  mem_resp_v_li, mem_resp_ready_lo;
  bp_mem_cce_data_resp_s mem_data_resp_li;
  logic                  mem_data_resp_v_li, mem_data_resp_ready_lo;
  bp_me_cce_to_wormhole_link_client
   #(.cfg_p(bp_cfg_gp)
     ,.x_cord_width_p(wh_cord_width_gp-1)
     ,.y_cord_width_p(1)
     )
   client_link
    (.clk_i(blackparrot_clk)
     ,.reset_i(bp_tag_data_lo.reset | ~tag_trace_done_lo)

     ,.mem_cmd_o(mem_cmd_lo)
     ,.mem_cmd_v_o(mem_cmd_v_lo)
     ,.mem_cmd_yumi_i(mem_cmd_yumi_li)

     ,.mem_data_cmd_o(mem_data_cmd_lo)
     ,.mem_data_cmd_v_o(mem_data_cmd_v_lo)
     ,.mem_data_cmd_yumi_i(mem_data_cmd_yumi_li)

     ,.mem_resp_i(mem_resp_li)
     ,.mem_resp_v_i(mem_resp_v_li)
     ,.mem_resp_ready_o(mem_resp_ready_lo)

     ,.mem_data_resp_i(mem_data_resp_li)
     ,.mem_data_resp_v_i(mem_data_resp_v_li)
     ,.mem_data_resp_ready_o(mem_data_resp_ready_lo)

     ,.my_x_i(bp_tag_data_lo.cord[0+:7])
     ,.my_y_i('0)

     ,.link_i(gw_client_link_li)
     ,.link_o(gw_client_link_lo)
     );

  logic req_outstanding_r;
  bsg_dff_reset_en
   #(.width_p(1))
   req_outstanding_reg
    (.clk_i(blackparrot_clk)
     ,.reset_i(bp_tag_data_lo.reset | ~tag_trace_done_lo)
     ,.en_i(mem_cmd_yumi_li | mem_data_cmd_yumi_li | mem_resp_v_li | mem_data_resp_v_li)
  
     ,.data_i(mem_cmd_yumi_li | mem_data_cmd_yumi_li)
     ,.data_o(req_outstanding_r)
     );
  
  wire host_data_cmd_not_dram = mem_data_cmd_v_lo & (mem_data_cmd_lo.addr < dram_base_addr_gp);
  wire host_cmd_not_dram      = mem_cmd_v_lo & (mem_cmd_lo.addr < dram_base_addr_gp);
  
  assign host_cmd_li          = mem_cmd_lo;
  assign host_cmd_v_li        = mem_cmd_v_lo & host_cmd_not_dram & ~req_outstanding_r;
  assign dram_cmd_li          = mem_cmd_lo;
  assign dram_cmd_v_li        = mem_cmd_v_lo & ~host_cmd_not_dram & ~req_outstanding_r;
  assign mem_cmd_yumi_li      = host_cmd_not_dram 
                                ? host_cmd_yumi_lo 
                                : dram_cmd_yumi_lo;
  
  assign host_data_cmd_li     = mem_data_cmd_lo;
  assign host_data_cmd_v_li   = mem_data_cmd_v_lo & host_data_cmd_not_dram & ~req_outstanding_r;
  assign dram_data_cmd_li     = mem_data_cmd_lo;
  assign dram_data_cmd_v_li   = mem_data_cmd_v_lo & ~host_data_cmd_not_dram & ~req_outstanding_r;
  assign mem_data_cmd_yumi_li = host_data_cmd_not_dram 
                                ? host_data_cmd_yumi_lo 
                                : dram_data_cmd_yumi_lo;
  
  assign mem_resp_li = host_resp_v_lo ? host_resp_lo : dram_resp_lo;
  assign mem_resp_v_li = host_resp_v_lo | dram_resp_v_lo;
  assign host_resp_ready_li = mem_resp_ready_lo;
  assign dram_resp_ready_li = mem_resp_ready_lo;
  
  assign mem_data_resp_li = host_data_resp_v_lo ? host_data_resp_lo : dram_data_resp_lo;
  assign mem_data_resp_v_li = host_data_resp_v_lo | dram_data_resp_v_lo;
  assign host_data_resp_ready_li = mem_data_resp_ready_lo;
  assign dram_data_resp_ready_li = mem_data_resp_ready_lo;

  //////////////////////////////////////////////////
  //
  // Async crossings
  //
  bsg_ready_and_link_sif_s io_cmd_link_li, io_cmd_link_lo;
  bsg_ready_and_link_sif_s io_resp_link_li, io_resp_link_lo;
  
  logic gw_master_link_full_lo;
  assign gw_master_link_li.ready_and_rev = ~gw_master_link_full_lo;
  wire gw_master_link_enq_li = gw_master_link_lo.v & gw_master_link_li.ready_and_rev;
  wire io_cmd_link_deq_li = io_cmd_link_li.v & io_cmd_link_lo.ready_and_rev;
  bsg_async_fifo
   #(.lg_size_p(3)
     ,.width_p(ct_width_gp)
     )
   gw_cmd_link_async_fifo
    (.w_clk_i(blackparrot_clk)
     ,.w_reset_i(bp_tag_data_lo.reset)
     ,.w_enq_i(gw_master_link_enq_li)
     ,.w_data_i(gw_master_link_lo.data)
     ,.w_full_o(gw_master_link_full_lo)

     ,.r_clk_i(router_clk)
     ,.r_reset_i(router_reset_lo)
     ,.r_deq_i(io_cmd_link_deq_li)
     ,.r_data_o(io_cmd_link_li.data)
     ,.r_valid_o(io_cmd_link_li.v)
     );

  logic gw_client_link_full_lo;
  assign gw_client_link_li.ready_and_rev = ~gw_client_link_full_lo;
  wire gw_client_link_enq_li = gw_client_link_lo.v & gw_client_link_li.ready_and_rev;
  wire io_resp_link_deq_li = io_resp_link_li.v & io_resp_link_lo.ready_and_rev;
  bsg_async_fifo
   #(.lg_size_p(3)
     ,.width_p(ct_width_gp)
     )
   gw_resp_async_fifo
    (.w_clk_i(blackparrot_clk)
     ,.w_reset_i(bp_tag_data_lo.reset)
     ,.w_enq_i(gw_client_link_enq_li)
     ,.w_data_i(gw_client_link_lo.data)
     ,.w_full_o(gw_client_link_full_lo)

     ,.r_clk_i(router_clk)
     ,.r_reset_i(router_reset_lo)
     ,.r_deq_i(io_resp_link_deq_li)
     ,.r_data_o(io_resp_link_li.data)
     ,.r_valid_o(io_resp_link_li.v)
     );

  logic io_cmd_link_full_lo;
  assign io_cmd_link_li.ready_and_rev = ~io_cmd_link_full_lo;
  wire io_cmd_link_enq_li = io_cmd_link_lo.v & io_cmd_link_li.ready_and_rev;
  wire gw_client_link_deq_li = gw_client_link_li.v & gw_client_link_lo.ready_and_rev;
  bsg_async_fifo
   #(.lg_size_p(3)
     ,.width_p(ct_width_gp)
     )
   io_cmd_link_async_fifo
    (.w_clk_i(router_clk)
     ,.w_reset_i(router_reset_lo)
     ,.w_enq_i(io_cmd_link_enq_li)
     ,.w_data_i(io_cmd_link_lo.data)
     ,.w_full_o(io_cmd_link_full_lo)

     ,.r_clk_i(blackparrot_clk)
     ,.r_reset_i(bp_tag_data_lo.reset)
     ,.r_deq_i(gw_client_link_deq_li)
     ,.r_data_o(gw_client_link_li.data)
     ,.r_valid_o(gw_client_link_li.v)
     );

  logic io_resp_link_full_lo;
  assign io_resp_link_li.ready_and_rev = ~io_resp_link_full_lo;
  wire io_resp_link_enq_li = io_resp_link_lo.v & io_resp_link_li.ready_and_rev;
  wire gw_master_link_deq_li = gw_master_link_li.v & gw_master_link_lo.ready_and_rev;
  bsg_async_fifo
   #(.lg_size_p(3)
     ,.width_p(ct_width_gp)
     )
   io_resp_link_async_fifo
    (.w_clk_i(router_clk)
     ,.w_reset_i(router_reset_lo)
     ,.w_enq_i(io_resp_link_enq_li)
     ,.w_data_i(io_resp_link_lo.data)
     ,.w_full_o(io_resp_link_full_lo)

     ,.r_clk_i(blackparrot_clk)
     ,.r_reset_i(bp_tag_data_lo.reset)
     ,.r_deq_i(gw_master_link_deq_li)
     ,.r_data_o(gw_master_link_li.data)
     ,.r_valid_o(gw_master_link_li.v)
     );

  assign rtr_links_li[0] = io_cmd_link_li;
  assign rtr_links_li[1] = io_resp_link_li;
  assign io_cmd_link_lo  = rtr_links_lo[0];
  assign io_resp_link_lo = rtr_links_lo[1];

endmodule

