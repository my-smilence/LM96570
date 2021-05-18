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
// Dependencies: sthv_800���巢�����
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
 input sys_clk, //ϵͳʱ��50M
 input  rst_n,//��λ�͵���Ч

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
  
 // output wire hv_thsd  //�¶ȱ���ͣ�����͵���Ч��һ���ø�λ
  output wire hv_cw,  //cw���������ƣ���λ��Ч
  output wire hv_ck_100m   //sthv_800 ϵͳʱ�ӣ�min:25Mhz ,type:100M ,max :200M
    );


//assign ck_100m =1'b0;
 pluse_send   u1_pluse_send
 (
.clk(hv_ck_100m),            //PLL_clock 100Mhz 
.rst_n(rst_n),           //reset ,low active
//sthv800;       hv_inx:xΪͨ���ţ�����8ͨ��;
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
  
.hv_thsd(hv_thsd),    //�¶ȱ���ͣ�����͵���Ч��һ���ø�λ
.hv_cw(hv_cw),       //cw���������ƣ���λ��Ч
.pluse_done(pluse_done)  //���η������
//  input SYNC_PULSE    //�����źţ��ɽӰ���
//  iutput PLUSE_DONE   //finish�ź�
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
