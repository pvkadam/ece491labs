# 
# Synthesis run script generated by Vivado
# 

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7a100tcsg324-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir {C:/Users/husseinz/Desktop/ece 491/ece491labs/Lab01/Lab_1/Lab_1.cache/wt} [current_project]
set_property parent.project_path {C:/Users/husseinz/Desktop/ece 491/ece491labs/Lab01/Lab_1/Lab_1.xpr} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property board_part digilentinc.com:nexys4_ddr:part0:1.1 [current_project]
read_verilog -library xil_defaultlib -sv {
  {C:/Users/husseinz/Desktop/ece 491/ece491labs/Lab01/Lab_1/counter_parm.sv}
  {C:/Users/husseinz/Desktop/ece 491/ece491labs/Lab01/Lab_1/seven_seg.sv}
  {C:/Users/husseinz/Desktop/ece 491/ece491labs/Lab01/Lab_1/clkenb.sv}
  {C:/Users/husseinz/Desktop/ece 491/ece491labs/Lab01/Lab_1/decoder_3_8_en.sv}
  {C:/Users/husseinz/Desktop/ece 491/ece491labs/Lab01/Lab_1/mux8_parm.sv}
  {C:/Users/husseinz/Desktop/ece 491/ece491labs/Lab01/Lab_1/dispctl.sv}
  {C:/Users/husseinz/Desktop/ece 491/ece491labs/Lab01/Lab_1/reg_param.sv}
  {C:/Users/husseinz/Desktop/ece 491/ece491labs/Lab01/Lab_1/nexys4DDR.sv}
}
foreach dcp [get_files -quiet -all *.dcp] {
  set_property used_in_implementation false $dcp
}
read_xdc {{C:/Users/husseinz/Desktop/ece 491/ece491labs/Lab01/Lab_1/nexys4DDR.xdc}}
set_property used_in_implementation false [get_files {{C:/Users/husseinz/Desktop/ece 491/ece491labs/Lab01/Lab_1/nexys4DDR.xdc}}]


synth_design -top nexys4DDR -part xc7a100tcsg324-1


write_checkpoint -force -noxdef nexys4DDR.dcp

catch { report_utilization -file nexys4DDR_utilization_synth.rpt -pb nexys4DDR_utilization_synth.pb }
