//------------------------------------------------------------------------------
//File       : digital_clock_tb.sv
//Author     : Yasaswini Chunduru/1BM23EC301
//Created    : 2026-01-28
//Module     : tb
//Project    : SystemVerilog and Verification (23EC6PE2SV),
//Faculty    : Prof. Ajaykumar Devarapalli
//Description: Basic Digital Clock used for basic functional coverage example.
//------------------------------------------------------------------------------

`timescale 1ns/1ps

module tb;
  logic clk = 0;
  logic rst;
  logic [5:0] sec, min;

  always #5 clk = ~clk; 

  digital_clock dut (.*);
  
  covergroup cg_clock @(posedge clk);
    
    // 1. Seconds Coverpoint
    cp_sec: coverpoint sec {
      bins rollover = (59 => 0);
    }

    // 2. Minutes Coverpoint
    cp_min: coverpoint min {
      bins valid_mins[] = {[0:59]};
      ignore_bins invalid = {[60:63]};
    }

    // 3. Cross Coverage
    // Verify that EVERY minute (0-59) is reached specifically via a rollover event.
    cross_rollover: cross cp_sec, cp_min; 

  endgroup

  cg_clock cg;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;

    cg = new();

    // Reset
    rst = 1; 
    repeat(5) @(posedge clk);
    rst = 0;

    $display("-----------------------------------------");
    $display(" Simulating full hour (please wait...)   ");
    $display("-----------------------------------------");

    repeat (3700) begin 
      @(posedge clk);
    end

    $display("-----------------------------------------");
    $display(" Final Coverage: %0.2f %%", cg.get_inst_coverage());
    
    if (cg.get_inst_coverage() == 100.0) 
      $display(" STATUS: PASSED (Full Clock Verified)");
    else
      $display(" STATUS: FAILED (Missed States)");
      
    $display("-----------------------------------------");
    $finish;
  end
endmodule
