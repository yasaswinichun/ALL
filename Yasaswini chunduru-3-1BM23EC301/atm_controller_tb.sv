//------------------------------------------------------------------------------
//File       : atm_controller_tb.sv
//Author     : Yasaswini Chunduru/1BM23EC301
//Created    : 2026-01-29
//Module     : tb
//Project    : SystemVerilog and Verification (23EC6PE2SV),
//Faculty    : Prof. Ajaykumar Devarapalli
//Description: ATM Controller used for basic functional coverage example.
//------------------------------------------------------------------------------

`timescale 1ns/1ps

import atm_pkg::*;

module tb;
  logic clk = 0, rst;
  logic card_inserted, pin_correct, balance_ok;
  logic dispense_cash;
  state_t state;

  always #5 clk = ~clk;

  atm_controller dut (.*);

  covergroup cg_atm @(posedge clk);
    cp_state: coverpoint state {
      bins all_states[] = {IDLE, CHECK_PIN, CHECK_BAL, DISPENSE};
    }

    cp_trans: coverpoint state {
      bins trans_pin_pass  = (CHECK_PIN => CHECK_BAL);
      bins trans_pin_fail  = (CHECK_PIN => IDLE);
      bins trans_bal_pass  = (CHECK_BAL => DISPENSE);
      bins trans_bal_fail  = (CHECK_BAL => IDLE);
    }
  endgroup

  // Create handle
  cg_atm cg;

  // ASSERTIONS
  property p_safe_dispense;
    @(posedge clk) dispense_cash |-> (pin_correct && balance_ok);
  endproperty

  assert_safe_dispense: assert property (p_safe_dispense)
    else $error("CRITICAL SECURITY FAIL: Cash dispensed without checks!");

  property p_return_idle;
    @(posedge clk) (state == DISPENSE) |=> (state == IDLE);
  endproperty

  assert_return_idle: assert property (p_return_idle)
    else $error("FLOW FAIL: ATM did not return to IDLE after dispensing.");


  // STIMULUS
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;

    // Instantiate the covergroup
    cg = new();

    $display("--- Starting ATM Verification ---");

    // Initialize
    rst = 1; card_inserted = 0; pin_correct = 0; balance_ok = 0;
    repeat(3) @(posedge clk);
    rst = 0;

    // SCENARIO 1: Happy Path (Success)
    // Covers: IDLE->PIN->BAL->DISPENSE
    $display("[Scenario 1] Valid Transaction");
    card_inserted = 1; 
    @(posedge clk); 
    
    pin_correct = 1;   
    @(posedge clk); 
    
    balance_ok = 1;    
    @(posedge clk); 
    #1;
    
    if (dispense_cash) $display("  -> Success: Cash Dispensed");
    else $error("  -> Fail: Cash NOT dispensed");
    
    @(posedge clk); // Return to IDLE
    #1;
    card_inserted = 0; pin_correct = 0; balance_ok = 0;
    @(posedge clk);

    // SCENARIO 2: Bad PIN (Failure)
    // Covers: CHECK_PIN -> IDLE
    $display("[Scenario 2] Invalid PIN");
    card_inserted = 1;
    @(posedge clk); // To CHECK_PIN
    #1;
    
    pin_correct = 0; // Wrong PIN
    @(posedge clk);  // Back to IDLE
    #1; 
    
    if (state == IDLE) $display("  -> Success: Aborted on PIN");
    else $error("  -> Fail: Did not return to IDLE");

    @(posedge clk);
    card_inserted = 0; pin_correct = 0; balance_ok = 0;
    @(posedge clk);

    // NEW SCENARIO 3: Bad Balance (Failure)
    // Covers: CHECK_BAL -> IDLE
    $display("[Scenario 3] Insufficient Balance");
    card_inserted = 1;
    @(posedge clk); // To CHECK_PIN
    
    pin_correct = 1; // PIN OK
    @(posedge clk); // To CHECK_BAL
    #1;

    balance_ok = 0; // NO MONEY!
    @(posedge clk); // Should go to IDLE (Not Dispense)
    #1;

    if (state == IDLE && dispense_cash == 0) 
      $display("  -> Success: Aborted on Balance");
    else 
      $error("  -> Fail: Wrong behavior on Low Balance");

    card_inserted = 0;
    @(posedge clk);

    // REPORTING
    $display(" Final Coverage: %0.2f %%", cg.get_inst_coverage());
    $finish;
  end

endmodule
