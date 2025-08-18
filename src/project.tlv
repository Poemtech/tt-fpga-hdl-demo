\m5_TLV_version 1d: tl-x.org
\m5
   use(m5-1.0)
   

   // #################################################################
   // #                                                               #
   // #  Starting-Point Code for MEST Course Tiny Tapeout Calculator  #
   // #                                                               #
   // #################################################################
   
   // ========
   // Settings
   // ========
   
   var(my_design, tt_um_example)   /// The name of your top-level TT module, to match your info.yml.
   var(target, TT10) /// Use "FPGA" for TT03 Demo Boards (without bidirectional I/Os).
   var(debounce_inputs, 0)
          /// Legal values:
          ///   1: Provide synchronization and debouncing on all input signals.
          ///   0: Don't provide synchronization and debouncing.
          ///   m5_if_defined_as(MAKERCHIP, 1, 0, 1): Debounce unless in Makerchip.
   var(in_fpga, 1)   /// For Makerchip development: 1 to include the demo board in VIZ (in which case, logic will be under /fpga_pins/fpga).
   

   // ======================
   // Computed From Settings
   // ======================
   
   // If debouncing, a user's module is within a wrapper, so it has a different name.
   var(user_module_name, m5_if(m5_debounce_inputs, my_design, m5_my_design))
   var(debounce_cnt, m5_if_defined_as(MAKERCHIP, 1, 8'h03, 8'hff))
   // No TT lab outside of Makerchip.
   if_defined_as(MAKERCHIP, 1, [''], ['m5_set(in_fpga, 0)'])


\SV
   // =================
   // Include Libraries
   // =================
   
   // Tiny Tapeout Lab.
   m4_include_lib(https:/['']/raw.githubusercontent.com/os-fpga/Virtual-FPGA-Lab/5744600215af09224b7235479be84c30c6e50cb7/tlv_lib/tiny_tapeout_lib.tlv)
   // Calculator VIZ.
   m4_include_lib(https:/['']/raw.githubusercontent.com/efabless/chipcraft---mest-course/main/tlv_lib/calculator_shell_lib.tlv)



\TLV calc()
    
   |calc
      @1
         
         $reset = *reset;
         // Constrain the inputs to avoid overflow.
         $val1[7:0] = >>1$out; //Feed the output back to the input as the next operand.
        // $val2[7:0] = {5'b0, $rand2[2:0]};
         //...
       // Calculator arithmetic functions
         $sum[7:0]  = $val1 + $val2;
         $diff[7:0] = $val1 - $val2;
         $prod[7:0] = $val1 * $val2;
         $quot[7:0] = $val2 == 0 ? 8'hff : $val1 / $val2;
      // Operation button
      
         $equals_in[7:0] =  *ui_in[7];
         $valid = $reset ? 1'b0 :
                           $equals_in && ! >>1$equals_in;

         $out[7:0] =    $reset ? 8'b0: // Highest priority
                        $valid ? >>1$out    :
                           $op[1:0] == 2'd0 ? $sum :
                           $op[1:0] == 2'd1 ? $diff:
                           $op[1:0] == 2'd2 ? $prod: 
                           $quot; 
                          
                           
         $op[1:0] = *ui_in[5:4];
         $val2[7:0] = {4'b0, *ui_in[3:0]};
         *uo_out = $out == 8'h1 ? 8'b00000110 :
                   $out == 8'h2 ? 8'b01011011 :               
                   $out == 8'h3 ? 8'b01001111 :
                   $out == 8'h4 ? 8'b01100110 :
                   $out == 8'h5 ? 8'b01101101 :
                   $out == 8'h6 ? 8'b01111101 :
                   $out == 8'h7 ? 8'b00000111 :
                   $out == 8'h8 ? 8'b01111111 :
                   $out == 8'h9 ? 8'b01101111 :
                   $out == 8'ha ? 8'b01110111 :
                   $out == 8'hb ? 8'b01111100 :
                   $out == 8'hc ? 8'b00111001 :
                   $out == 8'hd ? 8'b01011110 :
                   $out == 8'he ? 8'b01111001 :
                   $out == 8'hf ? 8'b01110001 :
                   8'b01011111;
   
         // Note that pipesignals assigned here can be found under /fpga_pins/fpga (if in_fpga is set to 1 above).



   m5+cal_viz(@1, m5_if(m5_in_fpga, /fpga, /top))

   // Connect Tiny Tapeout outputs. Note that uio_ outputs are not available in the Tiny-Tapeout-3-based FPGA boards.
  // *uo_out = 8'b0;
   *uio_out = 8'b0;
   *uio_oe = 8'b0;



\SV

// ================================================
// A simple Makerchip Verilog test bench driving random stimulus.
// Modify the module contents to your needs.
// ================================================

module top(input logic clk, input logic reset, input logic [31:0] cyc_cnt, output logic passed, output logic failed);
   // Tiny tapeout I/O signals.
   logic [7:0] ui_in, uio_in, uo_out, uio_out, uio_oe;
   logic [31:0] r;  // a random value
   always @(posedge clk) r <= m5_if_defined_as(MAKERCHIP, 1, ['$urandom()'], ['0']);
   assign ui_in = r[7:0];
   assign uio_in = 8'b0;
   logic ena = 1'b0;
   logic rst_n = ! reset;
   
   // Instantiate the Tiny Tapeout module.
   m5_my_design tt(.*);
   
   assign passed = top.cyc_cnt > 80;
   assign failed = 1'b0;
endmodule


// Provide a wrapper module to debounce input signals if requested.
m5_if(m5_debounce_inputs, ['m5_tt_top(m5_my_design)'])
\SV



// =======================
// The Tiny Tapeout module
// =======================

module m5_user_module_name (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

   wire reset = ! rst_n;

   // List all potentially-unused inputs to prevent warnings
   wire _unused = &{ena, clk, rst_n, 1'b0};

\TLV tt_lab()
   // Connect Tiny Tapeout I/Os to Virtual FPGA Lab.
   m5+tt_connections()
   // Instantiate the Virtual FPGA Lab.
   m5+board(/top, /fpga, 7, $, , calc)
   // Label the switch inputs [0..7] (1..8 on the physical switch panel) (top-to-bottom).
   m5_if(m5_in_fpga, ['m5+tt_input_labels_viz(['"Value[0]", "Value[1]", "Value[2]", "Value[3]", "Op[0]", "Op[1]", "Op[2]", "="'])'])

\TLV
   /* verilator lint_off UNOPTFLAT */
   m5_if(m5_in_fpga, ['m5+tt_lab()'], ['m5+calc()'])

\SV
endmodule
