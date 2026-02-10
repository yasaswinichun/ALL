//------------------------------------------------------------------------------
//File       : atm_controller.sv
//Author     : Yasaswini Chunduru/1BM23EC301
//Created    : 2026-01-29
//Module     : atm_controller
//Project    : SystemVerilog and Verification (23EC6PE2SV),
//Faculty    : Prof. Ajaykumar Devarapalli
//Description: ATM Controller used for basic functional coverage example.
//------------------------------------------------------------------------------

package atm_pkg;
  typedef enum logic [1:0] {
    IDLE, 
    CHECK_PIN, 
    CHECK_BAL, 
    DISPENSE
  } state_t;
endpackage

import atm_pkg::*;

module atm_controller(
  input logic clk, rst,
  input logic card_inserted,
  input logic pin_correct,
  input logic balance_ok,
  output logic dispense_cash,
  output state_t state
);
  
  state_t next_state;

  always_ff @(posedge clk) begin
    if (rst) state <= IDLE;
    else     state <= next_state;
  end

  always_comb begin
    next_state = state;
    dispense_cash = 0;

    case (state)
      IDLE: begin
        if (card_inserted) next_state = CHECK_PIN;
      end
      CHECK_PIN: begin
        if (pin_correct) next_state = CHECK_BAL;
        else             next_state = IDLE; // Eject
      end
      CHECK_BAL: begin
        if (balance_ok)  next_state = DISPENSE;
        else             next_state = IDLE; // Decline
      end
      DISPENSE: begin
        dispense_cash = 1;
        next_state = IDLE;
      end
      default: next_state = IDLE;
    endcase
  end
endmodule
