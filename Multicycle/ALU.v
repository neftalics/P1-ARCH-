module Alu (A,B,AluOp,Result,zero);
  input [31:0] A,B;
  input [3:0] AluOp;
  output [31:0] Result;
  output zero;
  wire [31:0] Logic,Aritm;

  //Modulo Aritmetic aqui se hace el add , sub y slt 
  Aritmetic Arit (.A(A),
               .B(B),
               .AluOp(AluOp),
               .Aritm(Aritm)
               );

  //Modulo Logic aqui se hace el and, or, nor, xor 
  Logic Log (.A(A),
           .B(B),
           .AluOp(AluOp),
           .Logic(Logic)
           );

  // El Result depende de del segundo bit mas significativo si es 0 sabemos que ejecutaremos el modulo Aritmetic pero sino ejecutaremos el modulo Logic 
  assign Result = AluOp[2]? Logic : Aritm;
  
  //El zero se prende cuando todos los digitos del result son ceros y para asegurarnos de eso hacemos un or entre todos los bits del Result 
  //se niega porque el or entre todos los bits del Result si todos son ceros seria 0 y queremos q la salida sea 1 .
  assign zero = ~(| Result);

endmodule
