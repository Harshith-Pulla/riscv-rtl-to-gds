# RISC-V Processor — RTL to GDS Implementation

A complete RTL to GDSII implementation of a RISC-V processor core using the open-source OpenLane ASIC flow on SkyWater SKY130 130nm PDK.

---

## Signoff Summary

| Check | Result | Status |
|-------|--------|--------|
| DRC (Magic) | 0 violations | ✅ PASS |
| LVS (Netgen) | 41,452 nets matched | ✅ PASS |
| Setup Timing (WNS) | 0.00 ns | ✅ PASS |
| Hold Timing | +0.35 ns slack | ✅ PASS |
| IR Drop VPWR | 35.3 mV (1.96%) | ✅ PASS |
| IR Drop VGND | 34.5 mV (1.92%) | ✅ PASS |
| Clock Skew | 0.23 ns | ✅ PASS |
| Total Power | 174 mW | ✅ INFO |

---

## Tools Used

| Tool | Purpose |
|------|---------|
| OpenLane | RTL to GDS automation flow |
| OpenSTA 2.4.0 | Static Timing Analysis |
| OpenROAD PSM | IR Drop / PDN Analysis |
| Yosys | RTL Synthesis |
| Magic VLSI | DRC + Layout |
| Netgen | LVS Verification |
| SKY130 HD | Standard Cell Library |

---

## Flow Overview
```
RTL (Verilog)
    ↓ Synthesis (Yosys)
Gate-Level Netlist
    ↓ Floorplan + PDN
    ↓ Placement
    ↓ Clock Tree Synthesis
    ↓ Routing
    ↓ RC Extraction (SPEF)
    ↓ STA Signoff (OpenSTA)
    ↓ DRC / LVS (Magic/Netgen)
    ↓ IR Drop (OpenROAD PSM)
GDSII Layout ✅
```

## Key Results

- **Zero timing violations** at post-route signoff
- **DRC clean** — 0 Magic DRC violations
- **LVS clean** — layout matches netlist exactly (41,452 nets)
- **Clock skew: 0.23 ns** — balanced 4-level clock tree
- **IR drop: <2%** — robust power delivery network
- **Total power: 174 mW** at Typical corner (TT, 25°C, 1.8V)

---

## Repository Structure
```
├── rtl/              # Verilog RTL source files
├── constraints/      # SDC timing constraints
├── config/           # OpenLane configuration
├── reports/
│   ├── sta/          # Static Timing Analysis reports
│   ├── signoff/      # DRC, LVS, IR drop reports
│   └── power/        # Power analysis report
├── screenshots/      # GDS layout images
└── docs/             # Full project report
```

---

## Author

**Harshith Pulla**
RTL to GDS — RISC-V Processor Implementation
Technology: SkyWater SKY130 130nm | Tool: OpenLane
