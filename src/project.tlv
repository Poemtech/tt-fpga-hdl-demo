
\m5_TLV_version 1d: tl-x.org
\m5
   use(m5-1.0)
   
​
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
   
​
   // ======================
   // Computed From Settings
   // ======================
   
   // If debouncing, a user's module is within a wrapper, so it has a different name.
   var(user_module_name, m5_if(m5_debounce_inputs, my_design, m5_my_design))
   var(debounce_cnt, m5_if_defined_as(MAKERCHIP, 1, 8'h03, 8'hff))
   // No TT lab outside of Makerchip.
   if_defined_as(MAKERCHIP, 1, [''], ['m5_set(in_fpga, 0)'])
​
​
\SV
   // =================
   // Include Libraries
   // =================
   
   // Tiny Tapeout Lab.
   m4_include_lib(https:/['']/raw.githubusercontent.com/os-fpga/Virtual-FPGA-Lab/5744600215af09224b7235479be84c30c6e50cb7/tlv_lib/tiny_tapeout_lib.tlv)
   // Calculator VIZ.
   m4_include_lib(https:/['']/raw.githubusercontent.com/efabless/chipcraft---mest-course/main/tlv_lib/calculator_shell_lib.tlv)
​
​
​
\TLV calc()
   
   // ==========
   // User Logic
   // ==========
   
   |calc
      @0
         $reset = *reset;
         
         // Board's switch inputs
         $op[1:0] = *ui_in[5:4];
         $val2[7:0] = {4'b0, *ui_in[3:0]};
         $equals_in = *ui_in[7];
         
      @1
         // Calculator result value ($out) becomes first operand ($val1).
         $val1[7:0] = >>1$out;
         
         // Perform a valid computation when "=" button is pressed.
         $valid = $reset ? 1'b0 :
                           $equals_in && ! >>1$equals_in;
         
         // Calculate (all possible operations).
         $sum[7:0] = $val1 + $val2;























/top
@0
/digit[0:0]
/leds[7:0]
@0
/fpga_pins
/fpga
|calc
@0
@1
@2
/switch[7:0]
@0
$slideswitch
$sseg_
decimal_
point_
n
$sseg_
digit_
n
$sseg_
segment_
n
$viz_
lit
$diff
$digit
$equals_
in
$op
$out
$prod
$quot
$reset
$sum
$val1
$val2
$valid
$viz_
switch
*reset
*ui_in
*uio_oe
*uio_out
*uo_out
