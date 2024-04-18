//**********************************************************************
//  Project: ASIC-Hw4
//  File: top.v
//  Description: test for bram ip
//  Author: Ruiqi Tang
//  Timestamp:
//----------------------------------------------------------------------
// Code Revision History:
// Ver:     | Author    | Mod. Date     | Changes Made:
// v1.0.0   | R.T.      | 2024/04/18    | Initial version
//**********************************************************************


module top(
    clk,
    rstn,
    select,
    dataA,
    addr,

    dout,
    cout
);

//**********************************************************************
// --- Parameter
//**********************************************************************
    `define READ        2'b01
    `define WRITE       2'b10
    `define READ_ADD    2'b11

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;
    parameter RAM_DEPTH  = (1 << ADDR_WIDTH);

//**********************************************************************
// --- Input/Output Declaration
//**********************************************************************
    input  wire                     clk;
    input  wire                     rstn;
    input  wire  [1:0]              select;
    input  wire  [DATA_WIDTH-1:0]   dataA;
    input  wire  [ADDR_WIDTH-1:0]   addr;

    output reg   [DATA_WIDTH-1:0]   dout;
    output wire                     cout;

//**********************************************************************
// --- Internal Signal Declaration
//**********************************************************************
    wire    [DATA_WIDTH-1:0]        dout_buf_ram;
    wire    [DATA_WIDTH-1:0]        dout_buf_add;
    reg                             ena;
    reg                             wea;
    reg                             enable;
//**********************************************************************
// --- Main Core
//**********************************************************************

// --- MUX
    always @(*) begin
        case (select)
            `READ_ADD:  dout = dout_buf_add;
            default:    dout = dout_buf_ram;
        endcase
    end

// --- Control
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            ena     <= 1'b0;
            wea     <= 1'b0;
            enable  <= 1'b0;
        end
        else begin
            case (select)
                `READ: begin
                    ena     <= 1'b1;
                    wea     <= 1'b0;
                    enable  <= 1'b0;
                end
                `WRITE: begin
                    ena     <= 1'b1;
                    wea     <= 1'b1;
                    enable  <= 1'b0;
                end
                `READ_ADD: begin
                    ena     <= 1'b1;
                    wea     <= 1'b0;
                    enable  <= 1'b1;
                end
                default: begin
                    ena     <= 1'b0;
                    wea     <= 1'b0;
                    enable  <= 1'b0;
                end
            endcase
        end
    end

//**********************************************************************
// --- module: bram_ipcore
// --- Description: bram ip
//**********************************************************************
 bram_ipcore #(DATA_WIDTH, ADDR_WIDTH, RAM_DEPTH) 
 i_bram(
    .clka       (clk            ),
    .addra      (addr           ),
    .dina       (dataA          ),
    .ena        (ena            ),
    .wea        (wea            ),
    .douta      (dout_buf_ram   )
 );

//**********************************************************************
// --- module: half_adder
// --- Description: half adder
//**********************************************************************
half_adder #(DATA_WIDTH)
i_half_adder(
    .a          (dout_buf_ram ),
    .enable     (enable       ),
    .sum        (dout_buf_add ),
    .c_out      (cout         )
);


endmodule