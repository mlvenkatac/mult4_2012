set lib $::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

# Step 1: Read the cell timing library
read_liberty $lib

# Step 2: Read and link the netlist
read_verilog synth/mult_array_netlist.v
link_design mult_array

# Step 3: Define the clock with period T = 10 ns
create_clock -name clk -period 2.98 [get_ports clk]

# Step 4: Input arrival time
set_input_delay 1.0 -clock clk [delete_from_list [all_inputs] [get_ports clk]]

# Step 5: Output required time
set_output_delay 1.0 -clock clk [all_outputs]

# Step 6: Print the worst setup slack
report_worst_slack -max

# Step 7: Save the critical path report
report_checks -path_delay max -digits 3 > sta/mult_array_timing.rpt
exit
