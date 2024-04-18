//**********************************************************************
//  Project: ASIC-Hw4
//  File: bram_ipcore.v
//  Description: test the vivado bram ip
//  Author: Ruiqi Tang
//  Timestamp:
//----------------------------------------------------------------------
// Code Revision History:
// Ver:     | Author    | Mod. Date     | Changes Made:
// v1.0.0   | R.T.      | 2024/04/18    | Initial version
//**********************************************************************

module bram_ipcore(
    clka,
    addra,
    dina,
    ena,
    wea,
    douta
);
//**********************************************************************
// --- Parameter
//**********************************************************************
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;
    parameter RAM_DEPTH  = (1 << ADDR_WIDTH);

//**********************************************************************
// --- Input/Output Declaration
//**********************************************************************
    input  wire                     clka;    
    input  wire [ADDR_WIDTH-1:0]    addra;
    input  wire [DATA_WIDTH-1:0]    dina;
    input  wire                     ena;
    input  wire                     wea;

    output wire [DATA_WIDTH-1:0]    douta;
    
//**********************************************************************
// --- Main Core
//**********************************************************************
    blk_mem_gen_0 i_bram(
        .clka   (clka   ),
        .addra  (addra  ),
        .dina   (dina   ),
        .ena    (ena    ),
        .wea    (wea    ),
        .douta  (douta  )
    );

endmodule