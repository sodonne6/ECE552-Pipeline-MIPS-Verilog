## Project Overview

This directory contains the full course CPU project organized into three implementation stages:

- `phase1_files/` - baseline single-core CPU functionality
- `phase2/` - pipelined datapath with hazard/forwarding support
- `phase3/` - final implementation with cache hierarchy and memory arbitration

The architecture intent for the overall design is captured in the repository root image:

- `../architecture_diagram.png`

## How The Project Was Built (Three Stages)

### Stage 1: Functional Core Bring-Up (`phase1_files/`)

Main goals:

- Implement ISA decode, ALU operations, register file, and memory path.
- Validate instruction flow and assembler output.

Typical files:

- `cpu.v`, `ctrl_unit.v`, `ALU.v`, `register_file.v`
- `memory.v`, `memory_instr.v`
- `assembler.pl`
- `project-phase1-testbench.v`

Outcome:

- A working baseline CPU and tool flow for generating machine-code memory images.

### Stage 2: Pipeline Integration (`phase2/`)

Main goals:

- Split execution into pipeline stages and add pipeline registers.
- Resolve data/control hazards with forwarding and stalling.

Typical files:

- Pipeline regs: `IFID.v`, `IDEX.v`, `EXMEM.v`, `MEMWB.v`
- Hazard/forwarding: `hazard_detection_unit.v`, `forwardunit.v`
- Stage logic: `EX.v`, `M.v`, `WB.v`
- Validation: `project-phase2-testbench.v`

Outcome:

- Functionally pipelined CPU with hazard management.

### Stage 3: Final System with Cache Support (`phase3/`)

Main goals:

- Add instruction/data cache integration and memory interface logic.
- Handle cache miss/fill behavior and memory arbitration.
- Keep pipeline correctness while introducing cache stalls and valid/ready style controls.

Representative files:

- Top-level core: `cpu.v`
- Cache system: `Icache.v`, `D-Cache.v`, `cache_controller.v`, `cache_fill_FSM.v`
- Arrays/metadata: `DataArray.v`, `MetaDataArray.v`, `cache_data_array.v`, `cache_meta_array.v`
- Memory system: `multicycle_memory.v`, `memory_arbitration.v`, `cache_mem_interface.v`
- Final validation: `project-phase3-testbench.v`

Outcome:

- Final implementation combining pipeline + cache subsystem + memory coordination.

## Running The Final Implementation (Based On `phase3/`)

The final executable simulation setup is centered on `phase3/project-phase3-testbench.v`.

### 1) Prepare Program Images

- Use `phase3/assembler.pl` to assemble input `.list`/assembly into text images if needed.
- Existing test images include files like `test1binary.txt`, `test2.txt`, `test3.txt`, `test4.txt`.

Important defaults in memory modules:

- `phase3/memory.v` currently loads `test1binary.txt` on reset.
- `phase3/memory_instr.v` currently loads `test2.txt` on reset.

If you want a different workload, update the `$readmemh(...)` file names in those modules.

### 2) Compile in Simulator

This project was developed with ModelSim/Questa-style assets (`.mpf`, `.cr.mti`, `.wlf` files), so a ModelSim flow is the most direct.

Example command sequence from inside `project/phase3/`:

```bash
vlib work
vlog *.v
vsim cpu_ptb
run -all
```

Notes:

- The testbench module name is `cpu_ptb` (defined in `project-phase3-testbench.v`).
- If compile order issues appear, compile foundational modules first (memories, pipeline regs, ALU/support blocks, cache modules, then `cpu.v`, then the testbench).

### 3) Check Outputs

The testbench writes trace/stat outputs such as:

- `verilogsim.ptrace`
- `verilogsim.plog`

These logs include cycle-by-cycle events, register writes, memory ops, halt detection, and cache hit/request counters.

## Practical Tips

- Keep all runtime text images (`*.txt`) in `project/phase3/` so `$readmemh` paths resolve correctly.
- Start from one known-good test image first, then iterate.
- If memory/instruction images mismatch, simulation can run but produce misleading behavior, so verify both load files before debugging logic.