//------------------------------------------------------------------------------
// File       : alu_tb.sv
// Author     : Yasaswini Chunduru / 1BM23EC301
// Project    : SystemVerilog and Verification (23EC6PE2SV)
// Description: Cadence-compatible ALU testbench with functional coverage
//------------------------------------------------------------------------------

`timescale 1ns/1ps
import alu_pkg::*;

// ---------------- TRANSACTION CLASS ----------------
class Transaction;
  rand bit [7:0] a;
  rand bit [7:0] b;
  rand opcode_e op;

  constraint c_mul_priority {
    op dist {
      MUL := 20,
      ADD := 40,
      SUB := 40,
      XOR := 40
    };
  }
endclass

// ---------------- TESTBENCH ----------------
module tb;

  logic [7:0] a = 0, b = 0;
  opcode_e op = ADD;          
  logic [15:0] result;

  alu dut (
    .a(a),
    .b(b),
    .op(op),
    .result(result)
  );

  // Coverage
  covergroup cg_alu;
    cp_op: coverpoint op {
      bins all_ops[] = {ADD, SUB, MUL, XOR};
    }
  endgroup

  Transaction tr;
  cg_alu cg;

  initial begin
    // ---------------- WAVE DUMP SETUP ----------------
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);

    $shm_open("waves.shm");
    $shm_probe("AS");

    tr = new();
    cg = new();
    cg.start();


    #1;

    $display("Starting ALU Verification");

    repeat (50) begin
      void'(tr.randomize());

      a  = tr.a;
      b  = tr.b;
      op = tr.op;

      #10;           

      cg.sample();

      $display("t=%0t | op=%s | a=%0d | b=%0d | result=%0d",
               $time, op.name(), a, b, result);
    end

    // 🚨 KEEP SIMULATION ALIVE FOR WAVES
    #20;

    $display("-----------------------------------------");
    $display(" Final Coverage: %0.2f %%", cg.get_inst_coverage());
    $display("-----------------------------------------");

    $finish;
  end

endmodule
