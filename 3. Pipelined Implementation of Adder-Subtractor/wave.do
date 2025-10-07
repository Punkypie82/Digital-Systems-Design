onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group Testbench /AdderSubtractor_tb/A
add wave -noupdate -expand -group Testbench /AdderSubtractor_tb/B
add wave -noupdate -expand -group Testbench /AdderSubtractor_tb/nrst
add wave -noupdate -expand -group Testbench /AdderSubtractor_tb/addsub
add wave -noupdate -expand -group Testbench /AdderSubtractor_tb/clk
add wave -noupdate -expand -group Testbench /AdderSubtractor_tb/SUM
add wave -noupdate -expand -group Testbench /AdderSubtractor_tb/cout
add wave -noupdate -expand -group AdderSubtractor /AdderSubtractor_tb/uut/pipelineA
add wave -noupdate -expand -group AdderSubtractor /AdderSubtractor_tb/uut/pipelineB
add wave -noupdate -expand -group AdderSubtractor /AdderSubtractor_tb/uut/pipelineC
add wave -noupdate -expand -group AdderSubtractor /AdderSubtractor_tb/uut/pipelineSum
add wave -noupdate -expand -group AdderSubtractor /AdderSubtractor_tb/uut/pipelineAddsub

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 206
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ns} {105 ns}
