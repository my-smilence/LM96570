`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/28 16:50:02
// Design Name: f
// Module Name: lm96570
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
//********************************************LM96570 register map*************************************************************************//
/* register:    data:   coarse Delay        fine Delay    chanel:     current state:                   width:address+data
          00h     00 000  00_0000_0000_0000  000b          ch1         no user-programmed delay         6+22
		  01h     00 000  00_0000_0000_0010  001b          ch2         2  coarse delays + 1 fine delay  6+22
		  02h     00 000  00_0000_0000_0100  010b          ch3         4  coarse delays + 2 fine delay  6+22 
		  03h     00 000  00_0000_0000_0110  011b          ch4         6  coarse delays + 3 fine delay  6+22
		  04h     00 000  00_0000_0000_1000  100b          ch5         8  coarse delays + 4 fine delay  6+22
		  05h     00 000  00_0000_0000_1010  101b          ch6         10 coarse delays + 5 fine delay  6+22
		  06h     00 000  00_0000_0000_1100  110b          ch7         12 coarse delays + 6 fine delay  6+22
		  07h     00 000  00_0000_0000_1110  111b          ch8         14 coarse delays + 7 fine delay  6+22
   register:    data:                                     chanel:     current state:                   width:address+data
          08h     5555_5555_5555_5555h                      ch1 P       default                          6+64
		  09h     5555_5555_5555_5555h                      ch2 P       default                          6+64
		  0Ah     5555_5555_5555_5555h                      ch3 P       default                          6+64
		  0Bh     5555_5555_5555_5555h                      ch4 P       default                          6+64
		  0Ch     5555_5555_5555_5555h                      ch5 P       default                          6+64
		  0Dh     5555_5555_5555_5555h                      ch6 P       default                          6+64
		  0Eh     5555_5555_5555_5555h                      ch7 P       default                          6+64
		  0Fh     5555_5555_5555_5555h                      ch8 P       default                          6+64
	register:    data:                                     chanel:     current state:                   width:address+data	  
		  10h     AAAA_AAAA_AAAA_AAAAh                      ch1 N       default                          6+64
		  11h     AAAA_AAAA_AAAA_AAAAh                      ch2 N       default                          6+64
		  12h     AAAA_AAAA_AAAA_AAAAh                      ch3 N       default                          6+64
		  13h     AAAA_AAAA_AAAA_AAAAh                      ch4 N       default                          6+64
		  14h     AAAA_AAAA_AAAA_AAAAh                      ch5 N       default                          6+64
		  15h     AAAA_AAAA_AAAA_AAAAh                      ch6 N       default                          6+64
		  16h     AAAA_AAAA_AAAA_AAAAh                      ch7 N       default                          6+64
		  17h     AAAA_AAAA_AAAA_AAAAh                      ch8 N       default                          6+64
	register:    data:                                     chanel:     current state:                   width:address+data		  
		  18h     5555_5555_5555_5555h                      All P       default                          6+64
          19h     AAAA_AAAA_AAAA_AAAAh                      ALL N       default                          6+64	
	register:    data:                                                 current state:                   width:address+data		  
		  1Ah     0001_0001111_111b                                     default                          6+14
		  1Bh     0000_0000b                                            default                          6+8                  */
///**************************************************************************************************************************/
module LM96570(sclk,reset_N,sRD,sLE,sWR,TX_EN,ACK,led);

//------------- �� FPGA �ڲ����� -------//
input sclk; // ʱ������ 4-Wire Serial Interface Clock
input reset_N;// ��λ�ź�  Asynchronous Chip Reset


 //------------- ��Ӳ���ӿ� -------//
output reg sRD;  // 4-Wire Serial Interface Data Output for reading data registers
output reg sLE;  // 4-Wire Serial Interface Latch Enable
output sWR;  // 4-Wire Serial Interface Data Input for writing data registers
output reg TX_EN;// Beamformer starts firing
output reg ACK;
output reg [2:0]led;

//------------- �Ĵ�����ʼ�� -------//
reg addr_data; // ������λ�Ĵ���ѡ��1 ѡ��ַ��λ�Ĵ�����0 ѡ������λ�Ĵ���
reg [5:0]addr_buf; // ���͵�ַ�Ĵ��� 5bits
reg [63:0]data_buf; // �������ݼĴ��� ��� 64bits
reg [17:0]delay_buf;    //������ʱ���ƼĴ��� �̶� 18bits

reg [4:0]addr_cfg[25:1];  // �����ַ member  00h-07h;08h-0Fh;10h-17h;1Ah������8+8+8+1=25��5λ�Ĵ���
reg [63:0]data_cfg[25:1]; // �������� member 8ͨ����p/n,����16��Ĵ�ÿ��64bits    ������ʱ meber 8ͨ����ʱ�趨 22bits


//------------- ��������ʼ�� -------//
reg [4:0]cnt_cfg;  // ���ü����� ����������ݣ���ַ�����ݣ�
reg [2:0]cnt_addr; // ��ַλ�������
reg [5:0]cnt_data; // ����/��ʱ λ�������
reg [13:0]cnt_tx;   //�������ڼ���

 //------------- ����߼����� -------//
wire data_mid;
reg link_sWR;
assign sWR =link_sWR?data_mid:1'b0;
assign data_mid  = addr_data?addr_buf[0]:data_buf[0]; //1 ѡ��ַ��λ�Ĵ�����0 ѡ������λ�Ĵ���

//------------- ״̬����ʼ�� -------//
reg [5:0]state;
parameter     IDLE      = 6'b000_001,
				ADDR_SELECT	= 6'b000_010, 
				ADDR_OUT	= 6'b000_100, 
				DATA_OUT	= 6'b001_000, 
				ACK_OUT		= 6'b010_000, 
				ACK_IN		= 6'b100_000; 

//------------- �߼����ض��� -------//
parameter YES  =1'b1,
            NO   =1'b0;

			 			 
//------------ ��״̬������ -------//
always@(negedge sclk or negedge reset_N)    //�첽
if(~reset_N) // ϵͳ��λ��ʼ��
	 begin
		addr_cfg[25]<=5'b11010;            // ��ַ 1A
		//addr_cfg [2]<=5'b11001;            // ��ַ 19
		//addr_cfg [1]<=5'b11000;            // ��ַ 18
		        
		addr_cfg[24]<=5'b10111;            // ��ַ 17h
		addr_cfg[23]<=5'b10110;            // ��ַ 16h
		addr_cfg[22]<=5'b10101;            // ��ַ 15h
		addr_cfg[21]<=5'b10100;            // ��ַ 14h
		addr_cfg[20]<=5'b10011;            // ��ַ 13h
		addr_cfg[19]<=5'b10010;            // ��ַ 12h
		addr_cfg[18]<=5'b10001;            // ��ַ 11h
		addr_cfg[17]<=5'b10000;            // ��ַ 10h
		
		addr_cfg[16]<=5'b10111;            // ��ַ 0Fh
		addr_cfg[15]<=5'b01110;            // ��ַ 0Eh
		addr_cfg[14]<=5'b01101;            // ��ַ 0Dh
		addr_cfg[13]<=5'b01100;            // ��ַ 0Ch
		addr_cfg[12]<=5'b01011;            // ��ַ 0Bh
		addr_cfg[11]<=5'b01010;            // ��ַ 0Ah
		addr_cfg[10]<=5'b01001;            // ��ַ 09h
		addr_cfg[9]<=5'b01000;            // ��ַ 08h
		
		addr_cfg[8]<=5'b00111;            // ��ַ 07h
		addr_cfg[7]<=5'b00110;            // ��ַ 06h
		addr_cfg[6]<=5'b00101;            // ��ַ 05h
		addr_cfg[5]<=5'b00100;            // ��ַ 04h
		addr_cfg[4]<=5'b00011;            // ��ַ 03h
		addr_cfg[3]<=5'b00010;            // ��ַ 02h
		addr_cfg[2]<=5'b00001;            // ��ַ 01h
		addr_cfg[1]<=5'b00000;            // ��ַ 00h		
		
		data_cfg[25]<=14'b0001_001_0000_111;      //14bits
		//data_cfg[2]<=64'b1111_0000_1111_1110__0000_0011_1111_0000__0011_1110_0000_1111__0000_1110_0011_0010;
		//data_cfg[1]<=64'b0000_1111_0000_0001__1111_1100_0000_1111__1100_0001_1111_0000__1111_0001_1100_1101;
		data_cfg[24]<=64'b0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000; //8n
		data_cfg[23]<=64'b0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000;
		data_cfg[22]<=64'b0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000;
		data_cfg[21]<=64'b0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000;
		data_cfg[20]<=64'b0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000;
		data_cfg[19]<=64'b0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000;
		data_cfg[18]<=64'b0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000;
		data_cfg[17]<=64'b0101_0101_0101_0101__0101_0101_0101_0101__0101_0101_0101_0101__0101_0101_0101_0101;
		
		data_cfg[16]<=64'b0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000; //8p
		data_cfg[15]<=64'b0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000;
		data_cfg[14]<=64'b0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000;
		data_cfg[13]<=64'b0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000;
		data_cfg[12]<=64'b0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000;
		data_cfg[11]<=64'b0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000;
		data_cfg[10]<=64'b0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_0000;
		//data_cfg[1]<=64'b0101_0101_0101_0101__0101_0101_0101_0101__0101_0101_0101_0101__0101_0101_0101_0101;
		data_cfg[9]<=64'b1010_1010_1010_1010__1010_1010_1010_1010__1010_1010_1010_1010__1010_1010_1010_1010;
		
		//���������ȵ���    22bits ��ʱλ��
		data_cfg[8]<=22'b00_000_00_0000_0000_0000_111;
		data_cfg[7]<=22'b00_000_00_0000_0000_0000_110;
		data_cfg[6]<=22'b00_000_00_0000_0000_0000_101;
		data_cfg[5]<=22'b00_000_00_0000_0000_0000_100;
		data_cfg[4]<=22'b00_000_00_0000_0000_0000_011;
		data_cfg[3]<=22'b00_000_00_0000_0000_0000_010;
		data_cfg[2]<=22'b00_000_00_0000_0000_0000_001;
		data_cfg[1]<=22'b00_000_00_0000_0000_1111_111;
		
		TX_EN	   <= NO;
		sLE      <= 1'b1;
		cnt_cfg  <= 5'd25; //��25���Ĵ�����24��0����ʶλ24 1Ah
		state    <= IDLE;
		link_sWR <= NO;
		ACK <= NO;
		led <= 3'b000;
		sRD <= 1'b0;
		cnt_tx <= 14'd0;
		
	end
else	
	begin
		casex(state)
			IDLE:begin
						sLE <= 1'b1;
                        link_sWR <= NO;     //sWR = 1'b0
                        sRD <= 1'b0;        
						addr_data <= 1'b1; // 1�����ַ,0�������  
						ACK <= NO;

						 if(cnt_cfg)
							begin
								addr_buf <= {1'b0,addr_cfg[cnt_cfg]}; //1AH�Ĵ��ַaddr_bug[25];
								data_buf <= data_cfg[cnt_cfg];
								TX_EN 	<= NO;
								state		<= ADDR_SELECT;
							end  //if
					   else begin    //����
					   if(cnt_tx <= 10_000) begin
					    led <= 3'b110;     //��2
					    TX_EN   <=YES;
					    cnt_tx <= cnt_tx + 1'b1;
					    state   <=IDLE;
					    end
					    else begin
					    led <= 3'b110;     //��2
					    TX_EN   <=NO;
					    cnt_tx <= 14'd0;
					    state   <=IDLE;
					    end
					  end  //else begin
				 end
					
			ADDR_SELECT:begin
			            led <= 3'b001;//����	��ʱ���addr 0λ	            
						sLE 	 <= 1'b0;   //le����
						addr_data <= 1'b1; // 1�����ַ,
						link_sWR	 <= YES;     //sWR=addr_data? ��д��״̬
						cnt_addr  <=3'b101;  //5��ַλ��+һ��0��ʶ
						casex(addr_buf[4:0])   // ��ͬ�ĵ�ַλ��һ���������ж�
							5'b00???:cnt_data<=6'b01_1000;  //21:0 ��ʱ����λ��
							5'b01???:cnt_data<=6'b11_1111;  //63:0 7��pͨ��
							5'b10???:cnt_data<=6'b11_1111;  //63:0 1��p+8��n
							5'b1100?:cnt_data<=6'b11_1111;  //63:0 19/18ͨ��ͨ��
							5'b11010:cnt_data<=6'b00_1101;  //13:0 1Ah 
							
						endcase
						cnt_cfg<=cnt_cfg-1'b1;
						state<=ADDR_OUT;
					end
					
			ADDR_OUT:begin
							if(cnt_addr)							
								begin
								
								   led <= 3'b001;//����   ��ʱ���addr ��4λ+0	
								   addr_buf<=addr_buf>>1'b1; //��λ���͵�ַ
								   cnt_addr<=cnt_addr-1'b1;     //cnt_addr=5��0 ����6bits
								end
						    else begin
						    state <= DATA_OUT;
						    addr_data <= 1'b0; // 1�����ַ,0�������
						    led <= 3'b010;    //����    ��ʱ���data 0λ
						    link_sWR <= YES;     //sWR=addr_data?
						    end
					end
					
			DATA_OUT:begin
			               if(cnt_data)      //�������Ϊ����λ��-1��
			                     begin
			               //       addr_data <= 1'b0; // 1�����ַ,0�������			                           
			                       data_buf<=data_buf>>1'b1;
	                               cnt_data<=cnt_data-1'b1;
	                             end
	                        else if(cnt_cfg) //25���Ĵ�ȫ��������
	                        begin  
	                        link_sWR <= NO;
	                        state <= IDLE;
	                        sLE <= 1'b1;
	                        led <= 3'b111;     //ȫ��
	                        end
	                        else begin
	                        link_sWR <= NO;
	                        state <= IDLE;
	                        sLE <= 1'b1;
	                        ACK <= 1'b1;
	                        end	                        
                    end
	                           					
	endcase				
end
				
endmodule