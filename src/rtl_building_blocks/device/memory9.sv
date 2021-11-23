//a simple pseudo-2 port memory (can read and write simultaneously)
//Feel free to write a single port memory (inout data, either write or read every cycle) to decrease your bandwidth
module memory9 #(
  parameter int WIDTH = 16,
  parameter int HEIGHT = 1,
  parameter bit USED_AS_EXTERNAL_MEM// for area, bandwidth and energy estimation
  )
  (
  input logic clk,

  //read port (0 cycle: there is no clock edge between changing the read_addr and the output)
  input logic unsigned[$clog2(HEIGHT)-1:0] read_addr1,
  input logic read_en1,
  output logic[WIDTH-1:0] qout1,
  input logic unsigned[$clog2(HEIGHT)-1:0] read_addr2,
  input logic read_en2,
  output logic[WIDTH-1:0] qout2,
  input logic unsigned[$clog2(HEIGHT)-1:0] read_addr3,
  input logic read_en3,
  output logic[WIDTH-1:0] qout3,
  input logic unsigned[$clog2(HEIGHT)-1:0] read_addr4,
  input logic read_en4,
  output logic[WIDTH-1:0] qout4,
  input logic unsigned[$clog2(HEIGHT)-1:0] read_addr5,
  input logic read_en5,
  output logic[WIDTH-1:0] qout5,
  input logic unsigned[$clog2(HEIGHT)-1:0] read_addr6,
  input logic read_en6,
  output logic[WIDTH-1:0] qout6,
  input logic unsigned[$clog2(HEIGHT)-1:0] read_addr7,
  input logic read_en7,
  output logic[WIDTH-1:0] qout7,
  input logic unsigned[$clog2(HEIGHT)-1:0] read_addr8,
  input logic read_en8,
  output logic[WIDTH-1:0] qout8,
  input logic unsigned[$clog2(HEIGHT)-1:0] read_addr9,
  input logic read_en9,
  output logic[WIDTH-1:0] qout9,

  //write port (data is written on the rising clock edge)
  input logic unsigned[$clog2(HEIGHT)-1:0] write_addr,
  input logic [WIDTH-1:0] din,
  input logic write_en
  );


  //storage
  logic [WIDTH-1:0] data [0:HEIGHT-1];

  always @ (posedge clk) begin
    if (write_en) begin
        data[write_addr] <= din;
    end
  end

  assign qout1 = read_en1 ? data[read_addr1] :'x ;
  assign qout2 = read_en2 ? data[read_addr2] :'x ;
  assign qout3 = read_en3 ? data[read_addr3] :'x ;
  assign qout4 = read_en4 ? data[read_addr4] :'x ;
  assign qout5 = read_en5 ? data[read_addr5] :'x ;
  assign qout6 = read_en6 ? data[read_addr6] :'x ;
  assign qout7 = read_en7 ? data[read_addr7] :'x ;
  assign qout8 = read_en8 ? data[read_addr8] :'x ;
  assign qout9 = read_en9 ? data[read_addr9] :'x ;

  //area logging
  initial begin
    #0;
    if(!USED_AS_EXTERNAL_MEM) begin
      if (HEIGHT<256) begin
        tbench_top.area += 17*WIDTH*HEIGHT;
        $display("%m added %d to area", 17*WIDTH*HEIGHT);
      end else begin
        tbench_top.area += 1*WIDTH*HEIGHT;
        $display("%m added %d to area", 1*WIDTH*HEIGHT);
      end
    end
  end

  //energy logging:
  always @(posedge clk) begin
    if(read_en1)
      tbench_top.energy += WIDTH*(USED_AS_EXTERNAL_MEM?1:0.1);
    if(read_en2)
      tbench_top.energy += WIDTH*(USED_AS_EXTERNAL_MEM?1:0.1);
    if(read_en3)
      tbench_top.energy += WIDTH*(USED_AS_EXTERNAL_MEM?1:0.1);
    if(read_en4)
      tbench_top.energy += WIDTH*(USED_AS_EXTERNAL_MEM?1:0.1);
    if(read_en5)
      tbench_top.energy += WIDTH*(USED_AS_EXTERNAL_MEM?1:0.1);
    if(read_en6)
      tbench_top.energy += WIDTH*(USED_AS_EXTERNAL_MEM?1:0.1);
    if(read_en7)
      tbench_top.energy += WIDTH*(USED_AS_EXTERNAL_MEM?1:0.1);
    if(read_en8)
      tbench_top.energy += WIDTH*(USED_AS_EXTERNAL_MEM?1:0.1);
    if(read_en9)
      tbench_top.energy += WIDTH*(USED_AS_EXTERNAL_MEM?1:0.1);
  end
  always @(posedge clk) begin
    if(write_en)
      tbench_top.energy += WIDTH*(USED_AS_EXTERNAL_MEM?1:0.1);
  end

endmodule
