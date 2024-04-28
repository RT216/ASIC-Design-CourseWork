//**********************************************************************
//  Project: HDMI_TrafficLight
//  File: top.v
//  Description: top module of the project
//  Author: Ruiqi Tang
//  Timestamp:
//----------------------------------------------------------------------
// Code Revision History:
// Ver:     | Author    | Mod. Date     | Changes Made:
// v1.0.0   | R.T.      | 2024/04/28    | Initial version
//**********************************************************************

module top(
    sys_clk,
    sys_rstn,

    key,
    hdmi_out_data_p,
    hdmi_out_data_n,
    hdmi_out_clk_p,
    hdmi_out_clk_n
);

//**********************************************************************
// --- Parameter
//**********************************************************************

//**********************************************************************
// --- Input/Output Declaration
//**********************************************************************
    input           sys_clk;
    input           sys_rstn;

    input           key;
    output  [2:0]   hdmi_out_data_p;
    output  [2:0]   hdmi_out_data_n;
    output          hdmi_out_clk_p;
    output          hdmi_out_clk_n;

//**********************************************************************
// --- Internal Signal Declaration
//**********************************************************************
    wire            key_value;
    wire            key_valid;

    wire            red;
    wire            green;
    wire            yellow;

    wire            color_data;
    wire    [11:0]  col_pixel_number;
    wire    [10:0]  row_pixel_number;
    wire            clk_HDMI;

//**********************************************************************
// --- Main Core
//**********************************************************************

//**********************************************************************
// --- module: key_debounce
// --- Description: debounce the input key signal
//**********************************************************************
    key_debounce key_debounce_inst(
        .clk        (sys_clk    ),
        .rstn       (sys_rstn   ),
        .key        (key        ),
        .key_value  (key_value  ),
        .key_valid  (key_valid  )
    );

//**********************************************************************
// --- module: state_transition
// --- Description: control the state of the traffic light
//**********************************************************************
    state_transition state_transition_inst(
        .clk_125M   (sys_clk    ),
        .rstn       (sys_rstn   ),
        .key_value  (key_value  ),
        .key_valid  (key_valid  ),
        .red        (red        ),
        .green      (green      ),
        .yellow     (yellow     )
    );

//**********************************************************************
// --- module: get_pixel_color
// --- Description: get the color of the pixel
//**********************************************************************
    get_pixel_color get_pixel_color_inst(
        .clk_HDMI           (clk_HDMI          ),
        .rstn               (sys_rstn          ),
        .red                (red               ),
        .green              (green             ),
        .yellow             (yellow            ),
        .col_pixel_number   (col_pixel_number  ),
        .row_pixel_number   (row_pixel_number  ),
        .data               (color_data        )
    );

//**********************************************************************
// --- module: hdmi_controller
// --- Description: control the HDMI output
//**********************************************************************
    hdmi_controller hdmi_controller_inst(
        .clk_125M           (sys_clk            ),
        .rstn               (sys_rstn           ),
        .data               (color_data         ),
        .clk_HDMI           (clk_HDMI           ),
        .hdmi_out_data_n    (hdmi_out_data_n    ),
        .hdmi_out_data_p    (hdmi_out_data_p    ),
        .hdmi_out_clk_p     (hdmi_out_clk_p     ),
        .hdmi_out_clk_n     (hdmi_out_clk_n     ),
        .col_pixel_number   (col_pixel_number  ),
        .row_pixel_number   (row_pixel_number  )
    );


endmodule
