module Logic (A,B,AluOp,Logic);
  input [31:0] A,B;
  input [3:0] AluOp;
  output [31:0] Logic;

  assign Logic = AluOp[1]? AluOp[0]? ~(A | B) 
                                      : 
                                     (A ^ B) // cuando el Alu[1] es 1 haremos un xor o un nor 
                            :   
                           AluOp[0]? (A | B) 
                                      : 
                                     (A & B); /// cuando el Alu[0] es 0 haremos un and o un Or

endmodule
