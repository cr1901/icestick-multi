/* A multiboot version of arachne-pnr's rot.v
Requires PMOD-BTN from Digilent or some sort of already-debounced
GPIO input PMOD on the iCEstick. */


module top(input clk, output D1, output D2, output D3, output D4, output D5,
    input BTN1, input BTN2, input BTN3, input BTN4);
    reg ready = 0;
    reg [23:0]     divider;
    reg [3:0]      rot;
    reg            green;

    always @(posedge clk) begin
      if (ready)
        begin
           if (divider == (12000000/`MULTI_DIVIDER))
             begin
                divider <= 0;
                rot <= {rot[2:0], rot[3]};
                green <= ~green;
             end
           else
             divider <= divider + 1;
        end
      else
        begin
           ready <= 1;
           rot <= 4'b0001;
           divider <= 0;
        end
    end

    assign D1 = rot[0];
    assign D2 = rot[1];
    assign D3 = rot[2];
    assign D4 = rot[3];
    assign D5 = green;

    wire [3:0] btns;
    wire [1:0] sel;
    wire boot;

    assign btns = {BTN4, BTN3, BTN2, BTN1};

    encoder choose_boot(
        .btns(btns),
        .sel(sel),
        .valid(boot)
    );

    SB_WARMBOOT warmboot(
        .BOOT(boot),
        .S1(sel[1]),
        .S0(sel[0])
    );
endmodule // top


module encoder(input [3:0] btns, output [1:0] sel, output valid);
    wire [3:0] btns;
    reg [1:0] sel;
    reg valid;

    always @(btns) begin
        case(btns)
            4'b0001: begin
                sel <= 2'b0;
                valid <= 1'b1;
            end

            4'b0010: begin
                sel <= 2'b1;
                valid <= 1'b1;
            end

            4'b0100: begin
                sel <= 2'b10;
                valid <= 1'b1;
            end

            4'b1000: begin
                sel <= 2'b11;
                valid <= 1'b1;
            end

            default: begin
                sel <= 2'b0;
                valid <= 1'b0;
            end
        endcase
    end
endmodule // encoder
