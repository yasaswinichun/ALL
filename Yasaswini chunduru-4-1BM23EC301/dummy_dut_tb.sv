//------------------------------------------------------------------------------
//File       : dummy_dut_tb.sv
//Author     : Yasaswini Chunduru/1BM23EC301
//Created    : 2026-01-29
//Module     : tb
//Project    : SystemVerilog and Verification (23EC6PE2SV)
//Faculty    : Prof. Ajaykumar Devarapalli
//Description: Testbench verifying EthPacket class using constrained randomization
//             (length 4-8) and functional coverage logic.
//------------------------------------------------------------------------------

`timescale 1ns/1ps

class EthPacket;
  rand bit [7:0] payload[];
  rand int unsigned len;

  constraint c_len_limit { len inside {[4:8]}; }
  constraint c_payload_size { payload.size() == len; }

  function void print(string name);
    $display("Packet [%s]: len=%0d | payload size=%0d | data=%p", 
             name, len, payload.size(), payload);
  endfunction
endclass

module tb;
  
  EthPacket pkt;
  
  int wave_len;
  int wave_size;
  logic [7:0] wave_byte0; // To visualize the first byte of data

  covergroup cg_packet;
    cp_len: coverpoint pkt.len {
      bins valid_sizes[] = {[4:8]};
    }
  endgroup

  cg_packet cg;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;

    pkt = new();
    cg = new();

    $display(" Challenge: The 8-Byte Packet Verification");

    for (int i = 1; i <= 20; i++) begin
      void'(pkt.randomize());
      
      wave_len = pkt.len;
      wave_size = pkt.payload.size();
      wave_byte0 = pkt.payload[0];
      #5; 
      
      cg.sample();

      if (i <= 5) begin
        $display("--- Iteration %0d ---", i);
        pkt.print("RandomPkt");
      end
    end

    $display(" Final Coverage: %0.2f %%", cg.get_inst_coverage());
    $finish;
  end

endmodule
