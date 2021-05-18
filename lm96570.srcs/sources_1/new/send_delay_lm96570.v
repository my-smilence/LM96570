`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/28 16:51:07
// Design Name: 
// Module Name: send_delay_lm96570
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module send_delay_lm96570(

input wire sys_clk,  //系统时钟50Mhz
input wire rst_n,    //复位信号，低电有效
input wire lm_read,    //SRD,读取总线 

output wire TX_en,     //发射使能，高电平期间发射寄存器脉冲编码
output wire sclk,     //写入寄存时钟 max：80Mhz
output wire sle_n,     //低电有效使能，写入时首先拉低   
output wire lm_rst_n,    
output wire lm_write,   //SWR,写入总线
output wire [2:0]led,

output wire pll_clk_p,
output wire pll_clk_n

    );
assign lm_rst_n = ~rst_n;
////////////////////////////////////lm96570例化///////////////////////////////////////////////////////////    
    LM96570 u1_LM96570(
    
    .sclk(sclk),
    .reset_N(rst_n),
    .sRD(),
    .sLE(sle_n),
    .sWR(lm_write),
    .TX_EN(TX_en),
    .ACK(ACK),
    .led(led)
    
    );
    
/////////////////////PLL IP and clock input////////////////////////////
clk_wiz_0 clk_wiz_0_inst
   (// Clock in ports
    .clk_in1(sys_clk),            // IN 50Mhz
    // Clock out ports
    .clk_out1(),                // OUT 80Mhz
    .clk_out2(sclk),                // OUT 40Mhz
    // Status and control signals	 
    .reset(~rst_n),        // RESET IN
    .locked(locked));      // OUT
 
/* 
wire user_clk_bufg_oddr;
ODDR #(
      .DDR_CLK_EDGE("OPPOSITE_EDGE"), //"OPPOSITE_EDGE" or "SAME_EDGE"
      .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC"
 ) ODDR_out_clock_inst_user_clock (
     .Q(user_clk_bufg_oddr),   // 1-bit DDR output
     .C(sclk),   // 1-bit clock input
     .CE(1'b1), // 1-bit clock enable input
     .D1(1'b1), // 1-bit data input (positive edge)
     .D2(1'b0), // 1-bit data input (negative edge)
     .R(),   // 1-bit reset
     .S()    // 1-bit set
);*/

    
///////////////////////////差分时钟输出/////////////////////////////////////////
  OBUFDS #(
      .IOSTANDARD("BLVDS_25"), // Specify the output I/O standard
      .SLEW("SLOW")           // Specify the output slew rate
   ) OBUFDS_inst (
      .O(pll_clk_p),     // Diff_p output (connect directly to top-level port)
      .OB(pll_clk_n),   // Diff_n output (connect directly to top-level port)
      .I(sclk)      // Buffer input
   );

    
    
    
endmodule
