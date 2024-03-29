//-------------------------------------------------------
// mipsmulti.sv
// From David_Harris and Sarah_Harris book design
// Multicycle MIPS processor
//------------------------------------------------

module mips(input          clk, reset,
            output  [31:0] adr, writedata,
            output         memwrite,
            input   [31:0] readdata);

  wire        zero, pcen, irwrite, regwrite,
               alusrca, iord, memtoreg, regdst;
  wire [1:0]  alusrcb, pcsrc;
  wire [3:0]  alucontrol;
  wire [5:0]  op, funct;

  controller c(clk, reset, op, funct, zero,
               pcen, memwrite, irwrite, regwrite,
               alusrca, iord, memtoreg, regdst, 
               alusrcb, pcsrc, alucontrol);
  datapath dp(clk, reset, 
              pcen, irwrite, regwrite,
              alusrca, iord, memtoreg, regdst,
              alusrcb, pcsrc, alucontrol,
              op, funct, zero,
              adr, writedata, readdata);
endmodule

module controller(input         clk, reset,
                  input   [5:0] op, funct,
                  input         zero,
                  output        pcen, memwrite, irwrite, regwrite,
                  output        alusrca, iord, memtoreg, regdst,
                  output  [1:0] alusrcb, pcsrc,
                  output  [3:0] alucontrol);

  wire [1:0] aluop;
  wire branch, pcwrite;

  // Main Decoder and ALU Decoder subunits.
  maindec md(clk, reset, op,
             pcwrite, memwrite, irwrite, regwrite,
             alusrca, branch, iord, memtoreg, regdst, 
             alusrcb, pcsrc, aluop);
  aludec  ad(funct, aluop, alucontrol);

  // ADD CODE HERE
  // Add combinational logic (i.e. an assign statement) 
  // to produce the PCEn signal (pcen) from the branch, 
  // zero, and pcwrite signals
  assign pcen = pcwrite || (branch && zero);
 
endmodule

module maindec(input         clk, reset, 
               input   [5:0] op, 
               output        pcwrite, memwrite, irwrite, regwrite,
               output        alusrca, branch, iord, memtoreg, regdst,
               output  [1:0] alusrcb, pcsrc,
               output  [1:0] aluop);

  parameter   FETCH   = 4'b0000; // State 0
  parameter   DECODE  = 4'b0001; // State 1
  parameter   MEMADR  = 4'b0010;	// State 2
  parameter   MEMRD   = 4'b0011;	// State 3
  parameter   MEMWB   = 4'b0100;	// State 4
  parameter   MEMWR   = 4'b0101;	// State 5
  parameter   RTYPEEX = 4'b0110;	// State 6
  parameter   RTYPEWB = 4'b0111;	// State 7
  parameter   BEQEX   = 4'b1000;	// State 8
  parameter   ADDIEX  = 4'b1001;	// State 9
  parameter   ADDIWB  = 4'b1010;	// state 10
  parameter   JEX     = 4'b1011;	// State 11

  parameter   LW      = 6'b100011;	// Opcode for lw
  parameter   SW      = 6'b101011;	// Opcode for sw
  parameter   RTYPE   = 6'b000000;	// Opcode for R-type
  parameter   BEQ     = 6'b000100;	// Ospcode for beq
  parameter   ADDI    = 6'b001000;	// Opcode for addi
  parameter   J       = 6'b000010;	// Opcode for j

  reg [3:0]  state, nextstate;
  reg [14:0] controls;

  // state register
  always @(posedge clk or posedge reset) begin			
    if(reset) state <= FETCH;
    else state <= nextstate;
  end
  // ADD CODE HERE
  // Finish entering the next state logic below.  We've completed the first 
  // two states, FETCH and DECODE, for you.

  // next state logic
  always@(*)
    case(state)
      FETCH:   nextstate <= DECODE;
      DECODE:  case(op)
                 LW:      	nextstate <= MEMADR;
                 SW:      	nextstate <= MEMADR;
                 RTYPE:   	nextstate <= RTYPEEX;
                 BEQ:     	nextstate <= BEQEX;
                 ADDI:    	nextstate <= ADDIEX;
                 J:       	nextstate <= JEX;
                 default: 	nextstate <= 4'bx; // should never happen
               endcase
 		// Add code here
      MEMADR:	case(op)
      		  LW:	   	nextstate <= MEMRD;
      		  SW:	   	nextstate <= MEMWR;
      		  default:	nextstate <= 4'bx;
      		endcase
      MEMRD:	nextstate <= MEMWB;
      MEMWB: 	nextstate <= FETCH;
      MEMWR: 	nextstate <= FETCH;
      RTYPEEX: 	nextstate <= RTYPEWB;
      RTYPEWB: 	nextstate <= FETCH;
      BEQEX:   	nextstate <= FETCH;
      ADDIEX:  	nextstate <= ADDIWB;
      ADDIWB:  	nextstate <= FETCH;
      JEX:     	nextstate <= FETCH;
      default: 	nextstate <= 4'bx; // should never happen
    endcase

