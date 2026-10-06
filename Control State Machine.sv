module mlp_ctrl #(
    parameter int N_IN  = 64,
    parameter int N_HID = 16,
    parameter int N_OUT = 10
) (
    input  logic               clk,
    input  logic               rst_n,
    input  logic               start,
    input  logic signed [31:0] acc,      // from MAC

    output logic               busy,
    output logic               done,     // 1 cyc pulse
    output logic [3:0]         pred,

    output logic               mac_clr,
    output logic               mac_en,

    output logic               layer,    // 0 = L1, 1 = L2
    output logic [4:0]         neuron,
  output logic [6:0]         idx,      // input idx (which neuron)
    output logic               h_we      
);

    typedef enum logic [2:0] {
        IDLE, L1_INIT, L1_MAC, L1_STORE, L2_INIT, L2_MAC, L2_STORE, FINISH
    } state_t;

    state_t             state;
  logic signed [31:0] best_val;   // take the max
    logic [3:0]         best_idx;

    // moore outputs
    assign busy    = (state != IDLE);
    assign mac_clr = (state == L1_INIT) || (state == L2_INIT);
    assign mac_en  = (state == L1_MAC)  || (state == L2_MAC);
    assign layer   = (state == L2_INIT) || (state == L2_MAC) || (state == L2_STORE);
    assign h_we    = (state == L1_STORE);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= IDLE;
            neuron   <= '0;
            idx      <= '0;
            best_val <= '0;
            best_idx <= '0;
            pred     <= '0;
            done     <= 1'b0;
        end else begin
            done <= 1'b0;   // default low

            case (state)
                IDLE: begin
                    if (start) begin
                        neuron <= '0;
                        state  <= L1_INIT;
                    end
                end

                // 64 to 16
                L1_INIT: begin            // loading bias
                    idx   <= '0;
                    state <= L1_MAC;
                end
                L1_MAC: begin             
                    if (idx == N_IN - 1) state <= L1_STORE;
                    else                 idx   <= idx + 1'b1;
                end
                L1_STORE: begin           // write to memory!
                    if (neuron == N_HID - 1) begin
                        neuron <= '0;
                        state  <= L2_INIT;
                    end else begin
                        neuron <= neuron + 1'b1;
                        state  <= L1_INIT;
                    end
                end

               
                L2_INIT: begin
                    idx   <= '0;
                    state <= L2_MAC;
                end
                L2_MAC: begin             
                    if (idx == N_HID - 1) state <= L2_STORE;
                    else                  idx   <= idx + 1'b1;
                end
                L2_STORE: begin
                    
                    if (neuron == 0 || acc > best_val) begin
                        best_val <= acc;
                        best_idx <= neuron[3:0];
                    end
                    if (neuron == N_OUT - 1) state <= FINISH;
                    else begin
                        neuron <= neuron + 1'b1;
                        state  <= L2_INIT;
                    end
                end

                FINISH: begin
                    pred  <= best_idx;
                    done  <= 1'b1;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
