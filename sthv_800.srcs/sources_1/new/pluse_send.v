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
`define q1_send_cnt 1       //发射延迟,计数周期  （q1_send_delay+1）dt=延时时间
`define q2_send_cnt 1 
`define q3_send_cnt 1 
`define q4_send_cnt 1 
`define q5_send_cnt 1 
`define q6_send_cnt 1 
`define q7_send_cnt 1 
`define q8_send_cnt 1 

`define q1_duty_ratios_hvm 9       //占空比 计数周期 (q1_duty_ratios_hvm+1)*dt=占空比时间
`define q1_duty_ratios_hvp 9       //注意信号频率min:1M;   max:20M
`define q2_duty_ratios_hvm 9       
`define q2_duty_ratios_hvp 9
`define q3_duty_ratios_hvm 9       
`define q3_duty_ratios_hvp 9
`define q4_duty_ratios_hvm 9       
`define q4_duty_ratios_hvp 9
`define q5_duty_ratios_hvm 9       
`define q5_duty_ratios_hvp 9
`define q6_duty_ratios_hvm 9       
`define q6_duty_ratios_hvp 9
`define q7_duty_ratios_hvm 9       
`define q7_duty_ratios_hvp 9
`define q8_duty_ratios_hvm 9       
`define q8_duty_ratios_hvp 9

`define pluse_cnt 4         //脉冲计数  pluse_cnt
`define pluse_cyc 10_000    //脉冲周期
module pluse_send
(
input      clk,            //PLL_clock 100Mhz 
input      rst_n,           //reset ,low active
input      start,
//sthv800;       hv_inx:x为通道号，共计8通道;
  output reg hv_in1_p,
  output reg hv_in1_n,
  output reg hv_in2_p,
  output reg hv_in2_n,
  output reg hv_in3_p,
  output reg hv_in3_n,
  output reg hv_in4_p,
  output reg hv_in4_n,
  output reg hv_in5_p,
  output reg hv_in5_n,
  output reg hv_in6_p,
  output reg hv_in6_n,
  output reg hv_in7_p,
  output reg hv_in7_n,
  output reg hv_in8_p,
  output reg hv_in8_n,
  
  output reg hv_thsd,  //温度报警停机，低电有效，一般置高位
  output reg hv_cw,     //cw连续波控制，高位有效
  output reg pluse_done //发射结束同步信号
//  input SYNC_PULSE    //启动信号，可接按键
//  input PLUSE_DONE   //finish信号
    );
/////////////////////发射enable信号////////////////////////////   
/*reg[2:0]     send_start_reg;
reg  send_start_rise;
reg send_start;
always  @(posedge  sys_clk)
begin
    send_start_reg[0]   <=  SYNC_PULSE;
    send_start_reg[1]   <=  send_start_reg[0];
    send_start_reg[2]   <=  send_start_reg[1];
end

assign send_start_rise = ~send_start_reg[2] && send_start_reg[1];
always  @(posedge  sys_clk or negedge rst_n)
if(~rst_n)
send_start <= 1;b0;
else 
send_start <= send_start_rise;
/////////////////////发射结束finish信号//////////////////////////// 
reg[2:0] send_end_reg;
reg send_end_rise;
reg send_end;
always  @(posedge   sys_clk)
begin
    send_end_reg[0] <=  PLUSE_DONE;
    send_end_reg[1] <=  send_end_reg[0];
    send_end_reg[2] <=  send_end_reg[1];
end

assign send_end_rise = ~send_end_reg[2] && send_end_reg[1];
always  @(posedge  sys_clk or negedge rst_n)
if(~rst_n)
send_end <= 1;b0;
else 
send_end <= send_end_rise;
*/
//////////////////////////参数寄存配置//////////////////////////////
reg [3:0]Q1_state;
reg [3:0]Q2_state;
reg [3:0]Q3_state;
reg [3:0]Q4_state;
reg [3:0]Q5_state;
reg [3:0]Q6_state;
reg [3:0]Q7_state;
reg [3:0]Q8_state;  

reg [3:0] Q1_send_delay ;   //初始发射延时 
reg [3:0] Q2_send_delay ;
reg [3:0] Q3_send_delay ;
reg [3:0] Q4_send_delay ;
reg [3:0] Q5_send_delay ;
reg [3:0] Q6_send_delay ;
reg [3:0] Q7_send_delay ;
reg [3:0] Q8_send_delay ;

