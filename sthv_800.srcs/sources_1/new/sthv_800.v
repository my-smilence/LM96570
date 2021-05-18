`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yyx
// 
// Create Date: 2021/03/25 10:04:44
// Design Name: 
// Module Name: pluse_send
// Project Name: sthv_800
// Target Devices: 
// Tool Versions: vivado2018.3
// Description: 
// 
// Dependencies: sthv_800脉冲发射测试
// 
//================================================================================
//  Revision History:
 //  Date          By            Revision    Change Description
//--------------------------------------------------------------------------------
//  2021/03/25     yyx          1.0         Original
//*******************************************************************************/
// 
//////////////////////////////////////////////////////////////////////////////////

module sthv_800(
 input sys_clk, //系统时钟50M
 input  rst_n,//复位低电有效

  output wire hv_in1_p,
  output wire hv_in1_n,
  output wire hv_in2_p,
  output wire hv_in2_n,
  output wire hv_in3_p,
  output wire hv_in3_n,
  output wire hv_in4_p,
  output wire hv_in4_n,
  output wire hv_in5_p,
  output wire hv_in5_n,
  output wire hv_in6_p,
  output wire hv_in6_n,
  output wire hv_in7_p,
  output wire hv_in7_n,
  output wire hv_in8_p,
  output wire hv_in8_n,
  
 // output wire hv_thsd  //温度报警停机，低电有效，一般置高位
  output wire hv_cw,  //cw连续波控制，高位有效
  output wire hv_ck_100m   //sthv_800 系统时钟，min:25Mhz ,type:100M ,max :200M
    );


//assign ck_100m =1'b0;
 pluse_send   u1_pluse_send
 (
.clk(hv_ck_100m),            //PLL_clock 100Mhz 
.rst_n(rst_n),           //reset ,low active
//sthv800;       hv_inx:x为通道号，共计8通道;
.start(1'b1),
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
  
.hv_thsd(hv_thsd),    //温度报警停机，低电有效，一般置高位
.hv_cw(hv_cw),       //cw连续波控制，高位有效
.pluse_done(pluse_done)  //单次发射完成
//  input SYNC_PULSE    //启动信号，可接按键
//  iutput PLUSE_DONE   //finish信号
    );
    
/////////////////////PLL IP and clock input////////////////////////////
clk_wiz_0 clk_wiz_0_inst
   (// Clock in ports
    .clk_in(sys_clk),            // IN 50Mhz
    // Clock out ports
    .clk_out1(),       // OUT 200Mhz
    .clk_out2(hv_ck_100m),       // OUT 100Mhz
    .clk_out3(),                 // OUT 25Mhz
    .clk_out4(),                 // OUT10Mhz	 
    // Status and control signals	 
    .reset(~rst_n),        // RESET IN
    .locked(locked));      // OUT

endmodule
