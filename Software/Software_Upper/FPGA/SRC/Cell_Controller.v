module Cell_Controller#(
    parameter USART_ERROR_CODE = 8'hFF,
    parameter USART_HEAD0 = 8'hAB,
    parameter USART_HEAD1 = 8'hBA,
    parameter DATA_WIDTH = 4'h08
)(
    //normal_definition
    input   wire                         clk,
    input   wire                         rst_n,
    input   wire                         en,                      //High level enable
    //usartrx_definition
    input   wire                         usart_rx,
    output  wire [7:0]                   temperature,
    output  wire [7:0]                   busvoltage,
    output  wire                         cellstatus,
    output  wire                         usartstream_done,        //Positive edge trigger
    //pulsegenerate_definition
    input   wire                         trigger_n,               //Negative edge trigger
    input   wire[(DATA_WIDTH<<2)-1:0]    pulsewidth,
    input   wire[DATA_WIDTH-1:0]         sync_delay,
    output  wire                         pulse_out
);

    UsartRx_Stream #(.COMMUNICATION_ERROR_CODE(USART_ERROR_CODE), .HEAD0(USART_HEAD0), .HEAD1(USART_HEAD1)) uasrtrx_stream_inst(
        .clk(clk),
        .rst_n(rst_n),
        .usart_rx(usart_rx),
        .temperature(temperature),
        .busvoltage(busvoltage),
        .cellstatus(cellstatus),
        .done(usartstream_done)
    );

    PulseGenerate #(.DATA_WIDTH(DATA_WIDTH)) pulsegenerator_inst(
        .clk(clk),
        .rst_n(rst_n),
        .st_trigger(trigger_n & en),
        .pulsewidth(pulsewidth),
        .sync_delay(sync_delay),
        .pulse_out(pulse_out)
    );

endmodule

