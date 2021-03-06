`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:43:03 11/21/2010 
// Design Name: 
// Module Name:    fbwriter 
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
module fbwriter(
    // For Development
    reset,

    fifo_data,
    fifo_empty,
    fifo_rd_en,
    
    PLB_clk,
	 
	Bus2IP_Reset,    
    IP2Bus_MstRd_Req,
    IP2Bus_MstWr_Req,
    IP2Bus_Mst_Addr,
    IP2Bus_Mst_BE,
    IP2Bus_Mst_Lock,
    IP2Bus_Mst_Reset,
    Bus2IP_Mst_CmdAck,
    Bus2IP_Mst_Cmplt,
    Bus2IP_Mst_Error,
    Bus2IP_Mst_Rearbitrate,
    Bus2IP_Mst_Cmd_Timeout,
    Bus2IP_MstRd_d,
    Bus2IP_MstRd_src_rdy_n,
    IP2Bus_MstWr_d,
    Bus2IP_MstWr_dst_rdy_n
    );


parameter FB_BASE_ADDR                   = 10'b1001_0000_00;
parameter FB_CNTL_ADDR                   = 32'h40A0_8000;
parameter RAST_FBW_FIFO_LEN              = 96;
parameter LINE_LEN                       = 9;
parameter COL_LEN                        = 10;

parameter FLUSH_COL                      = 'd639;
parameter FLUSH_LINE                     = 'd479;

//parameter FLUSH_COL                      = 'd20;
//parameter FLUSH_LINE                     = 'd10;


// PLB Parameters
parameter C_MST_AWIDTH                   = 32;
parameter C_MST_DWIDTH                   = 32;


// FIFO interface
input      [0 : RAST_FBW_FIFO_LEN-1]      fifo_data;
input                                     fifo_empty;
output reg                                fifo_rd_en = 0;

input                                     reset;

// PLB interface
input                                     PLB_clk;
input                                     Bus2IP_Reset;
output                                    IP2Bus_MstRd_Req;
output                                    IP2Bus_MstWr_Req;
output     [0 : C_MST_AWIDTH-1]           IP2Bus_Mst_Addr;
output     [0 : C_MST_DWIDTH/8-1]         IP2Bus_Mst_BE;
output                                    IP2Bus_Mst_Lock;
output                                    IP2Bus_Mst_Reset;
input                                     Bus2IP_Mst_CmdAck;
input                                     Bus2IP_Mst_Cmplt;
input                                     Bus2IP_Mst_Error;
input                                     Bus2IP_Mst_Rearbitrate;
input                                     Bus2IP_Mst_Cmd_Timeout;
input      [0 : C_MST_DWIDTH-1]           Bus2IP_MstRd_d;
input                                     Bus2IP_MstRd_src_rdy_n;
output     [0 : C_MST_DWIDTH-1]           IP2Bus_MstWr_d;
input                                     Bus2IP_MstWr_dst_rdy_n;


  // writer registers  
  reg     [0 : LINE_LEN-1]               line;
  reg     [0 : COL_LEN-1]                col;
  reg     [0 : 31]                       color;
  reg                                    completed = 1;
  
  reg                                    buffer;
  reg                                    swap;

  reg                                    wr_req = 0;
  

  reg     [0 : LINE_LEN-1]               flush_line = 0;
  reg     [0 : COL_LEN-1]                flush_col = 0;
  
  wire flush_done = (flush_line == 'b0) && (flush_col == 'b0);

  // assign IPIF input wires
  assign IP2Bus_MstRd_Req                    = 0;
  assign IP2Bus_MstWr_Req                    = wr_req;
  //assign IP2Bus_Mst_Addr[0 : 10]             = FB_BASE_ADDR;
  //assign IP2Bus_Mst_Addr[11:19]              = line;
  //assign IP2Bus_Mst_Addr[20:29]              = col;
  //assign IP2Bus_Mst_Addr[30:31]              = 'b0;
  
  assign IP2Bus_Mst_Addr = (swap ? FB_CNTL_ADDR : {FB_BASE_ADDR, buffer, line, col, 2'b0} );
  
  
  assign IP2Bus_Mst_BE[0 : C_MST_DWIDTH/8-1] = ~('b0);
  assign IP2Bus_Mst_Lock                     = 0;
  assign IP2Bus_MstWr_d[0 : C_MST_DWIDTH-1]  = color;
    
  always @ (posedge PLB_clk)
    begin
	   if ( reset || Bus2IP_Reset ) 
		  completed <= 1;
		else if ( Bus2IP_Mst_Cmplt ) 
		  completed <= 1;
      else if ( completed && IP2Bus_MstWr_Req )
		  completed <= 0;
		else
		  completed <= completed;
	 end
  
  always @ (posedge PLB_clk)
    begin
      if ( reset || Bus2IP_Reset )
        fifo_rd_en <= 0;
		// want to make fifo_rd_en a pulse
      else if ( !fifo_empty && completed && !fifo_rd_en && flush_done)
        fifo_rd_en <= 1;
      else
        fifo_rd_en <= 0;
	 end

  // HACK!
  reg fifo_rd_en_delayed;
  always @ (posedge PLB_clk)
    fifo_rd_en_delayed <= fifo_rd_en;
  
  // flush line counter  
  always @ (posedge PLB_clk)
    if ( reset || Bus2IP_Reset )
      flush_line <= 9'd0;
    else if ( fifo_rd_en_delayed && fifo_data == ~('b0) )
      flush_line <= FLUSH_LINE;
    else if ( Bus2IP_Mst_Cmplt && !flush_done && flush_col == 'b0 )
      flush_line <= flush_line - 1;
    else 
      flush_line <= flush_line;
  
  // flush col counter  
  always @ (posedge PLB_clk)
    if ( reset || Bus2IP_Reset )
      flush_col <= 'd0;
    else if ( fifo_rd_en_delayed && (fifo_data == ~('b0)) )
      flush_col <= FLUSH_COL+1;
    else if ( Bus2IP_Mst_Cmplt && !flush_done )
      if ( flush_col == 'b0 )
        flush_col <= FLUSH_COL;
      else
        flush_col <= flush_col - 1;
    else 
      flush_col <= flush_col;
  
  reg flushing;
  always @ (posedge PLB_clk)
    begin
	   if ( reset || Bus2IP_Reset )
		 begin
           flushing <= 0;
           buffer   <= 0;
         end    
       else if (fifo_rd_en_delayed && (fifo_data == ~('b0)))
         begin
           flushing <= 1;
           buffer   <= ~buffer;
         end
       else if ( flush_done && flushing )
         begin
           // flip the buffer at the end of the flush
           flushing <= 0;
           buffer   <= buffer;
         end
       else 
         begin
           flushing <= flushing;
           buffer   <= buffer;
         end         
     end
  
  
  // assign line and col and color regs
  always @ (posedge PLB_clk)
    begin
	   if ( reset || Bus2IP_Reset )
		  begin
            line   <= 'h0;
            col    <= 'h0;
            color  <= 'h0;
		    wr_req <= 0;
            swap   <= 0;
		  end
	   else if ( Bus2IP_Mst_CmdAck )
		 begin
		   wr_req <= 0;
           swap   <= 0;
		 end
       else if ( !flush_done && completed && !swap )
	     begin
           line   <= flush_line;
           col    <= flush_col;
           color  <= 'd0;
           wr_req <= 1;
         end
       else if ( fifo_rd_en_delayed )
		  begin
		    // combinationally read whether it's a flush command
            if ( fifo_data == ~('b0) )
              begin
              // start flush operation
                //line   <= 'd479;
                //line   <= FLUSH_LINE;
                //col    <= 'd640; // give one request to change the controller
                //col    <= FLUSH_COL + 1;
                color  <= {FB_BASE_ADDR, buffer, 21'b0};
                wr_req <= 1;
                swap   <= 1;
              end
            else            
              begin
                line   <= fifo_data[15-LINE_LEN+1:15];
                col    <= fifo_data[31-COL_LEN+1:31];
                color  <= fifo_data[32:63];
		        wr_req <= 1;
              end
		  end
          
    end 
 
endmodule
