vlog -reportprogress 300 -work work Path/to/pipeline.v
vlog -reportprogress 300 -work work Path/to/TestBench.v
vsim -gui work.AdderSubtractor_tb -voptargs=+acc
do wave.do
run 830ns
