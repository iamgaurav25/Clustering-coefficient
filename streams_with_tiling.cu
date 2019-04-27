#include<stdio.h>
#include<stdlib.h>
#include <cuda.h>

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
		int output_val = 0;
		for (int k = 0; k < SIZE; ++k) 
			output_val += M[row*SIZE+k]*N[k*SIZE+col];
		P[row*SIZE+col] = output_val;
	}
  
}

__global__ void MatrixMulKernelWithTiling(int *M,int *N,int *P,int Tile_Width,int Width){
	__shared__ double ds_M[16][16];
	__shared__ double ds_N[16][16]; 
	
	int bx=blockIdx.x;
	int by=blockIdx.y;
	int tx=threadIdx.x;
	int ty=threadIdx.y;
	int Row=by*blockDim.y+ty;
	int Col=bx*blockDim.x+tx;

    
	int Pvalue=0;
	for(int p=0;p<Width/Tile_Width;p++){
		ds_M[ty][tx]=M[Row*Width+p*Tile_Width+tx];
		ds_N[ty][tx]=N[(p*Tile_Width+ty)*Width+Col];
		__syncthreads();
	for(int i=0;i<Tile_Width;i++)
		Pvalue+=ds_M[ty][i]*ds_N[i][tx];//partial dot product
	__syncthreads();
	}
	P[Row*Width+Col]=Pvalue;//final answer  
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
    int *arr1_h,*arr1_d,*arr2_d,*arr3_d,*degree_h, *arr_f1, *arr_f2, *arr_tmp1;
    int a,b;
	int f=0;
    long long int vertices, original_vertices;

	printf("1\n");
	cudaStream_t stream1, stream2;
	printf("2\n");
	
	size_t bufferSize = 32;
	size_t offset = bufferSize*bufferSize;
	printf("3\n");
	
	cudaStreamCreate(&stream1);
	printf("4\n");
	cudaError_t err = cudaGetLastError();
	printf("Error: %s\n", cudaGetErrorString(err));

	cudaStreamCreate(&stream2);
	printf("5\n");
	err = cudaGetLastError();
	printf("Error: %s\n", cudaGetErrorString(err));

    
	printf("10\n");           
	cudaMalloc(&arr1_d,bufferSize*bufferSize*sizeof(int));
	err = cudaGetLastError();
	printf("Error: %s\n", cudaGetErrorString(err));
	printf("11\n");           
    cudaMalloc(&arr2_d,bufferSize*bufferSize*sizeof(int));
	err = cudaGetLastError();
	printf("Error: %s\n", cudaGetErrorString(err));
	printf("12\n");           
    cudaMalloc(&arr3_d,bufferSize*bufferSize*sizeof(int));
	err = cudaGetLastError();
	printf("Error: %s\n", cudaGetErrorString(err));
	printf("13\n");           
    cudaHostAlloc(&arr_tmp1, bufferSize*bufferSize*sizeof(int),cudaHostAllocDefault);
	err = cudaGetLastError();
	printf("Error: %s\n", cudaGetErrorString(err));

	printf("14\n");           
	
	while(fscanf(fp,"%d %d\n",&a,&b)!=EOF){
        if(f==0){
            vertices=a;
            original_vertices=a;
            if(vertices<bufferSize){
                vertices=bufferSize;
            }
            else{
                long long int temp=bufferSize;
                while(vertices>temp){
                    temp=temp*2;
                }
                vertices=temp;
				printf("\nVertices:%lld\n",vertices);
            }

            cudaHostAlloc(&arr1_h, vertices*vertices*sizeof(int),cudaHostAllocDefault);
            cudaHostAlloc(&arr_f1, vertices*vertices*sizeof(int),cudaHostAllocDefault);
            cudaHostAlloc(&arr_f2, vertices*vertices*sizeof(int),cudaHostAllocDefault);
            
			degree_h= (int*)malloc(original_vertices*sizeof(int));

            for (long long int i = 0; i < vertices; ++i)
            {
                degree_h[i]=0;
            }

            for(long long int i=0;i<vertices;i++){
                for(long long int j=0;j<vertices;j++){
                    arr1_h[i*vertices+j]=0;
					arr_f1[i*vertices+j]=0;
                    arr_f2[i*vertices+j]=0;
                       
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
	fclose(fp);

	for(int i=0;i<vertices/bufferSize;i++){
		for(int j=0;j<vertices/bufferSize;j++){
			for(int k=0;k<vertices/bufferSize;k++){
				for(int k1=0;k1<bufferSize;k1++){				
/*					for(int x1=(i*vertices*bufferSize+k1*vertices+k*bufferSize),y1=0;y1<bufferSize;x1++,y1++)
						printf("%d ",arr1_h[x1]	);
					printf("\n");				

					printf("\n");			*/
					cudaMemcpyAsync(arr1_d+k1*bufferSize,arr1_h+i*vertices*bufferSize+k1*vertices+k*bufferSize,bufferSize*sizeof(int),cudaMemcpyHostToDevice,stream1);
					cudaMemcpyAsync(arr2_d+k1*bufferSize,arr1_h+k*vertices*bufferSize+k1*vertices+j*bufferSize,bufferSize*sizeof(int),cudaMemcpyHostToDevice,stream2);
//					cudaStreamSynchronize(stream1);
//					cudaStreamSynchronize(stream2);
				}

				cudaStreamSynchronize(stream1);
				cudaStreamSynchronize(stream2);

				dim3 threadsPerBlock(16, 16);              
				dim3 blocksPerGrid(bufferSize/16, bufferSize/16);       
				MatrixMulKernelWithTiling<<<blocksPerGrid, threadsPerBlock,0, stream1>>>(arr1_d, arr2_d, arr3_d,16,bufferSize); 

				cudaStreamSynchronize(stream1);
				cudaMemcpyAsync(arr_tmp1,arr3_d,offset*sizeof(int),cudaMemcpyDeviceToHost,stream2);
				cudaStreamSynchronize(stream2);
				//print(arr_tmp1,bufferSize);
				
				for(int k2=0;k2<bufferSize;k2++)
					for(int k3=0;k3<bufferSize;k3++)
						arr_f1[i*bufferSize*vertices+k2*vertices+j*bufferSize+k3] += arr_tmp1[k2*bufferSize+k3];
						
			}
		}

	}

//	print(arr_f1,vertices);
	
	for(int i=0;i<vertices/bufferSize;i++){
		for(int j=0;j<vertices/bufferSize;j++){
			for(int k=0;k<vertices/bufferSize;k++){
				for(int k1=0;k1<bufferSize;k1++){				
					cudaMemcpyAsync(arr1_d+k1*bufferSize,arr_f1+i*vertices*bufferSize+k1*vertices+k*bufferSize,bufferSize*sizeof(int),cudaMemcpyHostToDevice,stream1);
					cudaMemcpyAsync(arr2_d+k1*bufferSize,arr1_h+k*vertices*bufferSize+k1*vertices+j*bufferSize,bufferSize*sizeof(int),cudaMemcpyHostToDevice,stream2);
//					cudaStreamSynchronize(stream1);
//					cudaStreamSynchronize(stream2);
				}

				cudaStreamSynchronize(stream1);
				cudaStreamSynchronize(stream2);

				dim3 threadsPerBlock(16, 16);              
				dim3 blocksPerGrid(bufferSize/16, bufferSize/16);       
				MatrixMulKernelWithTiling<<<blocksPerGrid, threadsPerBlock,0, stream1>>>(arr1_d, arr2_d, arr3_d,16,bufferSize); 

				cudaStreamSynchronize(stream1);
				cudaMemcpyAsync(arr_tmp1,arr3_d,offset*sizeof(int),cudaMemcpyDeviceToHost,stream2);
				cudaStreamSynchronize(stream2);
				//print(arr_tmp1,bufferSize);
				
				for(int k2=0;k2<bufferSize;k2++)
					for(int k3=0;k3<bufferSize;k3++)
						arr_f2[i*bufferSize*vertices+k2*vertices+j*bufferSize+k3] += arr_tmp1[k2*bufferSize+k3];
						
			}
		}

	}
//print(arr_f2,vertices);
				
   	float cc=0;
    for(int i=0;i<original_vertices;i++){
        if(degree_h[i]>=2){
            cc=cc+((float(arr_f2[i*vertices+i]/2))/((degree_h[i]*(degree_h[i]-1))/2));
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

