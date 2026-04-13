//The module that contains all of the cache modules to instansiate.
module cache_container(maddr,clk,rst,mdata_in,mwen,mren,mdata_out,mdata_ready,iaddr,iren,idata,idata_ready);


    input [15:0] maddr;//address to read/write to
    input clk,rst; 
    input [15:0] mdata_in;
    input mwen, mren;//write/read enabled
    output [15:0] mdata_out;
    output mdata_ready;//assert high when data is valid

    input [15:0] iaddr;//address to read/write to
    input iren; //clock, reset, read enabled
    output [15:0] idata;//instruction pulled
    output idata_ready;//assert high when data is valid

    wire dmem_we,dmem_re, imem_re;//data/ I mem read/write enable
    wire imem_data_valid,dmem_data_valid;
    wire[15:0] dmem_data_in, dmem_data_out,imem_data_out,imem_addr,dmem_addr,addr;
    wire[15:0] data_in,data_out;
    wire mstall, istall;
    wire mem_access_req,mem_access_grant,inst_access_req,inst_access_grant;//who wants to access memory/who has permission
    wire data_valid,mem_wr_req,mem_rd_req;


    wire [15:0] dcache_addr;
    wire dcache_wr_en;
    wire [15:0] dcache_data_in;
    wire [15:0] dcache_data_out;

    // Cache meta-data array interface
    wire [7:0] dmeta_idx;
    wire dmeta_wr_en;
    wire dmeta_wr_way;
    wire [7:0] dmeta_tag_in;
    wire dmeta_valid_in;
    wire [7:0] dmeta_tag_out0;
    wire dmeta_valid_out0;
    wire [7:0] dmeta_tag_out1;
    wire dmeta_valid_out1;
    wire dmeta_lru_in;
    wire dmeta_lru_out;
    wire dmemory_read_en,imemory_read_en;

    wire [15:0] icache_addr;
    wire icache_wr_en;
    wire [15:0] icache_data_in;
    wire [15:0] icache_data_out;

    // Cache meta-data array interface
    wire [7:0] imeta_idx;
    wire imeta_wr_en;
    wire imeta_wr_way;
    wire [7:0] imeta_tag_in;
    wire imeta_valid_in;
    wire [7:0] imeta_tag_out0;
    wire imeta_valid_out0;
    wire [7:0] imeta_tag_out1;
    wire imeta_valid_out1;
    wire imeta_lru_in;
    wire imeta_lru_out;
    wire d_mem_write;//TODO add this to module

    //assign mdata_ready = ~mstall;
    //assign idata_ready = ~istall;
    // MDCacheInterface MDCI(.addr(maddr),.clk(clk),.rst(rst),.data_in(mdata_in),.data_out(mdata_out), .data_ready(mdata_ready),.wen(mwen),.ren(mren));
    // FICacheInterface FICI(.addr(iaddr),.clk(clk),.rst(rst),.data(idata),.data_ready(.idata_ready),.ren(iren));


     DCache IC(
        .clk(clk),
        .rst_n(~rst),
        .cpu_address(iaddr),
        .cpu_data_in(16'h0000),
        .cpu_write_en(1'b0), // 1 = write, 0 = read
        .cpu_read_en(iren),
        .memory_read_en(imemory_read_en),
        .memory_write_en(),
        .cpu_data_out(idata),
        .cpu_data_valid(idata_ready),
        .memory_data_valid(imem_data_valid),
        .memory_data_in(imem_data_out),
        .memory_data_out()//should never write through instructions
        ,.memory_address(imem_addr),
        .mem_req(icache_req),
        .mem_grant(icache_grant)
    );
    DCache DC(

        .clk(clk),
        .rst_n(~rst),
        .cpu_address(maddr),
        .cpu_data_in(mdata_in),
        .cpu_write_en(mwen), // 1 = write, 0 = read
        .cpu_read_en(mren),
        .cpu_data_out(mdata_out),
        .memory_read_en(dmemory_read_en),
        .memory_write_en(d_mem_write),
        .cpu_data_valid(mdata_ready),
        .memory_data_valid(dmem_data_valid),
        .memory_data_in(dmem_data_out),
        .memory_data_out(dmem_data_in)//should never write through instructions
        ,.memory_address(dmem_addr),
        .mem_req(dcache_req),
        .mem_grant(dcache_grant)

     );
memory_arbitration MARB(
    // System signals
    .clk(clk),
    .rst_n(~rst),
    
    // I-cache request interface
    .icache_req(icache_req),
    .icache_grant(icache_grant),
    
    // D-cache request interface
    .dcache_req(dcache_req),
    .dcache_grant(dcache_grant)
    
);


    cache_mem_interface CMI(.dwe(d_mem_write&dcache_grant),.dre(dmemory_read_en&dcache_grant),.ire(imemory_read_en&icache_grant),.clk(clk),.rst(rst),.i_data_valid(imem_data_valid), .d_data_valid(dmem_data_valid),.d_data_in(dmem_data_in),
    .d_addr(dmem_addr),.i_addr(imem_addr),.i_data_out(imem_data_out), .d_data_out(dmem_data_out), .dgrant(dcache_grant), .igrant(icache_grant));
    // memory_arbitration MA(//decide whether I or D cache gets access to memory
    //     // System signals
    //     .clk(clk),
    //     .rst_n(~rst),
        
    //     // I-cache request interface
    //     .icache_req(inst_access_req),
    //     .icache_grant(inst_access_grant),
        
    //     // D-cache request interface
    //     .dcache_req(mem_access_req),
    //     .dcache_grant(mem_access_grant)
    // );

    //assign addr = mem_wr_req|mem_access_grant? dmem_addr:imem_addr;

    //memory4c mem(.data_out(data_out), .data_in(data_in), .addr(addr), .enable(mem_access_grant|inst_access_grant|mem_wr_req), .wr(mem_wr_req), .clk(clk), .rst(rst), .data_valid(data_valid));
endmodule