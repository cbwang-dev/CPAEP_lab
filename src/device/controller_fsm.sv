module controller_fsm #(
  parameter int LOG2_OF_MEM_HEIGHT = 20,
  parameter int FEATURE_MAP_WIDTH = 1024,
  parameter int FEATURE_MAP_HEIGHT = 1024,
  parameter int INPUT_NB_CHANNELS = 64,
  parameter int OUTPUT_NB_CHANNELS = 64,
  parameter int KERNEL_SIZE = 3
  )
  (input logic clk,
  input logic arst_n_in, //asynchronous reset, active low

  input logic start,
  output logic running,

  //memory control interface
  // output logic mem_we,
  // output logic [LOG2_OF_MEM_HEIGHT-1:0] mem_write_addr,
  // output logic mem_re,
  // output logic [LOG2_OF_MEM_HEIGHT-1:0] mem_read_addr,

  //datapad control interface & external handshaking communication of a and b
  input logic a_valid,
  input logic b_valid,
  output logic b_ready,
  output logic a_ready,
  output logic write_a,
  output logic write_b,
  output logic mac_valid_1, mac_valid_2,mac_valid_3,
   output logic XXX,
  // output logic mac_accumulate_internal,
  // output logic mac_accumulate_with_0,

  output logic output_valid,
  output logic [32-1:0] output_x,
  output logic [32-1:0] output_y,
  output logic [32-1:0] output_ch,
  output logic [14-1:0] amem_addr,
  output logic amem_write_en,
  output logic [10:0] bmem_addr,
  output logic bmem_write_en,
  output logic [14-1:0]a1_addr,
  output logic [14-1:0]a2_addr,
  output logic [14-1:0]a3_addr,
  output logic [14-1:0]a4_addr,
  output logic [14-1:0]a5_addr,
  output logic [14-1:0]a6_addr,
  output logic [14-1:0]a7_addr,
  output logic [14-1:0]a8_addr,
  output logic [14-1:0]a9_addr,
  output logic [11-1:0]b1_addr,
  output logic [11-1:0]b2_addr,
  output logic [11-1:0]b3_addr,
  output logic [11-1:0]b4_addr,
  output logic [11-1:0]b5_addr,
  output logic [11-1:0]b6_addr,
  output logic [11-1:0]b7_addr,
  output logic [11-1:0]b8_addr,
  output logic [11-1:0]b9_addr,
  output logic a1_sel,a2_sel,a3_sel,a4_sel,a5_sel,a6_sel,a7_sel,a8_sel,a9_sel
  );
  //loop counters (see register.sv for macro)
  //`REG(32, k_v);
  //`REG(32, k_h);
  `REG(32, x);
  `REG(32, y);
  `REG(32, ch_in);
  `REG(32, ch_out);
  `REG(14,a1_addrd);
  `REG(14,a2_addrd);
  `REG(14,a3_addrd);
  `REG(14,a4_addrd);
  `REG(14,a5_addrd);
  `REG(14,a6_addrd);
  `REG(14,a7_addrd);
  `REG(14,a8_addrd);
  `REG(14,a9_addrd);
  `REG(11,b1_addrd);
  `REG(11,b2_addrd);
  `REG(11,b3_addrd);
  `REG(11,b4_addrd);
  `REG(11,b5_addrd);
  `REG(11,b6_addrd);
  `REG(11,b7_addrd);
  `REG(11,b8_addrd);
  `REG(11,b9_addrd);
  assign a1_addrd_we = 1;
  assign a2_addrd_we = 1;
  assign a3_addrd_we = 1;
  assign a4_addrd_we = 1;
  assign a5_addrd_we = 1;
  assign a6_addrd_we = 1;
  assign a7_addrd_we = 1;
  assign a8_addrd_we = 1;
  assign a9_addrd_we = 1;

  assign b1_addrd_we = 1;
  assign b2_addrd_we = 1;
  assign b3_addrd_we = 1;
  assign b4_addrd_we = 1;
  assign b5_addrd_we = 1;
  assign b6_addrd_we = 1;
  assign b7_addrd_we = 1;
  assign b8_addrd_we = 1;
  assign b9_addrd_we = 1;

  assign a1_addr = a1_addrd_next;
  assign a2_addr = a2_addrd_next;
  assign a3_addr = a3_addrd_next;
  assign a4_addr = a4_addrd_next;
  assign a5_addr = a5_addrd_next;
  assign a6_addr = a6_addrd_next;
  assign a7_addr = a7_addrd_next;
  assign a8_addr = a8_addrd_next;
  assign a9_addr = a9_addrd_next;
  
  assign b1_addr = b1_addrd_next;
  assign b2_addr = b2_addrd_next;
  assign b3_addr = b3_addrd_next;
  assign b4_addr = b4_addrd_next;
  assign b5_addr = b5_addrd_next;
  assign b6_addr = b6_addrd_next;
  assign b7_addr = b7_addrd_next;
  assign b8_addr = b8_addrd_next;
  assign b9_addr = b9_addrd_next;

  assign a1_addrd_next=(x-KERNEL_SIZE/2 >= 0 && x-KERNEL_SIZE/2 < FEATURE_MAP_WIDTH && y-KERNEL_SIZE/2 >= 0 && y-KERNEL_SIZE/2 < FEATURE_MAP_HEIGHT)? (256*(x-KERNEL_SIZE/2)+4*(y-KERNEL_SIZE/2)+ch_in):0;
  assign a2_addrd_next=(x+1-KERNEL_SIZE/2 >= 0 && x+1-KERNEL_SIZE/2 < FEATURE_MAP_WIDTH && y-KERNEL_SIZE/2 >= 0 && y-KERNEL_SIZE/2 < FEATURE_MAP_HEIGHT)? (256*(x+1-KERNEL_SIZE/2)+4*(y-KERNEL_SIZE/2)+ch_in):0;
  assign a3_addrd_next=(x+2-KERNEL_SIZE/2 >= 0 && x+2-KERNEL_SIZE/2 < FEATURE_MAP_WIDTH && y-KERNEL_SIZE/2 >= 0 && y-KERNEL_SIZE/2 < FEATURE_MAP_HEIGHT)? (256*(x+2-KERNEL_SIZE/2)+4*(y-KERNEL_SIZE/2)+ch_in):0;
  assign a4_addrd_next=(x-KERNEL_SIZE/2 >= 0 && x-KERNEL_SIZE/2 < FEATURE_MAP_WIDTH && y+1-KERNEL_SIZE/2 >= 0 && y+1-KERNEL_SIZE/2 < FEATURE_MAP_HEIGHT)? (256*(x-KERNEL_SIZE/2)+4*(y+1-KERNEL_SIZE/2)+ch_in):0;
  assign a5_addrd_next=(x+1-KERNEL_SIZE/2 >= 0 && x+1-KERNEL_SIZE/2 < FEATURE_MAP_WIDTH && y+1-KERNEL_SIZE/2 >= 0 && y+1-KERNEL_SIZE/2 < FEATURE_MAP_HEIGHT)? (256*(x+1-KERNEL_SIZE/2)+4*(y+1-KERNEL_SIZE/2)+ch_in):0;
  assign a6_addrd_next=(x+2-KERNEL_SIZE/2 >= 0 && x+2-KERNEL_SIZE/2 < FEATURE_MAP_WIDTH && y+1-KERNEL_SIZE/2 >= 0 && y+1-KERNEL_SIZE/2 < FEATURE_MAP_HEIGHT)? (256*(x+2-KERNEL_SIZE/2)+4*(y+1-KERNEL_SIZE/2)+ch_in):0;
  assign a7_addrd_next=(x-KERNEL_SIZE/2 >= 0 && x-KERNEL_SIZE/2 < FEATURE_MAP_WIDTH && y+2-KERNEL_SIZE/2 >= 0 && y+2-KERNEL_SIZE/2 < FEATURE_MAP_HEIGHT)? (256*(x-KERNEL_SIZE/2)+4*(y+2-KERNEL_SIZE/2)+ch_in):0;
  assign a8_addrd_next=(x+1-KERNEL_SIZE/2 >= 0 && x+1-KERNEL_SIZE/2 < FEATURE_MAP_WIDTH && y+2-KERNEL_SIZE/2 >= 0 && y+2-KERNEL_SIZE/2 < FEATURE_MAP_HEIGHT)? (256*(x+1-KERNEL_SIZE/2)+4*(y+2-KERNEL_SIZE/2)+ch_in):0;
  assign a9_addrd_next=(x+2-KERNEL_SIZE/2 >= 0 && x+2-KERNEL_SIZE/2 < FEATURE_MAP_WIDTH && y+2-KERNEL_SIZE/2 >= 0 && y+2-KERNEL_SIZE/2 < FEATURE_MAP_HEIGHT)? (256*(x+2-KERNEL_SIZE/2)+4*(y+2-KERNEL_SIZE/2)+ch_in):0;

  assign b1_addrd_next= 0+9*ch_out+288*ch_in;
  assign b2_addrd_next= 1+9*ch_out+288*ch_in;
  assign b3_addrd_next= 2+9*ch_out+288*ch_in;
  assign b4_addrd_next= 3+9*ch_out+288*ch_in;
  assign b5_addrd_next= 4+9*ch_out+288*ch_in;
  assign b6_addrd_next= 5+9*ch_out+288*ch_in;
  assign b7_addrd_next= 6+9*ch_out+288*ch_in;
  assign b8_addrd_next= 7+9*ch_out+288*ch_in;
  assign b9_addrd_next= 8+9*ch_out+288*ch_in;

  assign a1_sel=(x-KERNEL_SIZE/2 >= 0 && x-KERNEL_SIZE/2 < FEATURE_MAP_WIDTH && y-KERNEL_SIZE/2 >= 0 && y-KERNEL_SIZE/2 < FEATURE_MAP_HEIGHT)? 1:0;
  assign a2_sel=(x+1-KERNEL_SIZE/2 >= 0 && x+1-KERNEL_SIZE/2 < FEATURE_MAP_WIDTH && y-KERNEL_SIZE/2 >= 0 && y-KERNEL_SIZE/2 < FEATURE_MAP_HEIGHT)? 1:0;
  assign a3_sel=(x+2-KERNEL_SIZE/2 >= 0 && x+2-KERNEL_SIZE/2 < FEATURE_MAP_WIDTH && y-KERNEL_SIZE/2 >= 0 && y-KERNEL_SIZE/2 < FEATURE_MAP_HEIGHT )? 1:0;
  assign a4_sel=(x-KERNEL_SIZE/2 >= 0 && x-KERNEL_SIZE/2 < FEATURE_MAP_WIDTH && y+1-KERNEL_SIZE/2 >= 0 && y+1-KERNEL_SIZE/2 < FEATURE_MAP_HEIGHT )? 1:0;
  assign a5_sel=(x+1-KERNEL_SIZE/2 >= 0 && x+1-KERNEL_SIZE/2 < FEATURE_MAP_WIDTH && y+1-KERNEL_SIZE/2 >= 0 && y+1-KERNEL_SIZE/2 < FEATURE_MAP_HEIGHT )? 1:0;
  assign a6_sel=(x+2-KERNEL_SIZE/2 >= 0 && x+2-KERNEL_SIZE/2 < FEATURE_MAP_WIDTH && y+1-KERNEL_SIZE/2 >= 0 && y+1-KERNEL_SIZE/2 < FEATURE_MAP_HEIGHT )? 1:0;
  assign a7_sel=(x-KERNEL_SIZE/2 >= 0 && x-KERNEL_SIZE/2 < FEATURE_MAP_WIDTH && y+2-KERNEL_SIZE/2 >= 0 && y+2-KERNEL_SIZE/2 < FEATURE_MAP_HEIGHT )? 1:0;
  assign a8_sel=(x+1-KERNEL_SIZE/2 >= 0 && x+1-KERNEL_SIZE/2 < FEATURE_MAP_WIDTH && y+2-KERNEL_SIZE/2 >= 0 && y+2-KERNEL_SIZE/2 < FEATURE_MAP_HEIGHT )? 1:0;
  assign a9_sel=(x+2-KERNEL_SIZE/2 >= 0 && x+2-KERNEL_SIZE/2 < FEATURE_MAP_WIDTH && y+2-KERNEL_SIZE/2 >= 0 && y+2-KERNEL_SIZE/2 < FEATURE_MAP_HEIGHT )? 1:0;

  logic  reset_x, reset_y, reset_ch_in, reset_ch_out;
  //assign k_v_next = reset_k_v ? 0 : k_v + 1;
  //assign k_h_next = reset_k_h ? 0 : k_h + 1;
  assign x_next = reset_x ? 0 : x + 1;
  assign y_next = reset_y ? 0 : y + 1;
  assign ch_in_next = reset_ch_in ? 0 : ch_in + 1;
  assign ch_out_next = reset_ch_out ? 0 : ch_out + 1;

  logic last_x, last_y, last_ch_in, last_ch_out;
  //assign last_k_v = k_v == KERNEL_SIZE - 1;
  //assign last_k_h = k_h == KERNEL_SIZE - 1;
  assign last_x = x == FEATURE_MAP_WIDTH-1;
  assign last_y = y == FEATURE_MAP_HEIGHT-1;
  assign last_ch_in = ch_in == INPUT_NB_CHANNELS - 1;
  assign last_ch_out = ch_out == OUTPUT_NB_CHANNELS - 1;

  //assign reset_k_v = last_k_v;
  //assign reset_k_h = last_k_h;
  assign reset_x = last_x;
  assign reset_y = last_y;
  assign reset_ch_in = last_ch_in;
  assign reset_ch_out = last_ch_out;


  /*
  chosen loop order:
  for x
    for y
      for ch_in
        for ch_out     (with this order, accumulations need to be kept because ch_out is inside ch_in)
          body
  */
  // ==>
  assign ch_out_we = mac_valid_3; //only if last of all enclosed loops
  assign ch_in_we  = mac_valid_3 && last_ch_out; //only if last of all enclosed loops
  assign y_we      = mac_valid_3 && last_ch_out && last_ch_in; //only if last of all enclosed loops
  assign x_we      = mac_valid_3 && last_ch_out && last_ch_in && last_y; //only if last of all enclosed loops

  logic last_overall;
  assign last_overall   = last_ch_out && last_ch_in && last_y && last_x;


  `REG(32, prev_ch_out);
  assign prev_ch_out_next = ch_out;
  assign prev_ch_out_we = ch_out_we;
  //given loop order, partial sums need be saved over input channels
  //assign mem_we         = k_v == 0 && k_h == 0; // Note: one cycle after last_k_v and last_k_h, because of register in mac unit
  //assign mem_write_addr = prev_ch_out;

  //and loaded back
  //assign mem_re         = k_v == 0 && k_h == 0;
  //assign mem_read_addr  = ch_out;

  // assign mac_accumulate_internal = ! (k_v == 0 && k_h == 0);
  // assign mac_accumulate_with_0   = ch_in ==0 && k_v == 0 && k_h == 0;

  //mark outputs
  `REG(1, output_valid_reg);
  assign output_valid_reg_next = mac_valid_3 && last_ch_in;
  assign output_valid_reg_we   = 1;
  assign output_valid = output_valid_reg;

  register #(.WIDTH(32)) output_x_r (.clk(clk), .arst_n_in(arst_n_in),
                                                .din(x),
                                                .qout(output_x),
                                                .we(mac_valid_3 && last_ch_in));
  register #(.WIDTH(32)) output_y_r (.clk(clk), .arst_n_in(arst_n_in),
                                                .din(y),
                                                .qout(output_y),
                                                .we(mac_valid_3 && last_ch_in));
  register #(.WIDTH(32)) output_ch_r (.clk(clk), .arst_n_in(arst_n_in),
                                                .din(ch_out),
                                                .qout(output_ch),
                                                .we(mac_valid_3 && last_ch_in));
 logic [14-1:0]amem_next,amem_c;
  register #(.WIDTH(14)) amem (.clk(clk), .arst_n_in(arst_n_in),
                                                .din(amem_next),
                                                .qout(amem_addr),
                                                .we(1));
  assign amem_next = (amem_addr<=16383)?amem_c : 0;
 logic [11-1:0]bmem_next,bmem_c;
  register #(.WIDTH(11)) bmem (.clk(clk), .arst_n_in(arst_n_in),
                                                .din(bmem_next),
                                                .qout(bmem_addr),
                                                .we(1));
  assign bmem_next = (bmem_addr<=1151)?bmem_c : 0;
  //mini fsm to loop over <fetch_a, fetch_b, acc>

  typedef enum {IDLE, AF, BF, init, FETCH_1, MAC_1, MAC_2,MAC_3} fsm_state;
  fsm_state current_state;
  fsm_state next_state;
  always @ (posedge clk or negedge arst_n_in) begin
    if(arst_n_in==0) begin
      current_state <= IDLE;
    end else begin
      current_state <= next_state;
    end
  end
