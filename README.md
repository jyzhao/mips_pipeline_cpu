mips_pipeline_cpu
=================

MIPS Pipeline CPU, ECE 437, Purdue University

Pipeline Processor

In this multiweek lab, you will be designing a pipeline processor. This processor has the same functionality as the single cycle, it will execute the same ISA but the execution is broken down into stages. The primary components you will need to make are the pipeline registers. Most of the other components will be reused from the single cycle processor.

Design

lab7__1.png
Figure 1. Hierarchy
You will maintain a similar hierarchy for the pipeline as you did for the single cycle. The difference is that the pipeline can will strive to have up to 5 instructions ‘in flight’ at any point in time. This is done by breaking the ‘execution’ of an instruction into stages.

lab7__2.png
Figure 2. Pipeline
The pipeline diagram shows how the execution will be broken up between the 5 stages(fetch, decode, execute, memory, write back). We will go through the stages and see how they interact. The first stage, fetch, loads an instruction from the icache and then passes it along to the decode stage. The decode stage uses the control unit to decide what operations this instruction needs to perform and sets the appropriate signals for the remaining stages and passes those signals to the next stage. Also, in the decode stage the register file is read (not written) during this stage. The execute stage will use the appropriate control signals and data to perform an ‘execute’ operation then pass it to the next stage. The memory stage performs any load, store or other ‘memory’ operation and pass to the final stage. Finally, write back will update the ‘state’ of the machine by writing to the register file if the instruction needs to do this operation.

lab7__3.png
Figure 3. Control Signals
The other unit in the datapath not in any stage is the hazard unit. This component will handle the many issues that come about when you have multiple instructions in various stages of execution, as well as resolve issues with accessing shared resources.

Note
The caches are still pass through blocks for this processor, but the course staff may insert a version of our caches into your design when grading.
Design Specification

You will again use the interfaces the course staff provides when implementing your design. In this processor the register file should be clocked on the falling edge to allow writes in the first half of the cycle and reads on the last half of the cycle.

Packages
CPU types: This contains data types for your processor design.

Interfaces
CPU Ram: Connects your cpu to ram.

Datapath Cache: Connects your datapath to the caches.

Cache Control: Connects your caches to memory_control.

System: Connects the system to the testbench and fpga wrapper.

The use of these packages and interfaces is required in your design. These can not be modified, or changed in any way by you the student.

Important
Only the course staff may make changes to the interfaces and provided types. Should changes be necessary, you will be instructed to pull from the git repository to merge these changes.
Processor Specifications
Use of provided interfaces and packages.

Ability to execute the ISA specified by asm -i, excluding pseudo operations and LL/SC instructions.

Ability to handle hazards from instructions, components, and memory.

The ability to handle up to 5 instructions ‘in flight’.

Tip
Use interfaces (you make them) to connect the pipeline registers.
Setup

For this design you will work from your processors repository

Note
Merge back to your singlecycle branch if you need to.
git checkout singlecycle

Working from your singlecycle branch, issue the following commands:

git checkout -b pipeline

git pull origin pipeline

You should now have your single cycle files for use. and the new files as well.

Files
The following files contain the package and interfaces that are required in this design.

packages: cpu_types_pkg.vh

interfaces: cpu_ram_if.vh, datapath_cache_if.vh, cache_control_if.vh, system_if.vh

You should also have the following component files:

System Components
system.sv

system_fpga.sv

system_tb.sv

ram.sv

These files are templates to guide you in the design of your processor. They contain no functionality.

Processor Components
pipeline.sv

datapath.sv

caches.sv

memory_control.sv

Deliverables

You will be required to make a block diagram of your pipeline processor design. All components should have a testbench associated with them. For the first installment of this lab you are required to have the ISA implemented. The hazard unit does not need to handle most issues, just fetch and memory stages working in unison. You can find the evaluation sheet here for lab 5.

The next installment requires you to be able to handle hazards (remove no ops from asm files). The pipeline should be able to stall, resume execution, and insert bubbles appropriately into the pipeline to avoid corruption of processor state (register file and memory). You can find the evaluation sheet here for lab 6.

The final installment requires you to have forwarding implemented. All pipeline hazards should be accounted for in the hazard unit. Branches and arbitrary memory delays should be accounted for as well. You can find the evaluation sheet here for lab 7.

A table should also be created which will compare your single cycle processor to your pipeline processor. You should compare the maximum clock frequency of both designs, the length of the critical path( in units of time), the latency of instructions, and the MIPS of the processor using the fib.asm program. This information should be collected from synthesized code. Run the test bench on the mapped version for 20ns, 10ns, 5ns, 2ns.

The deliverables for the pipeline processor:

Block diagram of your processor.

Electronically generated with diagramming software.

All signals and detail present for your design.

Processor comparison table

HDL code for components and registers

All components connected to from the processor.

Testbench for hazard unit.

Each hazard documented in testbench.

Completed evaluation sheets for the respective labs.

Electronic submission of your design.

Last updated 2014-02-26 10:30:35 EST
