//**********************************************************************
//  Project: HDMI_TrafficLight
//  File: get_pixel_color.v
//  Description: input pixel address and output the color of the pixel
//  Author: Ruiqi Tang
//  Timestamp:
//----------------------------------------------------------------------
// Code Revision History:
// Ver:     | Author    | Mod. Date     | Changes Made:
// v1.0.0   | R.T.      | 2024/04/25    | Initial version
//**********************************************************************

module get_pixel_color(
    clk_HDMI,
    rstn,
    
    red,
    green,
    yellow,

    col_pixel_number,
    row_pixel_number,

    data
);

//**********************************************************************
// --- Parameter
//**********************************************************************

//**********************************************************************
// --- Input/Output Declaration
//**********************************************************************
    input   wire            clk_HDMI;
    input   wire            rstn;
    input   wire            red;
    input   wire            green;
    input   wire            yellow;

    input   wire    [11:0]  col_pixel_number;
    input   wire    [10:0]  row_pixel_number;

    output  reg     [23:0]  data;

//**********************************************************************
// --- Internal Signal Declaration
//**********************************************************************
    wire    [10:0]  addr;
    wire    [11:0]  circle_h_max, circle_h_min;
    reg     [23:0]  current_data;

//**********************************************************************
// --- Main Core
//**********************************************************************
    assign addr = (row_pixel_number > (11'd540 - 11'd300)) ? row_pixel_number - 11'd240 : 0;

    always @(*) begin
        case ({red, green, yellow})
            3'b000: current_data = 24'h000000;
            3'b100: current_data = 24'hFF0000;
            3'b010: current_data = 24'h00FF00;
            3'b001: current_data = 24'hFFFF00;
            default: current_data = 24'hFFFFFF;
        endcase
    end

    always @(posedge clk_HDMI or negedge rstn) begin
        if (rstn) begin
            data <= 24'h0;
        end
        else begin
            if(row_pixel_number > (11'd540 - 11'd300) && row_pixel_number < (11'd540 + 11'd300))
                if(col_pixel_number > circle_h_min && col_pixel_number < circle_h_max)
                    // if the pixel is in the circle, set the color
                    data <= current_data;
                else
                    data <= 24'h0;
            else
                data <= 24'h0;
        end
    end

//**********************************************************************
// --- module: circle_h_max_table & circle_h_min_table
// --- Description: LUT for circle_h_max & circle_h_min
//**********************************************************************
    circle_h_max_table circle_h_max_table_inst(
        .addra  (addr[9:0]      ),
        .clka   (clk_HDMI       ),
        .douta  (circle_h_max   )
    );

    circle_h_min_table circle_h_min_table_inst(
        .addra  (addr[9:0]      ),
        .clka   (clk_HDMI       ),
        .douta  (circle_h_min   )
    );


endmodule
