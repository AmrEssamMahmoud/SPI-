module ram (din, rx_valid, clk, rst_n, dout, tx_valid);
    parameter MEM_DEPTH = 256;
    parameter ADDR_SIZE = 8;

    input[9:0] din;
    input rx_valid, clk, rst_n;
    output reg[7:0] dout;
    output reg tx_valid;

    reg[7:0] write_addr, read_addr;
    reg[ADDR_SIZE-1:0] mem [MEM_DEPTH-1:0];

    always@(posedge clk) begin
        if (!rst_n) begin
            dout <= 0;
            tx_valid <= 0;
            write_addr <= 0;
            read_addr <= 0;
        end
        else if (din[9:8] == 2'b11) begin
            dout <= mem[read_addr];
            tx_valid <= 1;
        end
        else if (rx_valid) begin
            case (din[9:8])
                2'b00 : write_addr <= din[7:0];  
                2'b01 : mem[write_addr] <= din[7:0];
                2'b10 : read_addr <= din[7:0];
            endcase
            tx_valid <= 0;
        end
    end
endmodule