// output logic
  assign {pcwrite, memwrite, irwrite, regwrite, 
          alusrca, branch, iord, memtoreg, regdst,
          alusrcb, pcsrc, aluop} = controls;

  // ADD CODE HERE
  // Finish entering the output logic below.  We've entered the
  // output logic for the first two states, S0 and S1, for you.
  always @(*)
    case(state)
      FETCH:   controls <= 15'h5010;
      DECODE:  controls <= 15'h0030;
      MEMADR:  controls <= 15'h0420;
      MEMRD:   controls <= 15'h0100;
      MEMWB:   controls <= 15'h0880;
      MEMWR:   controls <= 15'h2100;
      RTYPEEX: controls <= 15'h0402; 
      RTYPEWB: controls <= 15'h0840;
      BEQEX:   controls <= 15'h0605;
      ADDIEX:  controls <= 15'h0420;
      ADDIWB:  controls <= 15'h0800;
      JEX:     controls <= 15'h4008;
      default: controls <= 15'hxxxx; // should never happen
    endcase
endmodule


  // ADD CODE HERE
  // Complete the design for the ALU Decoder.
  // Your design goes here.  Remember that this is a combinational 
  // module. 

  // Remember that you may also reuse any code from previous labs.
module aludec(input   [5:0] funct,
              input   [1:0] aluop,
              output reg [3:0] alucontrol);

  always @* begin
    case(aluop)
      2'b00: alucontrol <= 4'b0000;  // add
      2'b01: alucontrol <= 4'b0010;  // sub
      2'b11: alucontrol <= 4'b0101;  // or

      default: case(funct)          // RTYPE
          6'b100000: alucontrol <= 4'b0000; // ADD
          6'b100010: alucontrol <= 4'b0010; // SUB
          6'b100100: alucontrol <= 4'b0100; // AND
          6'b100101: alucontrol <= 4'b0101; // OR
          6'b100111: alucontrol <= 4'b0111; // NOR
          6'b100110: alucontrol <= 4'b0110; // XOR
          6'b101010: alucontrol <= 4'b1010; // SLT
          default:   alucontrol <= 4'bxxxx; // ???
      endcase
    endcase
  end 
endmodule
// The datapath unit is a structural verilog module.  That is,
// it is composed of instances of its sub-modules.  For example,
// the instruction register is instantiated as a 32-bit flopenr.
// The other submodules are likewise instantiated.

module datapath(input          clk, reset,
                input          pcen, irwrite, regwrite,
                input          alusrca, iord, memtoreg, regdst,
                input   [1:0]  alusrcb, pcsrc, 
                input   [3:0]  alucontrol,
                output  [5:0]  op, funct,
                output         zero,
                output  [31:0] adr, writedata, 
                input   [31:0] readdata);

  // Below are the internal signals of the datapath module.

  wire [4:0]  writereg;
  wire [31:0] pcnext, pc;
  wire [31:0] instr, data, srca, srcb;

  wire [31:0] A ,B;
  wire [31:0] aluresult, aluout;
  wire [31:0] signimm;   // the sign-extended immediate
  wire [31:0] signimmsh;	// the sign-extended immediate shifted left by 2
  wire [31:0] wd3, rd1, rd2;
  wire [31:0] pcjump;

  // op and funct fields to controller
  assign op = instr[31:26];
  assign funct = instr[5:0];
  assign writedata=B;
  assign pcjump={pc[31:28],{instr[25:0],2'b00}};
  // Your datapath hardware goes below.  Instantiate each of the submodules
  // that you need.  Remember that alu's, mux's and various other 
  // versions of parameterizable modules are available in mipsparts.sv
  // from Lab 9. You'll likely want to include this verilog file in your
  // simulation.
  flopenr #(32)	        pcreg(clk, reset, pcen, pcnext, pc);
  mux2 #(32)            muxfetch(pc, aluout, iord, adr);

  flopenr #(32)	        intrdecode(clk, reset, irwrite, readdata, instr);
  flopr #(32)		rdata(clk, reset, readdata, data);
  mux2 #(5)             muxrt(instr[20:16], instr[15:11], regdst, writereg);
  mux2 #(32)            wdmux(aluout, data, memtoreg, wd3);

  regfile               rf(clk, regwrite, instr[25:21], instr[20:16], writereg, wd3, rd1, rd2);
  signext               sign(instr[15:0], signimm);

  floprx2 #(32)         readata12(clk,reset,rd1,rd2,A,B);
  //assign                writedata=B;

  sl2                   sll2(signimm, signimmsh);
  mux4 #(32)            mux4x1(B, 32'b100, signimm, signimmsh, alusrcb, srcb);
  mux2 #(32)            muxsrca(pc, A, alusrca, srca);
  
  Alu                   alu(.A(srca), .B(srcb), .AluOp(alucontrol), .Result(aluresult), .zero(zero));

  //assign                pcjump={pc[31:28],pc[25:0],2'b00};
  flopr #(32)		alures(clk, reset, aluresult, aluout);

  mux3 #(32)		mux3x1(aluresult, aluout, pcjump, pcsrc, pcnext);
  
  // We've included parameterizable 3:1 and 4:1 muxes below for your use.

  // Remember to give your instantiated modules applicable names
  // such as pcreg (PC register), wdmux (Write Data Mux), etc.
  // so it's easier to understand.

  // ADD CODE HERE

  // datapath
  
endmodule
