# Digital VLSI Assignment: 4-bit Array Multiplier from RTL to GDSII

- **Name:** Lakshmana Venkatachary M
- **Roll Number:** 2012
- **Design:** 4-bit x 4-bit Unsigned Array Multiplier (mult_array)
- **Technology:** SkyWater SKY130 (130 nm), Standard Cell Library sky130_fd_sc_hd

## Repository Structure

    mult4_2012/
    ├── README.md
    ├── rtl/
    │   ├── full_adder.v
    │   └── mult_array.v
    ├── tb/
    │   └── tb_mult.v
    ├── synth/
    │   ├── synth.tcl
    │   ├── mult_array_netlist.v
    │   └── mult_array_stat.rpt
    ├── sta/
    │   ├── sta.tcl
    │   └── mult_array_timing.rpt
    ├── pnr/
    │   ├── config.json
    │   ├── metrics.json
    │   └── mult_array.gds
    └── report/
        └── report.pdf

## Commands Executed in Order

### 1. Environment Check
    export PDK=sky130A
    iverilog -V | head -1
    yosys -V
    sta -version
    echo $PDK_ROOT $PDK

### 2. Part A — RTL Design and Verification
    iverilog -g2012 -o sim tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v
    vvp sim
    gtkwave mult.vcd

### 3. Part B — Logic Synthesis with Yosys
    yosys -c synth/synth.tcl
    CELLS=$PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/verilog
    iverilog -g2012 -DFUNCTIONAL -DUNIT_DELAY=#1 -o gls tb/tb_mult.v $CELLS/primitives.v $CELLS/sky130_fd_sc_hd.v synth/mult_array_netlist.v
    vvp gls

### 4. Part C — Static Timing Analysis with OpenSTA
    sta sta/sta.tcl
    sed -i 's/-period 10.0/-period 2.98/g' sta/sta.tcl
    sta sta/sta.tcl

### 5. Part D — Physical Design: RTL to GDSII with LibreLane
    cd pnr
    # Run 1 at CLOCK_PERIOD = 4.0 ns (0 DRC, 0 LVS, -0.0102 ns slow-corner setup slack)
    librelane config.json

    # Run 2 at CLOCK_PERIOD = 4.5 ns (0 DRC, 0 LVS, +0.284 ns worst-case setup slack)
    sed -i 's/"CLOCK_PERIOD": 4.0/"CLOCK_PERIOD": 4.5/g' config.json
    librelane config.json

    cp $(ls -td runs/*/final | head -1)/metrics.json ./metrics.json
    cp $(ls -td runs/*/final/gds | head -1)/mult_array.gds ./mult_array.gds
    klayout mult_array.gds
