module Aritmetic (AluOp,A,B,Aritm);
  input [3:0] AluOp;
  input [31:0] A,B;
  output [31:0] Aritm;
  wire [31:0] mux1,adder,extend,mux2;

// mux b con ~b depedende del AluOp[1] determina si es suma o resta 
  assign mux1 = AluOp[1]? ~B : B;

// suma el AluOp[1] con A y B si es suma y con ~B si es resta
  assign adder = AluOp[1] + A + mux1;

// sacamos el bit mas significativo del adder y hacer el extend 
  assign extend = adder[31] + 32'b0;  // = 0 v 1 se llena solo al ser de 32 bits if 0: 000....00000 ^ 1: 0000000... 01

// mux para determinar si se pide un slt o no y asu vez dar la salida del bloque de AritmeticOp
  assign Aritm = AluOp[3]? extend : adder;
endmodule