reg [3:0] Q1_duty_delay;   //状态跳转计数,占空比
reg [3:0] Q2_duty_delay;
reg [3:0] Q3_duty_delay;
reg [3:0] Q4_duty_delay;
reg [3:0] Q5_duty_delay;
reg [3:0] Q6_duty_delay;
reg [3:0] Q7_duty_delay;
reg [3:0] Q8_duty_delay;

reg [3:0] Q1_tx_cnt ;    //发射计数，脉冲个数
reg [3:0] Q2_tx_cnt ; 
reg [3:0] Q3_tx_cnt ; 
reg [3:0] Q4_tx_cnt ; 
reg [3:0] Q5_tx_cnt ; 
reg [3:0] Q6_tx_cnt ; 
reg [3:0] Q7_tx_cnt ; 
reg [3:0] Q8_tx_cnt ; 

reg [7:0] Q1_wait_delay; //发射初始钳位 
reg [7:0] Q2_wait_delay;
reg [7:0] Q3_wait_delay;
reg [7:0] Q4_wait_delay;
reg [7:0] Q5_wait_delay;
reg [7:0] Q6_wait_delay;
reg [7:0] Q7_wait_delay;
reg [7:0] Q8_wait_delay;

reg [3:0] Q1_clamp_cnt; //钳位计数
reg [3:0] Q2_clamp_cnt;
reg [3:0] Q3_clamp_cnt;
reg [3:0] Q4_clamp_cnt;
reg [3:0] Q5_clamp_cnt;
reg [3:0] Q6_clamp_cnt;
reg [3:0] Q7_clamp_cnt;
reg [3:0] Q8_clamp_cnt;

reg [15:0]prf_wait_cnt;  //PRF重复发射计数时间
reg sysn_cnt;    //PRF重复发射计数通道时钟同步
 
//0-8通道状态   Qx为x通道,通道延时不同需分别配置
localparam  Q1_IDLE=4'd0;           //初始状态，等待启动信号
localparam  Q1_CLAMP=4'd1;          //钳位等待启动，2us
localparam  Q1_SEND_DELAY=4'd2;     //发射延时
localparam  Q1_hvm=4'd3;            //低电平
localparam  Q1_CLAMP_hvm=4'd4;      //低电平钳位
localparam  Q1_hvp=4'd5;            //高电平
localparam  Q1_CLAMP_hvp=4'd6;      //高电平钳位
localparam  Q1_WAIT=4'd7;           //脉冲周期延时
            
localparam  Q2_IDLE=4'd0;
localparam  Q2_CLAMP=4'd1;  
localparam  Q2_SEND_DELAY=4'd2; 
localparam  Q2_hvm=4'd3;
localparam  Q2_CLAMP_hvm=4'd4;
localparam  Q2_hvp=4'd5;
localparam  Q2_CLAMP_hvp=4'd6;
localparam  Q2_WAIT=4'd7;
      
localparam  Q3_IDLE=4'd0;
localparam  Q3_CLAMP=4'd1; 
localparam  Q3_SEND_DELAY=4'd2;
localparam  Q3_hvm=4'd3;
localparam  Q3_CLAMP_hvm=4'd4;
localparam  Q3_hvp=4'd5;
localparam  Q3_CLAMP_hvp=4'd6;
localparam  Q3_WAIT=4'd7;
    
localparam  Q4_IDLE=4'd0;
localparam  Q4_CLAMP=4'd1;
localparam  Q4_SEND_DELAY=4'd2;
localparam  Q4_hvm=4'd3;
localparam  Q4_CLAMP_hvm=4'd4;
localparam  Q4_hvp=4'd5;
localparam  Q4_CLAMP_hvp=4'd6;
localparam  Q4_WAIT=4'd7;

localparam  Q5_IDLE=4'd0;
localparam  Q5_CLAMP=4'd1;
localparam  Q5_SEND_DELAY=4'd2;
localparam  Q5_hvm=4'd3;
localparam  Q5_CLAMP_hvm=4'd4;
localparam  Q5_hvp=4'd5;
localparam  Q5_CLAMP_hvp=4'd6;
localparam  Q5_WAIT=4'd7;    
    
localparam  Q6_IDLE=4'd0;
localparam  Q6_CLAMP=4'd1;
localparam  Q6_SEND_DELAY=4'd2;
localparam  Q6_hvm=4'd3;
localparam  Q6_CLAMP_hvm=4'd4;
localparam  Q6_hvp=4'd5;
localparam  Q6_CLAMP_hvp=4'd6;
localparam  Q6_WAIT=4'd7;    
    
