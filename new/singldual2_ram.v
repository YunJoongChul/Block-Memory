`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/25 15:48:40
// Design Name: 
// Module Name: dual2
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


module dual2(clk, rst, start_w, start_r, data_out1, data_out2, done_w, done_r);
input clk, rst, start_w, start_r;
output reg done_w, done_r;
output [15:0] data_out1, data_out2;
reg wea;
reg [9:0] addra;
reg [8:0] addrb;
reg [15:0] dina;
reg [9:0] cnt1, cnt2;

blk_mem_gen_3 DUT(.clka(clk), .wea(wea), .addra(addra), .dina(dina), .clkb(clk), .addrb(addrb), .doutb({data_out2, data_out1}));

reg [2:0] state1, state2;
localparam IDLE = 3'd0, WRITE = 3'd1, READ = 3'd2, WRITE_DONE = 3'd3, READ_DONE = 3'd4;

always@(posedge clk or posedge rst)
begin
if(rst)
    state1 <= IDLE;
else
    case(state1)
            IDLE : if(start_w) state1 <= WRITE; else state1 <= IDLE;
            WRITE : if(dina == 1024)state1 <= WRITE_DONE; else state1 = WRITE;
            WRITE_DONE : state1 <= IDLE;
            default : state1 <= IDLE;
            endcase
            
end
always@(posedge clk or posedge rst)
begin
if(rst)
    state2 <= IDLE;
else
    case(state2)
            IDLE : if(start_r) state2 <= READ; else state2 <= IDLE;
            READ : if(addrb == 511) state2 <= READ_DONE; else state2 <= READ;
            READ_DONE : state2 <= IDLE;
            default : state2 <= IDLE;
            endcase
            
end

always@(posedge clk or posedge rst)
begin
if(rst)
    cnt1 <= 0;
else
    case(state1)
        WRITE : if(cnt1 == 1023) cnt1 <= 0; else cnt1 <= cnt1 + 1'd1;
        default : cnt1 <= 0;
    endcase
end

always@(posedge clk or posedge rst)
begin
if(rst)
    cnt2 <= 0;
else
    case(state2)
        READ : if(cnt2 == 511) cnt2 <= 0; else cnt2 <= cnt2 + 1'd1;
        default : cnt2 <= 0;
    endcase
end

always@(posedge clk or posedge rst)
begin
if(rst)
    wea <= 0;
else
    case(state1)
        WRITE : if(dina == 1024) wea <= 0;else wea <= 1; 
        default : wea <= 0;
    endcase
end

always@(posedge clk or posedge rst)
begin
if(rst)
    dina <= 0;
else
    case(state1)
        WRITE :  if(dina == 1024) dina <= 0; else dina <= cnt1 + 1'd1; 
        default : dina <= 0;
    endcase
end

always@(posedge clk or posedge rst)
begin
if(rst)
    addra <= 10'd0;
else
    case(state1)
        WRITE :if(addra == 1023) addra <= 0; else  addra <= cnt1;
        default : addra <=  addra;
    endcase
end

always@(posedge clk or posedge rst)
begin
if(rst)
    done_w <= 1'b0;
else
    case(state1)
        WRITE : if(dina == 1024) done_w <= 1'b1; else done_w <= 1'b0; 
        default : done_w <= 1'b0;
    endcase
end  

      
always@(posedge clk or posedge rst)
begin
if(rst)
    addrb <= 10'd0;
else
    case(state2)
        READ :if(addrb == 511) addrb <= addrb; else  addrb <= cnt2;
        default : addrb <=  addrb;
    endcase
end

always@(posedge clk or posedge rst)
begin
if(rst)
    done_r <= 1'b0;
else
    case(state2)
        READ_DONE :done_r <= 1'b1;
        default : done_r <= 1'b0;
    endcase
end
endmodule
