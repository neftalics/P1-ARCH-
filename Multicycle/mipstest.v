module testbench();
  reg clk;
  reg reset;

  wire [31:0]writedata, adr;
  wire memwrite;

  // instantiate device to be tested
  top dut(clk, reset, writedata, adr, memwrite);
  //dut dut(clk, reset, writedata, dataadr, memwrite);

  // initialize test
  initial
    begin
      reset <= 1; 
      #22; 
      reset <= 0;
    end

  // generate clock to sequence tests
  always
    begin
      clk <= 1; 
      #5; 
      clk <= 0; 
      #5;
    end

  // check that 7 gets written to address 84
  always@(negedge clk)
    begin
      if(memwrite) begin
        if(adr === 80 && writedata === 7) begin
          $display("Simulation succeeded");
          $finish;
        end else if (adr !== 80) begin
          $display("Simulation failed");
          $finish;
        end
      end
    end

    initial begin
        $dumpfile("testbenchmulti.vcd");
        $dumpvars; 
    end

endmodule
