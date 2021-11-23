module mac #(
  parameter int A_WIDTH = 16,
  parameter int B_WIDTH = 16,
  parameter int ACCUMULATOR_WIDTH = 32,
  parameter int OUTPUT_WIDTH = 16,
  parameter int OUTPUT_SCALE = 0
  )
  (
  input logic clk,
  input logic arst_n_in, //asynchronous reset, active low

  //input interface
  input logic input_valid_1, 
  input logic input_valid_2,
  input logic input_valid_3,
//   input logic accumulate_internal, //accumulate (accumulator <= a*b + accumulator) if high (1) or restart accumulation (accumulator <= a*b+0) if low (0)
//   input logic [ACCUMULATOR_WIDTH-1:0] partial_sum_in,
  input logic signed [A_WIDTH-1:0] a1,
   input logic signed [A_WIDTH-1:0] a2,
   input logic signed [A_WIDTH-1:0] a3,
   input logic signed [A_WIDTH-1:0] a4,
   input logic signed [A_WIDTH-1:0] a5,
   input logic signed [A_WIDTH-1:0] a6,
   input logic signed [A_WIDTH-1:0] a7,
   input logic signed [A_WIDTH-1:0] a8,
   input logic signed [A_WIDTH-1:0] a9,
  input logic signed [B_WIDTH-1:0] b1,
   input logic signed [B_WIDTH-1:0] b2,
   input logic signed [B_WIDTH-1:0] b3,
   input logic signed [B_WIDTH-1:0] b4,
   input logic signed [B_WIDTH-1:0] b5,
   input logic signed [B_WIDTH-1:0] b6,
   input logic signed [B_WIDTH-1:0] b7,
   input logic signed [B_WIDTH-1:0] b8,
   input logic signed [B_WIDTH-1:0] b9,
  input logic signed [ACCUMULATOR_WIDTH-1:0] fifo_out,

  //output
  output logic signed [OUTPUT_WIDTH-1:0] out
  );
  /*

                a -->  *  <-- b
                       |
                       |  ____________
                       \ /          __\______
                        +          /1___0__SEL\ <-- accumulate_internal
                        |           |   \------------ <-- partial_sum_in
                     ___|___________|----------> >> ---> out__
                    |  d            q  |
    input_valid --> |we       arst_n_in| <-- arst_n_in
                    |___clk____________|
                         |
                        clk
  */

  logic signed [ACCUMULATOR_WIDTH-1:0] product1, product2, product3, product4, product5, product6, product7, product8, product9, sum1, sum2, sum3, sum4, sum5;
   multiplier #(  .A_WIDTH(A_WIDTH),
                  .B_WIDTH(B_WIDTH),
                  .OUT_WIDTH(ACCUMULATOR_WIDTH),
                  .OUT_SCALE(0))
      mul_1
      (  .a(a1),
         .b(b1),
         .out(product1));

   multiplier #(  .A_WIDTH(A_WIDTH),
                  .B_WIDTH(B_WIDTH),
                  .OUT_WIDTH(ACCUMULATOR_WIDTH),
                  .OUT_SCALE(0))
      mul_2
      (.a(a2),
      .b(b2),
      .out(product2));
   
   multiplier #(  .A_WIDTH(A_WIDTH),
                  .B_WIDTH(B_WIDTH),
                  .OUT_WIDTH(ACCUMULATOR_WIDTH),
                  .OUT_SCALE(0))
      mul_3
      (.a(a3),
      .b(b3),
      .out(product3));

   multiplier #(  .A_WIDTH(A_WIDTH),
                  .B_WIDTH(B_WIDTH),
                  .OUT_WIDTH(ACCUMULATOR_WIDTH),
                  .OUT_SCALE(0))
      mul_4
      (.a(a4),
      .b(b4),
      .out(product4));

   multiplier #(  .A_WIDTH(A_WIDTH),
                  .B_WIDTH(B_WIDTH),
                  .OUT_WIDTH(ACCUMULATOR_WIDTH),
                  .OUT_SCALE(0))
      mul_5
      (.a(a5),
      .b(b5),
      .out(product5));

   multiplier #(  .A_WIDTH(A_WIDTH),
                  .B_WIDTH(B_WIDTH),
                  .OUT_WIDTH(ACCUMULATOR_WIDTH),
                  .OUT_SCALE(0))
      mul_6
      (.a(a6),
      .b(b6),
      .out(product6));

   multiplier #(  .A_WIDTH(A_WIDTH),
                  .B_WIDTH(B_WIDTH),
                  .OUT_WIDTH(ACCUMULATOR_WIDTH),
                  .OUT_SCALE(0)) 
      mul_7
      (.a(a7),
      .b(b7),
      .out(product7));

   multiplier #(  .A_WIDTH(A_WIDTH),
                  .B_WIDTH(B_WIDTH),
                  .OUT_WIDTH(ACCUMULATOR_WIDTH),
                  .OUT_SCALE(0))
      mul_8
      (.a(a8),
      .b(b8),
      .out(product8));

   multiplier #(  .A_WIDTH(A_WIDTH),
                  .B_WIDTH(B_WIDTH),
                  .OUT_WIDTH(ACCUMULATOR_WIDTH),
                  .OUT_SCALE(0))
      mul_9
      (.a(a9),
      .b(b9),
      .out(product9));







  //makes register with we accumulator_value_we, qout accumulator_value, din accumulator_value_next, clk clk and arst_n_in arst_n_in
  //see register.sv
  `REG(ACCUMULATOR_WIDTH, reg_1);
   `REG(ACCUMULATOR_WIDTH, reg_2);
   `REG(ACCUMULATOR_WIDTH, reg_3);
   `REG(ACCUMULATOR_WIDTH, reg_4);
   `REG(ACCUMULATOR_WIDTH, reg_5);
   `REG(ACCUMULATOR_WIDTH, reg_6);
   `REG(ACCUMULATOR_WIDTH, reg_7);
   `REG(ACCUMULATOR_WIDTH, reg_8);

  assign reg_1_we = input_valid_1;
  assign reg_1_next = sum1;
   assign reg_2_we = input_valid_1;
   assign reg_2_next = sum2;
   assign reg_3_we = input_valid_1;
   assign reg_3_next = sum3;
   assign reg_4_we = input_valid_1;
   assign reg_4_next = sum4;
   assign reg_5_we = input_valid_1;
   assign reg_5_next = product9;
  assign reg_6_we = input_valid_1;
  assign reg_6_next = fifo_out;
  assign reg_7_next= sum3;
  assign reg_7_we = input_valid_2;
  assign reg_8_next= sum5;
  assign reg_8_we = input_valid_2;

   logic signed [ACCUMULATOR_WIDTH-1:0] MUX1;
   assign MUX1 = input_valid_1 ? product1 : (input_valid_2 ? reg_1 : 0);
   logic signed [ACCUMULATOR_WIDTH-1:0] MUX2;
   assign MUX2 = input_valid_1 ? product2 : (input_valid_2 ? reg_2 : 0);
   logic signed [ACCUMULATOR_WIDTH-1:0] MUX3;
   assign MUX3 = input_valid_1 ? product3 : (input_valid_2 ? reg_3 : 0);
   logic signed [ACCUMULATOR_WIDTH-1:0] MUX4;
   assign MUX4 = input_valid_1 ? product4 : (input_valid_2 ? reg_4 : 0);
   logic signed [ACCUMULATOR_WIDTH-1:0] MUX5;
   assign MUX5 = input_valid_1 ? product5 : (input_valid_2 ? sum1 : 0);
   logic signed [ACCUMULATOR_WIDTH-1:0] MUX6;
   assign MUX6 = input_valid_1 ? product6 : (input_valid_2 ? sum2 : 0);
   logic signed [ACCUMULATOR_WIDTH-1:0] MUX7;
   assign MUX7 = input_valid_1 ? product7 : (input_valid_3 ? reg_7 : 0);
   logic signed [ACCUMULATOR_WIDTH-1:0] MUX8;
   assign MUX8 = input_valid_1 ? product8 : (input_valid_3 ? reg_8 : 0);

  adder #( .A_WIDTH(ACCUMULATOR_WIDTH),
           .B_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_SCALE(0))
    add_1
    (.a(MUX1),
     .b(MUX2),
     .out(sum1));

   adder #( .A_WIDTH(ACCUMULATOR_WIDTH),
             .B_WIDTH(ACCUMULATOR_WIDTH),
             .OUT_WIDTH(ACCUMULATOR_WIDTH),
             .OUT_SCALE(0))
      add_2
      (.a(MUX3),
         .b(MUX4),
         .out(sum2));
   
   adder #( .A_WIDTH(ACCUMULATOR_WIDTH),
             .B_WIDTH(ACCUMULATOR_WIDTH),
             .OUT_WIDTH(ACCUMULATOR_WIDTH),
             .OUT_SCALE(0))
      add_3
      (.a(MUX5),
         .b(MUX6),
         .out(sum3));

   adder #( .A_WIDTH(ACCUMULATOR_WIDTH),
             .B_WIDTH(ACCUMULATOR_WIDTH),
             .OUT_WIDTH(ACCUMULATOR_WIDTH),
             .OUT_SCALE(0))
      add_4
      (.a(MUX7),
         .b(MUX8),
         .out(sum4));
	
   adder #( .A_WIDTH(ACCUMULATOR_WIDTH),
             .B_WIDTH(ACCUMULATOR_WIDTH),
             .OUT_WIDTH(ACCUMULATOR_WIDTH),
             .OUT_SCALE(0))
      add_5
      (.a(reg_5),
         .b(reg_6),
         .out(sum5));

  assign out = sum4 >>> OUTPUT_SCALE;

endmodule
