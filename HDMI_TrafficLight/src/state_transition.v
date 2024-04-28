//**********************************************************************
//  Project: HDMI_TrafficLight
//  File: state_transition.v
//  Description: control the state of the traffic light
//  Author: Ruiqi Tang
//  Timestamp:
//----------------------------------------------------------------------
// Code Revision History:
// Ver:     | Author    | Mod. Date     | Changes Made:
// v1.0.0   | R.T.      | 2024/04/25    | Initial version
//**********************************************************************

module state_transition(
    clk_125M,
    rstn,

    key_value,
    key_valid,

    red,
    green,
    yellow
);

//**********************************************************************
// --- Parameter
//**********************************************************************
    `define STATE_IDLE      3'd0
    `define STATE_RED       3'd1
    `define STATE_GREEN     3'd2
    `define STATE_YELLOW    3'd3
    `define STATE_Y_FLASH   3'd4

    parameter CLK_FREQ = 125_000_000;   // 125MHz
    parameter RED_TIME = 10;            // 10s
    parameter GREEN_TIME = 10;          // 10s
    parameter YELLOW_TIME = 5;          // 5s
    parameter YELLOW_FLASH_TIME = 5;    // 5s

    localparam FREQ_WIDTH = $clog2(CLK_FREQ);

//**********************************************************************
// --- Input/Output Declaration
//**********************************************************************
    input   wire            clk_125M;
    input   wire            rstn;

    input   wire            key_value;
    input   wire            key_valid;

    output  reg             red;
    output  reg             green;
    output  reg             yellow;

//**********************************************************************
// --- Internal Signal Declaration
//**********************************************************************
    reg     [2:0]               current_state;
    reg     [2:0]               next_state;

    reg                         next_red;
    reg                         next_green;
    reg                         next_yellow;

    reg                         key_reg;
    reg                         key_posedge;

    reg                         always_red_flag;

    reg     [FREQ_WIDTH-1:0]    freq_cnt;
    reg     [3:0]               red_cnt;
    reg     [3:0]               green_cnt;
    reg     [3:0]               yellow_cnt;
    reg     [3:0]               y_flash_cnt;

//**********************************************************************
// --- Main Core
//**********************************************************************
// counters
    always @(posedge clk_125M, negedge rstn) begin
        if (!rstn) begin
            freq_cnt <= 0;
            red_cnt <= 0;
            green_cnt <= 0;
            yellow_cnt <= 0;
        end 
        else begin
            if (freq_cnt >= CLK_FREQ) begin
                freq_cnt <= 0;
            end
            else begin
                freq_cnt <= freq_cnt + 1;
            end

            case (current_state)
                `STATE_GREEN: begin
                    if (freq_cnt == CLK_FREQ - 1) begin
                        green_cnt <= green_cnt + 1;
                    end
                    red_cnt     <= 0;
                    yellow_cnt  <= 0;
                    y_flash_cnt <= 0;
                end
                `STATE_RED: begin
                    if (freq_cnt == CLK_FREQ - 1) begin
                        red_cnt <= red_cnt + 1;
                    end
                    green_cnt   <= 0;
                    yellow_cnt  <= 0;
                    y_flash_cnt <= 0;
                end
                `STATE_YELLOW: begin
                    if (freq_cnt == CLK_FREQ - 1) begin
                        yellow_cnt <= yellow_cnt + 1;
                    end
                    red_cnt     <= 0;
                    green_cnt   <= 0;
                    y_flash_cnt <= 0;
                end
                `STATE_Y_FLASH: begin
                    if (freq_cnt == CLK_FREQ - 1) begin
                        y_flash_cnt <= y_flash_cnt + 1;
                    end
                    red_cnt     <= 0;
                    green_cnt   <= 0;
                    yellow_cnt  <= 0;
                end
                default: begin
                    red_cnt     <= 0;
                    green_cnt   <= 0;
                    yellow_cnt  <= 0;
                    y_flash_cnt <= 0;
                end
            endcase
        end
    end
    
// state & output updater
    always @(posedge clk_125M, negedge rstn) begin
        if(!rstn) begin
            current_state <= `STATE_IDLE;
            red <= 0;
            green <= 0;
            yellow <= 0;
        end
        else begin
            current_state <= next_state;
            red <= next_red;
            green <= next_green;
            yellow <= next_yellow;
        end
    end

// read key change
    always @(posedge clk_125M, negedge rstn) begin
        if(!rstn) begin
            key_posedge <= 0;
            key_reg <= 0;
        end
        else begin
            if(key_valid) begin
                key_reg <= key_value;
                if(key_value && !key_reg) begin
                    key_posedge <= 1;
                end
                else begin
                    key_posedge <= 0;
                end
            end 
            else begin
                key_reg <= key_reg;
                key_posedge <= key_posedge;
            end
        end
    end

// trigger always-red flag
    always @(posedge clk_125M, negedge rstn) begin
        if(!rstn) begin
            always_red_flag <= 0;
        end
        else begin
            if(key_posedge) begin
                always_red_flag <= ~always_red_flag;
            end
            else begin
                always_red_flag <= always_red_flag;
            end
        end
    end

// state transition
    always @(*) begin
        if(always_red_flag) begin
            next_state = `STATE_RED;
        end
        else begin
            case (current_state)
                `STATE_IDLE: begin
                    next_state = `STATE_GREEN;
                end
                `STATE_GREEN: begin
                    if (green_cnt >= GREEN_TIME) begin
                        next_state = `STATE_Y_FLASH;
                    end
                end
                `STATE_Y_FLASH: begin
                    if (y_flash_cnt >= YELLOW_FLASH_TIME) begin
                        next_state = `STATE_RED;
                    end
                end
                `STATE_RED: begin
                    if (red_cnt >= RED_TIME) begin
                        next_state = `STATE_GREEN;
                    end
                end
                `STATE_YELLOW: begin
                    if (yellow_cnt >= YELLOW_TIME) begin
                        next_state = `STATE_GREEN;
                    end
                end
                default: begin
                    next_state = `STATE_IDLE;
                end
            endcase
        end
    end

// output control
    always @(*) begin
        case (current_state)
            `STATE_IDLE: begin
                next_red = 0;
                next_green = 0;
                next_yellow = 0;
            end
            `STATE_GREEN: begin
                next_red = 0;
                next_green = 1;
                next_yellow = 0;
            end
            `STATE_Y_FLASH: begin
                next_red = 0;
                next_green = 0;
                next_yellow = freq_cnt[FREQ_WIDTH - 2];
            end
            `STATE_RED: begin
                next_red = 1;
                next_green = 0;
                next_yellow = 0;
            end
            `STATE_YELLOW: begin
                next_red = 0;
                next_green = 0;
                next_yellow = 1;
            end
            default: begin
                next_red = 0;
                next_green = 0;
                next_yellow = 0;
            end
        endcase
    end


endmodule
