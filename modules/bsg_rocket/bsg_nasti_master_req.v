`include "bsg_rocket_pkg.vh"

module bsg_nasti_master_req
  import bsg_nasti_pkg::*;
  (input                  clk_i
  ,input                  reset_i
  // aw
  ,output                 nasti_aw_valid_o
  ,output bsg_nasti_a_pkt nasti_aw_data_o
  ,input                  nasti_aw_ready_i
  // w
  ,output                 nasti_w_valid_o
  ,output bsg_nasti_w_pkt nasti_w_data_o
  ,input                  nasti_w_ready_i
  // b
  ,input                  nasti_b_valid_i
  ,input  bsg_nasti_b_pkt nasti_b_data_i
  ,output                 nasti_b_ready_o
  // ar
  ,output                 nasti_ar_valid_o
  ,output bsg_nasti_a_pkt nasti_ar_data_o
  ,input                  nasti_ar_ready_i
  // req in
  ,input                  req_valid_i
  ,input    bsg_tun_dmx_t req_data_i
  ,output                 req_yumi_o);

  enum logic [4:0] {IDLE  = 5'b00001
                   ,RADDR = 5'b00010
                   ,WADDR = 5'b00100
                   ,WDATA = 5'b01000
                   ,WIDLE = 5'b10000} state_n, state_r;

  bsg_nasti_w_pkt nasti_w_data_r;

  // fsm
  always_ff @(posedge clk_i)
    if (reset_i)
      state_r <= IDLE;
    else
      state_r <= state_n;

  bsg_nasti_sa_pkt req_a_n;

  assign req_a_n = bsg_nasti_sa_pkt ' (req_data_i);

  wire aw_fire = req_valid_i & req_a_n.rw;
  wire ar_fire = req_valid_i & (~req_a_n.rw);

  always_comb begin

    state_n = state_r;

    unique case (state_r)

      IDLE:
        if (aw_fire)
          state_n = WADDR;
        else if (ar_fire)
          state_n = RADDR;

      RADDR:
        if (nasti_ar_ready_i)
          state_n = IDLE;

      WADDR:
        if (nasti_aw_ready_i)
          state_n = WDATA;

      WDATA:
        if (req_valid_i)
          state_n = WIDLE;

      WIDLE:
        if (nasti_w_data_r.last & nasti_w_ready_i)
          state_n = IDLE;
        else if (nasti_w_ready_i)
          state_n = WDATA;

      default:
        state_n = IDLE;

    endcase

  end

  // req
  assign req_yumi_o = ( state_r == IDLE || state_r == WDATA)? req_valid_i : 1'b0;

  // ar
  bsg_nasti_a_pkt nasti_ar_data_r;

  always_ff @(posedge clk_i)
    if (state_r == IDLE & ar_fire) begin
      nasti_ar_data_r.addr <= req_a_n.addr;
      nasti_ar_data_r.id <= req_a_n.id;
    end

  assign nasti_ar_data_r.len = 8'd7;
  assign nasti_ar_data_r.size = 3'd3;
  assign nasti_ar_data_r.burst = 2'd1;
  assign nasti_ar_data_r.lock = 1'b0;
  assign nasti_ar_data_r.cache = 4'd3;
  assign nasti_ar_data_r.prot = 3'd0;
  assign nasti_ar_data_r.qos = 4'd0;
  assign nasti_ar_data_r.region = 4'd0;

  assign nasti_ar_valid_o = (state_r == RADDR)? 1'b1 : 1'b0;
  assign nasti_ar_data_o = nasti_ar_data_r;

  // aw
  bsg_nasti_a_pkt nasti_aw_data_r;

  always_ff @(posedge clk_i)
    if (state_r == IDLE & aw_fire) begin
      nasti_aw_data_r.addr <= req_a_n.addr;
      nasti_aw_data_r.id <= req_a_n.id;
    end

  assign nasti_aw_data_r.len = 8'd7;
  assign nasti_aw_data_r.size = 3'd3;
  assign nasti_aw_data_r.burst = 2'd1;
  assign nasti_aw_data_r.lock = 1'b0;
  assign nasti_aw_data_r.cache = 4'd3;
  assign nasti_aw_data_r.prot = 3'd0;
  assign nasti_aw_data_r.qos = 4'd0;
  assign nasti_aw_data_r.region = 4'd0;

  assign nasti_aw_valid_o = (state_r == WADDR)? 1'b1 : 1'b0;
  assign nasti_aw_data_o = nasti_aw_data_r;

  // w

  bsg_nasti_sw_pkt req_w_n;

  assign req_w_n = bsg_nasti_sw_pkt ' (req_data_i);

  always_ff @(posedge clk_i)
    if (state_r == WDATA & req_valid_i) begin
      nasti_w_data_r.last <= req_w_n.last;
      nasti_w_data_r.data <= req_w_n.data;
    end

  assign nasti_w_data_r.strb = 8'd255;

  assign nasti_w_valid_o = (state_r == WIDLE)? 1'b1 : 1'b0;
  assign nasti_w_data_o = nasti_w_data_r;

  // b - always acknowledge response
  assign nasti_b_ready_o = 1'b1;

endmodule
