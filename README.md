# AXI4 Interconnect (2 Masters × 3 Slaves) – UVM Verification

UVM verification environment for an AXI4 interconnect that connects **2 AXI masters to 3 AXI slaves**.
The testbench checks address decoding, routing of all five AXI channels, burst transfers, ID based
responses and **round-robin arbitration** when two masters access the same slave.

> Done as part of the RTL Design & Verification course at **Maven Silicon** (BRN69).
> The DUT RTL was provided by Maven Silicon and is **not included** in this repository.
> Everything here (UVM testbench, interfaces with SVA, tests, coverage, Makefile) is my own work.

**Tools:** SystemVerilog · UVM 1.1d · SVA · Functional coverage · Questa 2024.1 (vlog / vsim / vcover) · Makefile

---

## Results

| | |
|---|---|
| Regression | **24 / 24 runs PASS** (4 tests + 10 random seeds × 2 multi-master tests) |
| UVM_ERROR / UVM_FATAL | **0 / 0** in every run |
| Assertions | **95.57 %** (108 of 113 hit, **0 failures**) |
| Functional coverage (covergroups) | **96.52 %** |
| Total coverage (filtered view) | **96.04 %** |
| Master → slave paths verified | **all 6** (M0, M1 → S0, S1, S2) |

![coverage](docs/images/coverage_summary.png)

Details: [`reports/regression_summary.txt`](reports/regression_summary.txt) ·
[`reports/scoreboard_log_excerpt.txt`](reports/scoreboard_log_excerpt.txt)

---

## DUT overview

| Item | Value |
|---|---|
| Masters / Slaves | 2 / 3 |
| Data / Address / ID width | 32 / 32 / 8 bits |
| Channels | AW, W, B (write) · AR, R (read) |
| Burst types | FIXED, INCR, WRAP |
| Arbitration | Round robin, one arbiter per slave (AW and AR) |
| Outstanding requests | 4 |

| Slave | Address range |
|---|---|
| Slave 0 | `0x4000_0000 – 0x4000_0FFF` |
| Slave 1 | `0x4000_1000 – 0x4000_1FFF` |
| Slave 2 | `0x4000_2000 – 0x4000_2FFF` |

---

## Testbench architecture

```
top
 ├─ axi_master_interface x2 ──┐                 ┌── axi_slave_interface x3
 │                            └── AXI INTERCONNECT (DUT) ──┘
 └─ test  (env_config: 2 master agents, 3 slave agents, reset agent, scoreboard)
     └─ env
         ├─ master_agt_top ─ m_agt[0], m_agt[1]      (sequencer, driver, monitor)
         ├─ slave_agt_top  ─ s_agt[0], s_agt[1], s_agt[2] (sequencer, driver, monitor)
         ├─ reset_agent    ─ reset_driver
         └─ scoreboard     ─ fifo_mas[2], fifo_slv[3] + covergroups
```

* **Master driver** – drives AW, W, B, AR, R in parallel (`fork…join`) and keeps the order with queues and semaphores.
* **Slave driver** – behaves like a memory slave: gives READY, stores write data using WSTRB, returns `BID = AWID`, sends `ARLEN+1` read beats with `RLAST`.
* **Monitors** – sample every VALID/READY handshake and send complete transactions to the scoreboard.
* **Scoreboard** – keeps master transactions by ID, matches them with what reached the slave, and compares address, control, every data beat, strobes, response and IDs. It also checks that each slave receives only addresses from its own range.
* **Reset agent** – drives `ARESETn` at the start of simulation.
* **Assertions** (in both interfaces, 23 properties) – signals stable until READY, VALID held until READY, reserved burst, WRAP length and alignment, 4 KB boundary, size/width limits, write response follows write address.
* **Coverage** – 15 covergroups (per master and per slave): address range, burst type/length/size, IDs, responses, VALID/READY crosses, data and strobe values.

---

## Tests

| Test | What it checks |
|---|---|
| `mas_0_test` | Master 0 → Slave 0, write + read |
| `mas_1_test` | Master 1 → Slave 1, write + read |
| `multi_diff_slave_test` | Master 0 → Slave 0 **and** Master 1 → Slave 2 at the same time (parallel paths) |
| `multi_same_slave_test` | Both masters → the same slave, for S0, S1 and S2 (arbitration) |

---

## Waveforms

**Master 1 → Slave 1, 4-beat WRAP write** (AWLEN = 3, AWSIZE = 1, WSTRB = 3, c, 3, c, WLAST on beat 4)
![m1s1](docs/images/wave_m1_to_s1_4beat_burst.png)

**Two masters to different slaves – both accepted in the same clock, no waiting**
![parallel](docs/images/wave_parallel_m0s0_m1s2.png)

**Arbitration – both masters request the same slave**
`request = 11` → `grant = 01` (Master 0) → Master 1 keeps AWVALID high and waits → `grant = 10` (Master 1)
![arb](docs/images/wave_arbitration.png)

**Master 0 → Slave 0 write and read**
![m0s0](docs/images/wave_m0_to_s0.png)

---

## Repository layout

```
interface/     axi_master_interface.sv, axi_slave_interface.sv (clocking blocks + SVA)
master_side/   master xtn, config, driver, monitor, sequencer, sequences, agent, agent top
slave_side/    slave xtn, config, driver, monitor, sequencer, sequence, agent, agent top
tb/            env_config, env, reset agent/driver/config, scoreboard (+ covergroups)
test/          test_pkg.sv, test.sv (base test + 4 tests)
sim/           Makefile and Questa wave scripts
reports/       regression summary and scoreboard log excerpt
docs/images/   waveforms and coverage screenshots
```

## How to run (Questa)

The RTL, `reset_interface` and `top.sv` belong to the Maven Silicon course material and are not in this repo.
Place them in `AXI_Interconnect_rtl/` and `test/top.sv`, then:

```bash
cd sim
make regress     # compile + run the 4 tests + merge coverage
make seeds       # 10 random seeds of the multi-master tests
make merge_all   # final merged coverage summary + HTML report
make waves       # open 4 Questa windows with signals already added
```

## What I learned

* AXI4 protocol in depth: 5 independent channels, VALID/READY handshake, bursts, IDs, responses
* How an interconnect decodes addresses, routes data and arbitrates between masters
* Building a multi-agent UVM environment with config_db and factory
* Writing SVA for protocol rules and closing functional coverage with random seeds
* Debugging with waveforms in Questa
