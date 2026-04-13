module cache_controller_bad(clk,rst_n,miss_detected, memory_data_valid,miss_address,busy, write_data_array,write_tag_array,memory_address);

input clk,rst_n,miss_detected, memory_data_valid;
input [15:0] miss_address;
output busy, write_data_array,write_tag_array;
output[15:0] memory_address;


cache_fill_FSM(
    //inputs
    .clk(clk),
    .rst_n(rst_n),
    .miss_detected(miss_detected),
    .memory_data_valid(memory_data_valid),
    .miss_address(miss_address),//16 bit

    //outputs
    .fsm_busy(busy),
    .write_data_array(write_data_array),
    .write_tag_array(write_tag_array),
    .memory_address(memory_address));//16 bit


endmodule  