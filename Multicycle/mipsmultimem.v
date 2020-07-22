//------------------------------------------------
// mipsmemsingle.sv
// Updated to SystemVerilog - Harris Harris version
// External memories used by MIPS single-cycle
// processor
//------------------------------------------------

module mem(input          clk, we, 
            input   [31:0] a, wd, 
            output  [31:0] rd);

  reg [31:0] RAM[0:63];
  initial
    begin
      $readmemh("memfile.dat",RAM); // initialize memory
    end
 
  assign rd = RAM[a[31:2]]; // word aligned

  always @(posedge clk) begin
    if (we)
      RAM[a[31:2]] <= wd;
  end
endmodule
