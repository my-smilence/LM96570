`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/23 18:23:16
// Design Name: 
// Module Name: sim_top
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

`define clock_period 20
module sim_top(

    );
 reg sys_clk;            //system clock 50Mhz on board
 reg  rst_n;             //reset ,low active

 wire hv_in1_p;
 wire hv_in1_n;
 wire hv_in2_p;
 wire hv_in2_n;
 wire hv_in3_p;
 wire hv_in3_n;
 wire hv_in4_p;
 wire hv_in4_n;
 wire hv_in5_p;
 wire hv_in5_n;
 wire hv_in6_p;
 wire hv_in6_n;
 wire hv_in7_p;
 wire hv_in7_n;
 wire hv_in8_p;
 wire hv_in8_n;
  
 wire hv_thsd; 
 wire hv_cw;
 wire hv_ck_100m;

 /////////////////////PLL IP call////////////////////////////
clk_wiz_0 clk_wiz_0_inst
   (// Clock in ports
    .clk_in(sys_clk),            // IN 50Mhz
    // Clock out ports
    .clk_out1(),                // OUT 25Mhz
    .clk_out2(hv_ck_100m),               // OUT 100Mhz
    .clk_out3(),                // OUT 200Mhz
    .clk_out4(),    // OUT100Mhz	 
    // Status and control signals	 
    .reset(~rst_n),        // RESET IN
    .locked(locked));     // OUT

 pluse_send   u1_pluse_send(
.clk(hv_ck_100m),            //PLL_clock 100Mhz 
.rst_n(rst_n),           //reset ,low active
.start(1'b1),
//sthv800;       hv_inx:x为通道号，共计8通道;
.hv_in1_p(hv_in1_p),
.hv_in1_n(hv_in1_n),
.hv_in2_p(hv_in2_p),
.hv_in2_n(hv_in2_n),
.hv_in3_p(hv_in3_p),
.hv_in3_n(hv_in3_n),
.hv_in4_p(hv_in4_p),
.hv_in4_n(hv_in4_n),
.hv_in5_p(hv_in5_p),
.hv_in5_n(hv_in5_n),
.hv_in6_p(hv_in6_p),
.hv_in6_n(hv_in6_n),
.hv_in7_p(hv_in7_p),
.hv_in7_n(hv_in7_n),
.hv_in8_p(hv_in8_p),
.hv_in8_n(hv_in8_n),
  
.hv_thsd(hv_thsd),  //温度报警停机，低电有效，一般置高位
.hv_cw(hv_cw),    //cw连续波控制，高位有效
.pluse_done(pluse_done)  //单次发射完成
//  input SYNC_PULSE    //启动信号，可接按键
//  iutput PLUSE_DONE   //finish信号
    );

initial sys_clk=1;
 always#(`clock_period/2) sys_clk=~sys_clk;

 
 initial begin
 rst_n=0;
 
 #(`clock_period*20);
 rst_n=1;
 #(`clock_period*2000000);
 $stop;
 
 end
    
    
    
    
endmodule
