//-----------------------------------------------------------------------------
// Title         : Nexys4 Simple Top-Level File
// Project       : ECE 491
//-----------------------------------------------------------------------------
// File          : nexys4DDR.sv
// Author        : John Nestor  <nestorj@nestorj-mbpro-15>
// Created       : 22.07.2016
// Last modified : 22.07.2016
//-----------------------------------------------------------------------------
// Description :
// This file provides a starting point for Lab 1 and includes some basic I/O
// ports.  To use, un-comment the port declarations and the corresponding
// configuration statements in the constraints file "Nexys4DDR.xdc".
// This module only declares some basic i/o ports; additional ports
// can be added - see the board documentation and constraints file
// more information
//-----------------------------------------------------------------------------
// Modification history :
// 22.07.2016 : created
//-----------------------------------------------------------------------------

module nexys4DDR (
		 // un-comment the ports that you will use
          input logic         CLK100MHZ,
		  input logic [8:0]   SW,
		  input logic 	      BTNC,
//		  input logic 	      BTNU, 
		  input logic 	      BTNL, 
		  input logic 	      BTNR,
//        input logic 	      BTND,
		  
		  output logic [6:0]  SEGS,
		  output logic [7:0]  AN,
		  output logic 	      DP,
		  output logic [7:0]  data,
		  
		  output logic [2:0]  LED,		  
		  input logic         UART_TXD_IN,
//		  input logic         UART_RTS,		  
		  output logic        UART_RXD_OUT,
		  output logic        UART_RXD_OUT_copy,
		  output logic        JArdy,
		  output logic        JAferr
//		  output logic        UART_CTS		  
            );
            
        assign UART_RXD_OUT_copy = UART_RXD_OUT;
            
        parameter BAUD = 9600;
        
        logic [5:0]length;
        
        //assign length = {1'b0,1'b0,SW[11:8]};
        
        logic [7:0] tempdata;
        logic tempsend;
        
        //logic [7:0] data;
        logic [6:0] segments;
        logic [2:0] sev_data;
        logic rxd;
        
//        always_ff@(posedge CLK100MHZ)
//        begin
//            if(SW[12]) 
//            begin
//                tempdata <= data;
////                tempsend <= send;
//            end
//            else 
//            begin
         assign    tempdata = SW[7:0];
//                tempsend <= BTND;
//            end
//        end

        logic temptxd;

        always_ff@(posedge CLK100MHZ)
        begin
            if(SW[8]) 
            begin
                temptxd <= UART_RXD_OUT;
//                tempsend <= send;
            end
            else 
            begin
                temptxd <= UART_TXD_IN;
            end
        end
        
  // add SystemVerilog code & module instantiations here
   
      //  debounce #(.DEBOUNCE_TIME_MS(30)) DEBOUNDER(.clk(CLK100MHZ), .button_in(BTNU), .button_out(sendDebounced), .pulse());
        
        transmitter #(.BAUD(BAUD)) TRANS(
            .data(tempdata), 
            .send(BTNR), 
            .clk(CLK100MHZ), 
            .rst(BTNC), 
            .switch(BTNL), 
            .txd(UART_RXD_OUT), 
            .rdy(LED[0])
            //.txen(LED[1])
        );
        
        receiver #(.BAUD(BAUD)) RECEV(
              .rxd(temptxd),
              .clk(CLK100MHZ), 
              .rst(BTNC),
              .ferr(JAferr),
              .rdy(LED[2]),
              .data(data)
            );

//        mxtest_2 #(.WAIT_TIME(5000)) U_MXTEST (
//            .clk(CLK100MHZ), 
//            .reset(BTNC), 
//            .run(BTNR | sendDebounced), 
//            .send(send),
//            .length(length), 
//            .data(data), 
//            .ready(JArdy)
//	    );

        //instantiate seven seg display
           dispctl DISPCTL (.clk(CLK100MHZ), .reset(BTNC), 
                                .d7(data[7]), 
                                .d6(data[6]), 
                                .d5(data[5]), 
                                .d4(data[4]), 
                                .d3(data[3]), 
                                .d2(data[2]), 
                                .d1(data[1]), 
                                .d0(data[0]),
                                
                                .dp7(1'b0), 
                                .dp6(1'b0), 
                                .dp5(1'b0), 
                                .dp4(1'b0), 
                                .dp3(1'b0),
                                .dp2(1'b0), 
                                .dp1(1'b0), 
                                .dp0(1'b0),
                                .seg(SEGS),
                                .dp(DP),
                                .an(AN)
                 );

        assign JArdy = LED[2];
      //  assign JAferr = LED[1];

endmodule // nexys4DDR
