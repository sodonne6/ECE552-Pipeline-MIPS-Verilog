//to be hooked up to the I, D caches and handles contention, and inputs and outputs from memory
//reads blocks at a time only
module cache_mem_interface(dwe,dre,ire,clk,rst,i_data_valid, d_data_valid,d_data_in,d_addr,i_addr,i_data_out, d_data_out,dgrant,igrant);

input dwe,dre, ire,clk,rst;//is i cache/dcache write/read enabled.
output i_data_valid, d_data_valid;//is the data valid for i/d caches
input[15:0] d_data_in,d_addr,i_addr;// input data streams/ address streams
output [15:0] i_data_out, d_data_out;//data output lines
input dgrant,igrant;
wire[15:0] addr, data_out,n_addr;//intermediate signals 
wire data_valid;//output of memory
wire done;//is the current write/read finished
wire wr;//write to memory
parameter IDLE   = 2'b00;
parameter DCACHE = 2'b01;
parameter ICACHE = 2'b10;
parameter DWRITE = 2'b11;

wire[1:0] n_state;//what is currently accessing memory D/I CACHE means the respective cache is reading
wire[1:0] state;//what is currently accessing memory
wire request_queue1,request_queue2,request_queue3,request_queue4,request_queue;//whoever sent most oldest is in request queue
dff rq4(.d(request_queue4),.q(request_queue3),.wen(1'b1),.clk(clk),.rst(rst));
dff rq3(.d(request_queue3),.q(request_queue2),.wen(1'b1),.clk(clk),.rst(rst));
dff rq2(.d(request_queue2),.q(request_queue1),.wen(1'b1),.clk(clk),.rst(rst));
dff rq1(.d(request_queue1),.q(request_queue),.wen(1'b1),.clk(clk),.rst(rst));

assign request_queue4 = state==ICACHE; 

assign i_data_valid =request_queue&data_valid; //data_valid&request_queue;//&(state == ICACHE);
assign d_data_valid =(~request_queue)&data_valid;// data_valid&(~request_queue);//(state == DCACHE);
assign done = (state==IDLE)|(data_valid)|(state==DWRITE);//not actively using memory bring the next
assign wr = (state==DWRITE);
assign n_state = (igrant&ire)? ICACHE://~done?state://if not done keep same state
                (dgrant&(dwe|dre))?(dwe?DWRITE:DCACHE):IDLE;//     dwe? DWRITE://prioritize data writes, then reads, then instruction reads
//     dre? DCACHE:
//     ire? ICACHE:
//     IDLE;

assign n_addr = (n_state == ICACHE? i_addr:d_addr);//the only case we need i_addr is ICACHE, so assume d_addr ow

dff addr_ff[15:0](.q(addr),.d(n_addr),.wen(1'b1),.clk(clk),.rst(rst));
dff stateff[1:0](.q(state), .d(n_state), .wen(1'b1), .clk(clk), .rst(rst));
assign i_data_out= data_out;
assign d_data_out = data_out;
memory4c mem(.data_out(data_out), .data_in(d_data_in), .addr(addr), .enable((state != IDLE)), .wr(wr), .clk(clk), .rst(rst), .data_valid(data_valid));



endmodule