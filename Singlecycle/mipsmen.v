module dmem(input  wire clk, we,
            input  wire[31:0] a, wd,
            output [31:0] rd);

  reg [31:0] RAM[0:63];

  assign rd = RAM[a[31:2]]; // word aligned

  always @(posedge clk)
  begin
    if (we)
      RAM[a[31:2]] <= wd;
  end    
endmodule


module imem(input [5:0]  a,
            output [31:0] rd);

  reg [31:0] RAM[0:63];

  initial
    begin
    	$readmemh("memfile.dat", RAM);
      	//("memfile.dat",RAM); // initialize memory
    end

  assign rd = RAM[a]; // word aligned
endmodule
