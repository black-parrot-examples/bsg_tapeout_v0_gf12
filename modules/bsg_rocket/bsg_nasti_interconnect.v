`include "bsg_rocket_pkg.vh"

module bsg_nasti_interconnect
  import bsg_nasti_pkg::*;
  (input                     clk_i
  ,input                     reset_i
  // ar in
  ,input                     client_nasti_ar_valid_i
  ,input    bsg_nasti_a_pkt client_nasti_ar_data_i
  ,output                    client_nasti_ar_ready_o
  // aw in
  ,input                     client_nasti_aw_valid_i
  ,input    bsg_nasti_a_pkt client_nasti_aw_data_i
  ,output                    client_nasti_aw_ready_o
  // w in
  ,input                     client_nasti_w_valid_i
  ,input   bsg_nasti_w_pkt client_nasti_w_data_i
  ,output                    client_nasti_w_ready_o
  // b out
  ,output                    client_nasti_b_valid_o
  ,output bsg_nasti_b_pkt client_nasti_b_data_o
  ,input                     client_nasti_b_ready_i
  // r out
  ,output                    client_nasti_r_valid_o
  ,output   bsg_nasti_r_pkt client_nasti_r_data_o
  ,input                     client_nasti_r_ready_i
  // ar out
  ,output                    master_nasti_ar_valid_o
  ,output   bsg_nasti_a_pkt master_nasti_ar_data_o
  ,input                     master_nasti_ar_ready_i
  // aw out
  ,output                    master_nasti_aw_valid_o
  ,output   bsg_nasti_a_pkt master_nasti_aw_data_o
  ,input                     master_nasti_aw_ready_i
  // w out
  ,output                    master_nasti_w_valid_o
  ,output  bsg_nasti_w_pkt master_nasti_w_data_o
  ,input                     master_nasti_w_ready_i
  // b in
  ,input                     master_nasti_b_valid_i
  ,input  bsg_nasti_b_pkt master_nasti_b_data_i
  ,output                    master_nasti_b_ready_o
  // r in
  ,input                     master_nasti_r_valid_i
  ,input    bsg_nasti_r_pkt master_nasti_r_data_i
  ,output                    master_nasti_r_ready_o);

  wire        resp_valid;
  wire [70:0] resp_data;
  wire        resp_yumi;

  wire        req_valid;
  wire [70:0] req_data;
  wire        req_yumi;

  bsg_nasti_client client
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    // ar in
    ,.nasti_ar_valid_i(client_nasti_ar_valid_i)
    ,.nasti_ar_data_i(client_nasti_ar_data_i)
    ,.nasti_ar_ready_o(client_nasti_ar_ready_o)
    // aw in
    ,.nasti_aw_valid_i(client_nasti_aw_valid_i)
    ,.nasti_aw_data_i(client_nasti_aw_data_i)
    ,.nasti_aw_ready_o(client_nasti_aw_ready_o)
    // w in
    ,.nasti_w_valid_i(client_nasti_w_valid_i)
    ,.nasti_w_data_i(client_nasti_w_data_i)
    ,.nasti_w_ready_o(client_nasti_w_ready_o)
    // b out
    ,.nasti_b_valid_o(client_nasti_b_valid_o)
    ,.nasti_b_data_o(client_nasti_b_data_o)
    ,.nasti_b_ready_i(client_nasti_b_ready_i)
    // r out
    ,.nasti_r_valid_o(client_nasti_r_valid_o)
    ,.nasti_r_data_o(client_nasti_r_data_o)
    ,.nasti_r_ready_i(client_nasti_r_ready_i)
    // resp in
    ,.resp_valid_i(resp_valid)
    ,.resp_data_i(resp_data)
    ,.resp_yumi_o(resp_yumi)
    // req out
    ,.req_valid_o(req_valid)
    ,.req_data_o(req_data)
    ,.req_yumi_i(req_yumi));

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
    // ar out
    ,.nasti_ar_valid_o(master_nasti_ar_valid_o)
    ,.nasti_ar_data_o(master_nasti_ar_data_o)
    ,.nasti_ar_ready_i(master_nasti_ar_ready_i)
    // aw out
    ,.nasti_aw_valid_o(master_nasti_aw_valid_o)
    ,.nasti_aw_data_o(master_nasti_aw_data_o)
    ,.nasti_aw_ready_i(master_nasti_aw_ready_i)
    // w out
    ,.nasti_w_valid_o(master_nasti_w_valid_o)
    ,.nasti_w_data_o(master_nasti_w_data_o)
    ,.nasti_w_ready_i(master_nasti_w_ready_i)
    // b in
    ,.nasti_b_valid_i(master_nasti_b_valid_i)
    ,.nasti_b_data_i(master_nasti_b_data_i)
    ,.nasti_b_ready_o(master_nasti_b_ready_o)
    // r in
    ,.nasti_r_valid_i(master_nasti_r_valid_i)
    ,.nasti_r_data_i(master_nasti_r_data_i)
    ,.nasti_r_ready_o(master_nasti_r_ready_o));

endmodule
