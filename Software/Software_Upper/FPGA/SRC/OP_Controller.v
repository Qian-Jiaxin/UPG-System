module OP_Controller#(
    parameter USART_ERROR_CODE = 8'hFF,
    parameter USART_HEAD0 = 8'hAB,
    parameter USART_HEAD1 = 8'hBA,
    parameter ADDR_WIDTH = 4'h07,
    parameter DATA_WIDTH = 4'h08)
(
    input  wire                  clk,
    input  wire                  rst_n,

    input   wire [27:0]          usart_rx_bus,
    output  wire [27:0]          pulse_out_bus,

    input  wire                  st_cs_n,
    input  wire                  st_rden_n,
    input  wire                  st_wren_n,
    input  wire [ADDR_WIDTH-1:0] st_address,
    inout  wire [DATA_WIDTH-1:0] st_data,

    input   wire                 st_trigger_n,
    output  wire                 st_warning
);

    wire clk_100mhz, clk_200mhz;
    wire pll_locked;
    PLL	PLL_inst (
	    .inclk0(clk),
	    .c0(clk_100mhz),
	    .c1(clk_200mhz),
	    .locked(pll_locked)
	);

    wire  [DATA_WIDTH-1:0] data_in;
    wire  [DATA_WIDTH-1:0] data_out;

    Sys_Controller #(.USART_ERROR_CODE(USART_ERROR_CODE), .USART_HEAD0(USART_HEAD0), .USART_HEAD1(USART_HEAD1), .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) sys_controller_inst(
        .clk(clk_200mhz),
        .rst_n(rst_n),

        .usart_rx_bus(usart_rx_bus),
        .pulse_out_bus(pulse_out_bus),

        .st_cs_n(st_cs_n),
        .st_rden_n(st_rden_n),
        .st_wren_n(st_wren_n),
        .st_address(st_address),
        .st_data_in(data_in),
        .st_data_out(data_out),

        .st_trigger_n(st_trigger_n),
        .st_waring(st_warning)
    );

    assign st_data = (!st_rden_n) ? data_out : {DATA_WIDTH{1'bz}};

endmodule
