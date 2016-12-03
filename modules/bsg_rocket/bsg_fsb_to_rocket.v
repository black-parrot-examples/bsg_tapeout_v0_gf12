`include "bsg_rocket_pkg.vh"
`include "bsg_fsb_pkg.v"

module bsg_fsb_to_rocket
  import bsg_nasti_pkg::*;
  import bsg_fsb_pkg::*;
# (parameter dest_id_p = 0)
  (input                       clk_i
  ,input                       reset_i
  // fsb in
  ,input                       fsb_node_v_i
  ,input  bsg_fsb_pkt_client_s fsb_node_data_i
  ,output                      fsb_node_yumi_o
  // fsb out
  ,output                      fsb_node_v_o
  ,output bsg_fsb_pkt_client_s fsb_node_data_o
  ,input                       fsb_node_yumi_i
  // host in
  ,input                       host_valid_i
  ,input            bsg_host_t host_data_i
  ,output                      host_ready_o
  // host out
  ,output                      host_valid_o
  ,output           bsg_host_t host_data_o
  ,input                       host_ready_i
  // aw out
  ,output                      nasti_aw_valid_o
  ,output      bsg_nasti_a_pkt nasti_aw_data_o
  ,input                       nasti_aw_ready_i
  // w out
  ,output                      nasti_w_valid_o
  ,output      bsg_nasti_w_pkt nasti_w_data_o
  ,input                       nasti_w_ready_i
  // b in
  ,input                       nasti_b_valid_i
  ,input       bsg_nasti_b_pkt nasti_b_data_i
  ,output                      nasti_b_ready_o
  // ar out
  ,output                      nasti_ar_valid_o
  ,output      bsg_nasti_a_pkt nasti_ar_data_o
  ,input                       nasti_ar_ready_i
  // r in
  ,input                       nasti_r_valid_i
  ,input       bsg_nasti_r_pkt nasti_r_data_i
  ,output                      nasti_r_ready_o);

  // tunnel

  wire                      mux_v_i;
  bsg_fsb_pkt_client_data_t mux_data_i;
  wire                      mux_yumi_o;

  wire                      mux_v_o;
  bsg_fsb_pkt_client_data_t mux_data_o;
  wire                      mux_yumi_i;

  assign mux_v_i    = fsb_node_v_i;
  assign mux_data_i = bsg_fsb_pkt_client_data_t ' (fsb_node_data_i);
  assign fsb_node_yumi_o = mux_yumi_o;

  assign fsb_node_v_o           = mux_v_o;
  assign fsb_node_data_o.destid = (4) ' (dest_id_p);
  assign fsb_node_data_o.cmd    = 1'b0;
  assign fsb_node_data_o.data   = mux_data_o;
  assign mux_yumi_i = fsb_node_yumi_i;

  bsg_tun_dmx_ctrl_t  dmx_v_i;
  bsg_tun_dmx_array_t dmx_data_i;
  bsg_tun_dmx_ctrl_t  dmx_yumi_o;

  bsg_tun_dmx_ctrl_t  dmx_v_o;
  bsg_tun_dmx_array_t dmx_data_o;
  bsg_tun_dmx_ctrl_t  dmx_yumi_i;

  bsg_channel_tunnel #
    (.width_p(bsg_tun_dmx_width_p) // taken from bsg_rocket_pkg.vh
    ,.num_in_p(bsg_tun_num_in_p)   // taken from bsg_rocket_pkg.vh
    ,.remote_credits_p(128))
  tunnel
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    // mux in
    ,.multi_v_i(mux_v_i)
    ,.multi_data_i(mux_data_i)
    ,.multi_yumi_o(mux_yumi_o)
    // mux out
    ,.multi_v_o(mux_v_o)
    ,.multi_data_o(mux_data_o)
    ,.multi_yumi_i(mux_yumi_i)
    // dmux in
    ,.v_i(dmx_v_i)
    ,.data_i(dmx_data_i)
    ,.yumi_o(dmx_yumi_o)
    // dmux out
    ,.v_o(dmx_v_o)
    ,.data_o(dmx_data_o)
    ,.yumi_i(dmx_yumi_i));

  wire          htun_valid_i;
  bsg_tun_dmx_t htun_data_i;
  wire          htun_yumi_o;

  wire          htun_valid_o;
  bsg_tun_dmx_t htun_data_o;
  wire          htun_yumi_i;

  wire          req_valid;
  bsg_tun_dmx_t req_data;
  wire          req_yumi;

  wire          resp_valid;
  bsg_tun_dmx_t resp_data;
  wire          resp_yumi;

  assign {htun_valid_i, req_valid} = dmx_v_o;
  assign {htun_data_i, req_data}   = dmx_data_o;
  assign dmx_yumi_i = {htun_yumi_o, req_yumi};

  assign dmx_v_i    = {htun_valid_o, resp_valid};
  assign dmx_data_i = {htun_data_o, resp_data};
  assign {htun_yumi_i, resp_yumi} = dmx_yumi_o;

  // host

  bsg_host host
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    // data in
    ,.valid_i(htun_valid_i)
    ,.data_i(htun_data_i)
    ,.yumi_o(htun_yumi_o)
    // data out
    ,.valid_o(htun_valid_o)
    ,.data_o(htun_data_o)
    ,.yumi_i(htun_yumi_i)
    // host in
    ,.host_valid_i(host_valid_i)
    ,.host_data_i(host_data_i)
    ,.host_ready_o(host_ready_o)
    // host out
    ,.host_valid_o(host_valid_o)
    ,.host_data_o(host_data_o)
    ,.host_ready_i(host_ready_i));

  // nasti master

  bsg_nasti_master master
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    // req in
    ,.req_valid_i(req_valid)
    ,.req_data_i(req_data)
    ,.req_yumi_o(req_yumi)
    // resp out
    ,.resp_valid_o(resp_valid)
    ,.resp_data_o(resp_data)
    ,.resp_yumi_i(resp_yumi)
    // aw out
    ,.nasti_aw_valid_o(nasti_aw_valid_o)
    ,.nasti_aw_data_o(nasti_aw_data_o)
    ,.nasti_aw_ready_i(nasti_aw_ready_i)
    // w out
    ,.nasti_w_valid_o(nasti_w_valid_o)
    ,.nasti_w_data_o(nasti_w_data_o)
    ,.nasti_w_ready_i(nasti_w_ready_i)
    // b in
    ,.nasti_b_valid_i(nasti_b_valid_i)
    ,.nasti_b_data_i(nasti_b_data_i)
    ,.nasti_b_ready_o(nasti_b_ready_o)
    // ar out
    ,.nasti_ar_valid_o(nasti_ar_valid_o)
    ,.nasti_ar_data_o(nasti_ar_data_o)
    ,.nasti_ar_ready_i(nasti_ar_ready_i)
    // r in
    ,.nasti_r_valid_i(nasti_r_valid_i)
    ,.nasti_r_data_i(nasti_r_data_i)
    ,.nasti_r_ready_o(nasti_r_ready_o));

endmodule
