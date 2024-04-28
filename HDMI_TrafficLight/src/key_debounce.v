//**********************************************************************
//  Project: HDMI_TrafficLight
//  File: key_decounce.v
//  Description: output the steady state of the key
//  Author: Ruiqi Tang
//  Timestamp:
//----------------------------------------------------------------------
// Code Revision History:
// Ver:     | Author    | Mod. Date     | Changes Made:
// v1.0.0   | R.T.      | 2024/04/25    | Initial version
//**********************************************************************

module key_decounce(
    clk,
    rstn,
    key,
    key_value,
    key_valid
);

//**********************************************************************
// --- Parameter
//**********************************************************************
    parameter  CLK_FREQ = 125_000_000; // 125MHz
    parameter  DEBOUNCE_TIME = 20; // 20ms
    
    localparam CNT_MAX   = CLK_FREQ * DEBOUNCE_TIME / 1000;
    localparam CNT_WIDTH = $clog2(CNT_MAX);

//**********************************************************************
// --- Input/Output Declaration
//**********************************************************************
    input   wire            clk;
    input   wire            rstn;
    
    input   wire            key;
    
    output  reg             key_value;
    output  reg             key_valid;

//**********************************************************************
// --- Internal Signal Declaration
//**********************************************************************
    reg    [CNT_WIDTH-1:0]  cnt;
    reg                     key_last;

//**********************************************************************
// --- Main Core
//**********************************************************************
// record the last state of the key
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            key_last <= 0;
        end else begin
            key_last <= key;
        end
    end

// reset the counter when the state of the key is changed
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt <= 0;
        end 
        else begin
            if (key != key_last) begin
                cnt <= 0;
            end 
            else begin
                if (cnt == CNT_MAX - 1) begin
                    cnt <= 0;
                end 
                else begin
                    cnt <= cnt + 1;
                end
            end
        end
    end

// output the key value when the counter reaches the maximum value
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            key_value <= 0;
            key_valid <= 0;
        end 
        else begin
            if (cnt == CNT_MAX - 1) begin
                key_value <= key;
                key_valid <= 1;
            end 
            else begin
                key_value <= 0;
                key_valid <= 0;
            end
        end
    end



endmodule
