# LM96570
verilog for LM96570 Ultrasound Configurable Transmit Beamformer

所有代码已经上板测试过，可以直接使用
All codes have been tested on the board and can be used directly

tips:
1.LM96570 RESET为异步高电平复位，可以将fpga复位信号直接取反作为LM96570复位
2.寄存器写入时钟为下降沿触发，时序上保证差分时钟写入
3.差分信号：由于接入信号和差分端口同bank，逻辑电压2.5V-3.3V，这里配置为BLVDS_25，可选择DIFF1.8V

tips:
1. LM96570 RESET is an asynchronous high-level reset, and the FPGA reset signal can be directly inverted as LM96570 reset
2. The register write clock is triggered by the falling edge, and the timing guarantees the differential clock write
3. Differential signal: Since the access signal and the differential port are in the same bank, the logic voltage is 2.5V-3.3V, here is configured as BLVDS_25, and DIFF1.8V can be selected
