vlog -reportprogress 300 -work work Path/to/pipelineTea.v
vlog -reportprogress 300 -work work Path/to/TestBench.v
vsim -gui work.TEA_tb -voptargs=+acc
do wave.do
run 830ns
