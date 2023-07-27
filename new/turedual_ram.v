`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/27 10:21:05
// Design Name: 
// Module Name: ture_dualram
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


module ture_dualram(clk, rst, start, data_out1, data_out2, done_w, done_r);
input clk, rst, start;
(*keep = "ture"*)output [15:0] data_out1, data_out2;
(*keep = "ture"*)output reg done_w, done_r;

(*keep = "ture"*)reg wea, web;
(*keep = "ture"*)reg [15:0] dina, dinb;
(*keep = "ture"*)reg [9:0] addra, addrb;
blk_mem_gen_4 DUT(.clka(clk), .wea(wea), .addra(addra),.dina(dina), .douta(data_out1), .clkb(clk), .web(web) ,.addrb(addrb), .dinb(dinb), .doutb(data_out2));

(*keep = "ture"*)reg [2:0] state1, state2;
(*keep = "ture"*)reg [9:0] cnt1;
(*keep = "ture"*)reg [9 :0] cnt2;
localparam IDLE = 3'd0, WRITE = 3'd1, WRITE_DONE = 3'd3, READ = 3'd3,  READ_DONE = 3'd4;

always@(posedge clk or posedge rst)
begin
if(rst)
    state1 <= IDLE;
else
    case(state1)
            IDLE : if(start) state1 <= WRITE; else state1 <= IDLE;
            WRITE : if(dina == 512)state1 <= WRITE_DONE; else state1 = WRITE;
            READ : if(addra == 511) state1 <= READ_DONE; else state1 <= READ;
            READ_DONE : state1 <= IDLE;
            default : state1 <= IDLE;
            endcase
            
end

always@(posedge clk or posedge rst)
begin
if(rst)
    state2 <= IDLE;
else
    case(state2)
            IDLE : if(start) state2 <= WRITE; else state2 <= IDLE;
            WRITE : if(dinb == 1024)state2 <= WRITE_DONE; else state2 = WRITE;
            READ : if(addrb == 1023) state2 <= READ_DONE; else state2 <= READ;
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
        WRITE : if(cnt1 == 511) cnt1 <= 0; else cnt1 <= cnt1 + 1'd1;
        READ : if(cnt1 == 511) cnt1 <= 0; else cnt1 <= cnt1 + 1'd1;
        default : cnt1 <= 0;
    endcase
end

always@(posedge clk or posedge rst)
begin
if(rst)
    cnt2 <= 10'd512;
else
    case(state2)
        WRITE : if(cnt2 == 1023) cnt2 <= 10'd512; else cnt2 <= cnt2 + 1'd1;
        READ : if(cnt2 == 1023) cnt2 <= 512; else cnt2 <= cnt2 + 1'd1;
        default : cnt2 <= 10'd512;
    endcase
end

always@(posedge clk or posedge rst)
begin
if(rst)
    wea <= 0;
else
    case(state1)
        WRITE : if(dina == 512) wea <= 0;else wea <= 1; 
        default : wea <= 0;
    endcase
end

always@(posedge clk or posedge rst)
begin
if(rst)
    web <= 0;
else
    case(state2)
        WRITE : if(dinb == 1024) web <= 0;else web <= 1; 
        default : web <= 0;
    endcase
end
always@(posedge clk or posedge rst)
begin
if(rst)
    dina <= 0;
else
    case(state1)
        WRITE :  if(dina == 512) dina <= 0; else dina <= cnt1 + 1'd1; 
        default : dina <= 0;
    endcase
end

always@(posedge clk or posedge rst)
begin
if(rst)
    dinb <= 0;
else
    case(state2)
        WRITE :  if(dinb == 1024) dinb <= 0; else dinb <= cnt2 + 1'd1; 
        default : dinb <= 0;
    endcase
end

always@(posedge clk or posedge rst)
begin
if(rst)
    done_w <= 1'b0;
else
begin
    case(state1)
        WRITE : if(dina == 512) done_w <= 1'b1; else done_w <= 1'b0; 
        default : done_w <= 1'b0;
    endcase
    case(state2)
    WRITE : if(dinb == 1024) done_w <= 1'b1; else done_w <= 1'b0; 
        default : done_w <= 1'b0;
    endcase
end
end

always@(posedge clk or posedge rst)
begin
if(rst)
    addra <= 10'd0;
else
    case(state1)
        WRITE :if(addra == 511) addra <= 0; else  addra <= cnt1;
        READ : if(addra == 511) addra <= addra; else  addra <= cnt1;
        default : addra <=  addra;
    endcase
end

always@(posedge clk or posedge rst)
begin
if(rst)
    addrb <= 10'd0;
else
    case(state2)
        WRITE :if(addrb == 1023) addrb <= 10'd512; else  addrb <= cnt2;
        READ : if(addrb == 1023) addrb <= addrb; else  addrb <= cnt2;
        default : addrb <=  addrb;
    endcase
end

always@(posedge clk or posedge rst)
begin
if(rst)
    done_r <= 1'b0;
else
    case(state1)
        READ_DONE :done_r <= 1'b1;
        default : done_r <= 1'b0;
    endcase
    
     case(state2)
        READ_DONE :done_r <= 1'b1;
        default : done_r <= 1'b0;
    endcase
end


endmodule
