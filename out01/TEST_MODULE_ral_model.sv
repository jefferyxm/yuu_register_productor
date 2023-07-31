module test_module_csr (
    //Reg output
    reg_id_id,
    reg_clock_div,
    reg_clock_freq,
    reg_clock_en,
    reg_timer_counter,
    reg_timer_enable,
    reg_timer_start,
    reg_inten_int3e,
    reg_inten_int2e,
    reg_inten_int1e,
    reg_inten_int0e,
    //CLK, RST
    hclk,
    hrst_n,
    pclk,
    //APB Intf
    psel,
    penable,
    paddr,
    pwrite,
    pwdata,
    pready,
    prdata
);

parameter DATA_WIDTH  = 'd32;
parameter ADDR_WIDTH  = 'd32;

//Reg output
output reg [31 :0] reg_id_id;
output reg [1 :0] reg_clock_div;
output reg [1 :0] reg_clock_freq;
output reg        reg_clock_en;
output reg [3 :0] reg_timer_counter;
output reg        reg_timer_enable;
output reg        reg_timer_start;
output reg        reg_inten_int3e;
output reg        reg_inten_int2e;
output reg        reg_inten_int1e;
output reg        reg_inten_int0e;

//CLK, RST
input wire    hrst_n;
input wire    hclk;
input wire    pclk;

//APB
input wire                       psel;
input wire                       penable;
input wire                       pwrite;
input wire  [(DATA_WIDTH-1) :0]  pwdata;
input wire  [(ADDR_WIDTH-1) :0]  paddr;

output wire [(DATA_WIDTH-1) :0]  prdata;
output wire                      pready;

localparam R_ID = (32'h00000000 + 32'h00);
localparam R_CLOCK = (32'h00000000 + 32'h04);
localparam R_TIMER = (32'h00000100 + 32'h00);
localparam R_INTEN = (32'h00000200 + 32'h00);

wire    apb_wr_ps;
wire    apb_rd_ps;
wire    apb_rd_en;

assign apb_wr_ps = psel & pwrite & penable;
assign abp_rd_ps = psel & ~pwrite & penable;
assign apb_rd_en = psel & ~pwrite;

assign pready = 1'b1;

wire id_wren = apb_wr_ps & (paddr[(ADDR_WIDTH-1) :0] == R_ID);
wire clock_wren = apb_wr_ps & (paddr[(ADDR_WIDTH-1) :0] == R_CLOCK);
wire timer_wren = apb_wr_ps & (paddr[(ADDR_WIDTH-1) :0] == R_TIMER);
wire inten_wren = apb_wr_ps & (paddr[(ADDR_WIDTH-1) :0] == R_INTEN);

wire [(DATA_WIDTH-1) :0]  id_rdata; 
wire [(DATA_WIDTH-1) :0]  clock_rdata; 
wire [(DATA_WIDTH-1) :0]  timer_rdata; 
wire [(DATA_WIDTH-1) :0]  inten_rdata; 

//reg: id
always @(posedge pclk or negedge hrst_n) begin
  if (~hrst_n) begin
    reg_id_id <= 32'hDEADBEEF;
  end
  else if (id_wren) begin
    // reg_id_id <= pwdata[31 :0];
  end
end

//reg: clock
always @(posedge pclk or negedge hrst_n) begin
  if (~hrst_n) begin
    reg_clock_div <= 2'h0;
    reg_clock_freq <= 2'h0;
    reg_clock_en <= 1'h1;
  end
  else if (clock_wren) begin
    reg_clock_div <= pwdata[7 :6];
    reg_clock_freq <= pwdata[3 :2];
    reg_clock_en <= pwdata[1 :1];
  end
end

//reg: timer
always @(posedge pclk or negedge hrst_n) begin
  if (~hrst_n) begin
    reg_timer_counter <= 4'hF;
    reg_timer_enable <= 1'h0;
    reg_timer_start <= 1'h0;
  end
  else if (timer_wren) begin
    reg_timer_counter <= pwdata[11 :8];
    reg_timer_enable <= pwdata[4 :4];
    reg_timer_start <= pwdata[0 :0];
  end
end

//reg: inten
always @(posedge pclk or negedge hrst_n) begin
  if (~hrst_n) begin
    reg_inten_int3e <= 1'h1;
    reg_inten_int2e <= 1'h1;
    reg_inten_int1e <= 1'h1;
    reg_inten_int0e <= 1'h1;
  end
  else if (inten_wren) begin
    reg_inten_int3e <= pwdata[3 :3];
    reg_inten_int2e <= pwdata[2 :2];
    reg_inten_int1e <= pwdata[1 :1];
    reg_inten_int0e <= pwdata[0 :0];
  end
end


//rdata
assign id_rdata = {
    reg_id_id    
}
assign clock_rdata = {
    27'h0,
    reg_clock_div,
    reg_clock_freq,
    reg_clock_en    
}
assign timer_rdata = {
    26'h0,
    reg_timer_counter,
    reg_timer_enable,
    // reg_timer_start,
    1'h0
}
assign inten_rdata = {
    28'h0,
    reg_inten_int3e,
    reg_inten_int2e,
    reg_inten_int1e,
    reg_inten_int0e    
}

always @(*) begin
  if (apb_rd_en) begin
    case (paddr[(ADDR_WIDTH-1) :0])
      R_ID[(ADDR_WIDTH-1) :0]: prdata = id_rdata;
      R_CLOCK[(ADDR_WIDTH-1) :0]: prdata = clock_rdata;
      R_TIMER[(ADDR_WIDTH-1) :0]: prdata = timer_rdata;
      R_INTEN[(ADDR_WIDTH-1) :0]: prdata = inten_rdata;
    endcase
  end
  else begin
    prdata = {DATA_WIDTH{1'b0}};
  end
end

endmodule