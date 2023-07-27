`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/21 11:10:52
// Design Name: 
// Module Name: singlgport_rom
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module singlgport_rom(clk, rst, start_r, data_out, done);
input clk ,rst ,start_r;
output [15:0] data_out;
output  reg  done;
(*keep = "ture"*) reg [6:0] addra;
(*keep = "ture"*) reg ena;
(*keep = "ture"*) reg [1:0] state;

localparam s0 = 2'b00, s1 = 2'b01, s2 = 2'b10;

blk_mem_gen_0 DUT(.clka(clk), .ena(ena), .addra(addra), .douta(data_out));

always@(posedge clk or posedge rst)
begin
if(rst)
    state <= s0;
else
    case(state)
    s0 : if(start_r) state <= s1; else state <= s0;
    s1 : if(addra == 99) state <= s2; else state <= s1;
    s2 : state <= s0;
    default : state <= s0;
    endcase
end

always@(posedge clk or posedge rst)
begin
if(rst)
    ena <= 0;

else
    case(state)
    s1 : if(done) ena <= 0; else ena <= 1;
    default : ena <= 0;
    endcase
end

always@(posedge clk or posedge rst)
begin
if(rst)
    addra <= 0;

else
    case(state)
    s1 : if(addra == 99) addra <= 0; else addra <= addra + 1;
    default : addra <= 0;
    endcase
end

always@(posedge clk or posedge rst)
begin
if(rst)
    done <= 0;

else
    case(state)
    s2 :  done <= 1;
    default : done <= 0;
    endcase
end


endmodule
