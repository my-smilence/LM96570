`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/14 09:48:23
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
reg sys_clk;  //系统时钟50Mhz
reg rst_n;    //复位信号，低电有效
reg lm_read;    //SRD,读取总线 

 wire TX_en;     //发射使能，高电平期间发射寄存器脉冲编码
 wire sclk;     //写入寄存时钟 max：80Mhz
 wire sle_n;     //低电有效使能，写入时首先拉低   
 wire lm_rst_n;    
 wire lm_write;   //SWR,写入总线
 wire [2:0]led;

 wire pll_clk_p;
 wire pll_clk_n;
 assign lm_rst_n = rst_n;   
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
    
///////////////////////////差分时钟输出/////////////////////////////////////////
OBUFDS inst(

     .O (pll_clk_p),
     .OB (pll_clk_n),
     .I (sclk)

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
