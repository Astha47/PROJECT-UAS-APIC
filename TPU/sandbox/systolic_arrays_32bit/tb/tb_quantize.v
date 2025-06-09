`timescale 1ns / 1ps

module tb_quantize;

    // Parameter untuk Testbench dan DUT
    localparam ARRAY_SIZE_TB         = 1;
    localparam DATA_WIDTH_FOR_ORI    = 32;
    localparam INPUT_ELEMENT_WIDTH   = DATA_WIDTH_FOR_ORI + DATA_WIDTH_FOR_ORI + 5; // 69 bit
    localparam OUTPUT_DATA_WIDTH_TB  = 32;

    localparam NUM_INTEGER_BITS_OUT    = 16;
    localparam NUM_FRACTIONAL_BITS_OUT = 16;
    localparam NUM_FRACTIONAL_BITS_IN  = 32;
    localparam SHIFT_AMOUNT = NUM_FRACTIONAL_BITS_IN - NUM_FRACTIONAL_BITS_OUT; // 16

    localparam signed [OUTPUT_DATA_WIDTH_TB-1:0] Q16_16_MAX_VAL = 
        {1'b0, {(NUM_INTEGER_BITS_OUT-1){1'b1}}, {(NUM_FRACTIONAL_BITS_OUT){1'b1}} };
    localparam signed [OUTPUT_DATA_WIDTH_TB-1:0] Q16_16_MIN_VAL = 
        {1'b1, {(NUM_INTEGER_BITS_OUT-1){1'b0}}, {(NUM_FRACTIONAL_BITS_OUT){1'b0}} };

    localparam MAX_CASE_NAME_LENGTH = 60; 
    localparam CASE_NAME_WIDTH = MAX_CASE_NAME_LENGTH * 8;

    reg clk;
    reg signed [ARRAY_SIZE_TB*INPUT_ELEMENT_WIDTH-1:0] ori_data_tb;
    wire signed [ARRAY_SIZE_TB*OUTPUT_DATA_WIDTH_TB-1:0] quantized_data_dut;

    integer error_count;
    integer test_case_num;

    quantize #(
        .ARRAY_SIZE(ARRAY_SIZE_TB),
        .SRAM_DATA_WIDTH(32), 
        .DATA_WIDTH(DATA_WIDTH_FOR_ORI), 
        .OUTPUT_DATA_WIDTH(OUTPUT_DATA_WIDTH_TB)
    ) dut (
        .ori_data(ori_data_tb),
        .quantized_data(quantized_data_dut)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    function signed [OUTPUT_DATA_WIDTH_TB-1:0] calculate_expected_q16_16 (input signed [INPUT_ELEMENT_WIDTH-1:0] current_input_q37_32);
        reg signed [INPUT_ELEMENT_WIDTH-1:0] ref_scaled_value;
        reg signed [INPUT_ELEMENT_WIDTH-1:0] ref_rounded_value;
        reg signed [OUTPUT_DATA_WIDTH_TB-1:0] ref_presat_q16_16;
        reg signed [OUTPUT_DATA_WIDTH_TB-1:0] ref_final_result;
        reg                                  ref_round_add_bit;
        reg signed [INPUT_ELEMENT_WIDTH-1:0] saturation_max_limit_wide;
        reg signed [INPUT_ELEMENT_WIDTH-1:0] saturation_min_limit_wide;
    begin
        if (SHIFT_AMOUNT < 0) ref_scaled_value = current_input_q37_32;
        else if (SHIFT_AMOUNT >= INPUT_ELEMENT_WIDTH) ref_scaled_value = (current_input_q37_32 < 0) ? -1 : 0;
        else ref_scaled_value = current_input_q37_32 >>> SHIFT_AMOUNT;

        if (SHIFT_AMOUNT > 0 && SHIFT_AMOUNT <= INPUT_ELEMENT_WIDTH) ref_round_add_bit = current_input_q37_32[SHIFT_AMOUNT - 1];
        else ref_round_add_bit = 1'b0;
        ref_rounded_value = ref_scaled_value + ref_round_add_bit;
        
        ref_presat_q16_16 = ref_rounded_value[OUTPUT_DATA_WIDTH_TB-1:0];

        if (Q16_16_MAX_VAL[OUTPUT_DATA_WIDTH_TB-1] == 1'b0) begin
             saturation_max_limit_wide = {{INPUT_ELEMENT_WIDTH-OUTPUT_DATA_WIDTH_TB{1'b0}}, Q16_16_MAX_VAL};
        end else begin 
             saturation_max_limit_wide = {{INPUT_ELEMENT_WIDTH-OUTPUT_DATA_WIDTH_TB{1'b1}}, Q16_16_MAX_VAL};
        end

        if (Q16_16_MIN_VAL[OUTPUT_DATA_WIDTH_TB-1] == 1'b1) begin
             saturation_min_limit_wide = {{INPUT_ELEMENT_WIDTH-OUTPUT_DATA_WIDTH_TB{1'b1}}, Q16_16_MIN_VAL};
        end else begin
             saturation_min_limit_wide = {{INPUT_ELEMENT_WIDTH-OUTPUT_DATA_WIDTH_TB{1'b0}}, Q16_16_MIN_VAL};
        end
            
        if (ref_rounded_value >= saturation_max_limit_wide) begin
            ref_final_result = Q16_16_MAX_VAL;
        end else if (ref_rounded_value <= saturation_min_limit_wide) begin
            ref_final_result = Q16_16_MIN_VAL;
        end else begin
            ref_final_result = ref_presat_q16_16;
        end
        calculate_expected_q16_16 = ref_final_result;
    end
    endfunction

    function signed [INPUT_ELEMENT_WIDTH-1:0] float_to_q37_32 (input real val);
    begin
        // PERBAIKAN: Gunakan $rtoi untuk konversi real ke integer
        float_to_q37_32 = $rtoi(val * (2.0**NUM_FRACTIONAL_BITS_IN));
    end
    endfunction

    function real q16_16_to_float (input signed [OUTPUT_DATA_WIDTH_TB-1:0] val_q16_16);
    begin
        q16_16_to_float = val_q16_16 / (2.0**NUM_FRACTIONAL_BITS_OUT);
    end
    endfunction

    task run_test_case;
        input signed [INPUT_ELEMENT_WIDTH-1:0] test_input_q37_32;
        input [CASE_NAME_WIDTH-1:0] case_name_str; 

        reg signed [OUTPUT_DATA_WIDTH_TB-1:0] expected_q16_16;
        reg signed [OUTPUT_DATA_WIDTH_TB-1:0] actual_q16_16;
        integer char_idx;
        integer can_print_char; // Flag untuk menggantikan 'break'

        begin
            test_case_num = test_case_num + 1;
            ori_data_tb = test_input_q37_32; 
            #1; 

            actual_q16_16 = quantized_data_dut; 
            expected_q16_16 = calculate_expected_q16_16(test_input_q37_32);

            $write("Test Case %0d: ", test_case_num);
            // PERBAIKAN: Loop untuk display string dengan flag pengganti 'break'
            can_print_char = 1;
            for (char_idx = 0; (char_idx < MAX_CASE_NAME_LENGTH) && (can_print_char == 1) ; char_idx = char_idx + 1) begin
                if (case_name_str[char_idx*8 +: 8] != 8'h00) begin // Cek karakter null (ASCII 0)
                    $write("%c", case_name_str[char_idx*8 +: 8]);
                end else begin
                    can_print_char = 0; // Set flag untuk berhenti
                end
            end
            $display(""); 

            $display("  Input (Q37.32 hex): %0h (approx float: %f)", test_input_q37_32, test_input_q37_32 / (2.0**NUM_FRACTIONAL_BITS_IN));
            $display("  DUT Output (Q16.16 hex): %0h (approx float: %f)", actual_q16_16, q16_16_to_float(actual_q16_16));
            $display("  Expected (Q16.16 hex): %0h (approx float: %f)", expected_q16_16, q16_16_to_float(expected_q16_16));

            if (actual_q16_16 !== expected_q16_16) begin
                $error("MISMATCH! Expected %0h, Got %0h", expected_q16_16, actual_q16_16);
                error_count = error_count + 1;
            end else begin
                $display("  MATCH!");
            end
            $display("------------------------------------");
        end
    endtask

    initial begin
        $dumpfile("tb_quantize_q1616.vcd");
        $dumpvars(0, tb_quantize);

        error_count = 0;
        test_case_num = 0;
        ori_data_tb = {(ARRAY_SIZE_TB*INPUT_ELEMENT_WIDTH){1'b0}};
        #10;
        
        // Panggil task dengan string literal (pastikan panjangnya tidak melebihi MAX_CASE_NAME_LENGTH)
        // Untuk Verilog standar, string literal akan di-assign ke reg array.
        // Padding dengan spasi atau karakter null (8'h00) jika perlu agar panjangnya konsisten atau
        // agar loop display string berhenti dengan benar.
        // Di sini, kita asumsikan string diakhiri null implisit jika lebih pendek dari MAX_CASE_NAME_LENGTH,
        // atau loop display akan berhenti pada karakter null pertama.
        run_test_case(float_to_q37_32(0.0),         "Zero Input"); // String literal akan di-right-justify dan left-pad dengan nulls jika perlu
        run_test_case(float_to_q37_32(1.0),         "Positive Int 1.0");
        run_test_case(float_to_q37_32(1.5),         "Positive 1.5");
        run_test_case(float_to_q37_32(-1.0),        "Negative Int -1.0");
        run_test_case(float_to_q37_32(-1.5),        "Negative -1.5");
        run_test_case(float_to_q37_32(2.0) + (1 << 15), "Rounding Up (2.0 + 0.5 LSB_target_frac)");
        run_test_case(float_to_q37_32(2.0) + (1 << 14), "No Rounding (2.0 + 0.25 LSB_target_frac)");
        run_test_case(float_to_q37_32(32768.0),     "Saturation Positive (Input 32768.0)");
        run_test_case(float_to_q37_32(40000.0),     "Saturation Positive (Input 40000.0)");
        run_test_case(float_to_q37_32(32767.99999), "Near Saturation Positive");
        run_test_case(float_to_q37_32(-32768.1),    "Saturation Negative (Input -32768.1)");
        run_test_case(float_to_q37_32(-40000.0),    "Saturation Negative (Input -40000.0)");
        run_test_case(float_to_q37_32(-32768.0),    "Min Saturation Negative");

        #50;
        if (error_count == 0) begin
            $display("SUCCESS: All test cases passed!");
        end else begin
            $error("FAILURE: %0d error(s) found.", error_count);
        end
        $finish;
    end
endmodule