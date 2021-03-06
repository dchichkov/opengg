`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:20:46 11/21/2010 
// Design Name: 
// Module Name:    inst_bram 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module inst_bram( BRAM_rst, BRAM_clk, BRAM_en, BRAM_wen, 
                  BRAM_addr, BRAM_din, BRAM_dout,
                  clk, addr1, addr2, read0, read1, read2, read3, read4 );
    
    input              BRAM_rst;
    input              BRAM_clk;
    input              BRAM_en;
    input  [0:3]       BRAM_wen;
    input  [0:31]      BRAM_addr;
    output [0:31]      BRAM_din;
    input  [0:31]      BRAM_dout;
    
    input              clk;
    input  [31:0]      addr1;
    input  [31:0]      addr2;
    output reg [31:0]  read0;
    output reg [31:0]  read1;
    output reg [31:0]  read2;
    output reg [31:0]  read3;
    output reg [31:0]  read4;
        
    reg    [31:0]  mem [1023:0];  
    
    wire   [0:9]   addr;
    
    assign addr     = BRAM_addr [20:29];
    assign BRAM_din = mem[addr];
    assign wen      = BRAM_wen[0] | BRAM_wen[1] | BRAM_wen[2] | BRAM_wen[3];
    
    always @ (posedge BRAM_clk)
    begin
        if (wen)
            mem[addr] <= BRAM_dout;
    end
    
    always @ (posedge clk)
    begin
        read0 <= mem[addr1];
        read1 <= mem[addr2];
        read2 <= mem[addr2+1];
        read3 <= mem[addr2+2];
        read4 <= mem[addr2+3];
    end
    
endmodule
