onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /caches_tb/DUT/ccif/CPUS
add wave -noupdate /caches_tb/DUT/ccif/iwait
add wave -noupdate /caches_tb/DUT/ccif/iREN
add wave -noupdate /caches_tb/DUT/ccif/iload
add wave -noupdate /caches_tb/DUT/ccif/iaddr
add wave -noupdate /caches_tb/DUT/dcif/halt
add wave -noupdate /caches_tb/DUT/dcif/ihit
add wave -noupdate /caches_tb/DUT/dcif/imemREN
add wave -noupdate /caches_tb/DUT/dcif/imemload
add wave -noupdate /caches_tb/DUT/dcif/imemaddr
add wave -noupdate /caches_tb/DUT/dcif/flushed
add wave -noupdate -radix decimal /caches_tb/PERIOD
add wave -noupdate /caches_tb/CPUID
add wave -noupdate /caches_tb/tb_CLK
add wave -noupdate /caches_tb/tb_nRST
add wave -noupdate /caches_tb/instr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {65 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {210 ns}
