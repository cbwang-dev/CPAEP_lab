module top_chip #(
    parameter int IO_DATA_WIDTH = 16,
    parameter int ACCUMULATION_WIDTH = 32,
    parameter int EXT_MEM_HEIGHT = 1<<20,
    parameter int EXT_MEM_WIDTH = ACCUMULATION_WIDTH,
    parameter int FEATURE_MAP_WIDTH = 1024,
    parameter int FEATURE_MAP_HEIGHT = 1024,
    parameter int INPUT_NB_CHANNELS = 64,
    parameter int OUTPUT_NB_CHANNELS = 64,
    parameter int KERNEL_SIZE = 3
  )
  (input logic clk,
   input logic arst_n_in,  //asynchronous reset, active low

   //external_memory
   //read port
  //  output logic unsigned[$clog2(EXT_MEM_HEIGHT)-1:0] ext_mem_read_addr,
  //  output logic ext_mem_read_en,
  //  input logic[EXT_MEM_WIDTH-1:0] ext_mem_qout,

   //write port
  //  output logic unsigned[$clog2(EXT_MEM_HEIGHT)-1:0] ext_mem_write_addr,
  //  output logic [EXT_MEM_WIDTH-1:0] ext_mem_din,
  //  output logic ext_mem_write_en,

   //system inputs and outputs
   input logic [IO_DATA_WIDTH-1:0] a_input,
   input logic a_valid,
   output logic a_ready,
   input logic [IO_DATA_WIDTH-1:0] b_input,
   input logic b_valid,
   output logic b_ready,

   //output
   output logic signed [IO_DATA_WIDTH-1:0] out,
   output logic output_valid,
   output logic [$clog2(FEATURE_MAP_WIDTH)-1:0] output_x,
   output logic [$clog2(FEATURE_MAP_HEIGHT)-1:0] output_y,
   output logic [$clog2(OUTPUT_NB_CHANNELS)-1:0] output_ch,


   input logic start,
   output logic running
  );


  logic write_a;
  logic write_b;
  logic amem_write_en,bmem_write_en;
  logic a1_sel,a2_sel,a3_sel,a4_sel,a5_sel,a6_sel,a7_sel,a8_sel,a9_sel;
  logic [15:0]amem1,amem2,amem3,amem4,amem5,amem6,amem7,amem8,amem9;
  logic [15:0]bmem1,bmem2,bmem3,bmem4,bmem5,bmem6,bmem7,bmem8,bmem9;
  logic signed [IO_DATA_WIDTH-1:0] out_test;

  `REG(IO_DATA_WIDTH, a1);
  `REG(IO_DATA_WIDTH, a2);
  `REG(IO_DATA_WIDTH, a3);
  `REG(IO_DATA_WIDTH, a4);
  `REG(IO_DATA_WIDTH, a5);
  `REG(IO_DATA_WIDTH, a6);
  `REG(IO_DATA_WIDTH, a7);
  `REG(IO_DATA_WIDTH, a8);
  `REG(IO_DATA_WIDTH, a9);

  `REG(IO_DATA_WIDTH, b1);
  `REG(IO_DATA_WIDTH, b2);
  `REG(IO_DATA_WIDTH, b3);
  `REG(IO_DATA_WIDTH, b4);
  `REG(IO_DATA_WIDTH, b5);
  `REG(IO_DATA_WIDTH, b6);
  `REG(IO_DATA_WIDTH, b7);
  `REG(IO_DATA_WIDTH, b8);
  `REG(IO_DATA_WIDTH, b9);

  `REG(IO_DATA_WIDTH, reg_out_test);
  assign reg_out_test_next = out_test;
  assign reg_out_test_we = 1;
  assign out = reg_out_test;


  assign a1_next = (a1_sel)? amem1:0;
  assign a2_next = (a2_sel)? amem2:0;
  assign a3_next = (a3_sel)? amem3:0;
  assign a4_next = (a4_sel)? amem4:0;
  assign a5_next = (a5_sel)? amem5:0;
  assign a6_next = (a6_sel)? amem6:0;
  assign a7_next = (a7_sel)? amem7:0;
  assign a8_next = (a8_sel)? amem8:0;
  assign a9_next = (a9_sel)? amem9:0;

  assign b1_next = bmem1;
  assign b2_next = bmem2;
  assign b3_next = bmem3;
  assign b4_next = bmem4;
  assign b5_next = bmem5;
  assign b6_next = bmem6;
  assign b7_next = bmem7;
  assign b8_next = bmem8;
  assign b9_next = bmem9;

  assign a1_we = write_a;
  assign a2_we = write_a;
  assign a3_we = write_a;
  assign a4_we = write_a;
  assign a5_we = write_a;
  assign a6_we = write_a;
  assign a7_we = write_a;
  assign a8_we = write_a;
  assign a9_we = write_a;

  assign b1_we = write_b;
  assign b2_we = write_b;
  assign b3_we = write_b;
  assign b4_we = write_b;
  assign b5_we = write_b;
  assign b6_we = write_b;
  assign b7_we = write_b;
  assign b8_we = write_b;
  assign b9_we = write_b;

  logic mac_valid_1;
  logic mac_valid_2;
  logic mac_valid_3;
  logic XXX;

  logic [14-1:0]amem_addr,a1_addr,a2_addr,a3_addr,a4_addr,a5_addr,a6_addr,a7_addr,a8_addr,a9_addr;
  logic [11-1:0]bmem_addr,b1_addr,b2_addr,b3_addr,b4_addr,b5_addr,b6_addr,b7_addr,b8_addr,b9_addr;
  controller_fsm #(
  .LOG2_OF_MEM_HEIGHT($clog2(EXT_MEM_HEIGHT)),
  .FEATURE_MAP_WIDTH(FEATURE_MAP_WIDTH),
  .FEATURE_MAP_HEIGHT(FEATURE_MAP_HEIGHT),
  .INPUT_NB_CHANNELS(INPUT_NB_CHANNELS),
  .OUTPUT_NB_CHANNELS(OUTPUT_NB_CHANNELS),
  .KERNEL_SIZE(KERNEL_SIZE)
  )
  controller
  (.clk(clk),
  .arst_n_in(arst_n_in),
  .start(start),
  .running(running),

  .a_valid(a_valid),
  .a_ready(a_ready),
  .b_valid(b_valid),
  .b_ready(b_ready),

  .write_a(write_a),
  .write_b(write_b),
  .mac_valid_1(mac_valid_1),
  .mac_valid_2(mac_valid_2),
  .mac_valid_3(mac_valid_3),
  .XXX(XXX),

  .output_valid(output_valid),
  .output_x(output_x),
  .output_y(output_y),
  .output_ch(output_ch),
  .amem_addr(amem_addr),
  .amem_write_en(amem_write_en),
  .bmem_addr(bmem_addr),
  .bmem_write_en(bmem_write_en),
  .a1_addr(a1_addr),
  .a2_addr(a2_addr),
  .a3_addr(a3_addr),
  .a4_addr(a4_addr),
  .a5_addr(a5_addr),
  .a6_addr(a6_addr),
  .a7_addr(a7_addr),
  .a8_addr(a8_addr),
  .a9_addr(a9_addr),
  .a1_sel(a1_sel),
  .a2_sel(a2_sel),
  .a3_sel(a3_sel),
  .a4_sel(a4_sel),
  .a5_sel(a5_sel),
  .a6_sel(a6_sel),
  .a7_sel(a7_sel),
  .a8_sel(a8_sel),
  .a9_sel(a9_sel),
  .b1_addr(b1_addr),
  .b2_addr(b2_addr),
  .b3_addr(b3_addr),
  .b4_addr(b4_addr),
  .b5_addr(b5_addr),
  .b6_addr(b6_addr),
  .b7_addr(b7_addr),
  .b8_addr(b8_addr),
  .b9_addr(b9_addr)
  );

logic [IO_DATA_WIDTH-1:0] fifo_out;

  mac #(
    .A_WIDTH(IO_DATA_WIDTH),
    .B_WIDTH(IO_DATA_WIDTH),
    .ACCUMULATOR_WIDTH(ACCUMULATION_WIDTH),
    .OUTPUT_WIDTH(ACCUMULATION_WIDTH),
    .OUTPUT_SCALE(0)
  )
  mac_unit
  ( .clk(clk),
    .arst_n_in(arst_n_in),
    .input_valid_1(mac_valid_1),
    .input_valid_2(mac_valid_2),
    .input_valid_3(mac_valid_3),
    .a1(a1),
    .a2(a2),
    .a3(a3),
    .a4(a4),
    .a5(a5),
    .a6(a6),
    .a7(a7),
    .a8(a8),
    .a9(a9),
    .b1(b1),
    .b2(b2),
    .b3(b3),
    .b4(b4),
    .b5(b5),
    .b6(b6),
    .b7(b7),
    .b8(b8),
    .b9(b9),
    .fifo_out(fifo_out),
    .out(out_test));

  // assign out = mac_out;
  // assign ext_mem_din = mac_out;
//logic [IO_DATA_WIDTH-1:0] fifo_out;
logic fifo_input_valid;
assign fifo_input_valid = mac_valid_3 || XXX;
logic [IO_DATA_WIDTH-1:0] fifo_din;
assign fifo_din = XXX ? 0 : out_test;

memory9 #(
  .WIDTH(16),
  .HEIGHT(16384),
  .USED_AS_EXTERNAL_MEM(0)
)memory_a
( .clk(clk),
  .read_addr1(a1_addr),
  .read_en1(write_a),
  .qout1(amem1),
  .read_addr2(a2_addr),
  .read_en2(write_a),
  .qout2(amem2),
  .read_addr3(a3_addr),
  .read_en3(write_a),
  .qout3(amem3),
  .read_addr4(a4_addr),
  .read_en4(write_a),
  .qout4(amem4),
  .read_addr5(a5_addr),
  .read_en5(write_a),
  .qout5(amem5),
  .read_addr6(a6_addr),
  .read_en6(write_a),
  .qout6(amem6),
  .read_addr7(a7_addr),
  .read_en7(write_a),
  .qout7(amem7),
  .read_addr8(a8_addr),
  .read_en8(write_a),
  .qout8(amem8),
  .read_addr9(a9_addr),
  .read_en9(write_a),
  .qout9(amem9),
  .write_addr(amem_addr),
  .din(a_input),
  .write_en(amem_write_en)
);

memory9 #(
  .WIDTH(16),
  .HEIGHT(2048),
  .USED_AS_EXTERNAL_MEM(0)
)memory_b
( .clk(clk),
  .read_addr1(b1_addr),
  .read_en1(write_b),
  .qout1(bmem1),
  .read_addr2(b2_addr),
  .read_en2(write_b),
  .qout2(bmem2),
  .read_addr3(b3_addr),
  .read_en3(write_b),
  .qout3(bmem3),
  .read_addr4(b4_addr),
  .read_en4(write_b),
  .qout4(bmem4),
  .read_addr5(b5_addr),
  .read_en5(write_b),
  .qout5(bmem5),
  .read_addr6(b6_addr),
  .read_en6(write_b),
  .qout6(bmem6),
  .read_addr7(b7_addr),
  .read_en7(write_b),
  .qout7(bmem7),
  .read_addr8(b8_addr),
  .read_en8(write_b),
  .qout8(bmem8),
  .read_addr9(b9_addr),
  .read_en9(write_b),
  .qout9(bmem9),
  .write_addr(bmem_addr),
  .din(b_input),
  .write_en(bmem_write_en)
);

fifo #(
  .WIDTH(16),
  .LOG2_OF_DEPTH(4),
  .USE_AS_EXTERNAL_FIFO(0)
)fifo_unit
(
  .clk(clk),
  .arst_n_in(arst_n_in),
  .din(fifo_din),
  .input_valid(fifo_input_valid),
  .input_ready(),
  .qout(fifo_out),
  .output_valid(),
  .output_ready(mac_valid_1 || (fifo_input_valid))
);

endmodule
