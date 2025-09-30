module Distribute#(
    parameter ADDR_WIDTH = 7,
    parameter DATA_WIDTH = 8)
(
    input  wire                      clk,
    input  wire                      rst_n,
    input  wire                      st_cs_n,
    input  wire                      st_rden_n,
    input  wire                      st_wren_n,
    input  wire[ADDR_WIDTH-1:0]      st_address,
    input  wire[DATA_WIDTH-1:0]      st_data_in,
    output reg [DATA_WIDTH-1:0]      st_data_out,

    input  wire[DATA_WIDTH*28-1:0]   temperature_bus,
    input  wire[DATA_WIDTH-1:0]      temperature_crc,

    input  wire[DATA_WIDTH*28-1:0]   busvoltage_bus,
    input  wire[DATA_WIDTH-1:0]      busvoltage_crc,

    input  wire[(DATA_WIDTH<<2)-1:0] status_32b,
    input  wire[DATA_WIDTH-1:0]      status_crc,

    output reg [DATA_WIDTH*28-1:0]   sync_delay_bus,
    output reg [DATA_WIDTH-1:0]      sync_delay_crc,

    output wire[(DATA_WIDTH<<2)-1:0] pulsewidth_32b,
    output reg [DATA_WIDTH-1:0]      pulsewidth_crc,

    output wire[(DATA_WIDTH<<2)-1:0] enable_id_32b,
    output reg [DATA_WIDTH-1:0]      enable_id_crc
);
    // Synchronized Beat Settings Address
    localparam ADDR_SYNC_DELAY_00   = 7'h00;
    localparam ADDR_SYNC_DELAY_01   = 7'h01;
    localparam ADDR_SYNC_DELAY_02   = 7'h02;
    localparam ADDR_SYNC_DELAY_03   = 7'h03;
    localparam ADDR_SYNC_DELAY_04   = 7'h04;
    localparam ADDR_SYNC_DELAY_05   = 7'h05;
    localparam ADDR_SYNC_DELAY_06   = 7'h06;
    localparam ADDR_SYNC_DELAY_07   = 7'h07;
    localparam ADDR_SYNC_DELAY_08   = 7'h08;
    localparam ADDR_SYNC_DELAY_09   = 7'h09;
    localparam ADDR_SYNC_DELAY_10   = 7'h0A;
    localparam ADDR_SYNC_DELAY_11   = 7'h0B;
    localparam ADDR_SYNC_DELAY_12   = 7'h0C;
    localparam ADDR_SYNC_DELAY_13   = 7'h0D;
    localparam ADDR_SYNC_DELAY_14   = 7'h0E;
    localparam ADDR_SYNC_DELAY_15   = 7'h0F;
    localparam ADDR_SYNC_DELAY_16   = 7'h10;
    localparam ADDR_SYNC_DELAY_17   = 7'h11;
    localparam ADDR_SYNC_DELAY_18   = 7'h12;
    localparam ADDR_SYNC_DELAY_19   = 7'h13;
    localparam ADDR_SYNC_DELAY_20   = 7'h14;
    localparam ADDR_SYNC_DELAY_21   = 7'h15;
    localparam ADDR_SYNC_DELAY_22   = 7'h16;
    localparam ADDR_SYNC_DELAY_23   = 7'h17;
    localparam ADDR_SYNC_DELAY_24   = 7'h18;
    localparam ADDR_SYNC_DELAY_25   = 7'h19;
    localparam ADDR_SYNC_DELAY_26   = 7'h1A;
    localparam ADDR_SYNC_DELAY_27   = 7'h1B;
    localparam ADDR_SYNC_DELAY_CRC  = 7'h1C;

    // Pulse Width Settings Address
    localparam ADDR_PULSEWIDTH_00   = 7'h1D;
    localparam ADDR_PULSEWIDTH_01   = 7'h1E;
    localparam ADDR_PULSEWIDTH_02   = 7'h1F;
    localparam ADDR_PULSEWIDTH_03   = 7'h20;
    localparam ADDR_PULSEWIDTH_CRC  = 7'h21;

    // Enable Module Settings Address
    localparam ADDR_ENABLE_ID_00    = 7'h22;
    localparam ADDR_ENABLE_ID_01    = 7'h23;
    localparam ADDR_ENABLE_ID_02    = 7'h24;
    localparam ADDR_ENABLE_ID_03    = 7'h25;
    localparam ADDR_ENABLE_ID_CRC   = 8'h26;

    // Temperature Address
    localparam ADDR_TEMP_00        = 7'h30;
    localparam ADDR_TEMP_01        = 7'h31;
    localparam ADDR_TEMP_02        = 7'h32;
    localparam ADDR_TEMP_03        = 7'h33;
    localparam ADDR_TEMP_04        = 7'h34;
    localparam ADDR_TEMP_05        = 7'h35;
    localparam ADDR_TEMP_06        = 7'h36;
    localparam ADDR_TEMP_07        = 7'h37;
    localparam ADDR_TEMP_08        = 7'h38;
    localparam ADDR_TEMP_09        = 7'h39;
    localparam ADDR_TEMP_10        = 7'h3A;
    localparam ADDR_TEMP_11        = 7'h3B;
    localparam ADDR_TEMP_12        = 7'h3C;
    localparam ADDR_TEMP_13        = 7'h3D;
    localparam ADDR_TEMP_14        = 7'h3E;
    localparam ADDR_TEMP_15        = 7'h3F;
    localparam ADDR_TEMP_16        = 7'h40;
    localparam ADDR_TEMP_17        = 7'h41;
    localparam ADDR_TEMP_18        = 7'h42;
    localparam ADDR_TEMP_19        = 7'h43;
    localparam ADDR_TEMP_20        = 7'h44;
    localparam ADDR_TEMP_21        = 7'h45;
    localparam ADDR_TEMP_22        = 7'h46;
    localparam ADDR_TEMP_23        = 7'h47;
    localparam ADDR_TEMP_24        = 7'h48;
    localparam ADDR_TEMP_25        = 7'h49;
    localparam ADDR_TEMP_26        = 7'h4A;
    localparam ADDR_TEMP_27        = 7'h4B;
    localparam ADDR_TEMP_CRC       = 7'h4C;

    // Bus Voltage Address
    localparam ADDR_VBUS_00        = 7'h4D;
    localparam ADDR_VBUS_01        = 7'h4E;
    localparam ADDR_VBUS_02        = 7'h4F;
    localparam ADDR_VBUS_03        = 7'h50;
    localparam ADDR_VBUS_04        = 7'h51;
    localparam ADDR_VBUS_05        = 7'h52;
    localparam ADDR_VBUS_06        = 7'h53;
    localparam ADDR_VBUS_07        = 7'h54;
    localparam ADDR_VBUS_08        = 7'h55;
    localparam ADDR_VBUS_09        = 7'h56;
    localparam ADDR_VBUS_10        = 7'h57;
    localparam ADDR_VBUS_11        = 7'h58;
    localparam ADDR_VBUS_12        = 7'h59;
    localparam ADDR_VBUS_13        = 7'h5A;
    localparam ADDR_VBUS_14        = 7'h5B;
    localparam ADDR_VBUS_15        = 7'h5C;
    localparam ADDR_VBUS_16        = 7'h5D;
    localparam ADDR_VBUS_17        = 7'h5E;
    localparam ADDR_VBUS_18        = 7'h5F;
    localparam ADDR_VBUS_19        = 7'h60;
    localparam ADDR_VBUS_20        = 7'h61;
    localparam ADDR_VBUS_21        = 7'h62;
    localparam ADDR_VBUS_22        = 7'h63;
    localparam ADDR_VBUS_23        = 7'h64;
    localparam ADDR_VBUS_24        = 7'h65;
    localparam ADDR_VBUS_25        = 7'h66;
    localparam ADDR_VBUS_26        = 7'h67;
    localparam ADDR_VBUS_27        = 7'h68;
    localparam ADDR_VBUS_CRC       = 7'h69;

    // Status Address
    localparam ADDR_STATUS_00      = 7'h6A;
    localparam ADDR_STATUS_01      = 7'h6B;
    localparam ADDR_STATUS_02      = 7'h6C;
    localparam ADDR_STATUS_03      = 7'h6D;
    localparam ADDR_STATUS_CRC     = 7'h6E;

    // Read Operation Delay Value
    localparam COUNTS_COMPARE       = 8'd24;

    // 内部使用解包后的数组
    wire [DATA_WIDTH-1:0] temperature [0:27];
    wire [DATA_WIDTH-1:0] busvoltage [0:27];
    genvar i;
    generate
        for (i = 0; i < 28; i = i + 1) begin : unpack_signals
            assign temperature[i] = temperature_bus[i*DATA_WIDTH +: DATA_WIDTH];
            assign busvoltage[i] = busvoltage_bus[i*DATA_WIDTH +: DATA_WIDTH];
            // sync_delay在always块中赋值，不需要assign
        end
    endgenerate


    reg [7:0]            counts;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counts <= 8'b0;
        end
        else if ( !st_cs_n ) begin
            counts <= counts + 1'b1;
        end
        else begin
            counts <= 8'b0;
        end
    end

    reg [DATA_WIDTH-1:0] pulsewidth[0:3];

    reg [DATA_WIDTH-1:0] enable_id [0:3];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            st_data_out    <= {DATA_WIDTH{1'b0}};
            sync_delay_bus <= {DATA_WIDTH*28{1'b0}};
            sync_delay_crc <= {DATA_WIDTH{1'b0}};

            pulsewidth[00]  <= {DATA_WIDTH{1'b0}};
            pulsewidth[01]  <= {DATA_WIDTH{1'b0}};
            pulsewidth[02]  <= {DATA_WIDTH{1'b0}};
            pulsewidth[03]  <= {DATA_WIDTH{1'b0}};
            pulsewidth_crc <= {DATA_WIDTH{1'b0}};

            enable_id[00]   <= {DATA_WIDTH{1'b0}};
            enable_id[01]   <= {DATA_WIDTH{1'b0}};
            enable_id[02]   <= {DATA_WIDTH{1'b0}};
            enable_id[03]   <= {DATA_WIDTH{1'b0}};
            enable_id_crc  <= {DATA_WIDTH{1'b0}};
        end
        else if ( !st_cs_n ) begin
            if ( !st_wren_n ) begin
                case (st_address)
                    ADDR_SYNC_DELAY_00 : sync_delay_bus[0*DATA_WIDTH +: DATA_WIDTH]   <= st_data_in;
                    ADDR_SYNC_DELAY_01 : sync_delay_bus[1*DATA_WIDTH +: DATA_WIDTH]   <= st_data_in;
                    ADDR_SYNC_DELAY_02 : sync_delay_bus[2*DATA_WIDTH +: DATA_WIDTH]   <= st_data_in;
                    ADDR_SYNC_DELAY_03 : sync_delay_bus[3*DATA_WIDTH +: DATA_WIDTH]   <= st_data_in;
                    ADDR_SYNC_DELAY_04 : sync_delay_bus[4*DATA_WIDTH +: DATA_WIDTH]   <= st_data_in;
                    ADDR_SYNC_DELAY_05 : sync_delay_bus[5*DATA_WIDTH +: DATA_WIDTH]   <= st_data_in;
                    ADDR_SYNC_DELAY_06 : sync_delay_bus[6*DATA_WIDTH +: DATA_WIDTH]   <= st_data_in;
                    ADDR_SYNC_DELAY_07 : sync_delay_bus[7*DATA_WIDTH +: DATA_WIDTH]   <= st_data_in;
                    ADDR_SYNC_DELAY_08 : sync_delay_bus[8*DATA_WIDTH +: DATA_WIDTH]   <= st_data_in;
                    ADDR_SYNC_DELAY_09 : sync_delay_bus[9*DATA_WIDTH +: DATA_WIDTH]   <= st_data_in;
                    ADDR_SYNC_DELAY_10 : sync_delay_bus[10*DATA_WIDTH +: DATA_WIDTH]  <= st_data_in;
                    ADDR_SYNC_DELAY_11 : sync_delay_bus[11*DATA_WIDTH +: DATA_WIDTH]  <= st_data_in;
                    ADDR_SYNC_DELAY_12 : sync_delay_bus[12*DATA_WIDTH +: DATA_WIDTH]  <= st_data_in;
                    ADDR_SYNC_DELAY_13 : sync_delay_bus[13*DATA_WIDTH +: DATA_WIDTH]  <= st_data_in;
                    ADDR_SYNC_DELAY_14 : sync_delay_bus[14*DATA_WIDTH +: DATA_WIDTH]  <= st_data_in;
                    ADDR_SYNC_DELAY_15 : sync_delay_bus[15*DATA_WIDTH +: DATA_WIDTH]  <= st_data_in;
                    ADDR_SYNC_DELAY_16 : sync_delay_bus[16*DATA_WIDTH +: DATA_WIDTH]  <= st_data_in;
                    ADDR_SYNC_DELAY_17 : sync_delay_bus[17*DATA_WIDTH +: DATA_WIDTH]  <= st_data_in;
                    ADDR_SYNC_DELAY_18 : sync_delay_bus[18*DATA_WIDTH +: DATA_WIDTH]  <= st_data_in;
                    ADDR_SYNC_DELAY_19 : sync_delay_bus[19*DATA_WIDTH +: DATA_WIDTH]  <= st_data_in;
                    ADDR_SYNC_DELAY_20 : sync_delay_bus[20*DATA_WIDTH +: DATA_WIDTH]  <= st_data_in;
                    ADDR_SYNC_DELAY_21 : sync_delay_bus[21*DATA_WIDTH +: DATA_WIDTH]  <= st_data_in;
                    ADDR_SYNC_DELAY_22 : sync_delay_bus[22*DATA_WIDTH +: DATA_WIDTH]  <= st_data_in;
                    ADDR_SYNC_DELAY_23 : sync_delay_bus[23*DATA_WIDTH +: DATA_WIDTH]  <= st_data_in;
                    ADDR_SYNC_DELAY_24 : sync_delay_bus[24*DATA_WIDTH +: DATA_WIDTH]  <= st_data_in;
                    ADDR_SYNC_DELAY_25 : sync_delay_bus[25*DATA_WIDTH +: DATA_WIDTH]  <= st_data_in;
                    ADDR_SYNC_DELAY_26 : sync_delay_bus[26*DATA_WIDTH +: DATA_WIDTH]  <= st_data_in;
                    ADDR_SYNC_DELAY_27 : sync_delay_bus[27*DATA_WIDTH +: DATA_WIDTH]  <= st_data_in;
                    ADDR_SYNC_DELAY_CRC: sync_delay_crc <= st_data_in;

                    ADDR_PULSEWIDTH_00 : pulsewidth[0]  <= st_data_in;
                    ADDR_PULSEWIDTH_01 : pulsewidth[1]  <= st_data_in;
                    ADDR_PULSEWIDTH_02 : pulsewidth[2]  <= st_data_in;
                    ADDR_PULSEWIDTH_03 : pulsewidth[3]  <= st_data_in;
                    ADDR_PULSEWIDTH_CRC: pulsewidth_crc <= st_data_in;

                    ADDR_ENABLE_ID_00  : enable_id[0]   <= st_data_in;
                    ADDR_ENABLE_ID_01  : enable_id[1]   <= st_data_in;
                    ADDR_ENABLE_ID_02  : enable_id[2]   <= st_data_in;
                    ADDR_ENABLE_ID_03  : enable_id[3]   <= st_data_in;
                    ADDR_ENABLE_ID_CRC : enable_id_crc  <= st_data_in;
                    default: ;
                endcase
            end
            else if ( (!st_rden_n) & (counts == COUNTS_COMPARE) ) begin
                case (st_address)
                    ADDR_SYNC_DELAY_00 : st_data_out <= sync_delay_bus[0*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_01 : st_data_out <= sync_delay_bus[1*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_02 : st_data_out <= sync_delay_bus[2*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_03 : st_data_out <= sync_delay_bus[3*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_04 : st_data_out <= sync_delay_bus[4*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_05 : st_data_out <= sync_delay_bus[5*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_06 : st_data_out <= sync_delay_bus[6*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_07 : st_data_out <= sync_delay_bus[7*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_08 : st_data_out <= sync_delay_bus[8*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_09 : st_data_out <= sync_delay_bus[9*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_10 : st_data_out <= sync_delay_bus[10*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_11 : st_data_out <= sync_delay_bus[11*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_12 : st_data_out <= sync_delay_bus[12*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_13 : st_data_out <= sync_delay_bus[13*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_14 : st_data_out <= sync_delay_bus[14*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_15 : st_data_out <= sync_delay_bus[15*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_16 : st_data_out <= sync_delay_bus[16*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_17 : st_data_out <= sync_delay_bus[17*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_18 : st_data_out <= sync_delay_bus[18*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_19 : st_data_out <= sync_delay_bus[19*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_20 : st_data_out <= sync_delay_bus[20*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_21 : st_data_out <= sync_delay_bus[21*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_22 : st_data_out <= sync_delay_bus[22*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_23 : st_data_out <= sync_delay_bus[23*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_24 : st_data_out <= sync_delay_bus[24*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_25 : st_data_out <= sync_delay_bus[25*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_26 : st_data_out <= sync_delay_bus[26*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_27 : st_data_out <= sync_delay_bus[27*DATA_WIDTH +: DATA_WIDTH];
                    ADDR_SYNC_DELAY_CRC: st_data_out <= sync_delay_crc;

                    ADDR_PULSEWIDTH_00 : st_data_out <= pulsewidth[0];
                    ADDR_PULSEWIDTH_01 : st_data_out <= pulsewidth[1];
                    ADDR_PULSEWIDTH_02 : st_data_out <= pulsewidth[2];
                    ADDR_PULSEWIDTH_03 : st_data_out <= pulsewidth[3];
                    ADDR_PULSEWIDTH_CRC: st_data_out <= pulsewidth_crc;

                    ADDR_ENABLE_ID_00  : st_data_out <= enable_id[0];
                    ADDR_ENABLE_ID_01  : st_data_out <= enable_id[1];
                    ADDR_ENABLE_ID_02  : st_data_out <= enable_id[2];
                    ADDR_ENABLE_ID_03  : st_data_out <= enable_id[3];
                    ADDR_ENABLE_ID_CRC : st_data_out <= enable_id_crc;

                    ADDR_TEMP_00   : st_data_out <= temperature[0];
                    ADDR_TEMP_01   : st_data_out <= temperature[1];
                    ADDR_TEMP_02   : st_data_out <= temperature[2];
                    ADDR_TEMP_03   : st_data_out <= temperature[3];
                    ADDR_TEMP_04   : st_data_out <= temperature[4];
                    ADDR_TEMP_05   : st_data_out <= temperature[5];
                    ADDR_TEMP_06   : st_data_out <= temperature[6];
                    ADDR_TEMP_07   : st_data_out <= temperature[7];
                    ADDR_TEMP_08   : st_data_out <= temperature[8];
                    ADDR_TEMP_09   : st_data_out <= temperature[9];
                    ADDR_TEMP_10   : st_data_out <= temperature[10];
                    ADDR_TEMP_11   : st_data_out <= temperature[11];
                    ADDR_TEMP_12   : st_data_out <= temperature[12];
                    ADDR_TEMP_13   : st_data_out <= temperature[13];
                    ADDR_TEMP_14   : st_data_out <= temperature[14];
                    ADDR_TEMP_15   : st_data_out <= temperature[15];
                    ADDR_TEMP_16   : st_data_out <= temperature[16];
                    ADDR_TEMP_17   : st_data_out <= temperature[17];
                    ADDR_TEMP_18   : st_data_out <= temperature[18];
                    ADDR_TEMP_19   : st_data_out <= temperature[19];
                    ADDR_TEMP_20   : st_data_out <= temperature[20];
                    ADDR_TEMP_21   : st_data_out <= temperature[21];
                    ADDR_TEMP_22   : st_data_out <= temperature[22];
                    ADDR_TEMP_23   : st_data_out <= temperature[23];
                    ADDR_TEMP_24   : st_data_out <= temperature[24];
                    ADDR_TEMP_25   : st_data_out <= temperature[25];
                    ADDR_TEMP_26   : st_data_out <= temperature[26];
                    ADDR_TEMP_27   : st_data_out <= temperature[27];
                    ADDR_TEMP_CRC  : st_data_out <= temperature_crc;
 
                    ADDR_VBUS_00   : st_data_out <= busvoltage[0] ;
                    ADDR_VBUS_01   : st_data_out <= busvoltage[1] ;
                    ADDR_VBUS_02   : st_data_out <= busvoltage[2] ;
                    ADDR_VBUS_03   : st_data_out <= busvoltage[3] ;
                    ADDR_VBUS_04   : st_data_out <= busvoltage[4] ;
                    ADDR_VBUS_05   : st_data_out <= busvoltage[5] ;
                    ADDR_VBUS_06   : st_data_out <= busvoltage[6] ;
                    ADDR_VBUS_07   : st_data_out <= busvoltage[7] ;
                    ADDR_VBUS_08   : st_data_out <= busvoltage[8] ;
                    ADDR_VBUS_09   : st_data_out <= busvoltage[9] ;
                    ADDR_VBUS_10   : st_data_out <= busvoltage[10] ;
                    ADDR_VBUS_11   : st_data_out <= busvoltage[11] ;
                    ADDR_VBUS_12   : st_data_out <= busvoltage[12] ;
                    ADDR_VBUS_13   : st_data_out <= busvoltage[13] ;
                    ADDR_VBUS_14   : st_data_out <= busvoltage[14] ;
                    ADDR_VBUS_15   : st_data_out <= busvoltage[15] ;
                    ADDR_VBUS_16   : st_data_out <= busvoltage[16] ;
                    ADDR_VBUS_17   : st_data_out <= busvoltage[17] ;
                    ADDR_VBUS_18   : st_data_out <= busvoltage[18] ;
                    ADDR_VBUS_19   : st_data_out <= busvoltage[19] ;
                    ADDR_VBUS_20   : st_data_out <= busvoltage[20] ;
                    ADDR_VBUS_21   : st_data_out <= busvoltage[21] ;
                    ADDR_VBUS_22   : st_data_out <= busvoltage[22] ;
                    ADDR_VBUS_23   : st_data_out <= busvoltage[23] ;
                    ADDR_VBUS_24   : st_data_out <= busvoltage[24] ;
                    ADDR_VBUS_25   : st_data_out <= busvoltage[25] ;
                    ADDR_VBUS_26   : st_data_out <= busvoltage[26] ;
                    ADDR_VBUS_27   : st_data_out <= busvoltage[27] ;
                    ADDR_VBUS_CRC  : st_data_out <= busvoltage_crc;
 
                    ADDR_STATUS_00 : st_data_out <= status_32b[7:0];
                    ADDR_STATUS_01 : st_data_out <= status_32b[15:8];
                    ADDR_STATUS_02 : st_data_out <= status_32b[23:16];
                    ADDR_STATUS_03 : st_data_out <= status_32b[31:24];
                    ADDR_STATUS_CRC: st_data_out <= status_crc;

                    default : st_data_out <= {DATA_WIDTH{1'b0}};
                endcase
            end
        end
    end

    assign pulsewidth_32b = {pulsewidth[3], pulsewidth[2], pulsewidth[1], pulsewidth[0]};
    assign enable_id_32b  = {enable_id[3], enable_id[2], enable_id[1], enable_id[0]};

endmodule
