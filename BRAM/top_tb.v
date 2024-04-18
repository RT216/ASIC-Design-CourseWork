//**********************************************************************
//  Project: ASIC-Hw4
//  File: top_tb.v
//  Description: 
//  Author: Ruiqi Tang
//  Timestamp:
//----------------------------------------------------------------------
// Code Revision History:
// Ver:     | Author    | Mod. Date     | Changes Made:
// v1.0.0   | R.T.      | 2024/04/18    | Initial version
//**********************************************************************


module top_tb();

//**********************************************************************
// --- Parameter
//**********************************************************************
    `define IDEL        2'b00
    `define READ        2'b01
    `define WRITE       2'b10
    `define READ_ADD    2'b11

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;
    parameter RAM_DEPTH  = (1 << ADDR_WIDTH);

//**********************************************************************
// --- Internal Signal Declaration
//**********************************************************************
    reg                         clk;
    reg                         rstn ;
    reg   [2:0]                 select;
    reg   [DATA_WIDTH-1:0]      dataA;
    reg   [ADDR_WIDTH-1:0]      addr;

    wire  [DATA_WIDTH-1:0]      dout;
    wire                        cout; 

    reg   [DATA_WIDTH-1:0]      input_data [4:0];
//**********************************************************************
// --- Main Core
//**********************************************************************
// --- reset reg
    initial begin
        clk     = 1'b0;
        rstn    = 1'b0;
        select  = `IDEL;
        addr    = 'd0;
        dataA   = 'd0;
        #10
        rstn    = 1'b1;
    end

// --- clk generator
    always begin
        #5 clk = ~clk;
    end

// --- read mem data
    initial begin
        #20;
        $readmemb("/home/rich_tang/Documents/HDLProgramming/ASIC-Design-CourseWork/BRAM/InputData.txt", input_data);
    end

    integer fp_rd_data;
    initial begin
        fp_rd_data = $fopen("/home/rich_tang/Documents/HDLProgramming/ASIC-Design-CourseWork/BRAM/OutputData.txt", "w");
    end

    integer ii;
    initial begin
        ii = 0;
        #50
        for (ii =0 ;ii< 5 ;ii = ii +1 ) begin
            @(negedge clk)begin
                select  <= `WRITE;
                addr    <= ii;
                dataA   <= input_data[ii];
            end
            @(negedge clk)begin
                select  <= `IDEL;
            end
            repeat (5) begin
                @(negedge clk);
            end
        end
        for (ii =0 ;ii<3 ;ii=ii+1 ) begin
            @(negedge clk) begin
                select  <= `READ;
                addr    <= ii;
            end
            repeat (5) begin
                @(negedge clk);
            end
            @(negedge clk)begin
                $fwrite(fp_rd_data,"%b\n",i_top.dout);
                $fwrite(fp_rd_data,"%b\n",i_top.cout);
            end
        end
        for (ii =3 ;ii<5 ;ii=ii+1 ) begin
            @(negedge clk) begin
                select  <= `READ_ADD;
                addr    <= ii;
            end
            repeat (5) begin
                @(negedge clk);
            end
            @(negedge clk)begin
                $fwrite(fp_rd_data,"%b\n",i_top.dout);
                $fwrite(fp_rd_data,"%b\n",i_top.cout);
            end
        end
        $fclose(fp_rd_data);
        $finish;
    end


//**********************************************************************
// --- module: 
// --- Description: 
//**********************************************************************
    top #(DATA_WIDTH,ADDR_WIDTH,RAM_DEPTH)
    i_top(
        .clk            (clk       ),      
        .rstn           (rstn      ),
        .select         (select    ),   
        .dataA          (dataA     ),    
        .addr           (addr      ),
        .dout           (dout      ),
        .cout           (cout      )
    );


endmodule
