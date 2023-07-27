`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/25 10:27:21
// Design Name: 
// Module Name: singleport_ram
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


module singleport_ram(clk, rst ,start, dout, done_w, done_r);

input clk, rst, start;
output  [15:0] dout;
output reg done_w, done_r;
(*keep = "ture"*) reg [9:0] addra;
(*keep = "ture"*) reg [15:0] dina;
(*keep = "ture"*) reg wea;
(*keep = "ture"*) reg [2:0] state;
(*keep = "ture"*) reg [9:0] cnt;

blk_mem_gen_1 DUT(.addra(addra), .clka(clk), .dina(dina), .douta(dout), .wea(wea));

localparam IDLE = 3'd0, WRITE = 3'd1,  READ =3'd2, READ_DONE =3'd3;

always@(posedge clk or posedge rst)
begin
if(rst)
    state <= IDLE;
    
else
    case(state)
        IDLE :if(start == 1) state <= WRITE; else state <= IDLE;
        WRITE : if(dina == 1024) state <= READ; else state <= WRITE;
        READ : if(addra == 1023) state <= READ_DONE; else state <= READ;
        READ_DONE : state <= IDLE;
        default : state <= IDLE;
        endcase
end     

always@(posedge clk or posedge rst)
begin
if(rst)
    cnt <= 0;
else
    case(state)
        WRITE : if(cnt == 1023) cnt <= 0; else cnt <= cnt + 1'd1;
        READ : if(cnt == 1023) cnt <= 0; else cnt <= cnt + 1'd1;
        default : cnt <= 0;
    endcase
end

always@(posedge clk or posedge rst)
begin
if(rst)
    wea <= 0;
else
    case(state)
        WRITE : if(dina == 1024) wea <= 0;else wea <= 1; 
        default : wea <= 0;
    endcase
end

always@(posedge clk or posedge rst)
begin
if(rst)
    dina <= 0;
else
    case(state)
        WRITE :  if(dina == 1024) dina <= 0; else dina <= cnt + 1'd1; 
        default : dina <= 0;
    endcase
end

always@(posedge clk or posedge rst)
begin
if(rst)
    done_w <= 1'b0;
else
    case(state)
        WRITE : if(dina == 1024) done_w <= 1'b1; else done_w <= 1'b0; 
        default : done_w <= 1'b0;
    endcase
end
always@(posedge clk or posedge rst)
begin
if(rst)
    addra <= 10'd0;
else
    case(state)
        WRITE :if(addra == 1023) addra <= 0; else  addra <= cnt;
        READ : if(addra == 1023) addra <= addra; else  addra <= cnt;
        default : addra <=  addra;
    endcase
end

always@(posedge clk or posedge rst)
begin
if(rst)
    done_r <= 1'b0;
else
    case(state)
        READ_DONE :done_r <= 1'b1;
        default : done_r <= 1'b0;
    endcase
end


endmodule
