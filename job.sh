echo "tiling executing.."
cd /home/cs18m018/Project
nvprof=/usr/local/cuda/bin/nvprof
$nvprof --unified-memory-profiling off ./tile inputGraph.txt > out.txt
#./tile inputGraph.txt > out.txt


