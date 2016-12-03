`include "bsg_rocket_pkg.vh"
`include "bsg_fsb_pkg.v"

module bsg_rocket_to_fsb
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
  ,input                       fsb_node_yumi_i);

  wire       host_in_valid;
  bsg_host_t host_in_data;
  wire       host_in_ready;

  wire       host_out_valid;
  bsg_host_t host_out_data;
  wire       host_out_ready;

  wire            nasti_aw_valid;
  bsg_nasti_a_pkt nasti_aw_data;
  wire            nasti_aw_ready;

  wire            nasti_w_valid;
  bsg_nasti_w_pkt nasti_w_data;
  wire            nasti_w_ready;

  wire            nasti_b_valid;
  bsg_nasti_b_pkt nasti_b_data;
  wire            nasti_b_ready;

  wire            nasti_ar_valid;
  bsg_nasti_a_pkt nasti_ar_data;
  wire            nasti_ar_ready;

  wire            nasti_r_valid;
  bsg_nasti_r_pkt nasti_r_data;
  wire            nasti_r_ready;

  rocket_chip rocket
    (.clk(clk_i)
    ,.reset(reset_i)

    //----------------------------------------------------------------------------
    // BEGIN host client
    //----------------------------------------------------------------------------

    // host in
    ,.io_host_in_ready(host_in_ready)
    ,.io_host_in_valid(host_in_valid)
    ,.io_host_in_bits(host_in_data)
    // host out
    ,.io_host_out_ready(host_out_ready)
    ,.io_host_out_valid(host_out_valid)
    ,.io_host_out_bits(host_out_data)

    //----------------------------------------------------------------------------
    // END host client
    //----------------------------------------------------------------------------

    //----------------------------------------------------------------------------
    // BEGIN nasti(axi) master
    //----------------------------------------------------------------------------

    // aw out
    ,.io_mem_0_aw_ready(nasti_aw_ready)
    ,.io_mem_0_aw_valid(nasti_aw_valid)
    ,.io_mem_0_aw_bits_addr(nasti_aw_data.addr)
    ,.io_mem_0_aw_bits_len(nasti_aw_data.len)
    ,.io_mem_0_aw_bits_size(nasti_aw_data.size)
    ,.io_mem_0_aw_bits_burst(nasti_aw_data.burst)
    ,.io_mem_0_aw_bits_lock(nasti_aw_data.lock)
    ,.io_mem_0_aw_bits_cache(nasti_aw_data.cache)
    ,.io_mem_0_aw_bits_prot(nasti_aw_data.prot)
    ,.io_mem_0_aw_bits_qos(nasti_aw_data.qos)
    ,.io_mem_0_aw_bits_region(nasti_aw_data.region)
    ,.io_mem_0_aw_bits_id(nasti_aw_data.id)
    // w out
    ,.io_mem_0_w_ready(nasti_w_ready)
    ,.io_mem_0_w_valid(nasti_w_valid)
    ,.io_mem_0_w_bits_data(nasti_w_data.data)
    ,.io_mem_0_w_bits_last(nasti_w_data.last)
    ,.io_mem_0_w_bits_strb(nasti_w_data.strb)
    // b in
    ,.io_mem_0_b_ready(nasti_b_ready)
    ,.io_mem_0_b_valid(nasti_b_valid)
    ,.io_mem_0_b_bits_resp(nasti_b_data.resp)
    ,.io_mem_0_b_bits_id(nasti_b_data.id)
    // ar out
    ,.io_mem_0_ar_ready(nasti_ar_ready)
    ,.io_mem_0_ar_valid(nasti_ar_valid)
    ,.io_mem_0_ar_bits_addr(nasti_ar_data.addr)
    ,.io_mem_0_ar_bits_len(nasti_ar_data.len)
    ,.io_mem_0_ar_bits_size(nasti_ar_data.size)
    ,.io_mem_0_ar_bits_burst(nasti_ar_data.burst)
    ,.io_mem_0_ar_bits_lock(nasti_ar_data.lock)
    ,.io_mem_0_ar_bits_cache(nasti_ar_data.cache)
    ,.io_mem_0_ar_bits_prot(nasti_ar_data.prot)
    ,.io_mem_0_ar_bits_qos(nasti_ar_data.qos)
    ,.io_mem_0_ar_bits_region(nasti_ar_data.region)
    ,.io_mem_0_ar_bits_id(nasti_ar_data.id)
    // r in
    ,.io_mem_0_r_ready(nasti_r_ready)
    ,.io_mem_0_r_valid(nasti_r_valid)
    ,.io_mem_0_r_bits_resp(nasti_r_data.resp)
    ,.io_mem_0_r_bits_data(nasti_r_data.data)
    ,.io_mem_0_r_bits_last(nasti_r_data.last)
    ,.io_mem_0_r_bits_id(nasti_r_data.id)

    //----------------------------------------------------------------------------
    // END nasti(axi) master
    //----------------------------------------------------------------------------

    //----------------------------------------------------------------------------
    // BEGIN unused
    //----------------------------------------------------------------------------

    ,.io_mem_0_aw_bits_user()
    ,.io_mem_0_w_bits_user()
    ,.io_mem_0_b_bits_user()
    ,.io_mem_0_ar_bits_user()
    ,.io_mem_0_r_bits_user()
    ,.io_mem_backup_ctrl_en(1'b0)
    ,.io_mem_backup_ctrl_in_valid(1'b0)
    ,.io_mem_backup_ctrl_out_ready(1'b0)
    ,.io_mem_backup_ctrl_out_valid()
    ,.io_host_clk()
    ,.io_host_clk_edge()
    ,.io_host_debug_stats_csr()
    ,.init(1'b0));

    //----------------------------------------------------------------------------
    // END unused
    //----------------------------------------------------------------------------

  // host

  wire          htun_valid_i;
  bsg_tun_dmx_t htun_data_i;
  wire          htun_yumi_o;

  wire          htun_valid_o;
  bsg_tun_dmx_t htun_data_o;
  wire          htun_yumi_i;

  bsg_host host
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    // host in
    ,.host_valid_i(host_out_valid)
    ,.host_data_i(host_out_data)
    ,.host_ready_o(host_out_ready)
    // host out
    ,.host_valid_o(host_in_valid)
    ,.host_data_o(host_in_data)
    ,.host_ready_i(host_in_ready)
    // data in
    ,.valid_i(htun_valid_i)
    ,.data_i(htun_data_i)
    ,.yumi_o(htun_yumi_o)
    // data out
    ,.valid_o(htun_valid_o)
    ,.data_o(htun_data_o)
    ,.yumi_i(htun_yumi_i));

  // nasti client

  wire          resp_valid;
  bsg_tun_dmx_t resp_data;
  wire          resp_yumi;

  wire          req_valid;
  bsg_tun_dmx_t req_data;
  wire          req_yumi;

  bsg_nasti_client nasti_client
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    // aw in
    ,.nasti_aw_valid_i(nasti_aw_valid)
    ,.nasti_aw_data_i(nasti_aw_data)
    ,.nasti_aw_ready_o(nasti_aw_ready)
    // w in
    ,.nasti_w_valid_i(nasti_w_valid)
    ,.nasti_w_data_i(nasti_w_data)
    ,.nasti_w_ready_o(nasti_w_ready)
    // b out
    ,.nasti_b_valid_o(nasti_b_valid)
    ,.nasti_b_data_o(nasti_b_data)
    ,.nasti_b_ready_i(nasti_b_ready)
    // ar in
    ,.nasti_ar_valid_i(nasti_ar_valid)
    ,.nasti_ar_data_i(nasti_ar_data)
    ,.nasti_ar_ready_o(nasti_ar_ready)
    // r out
    ,.nasti_r_valid_o(nasti_r_valid)
    ,.nasti_r_data_o(nasti_r_data)
    ,.nasti_r_ready_i(nasti_r_ready)
    // resp in
    ,.resp_valid_i(resp_valid)
    ,.resp_data_i(resp_data)
    ,.resp_yumi_o(resp_yumi)
    // req out
    ,.req_valid_o(req_valid)
    ,.req_data_o(req_data)
    ,.req_yumi_i(req_yumi));

  // tunnel

  bsg_tun_dmx_ctrl_t  dmx_v_i;
  bsg_tun_dmx_array_t dmx_data_i;
  bsg_tun_dmx_ctrl_t  dmx_yumi_o;

  assign dmx_v_i    = {htun_valid_o, req_valid};
  assign dmx_data_i = {htun_data_o, req_data};
  assign {htun_yumi_i, req_yumi} = dmx_yumi_o;

  bsg_tun_dmx_ctrl_t  dmx_v_o;
  bsg_tun_dmx_array_t dmx_data_o;
  bsg_tun_dmx_ctrl_t  dmx_yumi_i;

  assign {htun_valid_i, resp_valid} = dmx_v_o;
  assign {htun_data_i, resp_data}   = dmx_data_o;
  assign dmx_yumi_i = {htun_yumi_o, resp_yumi};

  wire                      mux_v_i;
  bsg_fsb_pkt_client_data_t mux_data_i;
  wire                      mux_yumi_o;

  wire                      mux_v_o;
  bsg_fsb_pkt_client_data_t mux_data_o;
  wire                      mux_yumi_i;

  bsg_channel_tunnel #
    (.width_p(bsg_tun_dmx_width_p) // taken from bsg_rocket_pkg.vh
    ,.num_in_p(bsg_tun_num_in_p)   // taken from bsg_rocket_pkg.vh
    ,.remote_credits_p(128))
  tunnel
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    // dmux in
    ,.v_i(dmx_v_i)
    ,.data_i(dmx_data_i)
    ,.yumi_o(dmx_yumi_o)
    // dmux out
    ,.v_o(dmx_v_o)
    ,.data_o(dmx_data_o)
    ,.yumi_i(dmx_yumi_i)
    // mux in
    ,.multi_v_i(mux_v_i)
    ,.multi_data_i(mux_data_i)
    ,.multi_yumi_o(mux_yumi_o)
    // mux out
    ,.multi_v_o(mux_v_o)
    ,.multi_data_o(mux_data_o)
    ,.multi_yumi_i(mux_yumi_i));

  assign mux_v_i    = fsb_node_v_i;
  assign mux_data_i = bsg_fsb_pkt_client_data_t ' (fsb_node_data_i);
  assign fsb_node_yumi_o = mux_yumi_o;

  assign fsb_node_v_o           = mux_v_o;
  assign fsb_node_data_o.destid = (4) ' (dest_id_p);
  assign fsb_node_data_o.cmd    = 1'b0;
  assign fsb_node_data_o.data   = mux_data_o;
  assign mux_yumi_i = fsb_node_yumi_i;

endmodule