localparam  Q7_IDLE=4'd0;
localparam  Q7_CLAMP=4'd1;
localparam  Q7_SEND_DELAY=4'd2;
localparam  Q7_hvm=4'd3;
localparam  Q7_CLAMP_hvm=4'd4;
localparam  Q7_hvp=4'd5;
localparam  Q7_CLAMP_hvp=4'd6;
localparam  Q7_WAIT=4'd7;

localparam  Q8_IDLE=4'd0;
localparam  Q8_CLAMP=4'd1;
localparam  Q8_SEND_DELAY=4'd2;
localparam  Q8_hvm=4'd3;
localparam  Q8_CLAMP_hvm=4'd4;
localparam  Q8_hvp=4'd5;
localparam  Q8_CLAMP_hvp=4'd6;
localparam  Q8_WAIT=4'd7;




/////////////////////////////////通道状态///////////////////////////////////////////
//通道1  channel 1 for main control
always @(posedge clk or negedge rst_n)
if(~rst_n) begin
Q1_state <= Q1_IDLE;
Q1_clamp_cnt <= 4'd0;
Q1_send_delay <= 4'd0;
Q1_duty_delay <= 4'd0;
Q1_tx_cnt <= 4'd0;
Q1_wait_delay <=8 'd0;
prf_wait_cnt <= 16'd0;
pluse_done <= 1'b0;
sysn_cnt <= 1'b0;
end
else begin
case(Q1_state)

