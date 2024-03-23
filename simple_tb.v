module spi_tb ();
reg MOSI,SS_n,clk,rst_n;
wire MISO ;
spi_wrapper dut (MOSI,MISO,SS_n,clk,rst_n);
initial begin
    clk=0;
    forever begin
        #1 clk=~clk ;
    end
end
initial begin
         //reset 
    rst_n=0;
    repeat (1) @(negedge clk);
    rst_n=1;
    //start comunication
    @(negedge clk);
    SS_n=0;
    //write
    @(negedge clk);
    MOSI=0;
    //DIN[9:8] = 00 write address
    @(negedge clk);
    MOSI=0;
    @(negedge clk);
    MOSI=0;
    //DIN[7:0] address
    repeat (8) begin
        @(negedge clk);
        MOSI=0;
    end
    //wait another clk edge (rx_data =  temp)
    @(negedge clk);
    //end comunication idle
    @(negedge clk);
     SS_n=1;
    //start comunication
    @(negedge clk); 
    SS_n=0;
    //write
    @(negedge clk);
    MOSI=0;
    //DIN [9:8] = 01 write data
    @(negedge clk);     
    MOSI=0;
    @(negedge clk);
    MOSI=1;
    //Din [7:0] data
    repeat (8) begin
        @(negedge clk);
        MOSI=1;
    end

    //wait another clk edge (rx_data =  temp)
    @(negedge clk);
    //end comunication
    @(negedge clk); 
    SS_n=1; 
    //start comunication
    @(negedge clk); 
    SS_n=0;
    //read
    @(negedge clk); 
    MOSI=1;
    //DIN [9:8] = 10 read address
    @(negedge clk); 
    MOSI=1;
    @(negedge clk); 
    MOSI=0;
    //DIN [7:0] address
    repeat (8) begin
        @(negedge clk);
        MOSI=0;
    end
    //wait another clk edge (rx_data =  temp)
    @(negedge clk);
    //stop communication
    @(negedge clk); 
    SS_n=1; 
    //start comunication
    @(negedge clk); 
    SS_n=0;
    //read
    @(negedge clk); 
    MOSI=1;
    //DIN [9:8] = 11 read data
    @(negedge clk); 
    MOSI=1;
    @(negedge clk); 
    MOSI=1;
    //DIN [7:0] dummy
    repeat (8) begin
        @(negedge clk);
        MOSI=$random;
    end
    //wait another clk edge (rx_data =  temp)
    @(negedge clk);
    // wait for the ram to set TX_DATA
    @(negedge clk);
    //  tx data to miso
    repeat (9)  @(negedge clk);

    //stop communication
    @(negedge clk); 
    SS_n=1; 
    @(negedge clk);
    @(negedge clk);
    $stop;
    end


endmodule