logic [5:0]initcount_fsm;
 `REG(6,initcount);
  assign initcount_next = (initcount==35)? 0 : initcount_fsm;
  assign initcount_we = 1;

  always_comb begin
    //defaults: applicable if not overwritten below
    next_state = current_state;
    initcount_fsm = initcount_fsm;
    mac_valid_1 = 0;
    mac_valid_2 = 0;
    mac_valid_3 = 0;
    running = 1;
    amem_c = amem_c;
    amem_write_en=0;
    bmem_c = bmem_c;
    bmem_write_en = 0;

    case (current_state)
      IDLE: begin
        initcount_fsm = 0;
	amem_c=0;
	bmem_c=0;
	XXX = 0;
        running = 0;
	a_ready = 0;
        b_ready = 0;
	mac_valid_1 = 0;
	mac_valid_2 = 0;
        mac_valid_3 = 0;
        next_state = start ? AF: IDLE;
      end
      AF : begin
	XXX = 0;
        running = 0;
	a_ready = 1;
        b_ready = 0;
	mac_valid_1 = 0;
	mac_valid_2 = 0;
        mac_valid_3 = 0;
	amem_c = amem_addr+1;
	amem_write_en=1;
        next_state = (amem_addr==16383) ? BF: AF;
	end
        BF : begin
	XXX = 0;
        running = 0;
	a_ready = 0;
        b_ready = 1;
	mac_valid_1 = 0;
	mac_valid_2 = 0;
        mac_valid_3 = 0;
	bmem_c = bmem_addr+1;
	bmem_write_en=1;
        next_state = (bmem_addr==1151) ? init: BF;
	end
      init: begin
        initcount_fsm = initcount +1;
        XXX = 1;
	running = 0;
	a_ready = 0;
        b_ready = 0;
	mac_valid_1 = 0;
	mac_valid_2 = 0;
        mac_valid_3 = 0;
	next_state = (initcount==33)? FETCH_1:init;
	end
      FETCH_1: begin
	write_a = (ch_out==0)?1:0;
        XXX = 0;
        write_b = 1;
	mac_valid_1 = 0;
	mac_valid_2 = 0;
        mac_valid_3 = 0;
        next_state = MAC_1;
      end
      MAC_1: begin
        XXX = 0;
	a_ready = 0;
        b_ready = 0;
	write_a = 0;
        write_b = 0;
        mac_valid_1 = 1;
        mac_valid_2 = 0;
        mac_valid_3 = 0;
        next_state = MAC_2;
      end
      MAC_2: begin
        XXX = 0;
	a_ready = 0;
        b_ready = 0;
        mac_valid_1 = 0;
        mac_valid_2 = 1;
        mac_valid_3 = 0;
        next_state = MAC_3;
      end
        MAC_3: begin
        XXX = 0;
	a_ready = 0;
        b_ready = 0;
        mac_valid_1 = 0;
        mac_valid_2 = 0;
        mac_valid_3 = 1;
        next_state = last_overall ? IDLE: ((ch_out==32'h1f && ch_in ==32'h3) ?  init :FETCH_1);
      end
    endcase
  end
endmodule
