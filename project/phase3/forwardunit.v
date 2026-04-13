//forwarding unit, assumes proper stalling
module fu(fALUin1,fALUin1_reg,fALUin2,fALUin2_reg,xaddr1, xaddr2, maddr,waddr,mwen, wwen,reg1en, reg2en,mALU_out, wout,mlb,mByteload,xrd,xlb,msw, mrtaddr,fMEMin,fMEMin_reg );
input [3:0] xaddr1, xaddr2;//addresses of the 
input[3:0] xrd;//register used for llb lhb
input [3:0] maddr,waddr;//address of the outputs of Mem, WB phases
input  mwen, wwen;//Mem,  wb, writing to register
input  reg1en, reg2en;//do you even want to use the register value?
input[15:0] mALU_out, wout;//output of ALU in respective phases
output fALUin1, fALUin2;//1- use forwarded register values 0- use current register values
output [15:0] fALUin1_reg,fALUin2_reg;//forwarded register values
input mlb;//is the operation in m, a load high/low bit
input xlb;
input [15:0] mByteload;//value of such an operation 
input msw;//is the op in m phase sw
input [3:0] mrtaddr;//addres of rt in mem, this will be the value stored in sw operations
output fMEMin;//do we forward
output [15:0] fMEMin_reg;//what value we forward


assign fALUin1 = xlb? reg1en&(xrd!=0)&((xrd==maddr)|(xrd == waddr))
                :(xaddr1 != 0)&reg1en&(((xaddr1==maddr)&mwen)|((xaddr1==waddr)&wwen));//is a register being over written
assign fALUin2 = xlb?reg2en&(xrd!=0)&((xrd==maddr)|(xrd == waddr))
                :(xaddr2 != 0)&reg2en&(((xaddr2==maddr)&mwen)|((xaddr2==waddr)&wwen));
//also don't forward for 0 register, idk if this matters but im putting it

assign fALUin1_reg = xlb? (xrd==maddr? mByteload:wout)
                     :(xaddr1==maddr)&mwen? (mlb?mByteload:mALU_out)://check Mem phase first, as this would overwrite the WB phase
                      wout;//otherwise just do write output
                     //default to sending back previous cycle's ALU output, 
                     //for correctness, assumes M operation isn't a memory read, need proper stalling in case this happens 
assign fALUin2_reg = xlb? (xrd==maddr? mByteload:wout)
                    :(xaddr2==maddr)&mwen? (mlb?mByteload:mALU_out)://same but for second input
                      wout;
                      //if in the mem phase, it is an llb or lhb op, do that op instead for the input
assign fMEMin = msw &(mrtaddr== waddr)&wwen&(waddr != 0);
assign fMEMin_reg = waddr;

endmodule