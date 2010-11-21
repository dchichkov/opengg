`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:16:13 10/15/2010 
// Design Name: 
// Module Name:    fetch 
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
`include "gl_defines.v"

module gl_core_internal(clk, reset, bram_enable, bram_rst, bram_addr_out, bram_data_in, bram_addr);

    
    input           clk;                            // clock signal
    input           reset;                          // pipeline reset

    /* BRAM Control Signals */
    output          bram_enable;                    // bram enable
    output          bram_rst;                       // bram reset
    output [31:0]   bram_addr;                      // bram address port
    input  [31:0]   bram_data_in;                   // data from bram
    
    output reg [31:0] bram_addr_out;                // bram address to read from
    wire [31:0]     bram_read_0;                    // bram data read 
    wire [31:0]     bram_read_1;                    // 
    wire [31:0]     bram_read_2;                    // 
    wire [31:0]     bram_read_3;                    // 
    
    /* Matrix Controller Signals */
    wire            mul_en;                         // matrix multiply enable
    wire            matrix_mode;                    // matrix mode
    wire            mul_type;                       // matrix multiply type (4x4 * 4x4 (1) or 4x4 * 4x1 (0))
    
    wire            matrix_mul_en,                  // matrix multiply enable
                    matrix_mode_out,                // connect between mat_mul.matrix_mode_out and mat_ctrl
                    matrix_mul_type,                // matrix multiply type (4x4 * 4x4 (1) or 4x4 * 4x1 (0))
                    matrix_ctrl_write_en;           // matrix write enable
    
    wire [127:0]    peek_out_0;                     // matrix_ctrl peek
    wire [127:0]    peek_out_1;                     // matrix_ctrl peek
    wire [127:0]    peek_out_2;                     // matrix_ctrl peek
    wire [127:0]    peek_out_3;                     // matrix_ctrl peek
    wire [127:0]    mc_write_in_0;                  // matrix_ctrl write in
    wire [127:0]    mc_write_in_1;                  // matrix_ctrl write in
    wire [127:0]    mc_write_in_2;                  // matrix_ctrl write in
    wire [127:0]    mc_write_in_3;                  // matrix_ctrl write in
    wire [127:0]    mc_data_in;                     // matrix_ctrl input line for push

    wire [31:0]     v_x;
    wire [31:0]     v_y;
    wire [31:0]     v_width;
    wire [31:0]     v_height;
    
    /* Viewport Registers */
    
    
    /* Pipeline Control Signals */
    wire            stall;                          // fetch stall
    
    
    /*********************************************/
    /*  FETCH                                    */
    /*********************************************/
    
    /*wire  [31:0]    inst;                           // instruction fetched from BRAM
    
    gl_fetch fetch( .inst_out(inst), 
                    .inst_in(bram_data_in), 
                    .inst_addr(bram_addr_out),
                    .clk(clk), 
                    .stall(stall), 
                    .reset(reset));*/
    
    wire [31:0]     fetch_inst_in;                   // instruction read from BRAM (addr 1)
    wire [31:0]     fetch_inst_out;                  // instruction output to decode
    wire [31:0]     fetch_inst_addr;                 // bram address to read instruction (addr 1)
    wire [31:0]     decode_bram_addr;                // bram address of data
    
    gl_fetch fetch(.inst_out(fetch_inst_out), 
                   .inst_in(fetch_inst_in), 
                   .inst_addr(fetch_inst_addr), 
                   .decode_bram_addr(decode_bram_addr),
                   .clk(clk),
                   .stall(stall), 
                   .reset(fetch_rst));
    
    /*********************************************/
    /*  DECODE                                   */
    /*********************************************/

    wire [7:0]  opcode;
    wire [22:0] imm;
    wire        inst_type;
    
    assign  opcode      = fetch_inst_out[7:0];
    assign  imm         = fetch_inst_out[30:8];
    assign  inst_type   = fetch_inst_out[31];
    
    gl_decode  dc (.clk(clk), .opcode(opcode), .imm(imm), .type(inst_type), 
                  .bram_addr_out(decode_addr_out),
                  .bram_addr_in(decode_bram_addr),
                  .bram_read_in_0(bram_read_0), 
                  .bram_read_in_1(bram_read_1), 
                  .bram_read_in_2(bram_read_2), 
                  .bram_read_in_3(bram_read_3),
                  .viewport_x(v_min_x), 
                  .viewport_y(v_min_y), 
                  .viewport_width(v_max_x), 
                  .viewport_height(v_max_y),
                  .push_en(push_en), 
                  .pop_en(pop_en), 
                  .color_in(color_in), 
                  .color_out(color_out),
                  .matrix_load_en(matrix_load_en), 
                  .matrix_load_id_en(matrix_load_id_en),
                  .matrix_mul_en(matrix_mul_en), 
                  .matrix_mul_type(matrix_mul_type), 
                  .matrix_mode_out(matrix_mode_out),
                  .perspective_div_en(perspective_div_en),
                  .stall(stall) );
    
    /*
    wire [7:0]  opcode;
    wire [22:0] imm;
    wire        inst_type;
    
    assign  opcode      = inst[7:0];
    assign  imm         = inst[30:8];
    assign  inst_type   = inst[31];
    
    gl_decode decode(   .opcode(opcode),
                        .imm(imm),
                        .type(inst_type),
                        .clk(clk), 
                        .stall(stall)); */

    /*********************************************/
    /*  EXECUTE                                  */
    /*********************************************/   
        
    matrix_ctrl matctr( .clk(clk), 
                        .matrix_mode(matrix_mode_out), 
                        .pop_en(pop_en), 
                        .push_en(push_en), 
                        .data_in(data_in), 
                        .data_out(data_out),
                        .write_en(matrix_ctrl_write_en),
                        .peek_out_0(peek_out_0), 
                        .peek_out_1(peek_out_1), 
                        .peek_out_2(peek_out_2), 
                        .peek_out_3(peek_out_3),
                        .write_in_0(mc_write_in_0), 
                        .write_in_1(mc_write_in_1), 
                        .write_in_2(mc_write_in_2), 
                        .write_in_3(mc_write_in_3) );
    
    
    matrix_mul matmul(  .clk(clk), 
                        .en(mul_en), 
                        .matrix_mode_in(matrix_mode), 
                        .matrix_mode_out(matrix_mode_out),
                        .mul_type(mul_type), 
                        .bram_addr_in(bram_addr_in), 
                        .bram_addr_out(bram_addr_out), 
                        .bram_read_in_0(bram_read_0), 
                        .bram_read_in_1(bram_read_1), 
                        .bram_read_in_2(bram_read_2), 
                        .bram_read_in_3(bram_read_3),
                        .matrix_peek_0(peek_out_0), 
                        .matrix_peek_1(peek_out_1), 
                        .matrix_peek_2(peek_out_2), 
                        .matrix_peek_3(peek_out_3),
                        .matrix_write_en(matrix_ctrl_write_en), 
                        .matrix_write_out_0(mc_write_in_0), 
                        .matrix_write_out_1(mc_write_in_1), 
                        .matrix_write_out_2(mc_write_in_2), 
                        .matrix_write_out_3(mc_write_in_3) );
    
    
    /* Perspective Division */
    wire [31:0]         pd_x;
    wire [31:0]         pd_y;
    wire [31:0]         pd_z;
    wire [31:0]         pd_w;
    
    reg  [31:0]         pd_vert_x;
    reg  [31:0]         pd_vert_y;
    reg  [31:0]         pd_vert_z;
    
    //mc_write_in_0[31:0];
    
    fp_div pd_div1(.a(pd_x), .b(pd_w), .result(pd_result_x));
    fp_div pd_div2(.a(pd_y), .b(pd_w), .result(pd_result_y));
    fp_div pd_div3(.a(pd_z), .b(pd_w), .result(pd_result_z));
    
    always @ (posedge clk)
    begin
        if (pd_en)
        begin
            pd_vert_x <= pd_result_x;
            pd_vert_y <= pd_result_y;
            pd_vert_z <= pd_result_z;
        end
    end
    
    /* Viewport Transformation */
    
    wire [31:0] vt_mulx_result;
    wire [31:0] vt_muly_result;
    wire [31:0] vt_addx_result;
    wire [31:0] vt_addy_result;
    wire [31:0] vt_addx2_result;
    wire [31:0] vt_addy2_result;
    
    fp_mul vt_mulx  (.a(pd_vert_x), .b(v_width), .result(vt_mulx_result));
    fp_add vt_addx  (.a(vt_mulx_result), .b(v_width), .result(vt_addx_result));
    fp_add vt_addx2 (.a(v_x), .b(vt_addx_result), .result(vt_addx2_result));
    
    fp_mul vt_muly  (.a(pd_vert_y), .b(v_width), .result(vt_muly_result));
    fp_add vt_addy  (.a(vt_muly_result), .b(v_width), .result(vt_addy_result));
    fp_add vt_addy2 (.a(v_y), .b(vt_addy_result), .result(vt_addy2_result));
    
    reg [31:0] x_result;
    reg [31:0] y_result;
    
    always @ (posedge clk)
    begin
        if (vt_en)
        begin
             // write to fifo
             x_result <= vt_addx2_result;
             y_result <= vt_addy2_result;
        end
    end
    
    assign bram_enable = 1;
    assign bram_rst = 0;
    
    
endmodule




                
