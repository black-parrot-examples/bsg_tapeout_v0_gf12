// MBT 8/3/2016
//

// **************************************************************
// *
// * pull in macros that define I/Os
// * see bsg_packaging
// *

`include "bsg_iopad_macros.v"


module bsg_frame

// **************************************************************
// *
// * pull in top-level module signature, corresponding to pinout
// * also defines the I/O pads
// *

`include "bsg_pinout.v"

// ***********************************
// *
// * pack bsg_comm_link into structs
// *
// *

`include "bsg_comm_link.vh"

`declare_bsg_comm_link_channel_in_s (8);
`declare_bsg_comm_link_channel_out_s(8);

   bsg_comm_link_channel_in_s  [3:0] ch_li;
   bsg_comm_link_channel_out_s [3:0] ch_lo;

`define BSG_SWIZZLE_3120(a) { a[3],a[1],a[2],a[0] }
`define BSG_NO_SWIZZLE_3210(name,field) { name[3].field, name[2].field, name[1].field, name[0].field }

   // swizzle input channels for physical design reasons; swapping B and C channels
   assign `BSG_NO_SWIZZLE_3210(ch_li,io_clk_tline)   = `BSG_SWIZZLE_3120(sdi_sclk_i_int);
   assign `BSG_NO_SWIZZLE_3210(ch_li,io_valid_tline) = `BSG_SWIZZLE_3120(sdi_ncmd_i_int);
   assign `BSG_NO_SWIZZLE_3210(ch_li,io_data_tline)  = { sdi_D_data_i_int, sdi_B_data_i_int, sdi_C_data_i_int, sdi_A_data_i_int };
   assign `BSG_SWIZZLE_3120(sdi_token_o_int)         = `BSG_NO_SWIZZLE_3210(ch_lo,io_token_clk_tline);

   // no swizzle of output channels
   genvar i;

   for (i = 0; i < 4; i=i+1)
     begin: rof
        assign sdo_ncmd_o_int [i]                 = ch_lo[i].im_valid_tline;
        assign sdo_clk_o_int  [i]                 = ch_lo[i].im_clk_tline;
        assign ch_li          [i].token_clk_tline = sdo_token_i_int[i];
     end

   assign {sdi_D_data_o_int, sdi_C_data_o_int, sdi_B_data_o_int, sdi_A_data_o_int } = `BSG_NO_SWIZZLE_3210(ch_lo,im_data_tline);

// ***********************************
// *
// * instantiate body of chip
// *
// *

   bsg_frame_core      #(.uniqueness_p(1)
                        ) bcc
     (.core_clk_i            (misc_L_i_int[3])
      ,.async_reset_i        (reset_i_int    )
      ,.io_master_clk_i      (PLL_CLK_i_int  )

      ,.bsg_comm_link_i      (ch_li)
      ,.bsg_comm_link_o      (ch_lo)

      ,.im_slave_reset_tline_r_o()             // unused by ASIC
      ,.core_reset_o            ()             // post calibration reset
      );

`include "bsg_pinout_end.v"
