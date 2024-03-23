module spi (
    MOSI,MISO,SS_n,clk,rst_n,rx_data,rx_valid,tx_data,tx_valid
);
    input MOSI,SS_n,clk,rst_n,tx_valid;
    output reg MISO,rx_valid;
    input [7:0] tx_data;
    output reg [9:0] rx_data;
    reg get_data;
    reg [4:0]counter;
    reg [9:0] temp;
    parameter IDLE = 0;
    parameter CHK_CMD = 1;
    parameter WRITE = 2;
    parameter READ_ADD = 3;
    parameter READ_DATA = 4;

    (* fsm_encoding = "sequential" *)    
    reg [2:0] cs,ns;

    //state memory
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            cs<= IDLE;
         end

        else 
            cs<= ns;    
    end
    
    // next state  logic
    always @(cs or SS_n or MOSI ) begin
        case (cs)
            IDLE :begin
                if (~SS_n)
                    ns= CHK_CMD;
                else
                    ns= IDLE;
            end
            CHK_CMD :begin
                if (SS_n==0 && MOSI==0)
                    ns=  WRITE ;
                else if (SS_n==0 && MOSI==1 && get_data==1)
                    ns= READ_DATA ;
                else if (SS_n==0 && MOSI==1 && get_data==0) 
                    ns= READ_ADD;
                else if (SS_n) 
                 ns= IDLE; 
            end
            WRITE :begin
                if (~SS_n)
                    ns= WRITE ;
                else 
                    ns= IDLE ;    
            end
            READ_ADD : begin
                if (~SS_n)
                    ns= READ_ADD ;
                else
                    ns= IDLE ;
            end 
            READ_DATA : begin
                if (~SS_n)
                    ns= READ_DATA ;
                else
                    ns= IDLE ;
            end                 
  
        endcase
    end

    // OUTPUT LOGIC
    always@(posedge clk) begin
        if (!rst_n) 
            MISO <= 0;
        else begin
            case (cs)
                IDLE : begin
                        rx_valid <= 0;
                        counter <= 0;
                        MISO <= 0;
                end
                WRITE : begin
                    if (counter < 11) begin
                        temp <= {temp[8:0], MOSI};
                        if (counter == 10) begin
                            rx_data <= temp;
                            rx_valid <= 1;
                        end
                           
                        else 
                            counter <= counter + 1;
                    end
                end
                READ_ADD : begin
                    if (counter < 11) begin
                        temp <= {temp[8:0], MOSI};
                        if (counter == 10) begin
                            rx_data <= temp;
                            rx_valid <= 1;
                            get_data <= 1;
                        end
                        else 
                            counter <= counter + 1;
                    end
                end
                READ_DATA : begin
                    if (counter < 20) begin
                        temp <= {temp[8:0], MOSI};
                        if (counter == 10)
                            rx_data <= temp;
                        if (tx_valid)
                            MISO <= tx_data[19-counter];
                        if (counter == 19)
                            get_data <= 0;
                        else 
                            counter <= counter + 1;
                    end
                end  
            endcase
        end
    end
    endmodule






    
