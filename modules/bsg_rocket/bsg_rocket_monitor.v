`include "bsg_rocket_pkg.vh"

module bsg_rocket_monitor
  import bsg_nasti_pkg::*;
  (input                 clk_i
  ,input                 reset_i
  // client host a
  ,input                 client_host_out_valid
  ,input      bsg_host_t client_host_out_data
  ,input                 client_host_out_ready
  // client host b
  ,input                 client_host_in_valid
  ,input      bsg_host_t client_host_in_data
  ,input                 client_host_in_ready
  // client aw
  ,input                 client_nasti_aw_valid
  ,input bsg_nasti_a_pkt client_nasti_aw_data
  ,input                 client_nasti_aw_ready
  // client w
  ,input                 client_nasti_w_valid
  ,input bsg_nasti_w_pkt client_nasti_w_data
  ,input                 client_nasti_w_ready
  // client b (write-ack only in client)
  ,input                 client_nasti_b_valid
  ,input bsg_nasti_b_pkt client_nasti_b_data
  ,input                 client_nasti_b_ready
  // client ar
  ,input                 client_nasti_ar_valid
  ,input bsg_nasti_a_pkt client_nasti_ar_data
  ,input                 client_nasti_ar_ready
  // client r
  ,input                 client_nasti_r_valid
  ,input bsg_nasti_r_pkt client_nasti_r_data
  ,input                 client_nasti_r_ready
  // master host a
  ,input                 master_host_out_valid
  ,input      bsg_host_t master_host_out_data
  ,input                 master_host_out_ready
  // master host b
  ,input                 master_host_in_valid
  ,input      bsg_host_t master_host_in_data
  ,input                 master_host_in_ready
  // master aw
  ,input                 master_nasti_aw_valid
  ,input bsg_nasti_a_pkt master_nasti_aw_data
  ,input                 master_nasti_aw_ready
  // master w
  ,input                 master_nasti_w_valid
  ,input bsg_nasti_w_pkt master_nasti_w_data
  ,input                 master_nasti_w_ready
  // master b (write-ack only in client)
  ,input                 master_nasti_b_valid
  ,input bsg_nasti_b_pkt master_nasti_b_data
  ,input                 master_nasti_b_ready
  // master ar
  ,input                 master_nasti_ar_valid
  ,input bsg_nasti_a_pkt master_nasti_ar_data
  ,input                 master_nasti_ar_ready
  // master r
  ,input                 master_nasti_r_valid
  ,input bsg_nasti_r_pkt master_nasti_r_data
  ,input                 master_nasti_r_ready);

  always @(posedge clk_i)
    if (~reset_i & client_nasti_ar_valid & client_nasti_ar_ready) begin
      $fwrite(32'h80000002,"CLIENT_AR = id:%b\n"    , client_nasti_ar_data.id);
      $fwrite(32'h80000002,"CLIENT_AR = addr:%b\n"  , client_nasti_ar_data.addr);
      $fwrite(32'h80000002,"CLIENT_AR = len:%b\n"   , client_nasti_ar_data.len);
      $fwrite(32'h80000002,"CLIENT_AR = size:%b\n"  , client_nasti_ar_data.size);
      $fwrite(32'h80000002,"CLIENT_AR = burst:%b\n" , client_nasti_ar_data.burst);
      $fwrite(32'h80000002,"CLIENT_AR = lock:%b\n"  , client_nasti_ar_data.lock);
      $fwrite(32'h80000002,"CLIENT_AR = cache:%b\n" , client_nasti_ar_data.cache);
      $fwrite(32'h80000002,"CLIENT_AR = prot:%b\n"  , client_nasti_ar_data.prot);
      $fwrite(32'h80000002,"CLIENT_AR = qos:%b\n"   , client_nasti_ar_data.qos);
      $fwrite(32'h80000002,"CLIENT_AR = region:%b\n", client_nasti_ar_data.region);
    end

  always @(posedge clk_i)
    if (~reset_i & master_nasti_ar_valid & master_nasti_ar_ready) begin
      $fwrite(32'h80000002,"MASTER_AR = id:%b\n"    , master_nasti_ar_data.id);
      $fwrite(32'h80000002,"MASTER_AR = addr:%b\n"  , master_nasti_ar_data.addr);
      $fwrite(32'h80000002,"MASTER_AR = len:%b\n"   , master_nasti_ar_data.len);
      $fwrite(32'h80000002,"MASTER_AR = size:%b\n"  , master_nasti_ar_data.size);
      $fwrite(32'h80000002,"MASTER_AR = burst:%b\n" , master_nasti_ar_data.burst);
      $fwrite(32'h80000002,"MASTER_AR = lock:%b\n"  , master_nasti_ar_data.lock);
      $fwrite(32'h80000002,"MASTER_AR = cache:%b\n" , master_nasti_ar_data.cache);
      $fwrite(32'h80000002,"MASTER_AR = prot:%b\n"  , master_nasti_ar_data.prot);
      $fwrite(32'h80000002,"MASTER_AR = qos:%b\n"   , master_nasti_ar_data.qos);
      $fwrite(32'h80000002,"MASTER_AR = region:%b\n", master_nasti_ar_data.region);
    end

  always @(posedge clk_i)
    if (~reset_i & client_nasti_aw_valid & client_nasti_aw_ready) begin
      $fwrite(32'h80000002,"CLIENT_AW = id:%b\n"    , client_nasti_aw_data.id);
      $fwrite(32'h80000002,"CLIENT_AW = addr:%b\n"  , client_nasti_aw_data.addr);
      $fwrite(32'h80000002,"CLIENT_AW = len:%b\n"   , client_nasti_aw_data.len);
      $fwrite(32'h80000002,"CLIENT_AW = size:%b\n"  , client_nasti_aw_data.size);
      $fwrite(32'h80000002,"CLIENT_AW = burst:%b\n" , client_nasti_aw_data.burst);
      $fwrite(32'h80000002,"CLIENT_AW = lock:%b\n"  , client_nasti_aw_data.lock);
      $fwrite(32'h80000002,"CLIENT_AW = cache:%b\n" , client_nasti_aw_data.cache);
      $fwrite(32'h80000002,"CLIENT_AW = prot:%b\n"  , client_nasti_aw_data.prot);
      $fwrite(32'h80000002,"CLIENT_AW = qos:%b\n"   , client_nasti_aw_data.qos);
      $fwrite(32'h80000002,"CLIENT_AW = region:%b\n", client_nasti_aw_data.region);
    end

  always @(posedge clk_i)
    if (~reset_i & master_nasti_aw_valid & master_nasti_aw_ready) begin
      $fwrite(32'h80000002,"MASTER_AW = id:%b\n"    , master_nasti_aw_data.id);
      $fwrite(32'h80000002,"MASTER_AW = addr:%b\n"  , master_nasti_aw_data.addr);
      $fwrite(32'h80000002,"MASTER_AW = len:%b\n"   , master_nasti_aw_data.len);
      $fwrite(32'h80000002,"MASTER_AW = size:%b\n"  , master_nasti_aw_data.size);
      $fwrite(32'h80000002,"MASTER_AW = burst:%b\n" , master_nasti_aw_data.burst);
      $fwrite(32'h80000002,"MASTER_AW = lock:%b\n"  , master_nasti_aw_data.lock);
      $fwrite(32'h80000002,"MASTER_AW = cache:%b\n" , master_nasti_aw_data.cache);
      $fwrite(32'h80000002,"MASTER_AW = prot:%b\n"  , master_nasti_aw_data.prot);
      $fwrite(32'h80000002,"MASTER_AW = qos:%b\n"   , master_nasti_aw_data.qos);
      $fwrite(32'h80000002,"MASTER_AW = region:%b\n", master_nasti_aw_data.region);
    end

  always @(posedge clk_i)
    if (~reset_i & client_nasti_w_valid & client_nasti_w_ready) begin
      $fwrite(32'h80000002,"CLIENT_W = data:%b\n", client_nasti_w_data.data);
      $fwrite(32'h80000002,"CLIENT_W = last:%b\n", client_nasti_w_data.last);
      $fwrite(32'h80000002,"CLIENT_W = strb:%b\n", client_nasti_w_data.strb);
    end

  always @(posedge clk_i)
    if (~reset_i & master_nasti_w_valid & master_nasti_w_ready) begin
      $fwrite(32'h80000002,"MASTER_W = data:%b\n", master_nasti_w_data.data);
      $fwrite(32'h80000002,"MASTER_W = last:%b\n", master_nasti_w_data.last);
      $fwrite(32'h80000002,"MASTER_W = strb:%b\n", master_nasti_w_data.strb);
    end

  always @(posedge clk_i)
    if (~reset_i & client_nasti_b_valid & client_nasti_b_ready) begin
      $fwrite(32'h80000002,"CLIENT_B = resp:%b\n", client_nasti_b_data.resp);
      $fwrite(32'h80000002,"CLIENT_B = id:%b\n", client_nasti_b_data.id);
    end

  always @(posedge clk_i)
    if (~reset_i & client_nasti_r_valid & client_nasti_r_ready) begin
      $fwrite(32'h80000002,"CLIENT_R = resp:%b\n", client_nasti_r_data.resp);
      $fwrite(32'h80000002,"CLIENT_R = data:%b\n", client_nasti_r_data.data);
      $fwrite(32'h80000002,"CLIENT_R = last:%b\n", client_nasti_r_data.last);
      $fwrite(32'h80000002,"CLIENT_R = id:%b\n"  , client_nasti_r_data.id);
    end

  always @(posedge clk_i)
    if (~reset_i & master_nasti_r_valid & master_nasti_r_ready) begin
      $fwrite(32'h80000002,"MASTER_R = resp:%b\n", master_nasti_r_data.resp);
      $fwrite(32'h80000002,"MASTER_R = data:%b\n", master_nasti_r_data.data);
      $fwrite(32'h80000002,"MASTER_R = last:%b\n", master_nasti_r_data.last);
      $fwrite(32'h80000002,"MASTER_R = id:%b\n"  , master_nasti_r_data.id);
    end

  always @(posedge clk_i)
    if (~reset_i & client_host_out_valid & client_host_out_ready)
      $fwrite(32'h80000002,"CLIENT_HOST_OUT = %b\n", client_host_out_data);

  always @(posedge clk_i)
    if (~reset_i & master_host_out_valid & master_host_out_ready)
      $fwrite(32'h80000002,"MASTER_HOST_OUT = %b\n", master_host_out_data);

  always @(posedge clk_i)
    if (~reset_i & client_host_in_valid & client_host_in_ready)
      $fwrite(32'h80000002,"CLIENT_HOST_IN = %b\n", client_host_in_data);

  always @(posedge clk_i)
    if (~reset_i & master_host_in_valid & master_host_in_ready)
      $fwrite(32'h80000002,"MASTER_HOST_IN = %b\n", master_host_in_data);

endmodule
