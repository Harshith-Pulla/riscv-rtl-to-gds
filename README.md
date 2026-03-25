**# RTL to GDSII Implementation of a 32-bit RV32I Single-Cycle RISC-V Processor

<p align="center">
  <img src="https://img.shields.io/badge/RISC--V-RV32I-blue?style=for-the-badge&logo=riscv"/>
  <img src="https://img.shields.io/badge/PDK-SkyWater%20130nm-green?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Tool-OpenLane%20%2F%20OpenROAD-orange?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Status-Tapeout%20Ready-brightgreen?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/DRC-Clean-brightgreen?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/LVS-Clean-brightgreen?style=for-the-badge"/>
</p>

---

## 📌 Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [RTL Design](#rtl-design)
- [Verification](#verification)
- [ASIC Flow](#asic-flow)
- [Results](#results)
- [Tools Used](#tools-used)
- [How to Run](#how-to-run)
- [Team](#team)

---

## Overview

This project implements a fully functional **32-bit RV32I single-cycle RISC-V processor** and takes it through the complete **RTL to GDSII physical design flow** using the open-source **OpenLane/OpenROAD** toolchain, targeting the **SkyWater 130nm (sky130_fd_sc_hd)** process design kit.

The processor supports the complete **RV32I base integer instruction set**, including:

- **R-type** — register-register operations (ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU)
- **I-type** — immediate arithmetic and loads (ADDI, ANDI, ORI, XORI, LW, JALR)
- **S-type** — store instructions (SW)
- **B-type** — branch instructions (BEQ, BNE, BLT, BGE, BLTU, BGEU)
- **U-type** — upper immediate (LUI, AUIPC)
- **J-type** — jump instructions (JAL)

### Key Highlights

| Metric | Value |
|--------|-------|
| ISA | RV32I (32-bit base integer) |
| Architecture | Single-cycle |
| Technology | SkyWater 130nm (sky130_fd_sc_hd) |
| Clock Frequency | **70.92 MHz** (14.1 ns period) |
| Die Area | 900 × 900 μm |
| Chip Area | **305,093.86 μm²** |
| Standard Cells | 31,801 |
| DRC Violations | **0** ✅ |
| LVS Status | **Clean** ✅ |
| Hold Slack (WHS) | **0.35 ns** (MET) ✅ |

---

## Project Structure

```
riscv/
├── src/                          # RTL Verilog source files
│   ├── top.v                     # Top-level module
│   ├── instruction_fetch_unit.v  # PC register and fetch logic
│   ├── instruction_memory.v      # ROM (initialized from program.hex)
│   ├── control_unit.v            # Combinational instruction decoder
│   ├── data_path.v               # ALU, register file, memory integration
│   ├── alu.v                     # 32-bit ALU (10 operations)
│   ├── register_file.v           # 32×32-bit register file
│   ├── imm_gen.v                 # Immediate generator (all RV32I formats)
│   ├── data_memory.v             # Synchronous data memory
│   └── program.hex               # Test program in hex format
│
├── sim/                          # Simulation files
│   └── top_tb.v                  # Testbench
│
├── constraints/
│   └── top.sdc                   # Timing constraints (14.1 ns clock)
│
├── runs/
│   └── fourth_run/               # OpenLane run outputs
│       ├── results/
│       │   ├── synthesis/        # Synthesized netlist
│       │   ├── floorplan/        # Floorplan DEF
│       │   ├── placement/        # Placed DEF
│       │   ├── cts/              # Post-CTS DEF
│       │   ├── routing/          # Routed DEF
│       │   └── final/gds/        # Final GDSII (top.gds)
│       ├── reports/
│       │   └── signoff/          # DRC, LVS, timing, IR drop reports
│       └── logs/                 # Flow logs per stage
│
├── config.json                   # OpenLane flow configuration
└── README.md
```

---

## Architecture

The processor follows a classic single-cycle RISC-V datapath organized into four top-level modules:

```
                    ┌─────────────────────────────────────────────┐
                    │                    TOP                       │
                    │                                              │
   ┌──────────┐     │  ┌─────────────┐      ┌──────────────────┐  │
   │INSTRUCTION│───▶│  │ INSTRUCTION  │─────▶│   CONTROL UNIT   │  │
   │  MEMORY  │     │  │ FETCH UNIT  │      │  (Decoder/FSM)   │  │
   └──────────┘     │  └─────────────┘      └──────────────────┘  │
                    │         │                       │            │
                    │         ▼                       ▼            │
                    │  ┌────────────────────────────────────────┐  │
                    │  │             DATA PATH UNIT              │  │
                    │  │  ┌─────────┐  ┌──────────────────────┐ │  │
                    │  │  │   ALU   │  │   REGISTER FILE      │ │  │
                    │  │  └─────────┘  └──────────────────────┘ │  │
                    │  │               ┌──────────────────────┐  │  │
                    │  │               │    DATA MEMORY       │  │  │
                    │  │               └──────────────────────┘  │  │
                    │  └────────────────────────────────────────┘  │
                    └─────────────────────────────────────────────┘
```

---

## RTL Design

### Module Descriptions

| Module | File | Description |
|--------|------|-------------|
| `top` | `top.v` | Top-level wrapper; instantiates all sub-modules |
| `instruction_fetch_unit` | `instruction_fetch_unit.v` | 32-bit PC register; computes PC+4; selects branch/jump target |
| `instruction_memory` | `instruction_memory.v` | ROM initialized from `program.hex`; outputs 32-bit instruction |
| `control_unit` | `control_unit.v` | Combinational decoder; generates RegWrite, ALUSrc, MemWrite, MemRead, MemToReg, Branch, Jump, ALUControl |
| `data_path` | `data_path.v` | Integrates register file, imm gen, ALU, data memory; resolves branches |
| `alu` | `alu.v` | 32-bit ALU supporting ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU |
| `register_file` | `register_file.v` | 32×32-bit synchronous register file; 2 read ports, 1 write port |
| `imm_gen` | `imm_gen.v` | Sign-extends immediates for I, S, B, U, J formats |
| `data_memory` | `data_memory.v` | Synchronous 32-bit data memory with MemRead/MemWrite control |

### ALU Operations

| ALUControl | Operation | Instruction |
|-----------|-----------|-------------|
| `4'b0000` | ADD | ADD, ADDI, LW, SW |
| `4'b0001` | SUB | SUB, BEQ, BNE |
| `4'b0010` | AND | AND, ANDI |
| `4'b0011` | OR | OR, ORI |
| `4'b0100` | XOR | XOR, XORI |
| `4'b0101` | SLL | SLL, SLLI |
| `4'b0110` | SRL | SRL, SRLI |
| `4'b0111` | SRA | SRA, SRAI |
| `4'b1000` | SLT | SLT, SLTI |
| `4'b1001` | SLTU | SLTU, SLTIU |

---

## Verification

Functional verification was performed in **Xilinx Vivado** using a self-checking testbench.

### Simulation Results

- PC increments correctly by 4 bytes each clock cycle ✅
- All R-type, I-type, load/store, branch, and jump instructions verified ✅
- Control signals (RegWrite, ALUSrc, MemWrite, MemRead, Branch, Jump) assert correctly per instruction ✅
- PCSrc asserts on taken branches and jumps ✅

### Vivado Timing Results

| Metric | Value | Status |
|--------|-------|--------|
| Worst Negative Slack (WNS) | 0.228 ns | ✅ MET |
| Total Negative Slack (TNS) | 0.000 ns | ✅ MET |
| Worst Hold Slack (WHS) | 0.042 ns | ✅ MET |
| Failing Endpoints | 0 / 1915 | ✅ Clean |
| Clock Period | 14.000 ns | 71.429 MHz |

---

## ASIC Flow

The complete physical design was implemented using **OpenLane v2** on **Ubuntu 24.04 LTS**.

### Flow Overview

```
RTL (Verilog)
     │
     ▼
 Synthesis (Yosys)
     │  → Gate-level netlist, 20,724 cells, 305,093 μm²
     ▼
 Floorplan (OpenROAD)
     │  → 900×900 μm die, PDN with 100 μm stripe pitch
     ▼
 Placement (RePlAce + OpenDP)
     │  → 31,885 std cells placed, density = 50%
     ▼
 CTS (TritonCTS)
     │  → 824 clock buffers, 8,736 sinks, 6-level tree
     ▼
 Routing (FastRoute + TritonRoute)
     │  → met1–met5, 41,450 nets, 91 antenna cells
     ▼
 Signoff
     │  → STA: Hold slack 0.35ns ✅ | DRC: 0 violations ✅ | LVS: Clean ✅
     ▼
 GDSII (top.gds)
```

### OpenLane Configuration (`config.json`)

```json
{
  "DESIGN_NAME": "top",
  "CLOCK_PORT": "clk",
  "CLOCK_PERIOD": 14.1,
  "FP_CORE_UTIL": 45,
  "PL_TARGET_DENSITY": 0.50,
  "FP_SIZING": "absolute",
  "DIE_AREA": "0 0 900 900",
  "CORE_AREA": "10 10 890 890",
  "FP_PDN_VPITCH": 100,
  "FP_PDN_HPITCH": 100,
  "MAX_FANOUT_CONSTRAINT": 8,
  "SYNTH_MAX_FANOUT": 8,
  "DIODE_INSERTION_STRATEGY": 3
}
```

### Physical Design Flow — Progressive Statistics

| Metric | Floorplan | Placement | CTS | Routing |
|--------|-----------|-----------|-----|---------|
| Total Components | 43,497 | 43,581 | 44,405 | 101,935 |
| Standard Cells | 31,801 | 31,885 | 31,885 | 41,448 |
| Tapcells | 11,050 | 11,050 | 11,050 | 11,050 |
| Clock Buffers | — | — | 824 | 824 |
| Antenna Cells | — | — | — | 91 |
| Total Nets | 31,803 | 31,887 | 32,711 | 41,450 |
| Connections | 84,265 | 84,433 | 86,081 | 103,650 |

---

## Results

### Final Signoff Summary

| Category | Metric | Value | Status |
|----------|--------|-------|--------|
| **Area** | Die Area | 900 × 900 μm | — |
| **Area** | Chip Area | 305,093.86 μm² | — |
| **Timing** | Clock Period | 14.1 ns (70.92 MHz) | — |
| **Timing** | Hold Slack (WHS) | 0.35 ns | ✅ MET |
| **Timing** | Failing Endpoints | 0 | ✅ Clean |
| **Power** | Avg IR Drop (VPWR) | 18.9 mV | ✅ Within limit |
| **Power** | Avg IR Drop (VGND) | 18.8 mV | ✅ Within limit |
| **Physical** | DRC Violations | 0 | ✅ Clean |
| **Physical** | LVS | Circuits match uniquely | ✅ Clean |
| **CTS** | Clock Sinks | 8,736 | — |
| **CTS** | Buffers Inserted | 824 | — |
| **Routing** | Metal Layers | met1 – met5 | — |

---

## Tools Used

| Tool | Purpose | Version |
|------|---------|---------|
| **Xilinx Vivado** | RTL simulation, synthesis, timing analysis | 2024.x |
| **OpenLane** | RTL-to-GDSII automated flow | v2 |
| **OpenROAD** | Floorplan, placement, CTS, routing, STA | — |
| **Yosys** | Logic synthesis | — |
| **TritonCTS** | Clock tree synthesis | — |
| **FastRoute / TritonRoute** | Global and detailed routing | — |
| **Magic** | DRC, SPICE extraction | — |
| **Netgen** | LVS verification | — |
| **KLayout** | GDSII viewing and verification | 0.28.x |
| **OpenSTA** | Static timing analysis | — |
| **PDK** | SkyWater 130nm sky130_fd_sc_hd | sky130A |
| **OS** | Ubuntu 24.04 LTS | — |

---

## How to Run

### Prerequisites

- OpenLane v2 installed ([OpenLane Installation Guide](https://openlane.readthedocs.io))
- SkyWater sky130 PDK set up
- Docker (required by OpenLane)

### 1. Clone the Repository

```bash
git clone https://github.com/<your-username>/riscv-single-cycle-asic.git
cd riscv-single-cycle-asic
```

### 2. RTL Simulation (Vivado)

Open Xilinx Vivado, create a project, add all files from `src/` and `sim/`, and run behavioral simulation.

### 3. Run OpenLane Flow

```bash
# Copy design into OpenLane designs directory
cp -r riscv/ $OPENLANE_ROOT/designs/

# Launch OpenLane
cd $OPENLANE_ROOT
./flow.tcl -design riscv -tag fourth_run
```

### 4. View Results

```bash
# Open final GDS in KLayout
klayout runs/fourth_run/results/final/gds/top.gds

# View signoff reports
cat runs/fourth_run/reports/signoff/drc.rpt
cat runs/fourth_run/logs/signoff/32-irdrop.log
```

### 5. Open Interactive OpenROAD

```bash
openroad
read_def runs/fourth_run/results/routing/top.def
```

---

## Team

**Sreenidhi Institute of Science and Technology**
Department of Electronics and Communication Engineering
Course: Digital ASIC Flow | Academic Year 2025–2026

| Name | Roll Number |
|------|-------------|
| P. Harshith | 22311A04K5 |
| Ch. Vishnu | 22311A04L5 |
| G. Sai Charan | 22311A04M5 |

**Guide:** Prof. Vikram Poladia, ECE Department

---

## References

1. A. Waterman and K. Asanovic, *The RISC-V Instruction Set Manual, Volume I: Unprivileged ISA*, RISC-V Foundation, 2019.
2. OpenLane Documentation — https://openlane.readthedocs.io
3. OpenROAD Project — https://theopenroadproject.org
4. SkyWater PDK — https://github.com/google/skywater-pdk
5. D. Patterson and J. Hennessy, *Computer Organization and Design RISC-V Edition*, 2nd ed., Morgan Kaufmann, 2020.

---

<p align="center">
  Made with ❤️ using open-source EDA tools &nbsp;|&nbsp; SkyWater 130nm PDK &nbsp;|&nbsp; OpenLane / OpenROAD
</p>**