Q1_IDLE:begin
{hv_thsd, hv_cw,hv_in1_p,hv_in1_n} <= 4'b0000;
Q1_clamp_cnt <= 4'd0;
Q1_send_delay <= 4'd0;
Q1_duty_delay <= 4'd0;
Q1_wait_delay <= 8'd0;
Q1_tx_cnt <= 4'd0;
prf_wait_cnt <= 16'd0;
pluse_done <= 1'b0;
if(start == 1'b1)
Q1_state<= Q1_CLAMP;
else
Q1_state <= Q1_IDLE;
end

Q1_CLAMP:begin
{hv_thsd, hv_cw,hv_in1_p,hv_in1_n} <= 4'b1000;

if(Q1_wait_delay == 8'd200)begin
Q1_wait_delay <= 8'd0;
Q1_state <= Q1_SEND_DELAY;end
else begin
Q1_wait_delay <= Q1_wait_delay +1'b1;
Q1_state<= Q1_CLAMP;end
end

Q1_SEND_DELAY:begin     //发射延时并预启动
{hv_thsd, hv_cw,hv_in1_p,hv_in1_n} <= 4'b1000;

if(Q1_send_delay == `q1_send_cnt) begin
Q1_send_delay <= 4'd0;
Q1_state <= Q1_hvp;end
else begin
Q1_send_delay <= Q1_send_delay + 1'b1;
Q1_state <= Q1_SEND_DELAY;end
end


Q1_hvp:begin        //高电平
{hv_in1_p,hv_in1_n} <= 2'b01;

if(Q1_duty_delay == `q1_duty_ratios_hvp) begin
Q1_state <= Q1_CLAMP_hvp;
Q1_tx_cnt <= Q1_tx_cnt +1'b1;
Q1_duty_delay <= 4'd0;end   //if
else begin
Q1_duty_delay <= Q1_duty_delay + 1'b1;
Q1_state <= Q1_hvp;end  //else
end

Q1_CLAMP_hvp:begin
{hv_thsd, hv_cw,hv_in1_p,hv_in1_n} <= 4'b1000;

if(Q1_clamp_cnt == 4'd9) begin
Q1_state <= Q1_hvp;
Q1_clamp_cnt <= 4'd0;end    //if
else if(Q1_tx_cnt == `pluse_cnt) begin
Q1_state <= Q1_WAIT;
Q1_tx_cnt <= 4'd0;end   //else if
else begin
Q1_clamp_cnt <= Q1_clamp_cnt + 1'b1;
Q1_state <= Q1_CLAMP_hvp;
end  //else begin
end


/*
Q1_hvm: begin
{hv_in1_p,hv_in1_n} <= 2'b10;
Q1_duty_delay <= Q1_duty_delay + 1'b1;

if(Q1_duty_delay == `q1_duty_ratios_hvm) begin
Q1_tx_cnt <= Q1_tx_cnt + 1'b1;
Q1_state <= Q1_hvp;
Q1_duty_delay <= 4'd0;end
else if(Q1_tx_cnt == `pluse_cnt) begin 
Q1_state <= Q1_WAIT;end
end
*/


/*
Q1_CLAMP_hvm:begin
{hv_thsd, hv_cw,hv_in1_p,hv_in1_n} <= 4'b1000;
Q1_clamp_cnt <= Q1_clamp_cnt + 1'b1;

if(Q1_clamp_cnt == 4'd9) begin
Q1_state <= Q1_hvp;
Q1_clamp_cnt <= 4'd0;end
if(tx_cnt == `pluse_cnt) begin //计数脉冲满，进入等待周期  
Q1_state <= Q1_WAIT;
end
end*/

Q1_WAIT:begin
{hv_thsd, hv_cw,hv_in1_p,hv_in1_n} <= 4'b1000;

if(prf_wait_cnt == 16'd30_000)begin  //300us
Q1_state <= Q1_WAIT;
pluse_done <= 1'b1;
sysn_cnt <= sysn_cnt + 1'b1;end
if (sysn_cnt == 1)begin
Q1_state <= Q1_IDLE;
sysn_cnt <= 1'b0;end

else begin
prf_wait_cnt <= prf_wait_cnt +1'b1;
Q1_state <= Q1_WAIT; end
end

default: Q1_state <= Q1_IDLE;
endcase
end
////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////通道2  //////////////////////////////////  
always @(posedge clk or negedge rst_n)
if(~rst_n) begin
Q2_state <= Q2_IDLE;
Q2_clamp_cnt <= 4'd0;
Q2_send_delay <= 4'd0;
Q2_duty_delay <= 4'd0;
Q2_tx_cnt <= 4'd0;
Q2_wait_delay <= 8'd0;
end
else begin
case(Q2_state)

Q2_IDLE:begin
{hv_in2_p,hv_in2_n} <= 2'b00;
Q2_clamp_cnt <= 4'd0;
Q2_send_delay <= 4'd0;
Q2_duty_delay <= 4'd0;
Q2_wait_delay <= 8'd0;
Q2_tx_cnt <= 4'd0;
if(start == 1'b1)
Q2_state<= Q2_CLAMP;
else 
Q2_state <= Q2_IDLE;
end

Q2_CLAMP:begin
{hv_in2_p,hv_in2_n} <= 2'b00;

if(Q2_wait_delay == 8'd200)begin
Q2_wait_delay <= 8'd0;
Q2_state <= Q2_SEND_DELAY;end
else begin
Q2_wait_delay <= Q2_wait_delay +1'b1;
Q2_state<= Q2_CLAMP;end
end

Q2_SEND_DELAY:begin     //发射延时并预启动
{hv_in2_p,hv_in2_n} <= 2'b00;

if(Q2_send_delay == `q2_send_cnt) begin
Q2_send_delay <= 4'd0;
Q2_state <= Q2_hvp;end
else begin
Q2_send_delay <= Q2_send_delay + 1'b1;
Q2_state<= Q2_SEND_DELAY;
end
end


Q2_hvp:begin        //高电平
{hv_in2_p,hv_in2_n} <= 2'b01;

if(Q2_duty_delay == `q2_duty_ratios_hvp) begin
Q2_state <= Q2_CLAMP_hvp;
Q2_tx_cnt <= Q2_tx_cnt + 1'b1;
Q2_duty_delay <= 4'd0;end
else begin
Q2_duty_delay <= Q2_duty_delay + 1'b1;
Q2_state <= Q2_hvp;
end
end

Q2_CLAMP_hvp:begin
{hv_in2_p,hv_in2_n} <= 2'b00;

if(Q2_clamp_cnt == 4'd9) begin
Q2_state <= Q2_hvp;
Q2_clamp_cnt <= 4'd0;end
else if(Q2_tx_cnt == `pluse_cnt) begin
Q2_state <= Q2_WAIT;
Q2_tx_cnt <= 4'd0;end
else begin
Q2_clamp_cnt <= Q2_clamp_cnt + 1'b1;
Q2_state <= Q2_CLAMP_hvp;
end
end

Q2_WAIT:begin
{hv_in2_p,hv_in2_n} <= 2'b00;

if(pluse_done == 1)begin  //100Mhz clk -> 1khz发射周期
Q2_state <= Q2_IDLE;
end
else
Q2_state <= Q2_WAIT;
end

default: Q2_state <= Q2_IDLE;
endcase
end
///////////////////////////////////////////////////////////////////////////

/////////////////////////////////////通道3 ////////////////////////////////  
always @(posedge clk or negedge rst_n)
if(~rst_n) begin
Q3_state <= Q3_IDLE;
Q3_clamp_cnt <= 4'd0;
Q3_send_delay <= 4'd0;
Q3_duty_delay <= 4'd0;
Q3_tx_cnt <= 4'd0;
Q3_wait_delay <= 24'd0;
end
else begin
case(Q3_state)

Q3_IDLE:begin
{hv_in3_p,hv_in3_n} <= 2'b00;
Q3_clamp_cnt <= 4'd0;
Q3_send_delay <= 4'd0;
Q3_duty_delay <= 4'd0;
Q3_wait_delay <= 8'd0;
Q3_tx_cnt <= 4'd0;
if(start == 1'b1)
Q3_state<= Q3_CLAMP;
else 
Q3_state <= Q3_IDLE;
end

Q3_CLAMP:begin
{hv_in3_p,hv_in3_n} <= 2'b00;

if(Q3_wait_delay == 8'd200)begin
Q3_wait_delay <= 8'd0;
Q3_state <= Q3_SEND_DELAY;end
else begin
Q3_wait_delay <= Q3_wait_delay +1'b1;
Q3_state<= Q3_CLAMP;
end
end

Q3_SEND_DELAY:begin     //发射延时并预启动
{hv_in3_p,hv_in3_n} <= 2'b00;

if(Q3_send_delay == `q3_send_cnt) begin
Q3_send_delay <= 4'd0;
Q3_state <= Q3_hvp;end
else begin
Q3_send_delay <= Q3_send_delay + 1'b1;
Q3_state <= Q3_SEND_DELAY;
end
end


Q3_hvp:begin        //高电平
{hv_in3_p,hv_in3_n} <= 2'b01;

if(Q3_duty_delay == `q3_duty_ratios_hvp) begin
Q3_state <= Q3_CLAMP_hvp;
Q3_tx_cnt <= Q3_tx_cnt + 1'b1;
Q3_duty_delay <= 4'd0;end
else begin
Q3_duty_delay <= Q3_duty_delay + 1'b1;
Q3_state <= Q3_hvp;
end
end

Q3_CLAMP_hvp:begin
{hv_in3_p,hv_in3_n} <= 2'b00;

if(Q3_clamp_cnt == 4'd9) begin
Q3_state <= Q3_hvp;
Q3_clamp_cnt <= 4'd0;end
else if(Q3_tx_cnt == `pluse_cnt) begin
Q3_state <= Q3_WAIT;
Q3_tx_cnt <= 4'd0;end
else begin
Q3_clamp_cnt <= Q3_clamp_cnt + 1'b1;
Q3_state <= Q3_CLAMP_hvp;
end
end


Q3_WAIT:begin
{hv_in3_p,hv_in3_n} <= 2'b00;


if(pluse_done == 1)begin  //100Mhz clk -> 1khz发射周期
Q3_state <= Q3_IDLE;
end
else begin
Q3_state <= Q3_WAIT;
end
end

default: Q3_state <= Q3_IDLE;
endcase
end 

///////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////通道4 ///////////////////////////////////  
always @(posedge clk or negedge rst_n)
if(~rst_n) begin
Q4_state <= Q4_IDLE;
Q4_clamp_cnt <= 4'd0;
Q4_send_delay <= 4'd0;
Q4_duty_delay <= 4'd0;
Q4_tx_cnt <= 4'd0;
Q4_wait_delay <= 8'd0;
end
else begin
case(Q4_state)

Q4_IDLE:begin
{hv_in4_p,hv_in4_n} <= 2'b00;
Q4_clamp_cnt <= 4'd0;
Q4_send_delay <= 4'd0;
Q4_duty_delay <= 4'd0;
Q4_wait_delay <= 8'd0;
Q4_tx_cnt <= 4'd0;
if(start == 1'b1)
Q4_state<= Q4_CLAMP;
else
Q4_state <= Q4_IDLE;
end

Q4_CLAMP:begin
{hv_in4_p,hv_in4_n} <= 2'b00;

if(Q4_wait_delay == 8'd200)begin
Q4_wait_delay <= 8'd0;
Q4_state <= Q4_SEND_DELAY;end
else begin
Q4_wait_delay <= Q4_wait_delay +1'b1;
Q4_state<= Q4_CLAMP;
end
end

Q4_SEND_DELAY:begin     //发射延时并预启动
{hv_in4_p,hv_in4_n} <= 2'b00;

if(Q4_send_delay == `q4_send_cnt) begin
Q4_send_delay <= 4'd0;
Q4_state <= Q4_hvp;end
else begin
Q4_send_delay <= Q4_send_delay + 1'b1;
Q4_state <= Q4_SEND_DELAY;
end
end


Q4_hvp:begin        //高电平
{hv_in4_p,hv_in4_n} <= 2'b01;

if(Q4_duty_delay == `q4_duty_ratios_hvp) begin
Q4_state <= Q4_CLAMP_hvp;
Q4_tx_cnt <= Q4_tx_cnt + 1'b1;
Q4_duty_delay <= 4'd0;end
else begin
Q4_duty_delay <= Q4_duty_delay + 1'b1;
Q4_state <= Q4_hvp;
end
end

Q4_CLAMP_hvp:begin
{hv_in4_p,hv_in4_n} <= 2'b00;

if(Q4_clamp_cnt == 4'd9) begin
Q4_state <= Q4_hvp;
Q4_clamp_cnt <= 4'd0;end
else if(Q4_tx_cnt == `pluse_cnt) begin
Q4_state <= Q4_WAIT;
Q4_tx_cnt <= 4'd0;end
else begin
Q4_clamp_cnt <= Q4_clamp_cnt + 1'b1;
Q4_state <= Q4_CLAMP_hvp;
end
end


Q4_WAIT:begin
{hv_in4_p,hv_in4_n} <= 2'b00;

if(pluse_done == 1)begin  //100Mhz clk -> 1khz发射周期
Q4_state <= Q4_IDLE;
end
else begin
Q4_state <= Q4_WAIT;
end
end

default: Q4_state <= Q4_IDLE;
endcase
end 

///////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////通道5 ///////////////////////////////////  
always @(posedge clk or negedge rst_n)
if(~rst_n) begin
Q5_state <= Q5_IDLE;
Q5_clamp_cnt <= 4'd0;
Q5_send_delay <= 4'd0;
Q5_duty_delay <= 4'd0;
Q5_tx_cnt <= 4'd0;
Q5_wait_delay <= 8'd0;
end
else begin
case(Q5_state)

Q5_IDLE:begin
{hv_in5_p,hv_in5_n} <= 2'b00;
Q5_clamp_cnt <= 4'd0;
Q5_send_delay <= 4'd0;
Q5_duty_delay <= 4'd0;
Q5_wait_delay <= 8'd0;
Q5_tx_cnt <= 4'd0;
if(start == 1'b1)
Q5_state<= Q5_CLAMP;
else
Q5_state <= Q5_IDLE;
end

Q5_CLAMP:begin
{hv_in5_p,hv_in5_n} <= 2'b00;

if(Q5_wait_delay == 8'd200)begin
Q5_wait_delay <= 8'd0;
Q5_state <= Q5_SEND_DELAY;end
else begin
Q5_wait_delay <= Q5_wait_delay +1'b1;
Q5_state<= Q5_CLAMP;
end
end

Q5_SEND_DELAY:begin     //发射延时并预启动
{hv_in5_p,hv_in5_n} <= 2'b00;

if(Q5_send_delay == `q5_send_cnt) begin
Q5_send_delay <= 4'd0;
Q5_state <= Q5_hvp;end
else begin
Q5_send_delay <= Q5_send_delay + 1'b1;
Q5_state <= Q5_SEND_DELAY;
end
end


Q5_hvp:begin        //高电平
{hv_in5_p,hv_in5_n} <= 2'b01;

if(Q5_duty_delay == `q5_duty_ratios_hvp) begin
Q5_state <= Q5_CLAMP_hvp;
Q5_tx_cnt <= Q5_tx_cnt + 1'b1;
Q5_duty_delay <= 4'd0;end
else begin
Q5_duty_delay <= Q5_duty_delay + 1'b1;
Q5_state <= Q5_hvp;
end
end

Q5_CLAMP_hvp:begin
{hv_in5_p,hv_in5_n} <= 2'b00;

if(Q5_clamp_cnt == 4'd9) begin
Q5_state <= Q5_hvp;
Q5_clamp_cnt <= 4'd0;end
else if(Q5_tx_cnt == `pluse_cnt) begin
Q5_state <= Q5_WAIT;
Q5_tx_cnt <= 4'd0;end
else begin
Q5_clamp_cnt <= Q5_clamp_cnt + 1'b1;
Q5_state <= Q5_CLAMP_hvp;
end
end

Q5_WAIT:begin
{hv_in5_p,hv_in5_n} <= 2'b00;

if(pluse_done == 1)begin  //100Mhz clk -> 1khz发射周期
Q5_state <= Q5_IDLE;
end
else begin
Q5_state <= Q5_WAIT;
end
end

default: Q5_state <= Q5_IDLE;
endcase
end 
///////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////通道6 ///////////////////////////////////  
always @(posedge clk or negedge rst_n)
if(~rst_n) begin
Q6_state <= Q6_IDLE;
Q6_clamp_cnt <= 4'd0;
Q6_send_delay <= 4'd0;
Q6_duty_delay <= 4'd0;
Q6_tx_cnt <= 4'd0;
Q6_wait_delay <= 8'd0;
end
else begin
case(Q6_state)

Q6_IDLE:begin
{hv_in6_p,hv_in6_n} <= 2'b00;
Q6_clamp_cnt <= 4'd0;
Q6_send_delay <= 4'd0;
Q6_duty_delay <= 4'd0;
Q6_wait_delay <= 8'd0;
Q6_tx_cnt <= 4'd0;
if(start == 1'b1)
Q6_state<= Q6_CLAMP;
else
Q6_state <= Q6_IDLE;
end

Q6_CLAMP:begin
{hv_in6_p,hv_in6_n} <= 2'b00;

if(Q6_wait_delay == 8'd200)begin
Q6_wait_delay <= 8'd0;
Q6_state <= Q6_SEND_DELAY;end
else begin
Q6_wait_delay <= Q6_wait_delay +1'b1;
Q6_state<= Q6_CLAMP;
end
end

Q6_SEND_DELAY:begin     //发射延时并预启动
{hv_in6_p,hv_in6_n} <= 2'b00;

if(Q6_send_delay == `q6_send_cnt) begin
Q6_send_delay <= 4'd0;
Q6_state <= Q6_hvp;end
else begin
Q6_send_delay <= Q6_send_delay + 1'b1;
Q6_state <= Q6_SEND_DELAY;
end
end


Q6_hvp:begin        //高电平
{hv_in6_p,hv_in6_n} <= 2'b01;

if(Q6_duty_delay == `q6_duty_ratios_hvp) begin
Q6_state <= Q6_CLAMP_hvp;
Q6_tx_cnt <= Q6_tx_cnt + 1'b1;
Q6_duty_delay <= 4'd0;end
else begin
Q6_duty_delay <= Q6_duty_delay + 1'b1;
Q6_state <= Q6_hvp;
end
end

Q6_CLAMP_hvp:begin
{hv_in6_p,hv_in6_n} <= 2'b00;

if(Q6_clamp_cnt == 4'd9) begin
Q6_state <= Q6_hvp;
Q6_clamp_cnt <= 4'd0;end
else if(Q6_tx_cnt == `pluse_cnt) begin
Q6_state <= Q6_WAIT;
Q6_tx_cnt <= 4'd0;end
else begin
Q6_clamp_cnt <= Q6_clamp_cnt + 1'b1;
Q6_state <= Q6_CLAMP_hvp;
end
end


Q6_WAIT:begin
{hv_in6_p,hv_in6_n} <= 2'b00;

if(pluse_done == 1)begin  //100Mhz clk -> 1khz发射周期
Q6_state <= Q6_IDLE;
end
else begin
Q6_state <= Q6_WAIT;
end
end

default: Q6_state <= Q6_IDLE;
endcase
end 
///////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////通道7 ///////////////////////////////////  
always @(posedge clk or negedge rst_n)
if(~rst_n) begin
Q7_state <= Q7_IDLE;
Q7_clamp_cnt <= 4'd0;
Q7_send_delay <= 4'd0;
Q7_duty_delay <= 4'd0;
Q7_tx_cnt <= 4'd0;
Q7_wait_delay <= 8'd0;
end
else begin
case(Q7_state)

Q7_IDLE:begin
{hv_in7_p,hv_in7_n} <= 2'b00;
Q7_clamp_cnt <= 4'd0;
Q7_send_delay <= 4'd0;
Q7_duty_delay <= 4'd0;
Q7_wait_delay <= 8'd0;
Q7_tx_cnt <= 4'd0;
if(start == 1'b1)
Q7_state<= Q7_CLAMP;
else
Q7_state <= Q7_IDLE;
end

Q7_CLAMP:begin
{hv_in7_p,hv_in7_n} <= 2'b00;

if(Q7_wait_delay == 8'd200)begin
Q7_wait_delay <= 8'd0;
Q7_state <= Q7_SEND_DELAY;end
else begin
Q7_wait_delay <= Q7_wait_delay +1'b1;
Q7_state<= Q7_CLAMP;
end
end

Q7_SEND_DELAY:begin     //发射延时并预启动
{hv_in7_p,hv_in7_n} <= 2'b00;

if(Q7_send_delay == `q7_send_cnt) begin
Q7_send_delay <= 4'd0;
Q7_state <= Q7_hvp;end
else begin
Q7_send_delay <= Q7_send_delay + 1'b1;
Q7_state <= Q7_SEND_DELAY;
end
end


Q7_hvp:begin        //高电平
{hv_in7_p,hv_in7_n} <= 2'b01;

if(Q7_duty_delay == `q7_duty_ratios_hvp) begin
Q7_state <= Q7_CLAMP_hvp;
Q7_tx_cnt <= Q7_tx_cnt + 1'b1;
Q7_duty_delay <= 4'd0;end
else begin
Q7_duty_delay <= Q7_duty_delay + 1'b1;
Q7_state <= Q7_hvp;
end
end

Q7_CLAMP_hvp:begin
{hv_in7_p,hv_in7_n} <= 2'b00;

if(Q7_clamp_cnt == 4'd9) begin
Q7_state <= Q7_hvp;
Q7_clamp_cnt <= 4'd0;end
else if(Q7_tx_cnt == `pluse_cnt) begin
Q7_state <= Q7_WAIT;
Q7_tx_cnt <= 4'd0;end
else begin
Q7_clamp_cnt <= Q7_clamp_cnt + 1'b1;
Q7_state <= Q7_CLAMP_hvp;
end
end


Q7_WAIT:begin
{hv_in7_p,hv_in7_n} <= 2'b00;


if(pluse_done == 1)begin  //100Mhz clk -> 1khz发射周期
Q7_state <= Q7_IDLE;
end
else begin
Q7_state <= Q7_WAIT;
end
end

default: Q7_state <= Q7_IDLE;
endcase
end 
///////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////通道6 ///////////////////////////////////  
always @(posedge clk or negedge rst_n)
if(~rst_n) begin
Q8_state <= Q8_IDLE;
Q8_clamp_cnt <= 4'd0;
Q8_send_delay <= 4'd0;
Q8_duty_delay <= 4'd0;
Q8_tx_cnt <= 4'd0;
Q8_wait_delay <= 8'd0;
end
else begin
case(Q8_state)

Q8_IDLE:begin
{hv_in8_p,hv_in8_n} <= 2'b00;
Q8_clamp_cnt <= 4'd0;
Q8_send_delay <= 4'd0;
Q8_duty_delay <= 4'd0;
Q8_wait_delay <= 8'd0;
Q8_tx_cnt <= 4'd0;
if(start == 1'b1)
Q8_state<= Q8_CLAMP;
else
Q8_state <= Q8_IDLE;
end

Q8_CLAMP:begin
{hv_in8_p,hv_in8_n} <= 2'b00;

if(Q8_wait_delay == 8'd200)begin
Q8_wait_delay <= 8'd0;
Q8_state <= Q8_SEND_DELAY;end
else begin
Q8_wait_delay <= Q8_wait_delay +1'b1;
Q8_state<= Q8_CLAMP;
end
end

Q8_SEND_DELAY:begin     //发射延时并预启动
{hv_in8_p,hv_in8_n} <= 2'b00;

if(Q8_send_delay == `q8_send_cnt) begin
Q8_send_delay <= 4'd0;
Q8_state <= Q8_hvp;end
else begin
Q8_send_delay <= Q8_send_delay + 1'b1;
Q8_state <= Q8_SEND_DELAY;
end
end


Q8_hvp:begin        //高电平
{hv_in8_p,hv_in8_n} <= 2'b01;

if(Q8_duty_delay == `q8_duty_ratios_hvp) begin
Q8_state <= Q8_CLAMP_hvp;
Q8_tx_cnt <= Q8_tx_cnt + 1'b1;
Q8_duty_delay <= 4'd0;end
else begin
Q8_duty_delay <= Q8_duty_delay + 1'b1;
Q8_state <= Q8_hvp;
end
end

Q8_CLAMP_hvp:begin
{hv_in8_p,hv_in8_n} <= 2'b00;

if(Q8_clamp_cnt == 4'd9) begin
Q8_state <= Q8_hvp;
Q8_clamp_cnt <= 4'd0;end
else if(Q8_tx_cnt == `pluse_cnt) begin
Q8_state <= Q8_WAIT;
Q8_tx_cnt <= 4'd0;end
else begin
Q8_clamp_cnt <= Q8_clamp_cnt + 1'b1;
Q8_state <= Q8_CLAMP_hvp;
end
end


Q8_WAIT:begin
{hv_in8_p,hv_in8_n} <= 2'b00;
if(pluse_done == 1)begin  //100Mhz clk -> 1khz发射周期
Q8_state <= Q8_IDLE;
end
else begin
Q8_state <= Q8_WAIT;
end
end

default: Q8_state <= Q8_IDLE;
endcase
end 
   
endmodule
