onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group Testbench /TEA_tb/clk
add wave -noupdate -expand -group Testbench /TEA_tb/nrst
add wave -noupdate -expand -group Testbench /TEA_tb/start
add wave -noupdate -expand -group Testbench /TEA_tb/v0_in
add wave -noupdate -expand -group Testbench /TEA_tb/v1_in
add wave -noupdate -expand -group Testbench /TEA_tb/k0
add wave -noupdate -expand -group Testbench /TEA_tb/k1
add wave -noupdate -expand -group Testbench /TEA_tb/k2
add wave -noupdate -expand -group Testbench /TEA_tb/k3
add wave -noupdate -expand -group Testbench /TEA_tb/v0_out
add wave -noupdate -expand -group Testbench /TEA_tb/v1_out
add wave -noupdate -expand -group Testbench /TEA_tb/done
add wave -noupdate -expand -group TEA /TEA_tb/uut/v0_pipeline_p
add wave -noupdate -expand -group TEA /TEA_tb/uut/v0_pipeline_c
add wave -noupdate -expand -group TEA /TEA_tb/uut/v1_pipeline_p
add wave -noupdate -expand -group TEA /TEA_tb/uut/v1_pipeline_c
add wave -noupdate -expand -group TEA /TEA_tb/uut/sum_pipeline
add wave -noupdate -expand -group TEA /TEA_tb/uut/cycle_pipeline
add wave -noupdate -expand -group TEA /TEA_tb/uut/enable

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
