# Clustering-coefficient
Our objective is to find the clustering coefficient of any given graph G(V,E). By
definition, the clustering coefficient is a measure of the degree to which nodes in a
graph tends to cluster together.Clustering coefficient of a node of a graph is given by ratio of number of triangles
enclosed by the node to number of wedges enclosed by the same.

### Prerequisites
Install g++,CUDA.

## Running the tests
### Compile (Serial code)
```
g++ -std=c++11 -o serial_matmul serial_matmul.cpp
```
### Execute (Serial code)
```
./serial_matmul graph.txt
```
### Compile (Sparse serial code)
```
g++ -std=c++11 -o sparse_serial sparse_serial.cpp
```
### Execute (Sparse serial code)
```
./sparse_serial graph.txt
```
### Compile (Paralle tiling code)
```
nvcc -o parallel_matmul parallel_matmul.cu
```
### Execute (Parallel tiling code)
```
./parallel_matmul graph.txt
```
### Compile (Parallel streams code)
```
nvcc -o streams_with_tiling streams_with_tiling.cu
```
### Execute (Parallel streams code)
```
./streams_with_tiling graph.txt
```
