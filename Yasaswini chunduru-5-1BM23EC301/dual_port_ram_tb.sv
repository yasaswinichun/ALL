//------------------------------------------------------------------------------
//File       : dual_port_ram_tb.sv
//Author     : Yasaswini Chunduru/1BM23EC301
//Created    : 2026-01-29
//Module     : tb
//Project    : SystemVerilog and Verification (23EC6PE2SV)
//Faculty    : Prof. Ajaykumar Devarapalli
//Description: Testbench for Dual Port RAM using an Associative Array as a 
//             Reference Model. Includes constrained randomization and coverage.
//------------------------------------------------------------------------------

`timescale 1ns\1ps

module tb;
  // Parameters
  parameter DATA_WIDTH = 8;
  parameter ADDR_WIDTH = 8;

  // Interface Signals
  logic                  clk = 0;
  logic                  wr_en_a;
  logic [ADDR_WIDTH-1:0] addr_a;
  logic [DATA_WIDTH-1:0] data_in_a;
  logic                  rd_en_b;
  logic [ADDR_WIDTH-1:0] addr_b;
  logic [DATA_WIDTH-1:0] data_out_b;

  // REFERENCE MODEL (Associative Array)
  // Index: int (or bit[7:0]), Value: bit[7:0]
  bit [DATA_WIDTH-1:0] ref_model [int];

  // Queue to keep track of addresses we actually wrote to
  // (So we can read them back later)
  int written_addrs[$];

  always #5 clk = ~clk;

  dual_port_ram #(DATA_WIDTH, ADDR_WIDTH) dut (
    .clk(clk),
    .wr_en_a(wr_en_a),
    .addr_a(addr_a),
    .data_in_a(data_in_a),
    .rd_en_b(rd_en_b),
    .addr_b(addr_b),
    .data_out_b(data_out_b)
  );

  // COVERAGE
  covergroup cg_ram @(posedge clk);
    cp_wr_addr: coverpoint addr_a iff (wr_en_a) {
      bins low  = {[0:85]};
      bins mid  = {[86:170]};
      bins high = {[171:255]};
    }
    // Cover Data Values written
    cp_wr_data: coverpoint data_in_a iff (wr_en_a) {
      option.auto_bin_max = 8; // Split 0-255 into 8 bins
    }
  endgroup

  cg_ram cg;

  // TEST PROCEDURE
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;

    cg = new();
    
    // Initialize
    wr_en_a = 0; rd_en_b = 0;
    addr_a = 0; data_in_a = 0; addr_b = 0;


    $display(" Challenge: Dual Port RAM with Associative Array");

    // STEP 1: WRITE PHASE
    // Write random data to random addresses
    $display("--- Step 1: Writing Random Data ---");
    
    repeat(100) begin
      @(posedge clk);
      wr_en_a = 1;
      rd_en_b = 0;
      
      // Randomize Inputs
      addr_a = $urandom_range(0, 255);
      data_in_a = $urandom_range(0, 255);

      // Update Reference Model (Associative Array)
      ref_model[addr_a] = data_in_a;
      
      // Store address in queue for readback verification later
      written_addrs.push_back(addr_a);
    end
    
    // Disable Write
    @(posedge clk);
    wr_en_a = 0;

    // STEP 2: READ & COMPARE PHASE
    // Read back ONLY the addresses we wrote to
    $display("\n--- Step 2: Reading & Verifying ---");
    
    // Loop through every address stored in our queue
    foreach (written_addrs[i]) begin
      @(posedge clk);
      rd_en_b = 1;
      addr_b = written_addrs[i]; // Drive Read Address
      
      // Wait for Read Data
      @(posedge clk);
      #1;
      
      // Compare DUT Output vs Associative Array
      if (data_out_b === ref_model[addr_b]) begin
      end else begin
        $error("Check Addr %0d: Expected %0d, Got %0d --> [FAIL]", 
                 addr_b, ref_model[addr_b], data_out_b);
      end
    end
    
    $display("All checks completed.");

    // FINAL REPORT
    $display(" Final Coverage: %0.2f %%", cg.get_inst_coverage());
    $finish;
  end

endmodule
