//------------------------------------------------------------------------------
//File       : alu.sv
//Author     : Yasaswini Chunduru/1BM23EC301
//Created    : 2026-01-28
//Module     : alu
//Project    : SystemVerilog and Verification (23EC6PE2SV),
//Faculty    : Prof. Ajaykumar Devarapalli
//Description: 2-input 8-bit ALU used for basic functional coverage example.
//------------------------------------------------------------------------------

// 1. The package to share the Enum
package alu_pkg;
  typedef enum bit [1:0] {
    ADD = 0, 
    SUB = 1, 
    MUL = 2, 
    XOR = 3
  } opcode_e;
endpackage

// 2. The ALU Hardware
import alu_pkg::*;

module alu (
  input logic [7:0] a, b,
  input opcode_e op,
  output logic [15:0] result
);

  always_comb begin
    case (op)
      ADD: result = a + b;
      SUB: result = a - b;
      MUL: result = a * b;
      XOR: result = a ^ b;
      default: result = '0;
    endcase
  end
endmodule
