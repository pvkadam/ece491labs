`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Lafayette College 
// Engineer(s): 
// Kemal Dilsiz
// Zainab Hussein 
// 
// Create Date: 09/20/2016 01:54:21 PM
// Design Name: Receiver
// Module Name: receiver
// Project Name: Lab04 ECE 491
// Target Devices: Nexys 4 DDR
// Tool Versions: System Verilog, Vivado
// Description: 
// Will receive asynchronous serial transmission and convert it into 8 bit wide data.
// 
// Baud Rate is passed from the top level and SIXTEENBAUD is used for this receiver where we sample the input.
//
// Dependencies: 
// 
// Revision: 9/20/2016
// Revision 0.01 - File Created
// Additional Comments:
// No
// 
//////////////////////////////////////////////////////////////////////////////////


module async_receiver(
    input logic rxd,
    input logic clk, rst,
    output logic ferr,
    output logic rdy,
    output logic [7:0] data
    );
    
    parameter BAUD = 9600;
    parameter SIXTEENBAUD = BAUD * 16;
    logic BaudRate, rxd_prev;
    logic [2:0] bit_count;

    //clkenb is used for getting a enable signal that follows the desired baudrate
    clkenb #(.DIVFREQ(BAUD)) CLKENB2(.clk(clk), .reset(rst), .enb(BaudRate2));
    clkenb #(.DIVFREQ(SIXTEENBAUD)) CLKENB(.clk(clk), .reset(rst), .enb(BaudRate));
    
    typedef enum logic [3:0] {
        IDLE = 4'b0000, 
        START = 4'b1010, 
        RECEIVE = 4'b0001, 
        IDLE2 = 4'b0010, 
//        TR2 = 4'b0011,
//        TR3 = 4'b0100, 
//        TR4 = 4'b0101, 
//        TR5 = 4'b0110, 
//        TR6 = 4'b0111, 
//        TR7 = 4'b1000, 
        STOP = 4'b1001,
        WAIT = 4'b1111
    } state_t;
    
    state_t state, next;

    always_ff@(posedge clk)
       begin
        if(rst) 
            begin
                state <= IDLE;
            end
        else if(BaudRate)
            begin
                state <= next;
            end  
        else
            begin
                state <= state;
            end
        end
       
    logic reset_time_count = 0;
    logic reset_bit_count = 0;
    logic trigger; 
    
    always_ff@(posedge clk)
        begin
            if((rst || reset_bit_count))
                begin 
                    bit_count <= 3'b000;
                end
             else if(trigger && BaudRate)
                begin
                    bit_count <= bit_count + 1;
                end
          end
                  
   logic [3:0]time_count;
   logic increase;  
   
   always_ff@(posedge clk)
         begin
             if((reset_time_count || rst))
                 begin 
                     time_count <= 4'b0000;
                 end
              else if(increase && BaudRate)
                 begin
                     time_count <= time_count + 1;
                 end
              else
                 begin
                     time_count <= time_count;
                 end
           end
    
logic enable_data;  
logic d0,d1,d2,d3,d4,d5,d6,d7;  

assign data = {d7,d6,d5,d4,d3,d2,d1,d0};
    
       always_ff@(posedge clk) 
       begin
           if(enable_data)
           begin
             case (bit_count)
                   3'd0 : d0 = rxd;
                   3'd1 : d1 = rxd;
                   3'd2 : d2 = rxd;
                   3'd3 : d3 = rxd;
                   3'd4 : d4 = rxd;
                   3'd5 : d5 = rxd;
                   3'd6 : d6 = rxd;
                   3'd7 : d7 = rxd;
             endcase
           end
       end // always_ff    
    
    always_comb
       begin
        case(state)
            IDLE:
                begin
                    rdy = 1;
                    ferr = 0;
                    increase = 0;
                    trigger = 0;
                    reset_time_count = 0;
                    enable_data = 0;
                    
                    if(time_count != 0) reset_time_count = 1;
                                        
                    //why time count has to be zero?
//                    if((time_count == 0) && rxd ) 
//                        begin
                            next = IDLE;
//                        end

                     //simulation confusion here between the time_count = 0
                     //that transitions into the receive state and the one
                     //going into the start state. 
                     if((time_count == 0) && ~rxd)
                        begin
                            //increase = 1;
                            next = START;
                        end
                    
                end
                
               IDLE2:
                    begin
                        rdy = 1;
                        ferr = 1;
                        increase = 0;
                        trigger = 0;
                        reset_time_count = 0;
                        enable_data = 0;
                        
                        if(time_count != 0) reset_time_count = 1;

                        next = IDLE2;

                         if((time_count == 0) && ~rxd)
                            begin
                                //increase = 1;
                                next = START;
                            end
                        
                    end
            
            START:
                begin
                    ferr = 0;
                    rdy = 0;
                    increase = 1;
                    next = START;
                    trigger = 0;
                    reset_time_count = 0;
                    enable_data = 0;
                    
                    if((time_count == 6) && rxd)
                        begin
                            next = IDLE2;
                            ferr = 1;
                            reset_time_count = 1;
                        end
                    if((time_count == 7) && rxd)
                        begin
                            next = IDLE2;
                            ferr = 1;
                            reset_time_count = 1;
                        end
                    if((time_count == 14) && rxd)
                        begin
                            next = IDLE2;
                            ferr = 1;
                            reset_time_count = 1;
                        end
//                    if((time_count == 15) && rxd)
//                        begin
//                            next = IDLE;
//                            ferr = 1;
//                        end
                    if((time_count == 15))        
                        begin
                            next = RECEIVE;
                            ferr = 0;
                        end
                end
            
            RECEIVE:
                begin
                    ferr = 0;
                    rdy = 0;        
                    increase = 1;
                    next = RECEIVE;
                    trigger = 0;
                    enable_data = 0;
                    reset_time_count = 0;
                    
                    if(time_count == 7)
                        begin
                            //data = {rxd, data[7:1]};
                            trigger = 1;
                            enable_data = 1;
                            rdy = 0;
                            ferr = 0;
                        end 
//                    if(time_count == 9 || time_count == 10 || time_count == 11)
//                        begin
//                            trigger = 1;
//                            data[bit_count] = rxd;
//                            rdy = 0;
//                            ferr = 0;
//                        end 
                    if(bit_count == 0 && time_count == 15)
                        begin
                            trigger = 0;
                            next = STOP;
                        end
                end
            STOP:
                begin
                   rdy = 1;
                   increase = 1;
                   next = STOP;
                   trigger = 0;
                   ferr = 0;
                   reset_time_count = 0;
                   enable_data = 0;
                   
                   if(time_count == 7 && ~rxd)
                       begin
                            ferr = 1;
                            next = IDLE;
                       end
//                   else if(time_count == 8 && rxd)
//                       begin
//                            ferr = 0;
//                       end 
                   else if(time_count == 15)
                       begin
                            increase = 1;
                            next = IDLE;
                            
                             if((time_count == 15) && ~rxd)
                               begin
                                   increase = 1;
                                   next = START;
                               end
                               
                       end
               end
            
            default:
                begin
                next = IDLE2;
                rdy = 1;
                ferr = 1;
                trigger = 0;
                increase = 0;
                reset_time_count = 0;
                enable_data = 0;

                end
        endcase
       
    end
    
endmodule