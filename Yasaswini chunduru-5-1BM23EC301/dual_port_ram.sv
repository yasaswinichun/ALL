//------------------------------------------------------------------------------
//File       : dual_port_ram.sv
//Author     : Yasaswini Chunduru/1BM23EC301
//Created    : 2026-01-29
//Module     : dual_port_ram
//Project    : SystemVerilog and Verification (23EC6PE2SV)
//Faculty    : Prof. Ajaykumar Devarapalli
//Description: Dual Port RAM with Port A (Write) and Port B (Read).
//             Parameters allow for flexible Address and Data widths.
//------------------------------------------------------------------------------

module dual_port_ram #(
  parameter DATA_WIDTH = 8,
  parameter ADDR_WIDTH = 8
)(
  input  logic                  clk,
  
  // Port A (Write)
  input  logic                  wr_en_a,
  input  logic [ADDR_WIDTH-1:0] addr_a,
  input  logic [DATA_WIDTH-1:0] data_in_a,
  
  // Port B (Read)
  input  logic                  rd_en_b,
  input  logic [ADDR_WIDTH-1:0] addr_b,
  output logic [DATA_WIDTH-1:0] data_out_b
);

  // Memory Array: Depth = 2^ADDR_WIDTH
  logic [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH];

  // Port A: Synchronous Write
  always_ff @(posedge clk) begin
    if (wr_en_a) begin
      mem[addr_a] <= data_in_a;
    end
  end

  // Port B: Synchronous Read
  always_ff @(posedge clk) begin
    if (rd_en_b) begin
      data_out_b <= mem[addr_b];
    end
  end

endmodule
