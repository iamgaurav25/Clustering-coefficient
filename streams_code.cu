#include<stdio.h>
#include<stdlib.h>
#include <cuda.h>
#include <cuda_runtime.h>

void cudaCheckError() {                                          
 	cudaError_t error=cudaGetLastError();                                 
 	if(error!=cudaSuccess) {                                              
   		printf("Cuda failure %s:%d: '%s'\n",__FILE__,__LINE__,cudaGetErrorString(error));           
   		exit(0); 
 	}                                                                 
}

__global__ void MatrixMulKernel(int *M,int *N,int *P,int SIZE){
	int row = blockIdx.x*blockDim.x+threadIdx.x;
	int col = blockIdx.y*blockDim.y+threadIdx.y;

	if ((row < SIZE) && (col < SIZE)) {
		double output_val = 0;
		for (int k = 0; k < SIZE; ++k) 
			output_val += M[row*SIZE+k]*N[k*SIZE+col];
		P[row*SIZE+col] = output_val;
	}
  
}

void print(int* mat, int size){
	for(int i=0;i<size;i++){
		for(int j=0;j<size;j++)
			printf("%d ",mat[i*size+j]);
		printf("\n");
	}
}

int main(int argc, char** argv){
	FILE* fp = fopen(argv[1],"r");
    int *arr1_h,*arr1_d,*arr2_d,*arr3_d,*degree_h, *arr_f1, *arr_tmp1;
    int a,b,block_size=16,f=0;
    long long int vertices, original_vertices;

    while(fscanf(fp,"%d %d\n",&a,&b)!=EOF){
        if(f==0){
            vertices=a;
            original_vertices=a;
            if(vertices<block_size){
                vertices=block_size;
            }
            else{
                long long int temp=block_size;
                while(vertices>temp){
                    temp=temp*2;
                }
                vertices=temp;
            }

            cudaHostAlloc(&arr1_h, vertices*vertices*sizeof(int),cudaHostAllocDefault);
            cudaHostAlloc(&arr_f1, vertices*vertices*sizeof(int),cudaHostAllocDefault);
            
			degree_h= (int*)malloc(original_vertices*sizeof(int));

            for (long long int i = 0; i < vertices; ++i)
            {
                degree_h[i]=0;
            }

            for(long long int i=0;i<vertices;i++){
                for(long long int j=0;j<vertices;j++){
                    arr1_h[i*vertices+j]=0;
                }
            }

			for(long long int i=0;i<vertices;i++){
                for(long long int j=0;j<vertices;j++){
                    arr_f1[i*vertices+j]=0;
                }
            }
            f=1;
        }
        else{

            arr1_h[a*vertices+b]=1;
            arr1_h[b*vertices+a]=1;
            degree_h[a]++;
            degree_h[b]++;
        }
    }

	print(arr1_h,vertices);

	cudaStream_t stream1, stream2;

	size_t bufferSize = 16;
	size_t offset = bufferSize*bufferSize;

	cudaStreamCreate(&stream1);

	cudaStreamCreate(&stream2);

	cudaMalloc(&arr1_d,bufferSize*bufferSize*sizeof(int));
    cudaMalloc(&arr2_d,bufferSize*bufferSize*sizeof(int));
    cudaMalloc(&arr3_d,bufferSize*bufferSize*sizeof(int));
    cudaHostAlloc(&arr_tmp1, bufferSize*bufferSize*sizeof(int),cudaHostAllocDefault);
           
	for(int i=0;i<vertices/bufferSize;i++){
		for(int j=0;j<vertices/bufferSize;j++){
			for(int k=0;k<vertices/bufferSize;k++){
				for(int k1=0;k1<bufferSize;k1++){				
					cudaMemcpyAsync(arr1_d+k1*bufferSize,arr1_h+(i+k1)*vertices*bufferSize+k*bufferSize,bufferSize*sizeof(int),cudaMemcpyHostToDevice,stream1);
					cudaMemcpyAsync(arr2_d+k1*bufferSize,arr1_h+(k+k1)*vertices*bufferSize+j*bufferSize,bufferSize*sizeof(int),cudaMemcpyHostToDevice,stream2);
				}

				cudaStreamSynchronize(stream1);
				cudaStreamSynchronize(stream2);

				dim3 threadsPerBlock(16, 16);              
				dim3 blocksPerGrid(bufferSize/16, bufferSize/16);       
				MatrixMulKernel<<<blocksPerGrid, threadsPerBlock,0, stream1>>>(arr1_d, arr2_d, arr3_d,bufferSize); 

				cudaStreamSynchronize(stream1);
				cudaMemcpyAsync(arr_tmp1,arr3_d,offset*sizeof(int),cudaMemcpyDeviceToHost,stream2);

				cudaStreamSynchronize(stream2);

				for(int k2=0;k2<bufferSize;k2++)
					for(int k3=0;k3<bufferSize;k3++)
						arr_f1[(i+k2)*bufferSize*vertices+(j*bufferSize+k3)] += arr_tmp1[k2*bufferSize+k3];
			}
		}

	}
    
	for(int i=0;i<vertices/bufferSize;i++){
		for(int j=0;j<vertices/bufferSize;j++){
			for(int k=0;k<vertices/bufferSize;k++){
				for(int k1=0;k1<bufferSize;k1++){				

					cudaMemcpyAsync(arr1_d+k1*bufferSize,arr_f1+(i+k1)*vertices*bufferSize+k*bufferSize,bufferSize*sizeof(int),cudaMemcpyHostToDevice,stream1);
					cudaMemcpyAsync(arr2_d+k1*bufferSize,arr1_h+(k+k1)*vertices*bufferSize+j*bufferSize,bufferSize*sizeof(int),cudaMemcpyHostToDevice,stream2);
				}

				cudaStreamSynchronize(stream1);
				cudaStreamSynchronize(stream2);

				dim3 threadsPerBlock(16, 16);              
				dim3 blocksPerGrid(bufferSize/16, bufferSize/16);       
				MatrixMulKernel<<<blocksPerGrid, threadsPerBlock,0, stream1>>>(arr1_d, arr2_d, arr3_d,bufferSize); 

				cudaStreamSynchronize(stream1);
				cudaMemcpyAsync(arr_tmp1,arr3_d,offset*sizeof(int),cudaMemcpyDeviceToHost,stream2);

				cudaStreamSynchronize(stream2);

				for(int k2=0;k2<bufferSize;k2++)
					for(int k3=0;k3<bufferSize;k3++)
						arr_f1[(i+k2)*bufferSize*vertices+(j*bufferSize+k3)] += arr_tmp1[k2*bufferSize+k3];
			}
		}

	}

   	float cc=0;
    for(int i=0;i<original_vertices;i++){
        if(degree_h[i]>=2){
            cc=cc+((float(arr_f1[i*vertices+i]/2))/((degree_h[i]*(degree_h[i]-1))/2));
        }
    }

    cc=cc/original_vertices;
    printf("%f\n",cc);

	cudaStreamDestroy(stream1);
	cudaStreamDestroy(stream2);

	cudaFreeHost(&arr1_h);
	cudaFreeHost(&arr_tmp1);
	cudaFreeHost(&arr1_d);

    cudaFree(&arr1_d);
   	cudaFree(&arr2_d);
   	cudaFree(&arr3_d);

    return 0;
}

