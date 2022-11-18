`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// Module Name: toptest
// Aditional comments:
// Simulates query command. 
//next to be simulated- query adj
//////////////////////////////////////////////////////////////////////////////////
module toptest();

      // Regular IO
  // Oscillator input, master reset, demodulator input
  reg  reset, clk, demodin;

  // Modulator output
  wire modout;

  // Functionality control
  reg use_uid, use_q, comm_enable;

  // EPC ID source
  reg  [7:0] uid_byte_in;
  wire [3:0] uid_addr_out;
  wire       uid_clk_out;

  // ADC connections, not needed for now
  reg  adc_sample_datain;
  wire adc_sample_clk, adc_sample_ctl;

  // MSP430 connections, not needed for now
  reg  msp_sample_datain;
  wire msp_sample_clk, msp_sample_ctl;
  wire writedataout, writedataclk;

  // Debugging IO
  wire  debug_clk;
  wire debug_out;
  
  reg [1800:0] bitquery;
  reg [1800:0] bitqueryadj;
  
  wire [15:0] counter;
  reg counterenb;
  wire overflow;
  
  
  parameter QUERYREP   = 9'b000000001;
  parameter ACK        = 9'b000000010;
  parameter QUERY      = 9'b000000100;
  parameter QUERYADJ   = 9'b000001000;
  parameter SELECT     = 9'b000010000;
  parameter NACK       = 9'b000100000;
  parameter REQRN      = 9'b001000000;
  parameter READ       = 9'b010000000;
  parameter WRITE      = 9'b100000000;
  
  reg [8:0] command;
  
    counter16 c10(.clk(clk), .reset(reset), .enable(counterenb), .count(counter), .overflow(overflow));
    top U_top(reset, clk, demodin, modout, // regular IO
           adc_sample_ctl, adc_sample_clk, adc_sample_datain,    // adc connections
           msp_sample_ctl, msp_sample_clk, msp_sample_datain, // msp430 connections
           uid_byte_in, uid_addr_out, uid_clk_out,
           writedataout, writedataclk, 
           use_uid, use_q, comm_enable,
           debug_clk, debug_out);
           
    
           
    initial begin
        reset = 1;
        clk = 0;
        demodin = 1;
        
        use_uid=0;
        use_q = 0;
        comm_enable = 1;
        uid_byte_in = 8'b00000000;
        adc_sample_datain = 0;
        msp_sample_datain=0;
        
        counterenb = 1;
        command = QUERY;
        
        
        #0.1
        reset = 0;
        
        #2000
        
        command = QUERYADJ;

        end
    
    always #0.1 clk = ~clk; //2.5MHz clock frequency, bit rate
    
    assign debug_clk = clk;


    initial begin
       bitquery = 1801'b1111111111000000000000000000000000111111111111111111111111000000000000000000000000111111111111111111111111000000000000000000000000111111111111111111111111000000000000000000000000111111111111111111111111000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111111000000000000000000000000111111111111111111111111000000000000000000000000111111111111111111111111000000000000000000000000111111111111111111111111000000000000000000000000111111111111111111111111000000000000000000000000111111111111111111111111000000000000000000000000111111111111111111111111000000000000000000000000111111111111111111111111000000000000000000000000111111111111111111111111000000000000000000000000111111111111111111111111000000000000000000000000111111111111111111111111000000000000000000000000111111111111111111111111000000000000000000000000111111111111111111111111000000000000000000000000111111111111111111111111000000000000000000000000111111111111111111111111000000000000000000000000111111111111111111111111000000000000000000000000111111111111111111111111000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111111000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000000000011111111111111111111111100000000000000000000000011111111111111111111111;
       bitqueryadj = 1801'd0;          
    end
    
    


    always@(posedge clk && !reset) begin
    //initial
        if(counter <= 16'd1800) begin
            bitquery <= bitquery >> 1;
            demodin = bitquery;      
        end
        else demodin =1; 
        
       
    end


endmodule

/*
// FGPA Test of TOP functional block.
// Copyright 2010 University of Washington
// License: http://creativecommons.org/licenses/by/3.0/
// 2008 Dan Yeager

// Maps FPGA IO onto RFID tag (top.v)

module toptest(LEDR, LEDG, GPIO_0, KEY, SW, EXT_CLOCK,
               HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7);
  input  [3:0]  KEY;
  inout  [35:0] GPIO_0;
  output [17:0] LEDR;
  output [8:0]  LEDG;
  input         EXT_CLOCK;
  input  [17:0] SW;
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;

  // basic tag IO
  wire clk, reset, demodin, modout;


  // Functionality control
  wire use_uid, use_q, comm_enable;

  // read data connections
  wire adc_sample_ctl, adc_sample_clk, adc_sample_datain;
  wire msp_sample_ctl, msp_sample_clk, msp_sample_datain;

  // write data connections
  wire writedataout, writedataclk;

  // EPC ID source
  wire [7:0] uid_byte_in;
  wire [3:0] uid_addr_out;
  wire       uid_clk_out;

  // debugging connections
  wire debug_clk, debug_out;

  assign debug_clk = SW[5];

  assign GPIO_0[35:3] = 33'bZ;
  
  // Basic tag connections
  assign clk         =  EXT_CLOCK;
  assign reset       = ~KEY[1];
  assign demodin     =  GPIO_0[3];

  assign use_q       = SW[4];
  assign comm_enable = SW[3];
  assign use_uid     = SW[2];
  assign uid_byte_in = SW[17:10];
  
  // adc connections
  assign msp_sample_datain = SW[1];
  assign adc_sample_datain = SW[0];

/*
  // for debugging purposes: hold on to packet type after rx reset.
  reg  [8:0] rx_packet_reg;
  wire [8:0] rx_packet;
  always @ (posedge cmd_complete or posedge reset) begin
    if (reset) rx_packet_reg <= 0;
    else rx_packet_reg <= rx_packet;
  end

  wire [1:0] readwritebank;
  wire [7:0] readwriteptr;
  wire [7:0] readwords;
  reg  [1:0] readwritebank_reg;
  reg  [7:0] readwriteptr_reg;
  reg  [7:0] readwords_reg;
  always @ (posedge packet_complete or posedge reset) begin
    if (reset) begin
      readwritebank_reg <= 0;
      readwriteptr_reg  <= 0;
      readwords_reg     <= 0;
    end else if (rx_packet_reg[7] | rx_packet_reg[8]) begin
      readwritebank_reg <= readwritebank;
      readwriteptr_reg  <= readwriteptr;
      readwords_reg     <= readwords;
    end
  end
*/

  // red LED debugging connections
  assign LEDR[17] = reset;  // assign reset to LED for sanity check.
  assign LEDR[16] = 0;
  assign LEDR[15] = 0;
  assign LEDR[14] = 0;
  assign LEDR[13] = 0;
  assign LEDR[12] = 0;
  assign LEDR[11] = 0;
  assign LEDR[10:4] = 0;
  assign LEDR[3]   = 0;
  assign LEDR[2]   = 0;
  assign LEDR[1:0] = 0;

  assign LEDG[8:0]   = 0;

  assign GPIO_0[2] = modout;
  assign GPIO_0[1] = debug_clk;
  assign GPIO_0[0] = debug_out;
/*
sevenseg U_SEG0 (HEX0,readwritebank_reg);
sevenseg U_SEG1 (HEX1,readwriteptr_reg);
sevenseg U_SEG2 (HEX2,readwords_reg);
sevenseg U_SEG3 (HEX3,4'd3);
sevenseg U_SEG4 (HEX4,slotcounter[3:0]);
sevenseg U_SEG5 (HEX5,slotcounter[7:4]);
sevenseg U_SEG6 (HEX6,slotcounter[11:8]);
sevenseg U_SEG7 (HEX7,{1'b0,slotcounter[14:12]});
*/

top U_TOP (reset, clk, demodin, modout, // regular IO
           adc_sample_ctl, adc_sample_clk, adc_sample_datain,    // adc connections
           msp_sample_ctl, msp_sample_clk, msp_sample_datain, // msp430 connections
           uid_byte_in, uid_addr_out, uid_clk_out,
           writedataout, writedataclk, 
           use_uid, use_q, comm_enable,
           debug_clk, debug_out);

endmodule
*/
