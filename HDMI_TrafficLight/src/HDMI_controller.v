//**********************************************************************
//  Project: HDMI_TrafficLight
//  File: HDMI_controller.v
//  Description: control the HDMI output
//  Author: Ruiqi Tang
//  Timestamp:
//----------------------------------------------------------------------
// Code Revision History:
// Ver:     | Author    | Mod. Date     | Changes Made:
// v1.0.0   | R.T.      | 2024/04/25    | Initial version
//**********************************************************************

module hdmi_controller(
    clk_125M,
    rstn,

    data,

    clk_HDMI,
    hdmi_out_data_n,
    hdmi_out_data_p,
    hdmi_out_clk_p,
    hdmi_out_clk_n,

    col_pixel_number,
    row_pixel_number
);

//**********************************************************************
// --- Parameter
//**********************************************************************

//**********************************************************************
// --- Input/Output Declaration
//**********************************************************************
    input   wire            clk_125M;
    input   wire            rstn;

    input   wire    [23:0]  data;

    output  wire            clk_HDMI;
    output  wire    [2:0]   hdmi_out_data_n;
    output  wire    [2:0]   hdmi_out_data_p;
    output  wire            hdmi_out_clk_p;
    output  wire            hdmi_out_clk_n;
    output  wire    [11:0]  col_pixel_number;
    output  wire    [10:0]  row_pixel_number;

//**********************************************************************
// --- Internal Signal Declaration
//**********************************************************************
    wire                clk_lock;

    reg                 hsync, vsync;
    reg                 valid;

    reg         [11:0]  hcnt;
    reg         [10:0]  vcnt;
//**********************************************************************
// --- Main Core
//**********************************************************************
    assign col_pixel_number = hcnt - 12'd192;
    assign row_pixel_number = vcnt - 11'd41;

    always @(posedge clk_HDMI or posedge rstn) begin
        if (!rstn) begin
            hsync <= 1;vsync <= 1;
            valid <= 0;
            hcnt <= 0;vcnt <= 0;
        end
        else begin
            if (hcnt < 2199) begin
                hcnt <= hcnt + 1;
                if (hcnt < 44) begin
                    hsync <= 1;
                    if (vcnt < 6) begin
                        vsync <= 1;
                    end
                    else begin
                        vsync <= 0;
                    end
                end
                else begin
                    hsync <= 0;
                    if (hcnt == 191) begin
                        if ((vcnt > 41)&&(vcnt < 1121)) begin
                            valid <= 1;
                        end
                        else begin
                            valid <= 0;
                        end
                    end
                    if (hcnt == 2111) begin
                        valid <= 0;
                    end
                end
            end
            else begin
                hcnt <= 0;
                hsync <= 1;
                if (vcnt < 1124) begin
                    vcnt <= vcnt + 1;
                end
                else begin
                    vcnt <= 0;
                    vsync <= 1;
                end
            end
        end
    end

//**********************************************************************
// --- module: rgb2dvi_0
// --- Description: convert RGB to HDMI
//**********************************************************************
    rgb2dvi_0 rgb2dvi_inst0(
        .PixelClk       (clk_HDMI       ),
        .TMDS_Clk_n     (hdmi_out_clk_n ),
        .TMDS_Clk_p     (hdmi_out_clk_p ),
        .TMDS_Data_n    (hdmi_out_data_n),
        .TMDS_Data_p    (hdmi_out_data_p),
        .aRst           (clk_lock       ),
        .vid_pData      (data           ),
        .vid_pHSync     (hsync          ),
        .vid_pVDE       (valid          ),
        .vid_pVSync     (vsync          )
    );

//**********************************************************************
// --- module: clk_wiz_0
// --- Description: input 125M clk, output 148.5M clk
//**********************************************************************
    clk_wiz_0 clk_wiz_inst0(
        // Clock in ports
        .clk_in1    (clk_125M   ),
        // Clock out ports
        .clk_out1   (clk_HDMI   ),
        // Status and control signals
        .locked     (clk_lock   ),
        .resetn     (rstn       )
    );

endmodule
