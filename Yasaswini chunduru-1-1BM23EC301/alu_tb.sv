//------------------------------------------------------------------------------
//File       : alu_tb.sv
//Author     :Yasaswini Chunduru/1BM23EC301
//Created    : 2026-01-28
//Module     : tb
//Project    : SystemVerilog and Verification (23EC6PE2SV),
//Faculty    : Prof. Ajaykumar Devarapalli
//Description: 2-input 8-bit ALU used for basic functional coverage example.
//------------------------------------------------------------------------------

`timescale 1ns/1ps

import alu_pkg::*;

// Task 2: Create a class for the transaction
class Transaction;
  rand bit [7:0] a;
  rand bit [7:0] b;
  rand opcode_e op;

  // Task 4: Constraint - Ensure 'MUL' happens at least 20% of the time
  constraint c_mul_priority {
    op dist {
      MUL := 20,       // Weight of 20 for MUL
      [ADD:SUB] := 40, // Remaining weights distributed
      XOR := 40
    }; 
    // 20/(20+40+40) = 20% minimum probability.
  }
endclass

module tb;
  // Signals
  logic [7:0] a, b;
  opcode_e op;
  logic [15:0] result;

  // Interface/DUT Connection
  alu dut (
    .a(a), 
    .b(b), 
    .op(op), 
    .result(result)
  );

  // Task 5: Coverage - Verify all opcodes were tested
  covergroup cg_alu;
    cp_op: coverpoint op {
      bins all_ops[] = {ADD, SUB, MUL, XOR};
    }
  endgroup

  // Class handles
  Transaction tr;
  cg_alu cg;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;

    tr = new();
    cg = new();

    $display(" Starting ALU Verification ");

    // Run enough transactions to satisfy the distribution constraint
    repeat (50) begin
      void'(tr.randomize()); // Randomize based on constraints
      
      // Drive signals to DUT
      a = tr.a;
      b = tr.b;
      op = tr.op;

      #5;
      
      // Sample coverage and print
      cg.sample();
      $display("Op: %s | A: %d | B: %d | Res: %d", op.name(), a, b, result);
    end

    $display(" Final Coverage: %0.2f %%", cg.get_inst_coverage());
    
    // Automatic Check
    if (cg.get_inst_coverage() == 100.0) 
      $display(" STATUS: PASSED (All Opcodes Tested)");
    else
      $display(" STATUS: FAILED (Missed some Opcodes)");
  end
endmodule
