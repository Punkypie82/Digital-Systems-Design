; vlog -reportprogress 300 -work work Path/to/oneCycle.v
vlog -reportprogress 300 -work work Path/to/nCycle.v
vlog -reportprogress 300 -work work Path/to/TestBench_6bit.v
vsim -gui work.AdderSubtractor_tb -voptargs=+acc
do wave.do
run 830ns
