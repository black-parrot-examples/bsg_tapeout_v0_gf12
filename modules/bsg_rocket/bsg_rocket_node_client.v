`include "bsg_fsb_pkg.v"

module bsg_rocket_node_client
  import bsg_fsb_pkg::*;
# (parameter dest_id_p = 0)
  (input                       clk_i
  ,input                       reset_i
  ,input                       en_i
  // in
  ,input                       v_i
  ,input  bsg_fsb_pkt_client_s data_i
  ,output                      ready_o
  // out
  ,output                      v_o
  ,output bsg_fsb_pkt_client_s data_o
  ,input                       yumi_i);

  wire                 fifo_v;
  bsg_fsb_pkt_client_s fifo_data;
  wire                 fifo_yumi;

  bsg_two_fifo #
    (.width_p($bits(bsg_fsb_pkt_client_s)))
  fifo
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    // in valid/ready
    ,.v_i(v_i)
    ,.data_i(data_i)
    ,.ready_o(ready_o)
    // out valid/yumi
    ,.v_o(fifo_v)
    ,.data_o(fifo_data)
    ,.yumi_i(fifo_yumi));

  bsg_rocket_to_fsb #
    (.dest_id_p(dest_id_p))
  r2f
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    // fsb in
    ,.fsb_node_v_i(fifo_v)
    ,.fsb_node_data_i(fifo_data)
    ,.fsb_node_yumi_o(fifo_yumi)
    // fsb out
    ,.fsb_node_v_o(v_o)
    ,.fsb_node_data_o(data_o)
    ,.fsb_node_yumi_i(yumi_i));

endmodule
