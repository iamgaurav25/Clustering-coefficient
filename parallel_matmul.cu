#include<bits/stdc++.h>
using namespace std;



__global__ void MatrixMulKernel(int *M,int *N,int *P,int Tile_Width,int Width){
	__shared__ double ds_M[32][32];
	__shared__ double ds_N[32][32]; 
	
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

__global__ void MatrixMulKernel2(int *M,int *N,int *P,int Width){

    int Row=(blockIdx.y*blockDim.y)+threadIdx.y;//row number
    int Col=(blockIdx.x*blockDim.x)+threadIdx.x;//column number
    
    if((Row<Width)&&(Col<Width)){
        float Pvalue=0;
        
        for(int k=0;k<Width;k++){
            Pvalue+=M[Row*Width+k]*N[k*Width+Col];
        }
        P[Row*Width+Col]=Pvalue;//final answer
    }
}

int main(int argc, char** argv){
        ifstream infile(argv[1]);
        int *arr1_h,*arr1_d,*arr2_d,*arr3_d,*degree_h;
        int a,b,bd,gd,tile_width,f=0;
	float milliseconds;
        long long int vertices,edges,size,original_vertices;
	cudaEvent_t start, stop;
        cudaEventCreate(&start);
        cudaEventCreate(&stop);
        bd=32;
        tile_width=bd;
        while(infile >> a >> b){
        if(f==0){
            vertices=a;
            original_vertices=a;
            edges=b;
            if(vertices<tile_width){
                vertices=tile_width;
            }
            else{
                long long int temp=tile_width;
                while(vertices>temp){
                    temp=temp*2;
                }
                vertices=temp;
            }
            size=(vertices*vertices)*sizeof(int);
            arr1_h=new int[vertices*vertices];
            degree_h=new int[vertices];
            for (long long int i = 0; i < vertices; ++i)
            {
                degree_h[i]=0;
            }
            for(long long int i=0;i<vertices;i++){
                for(long long int j=0;j<vertices;j++){
                    arr1_h[i*vertices+j]=0;
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
        cudaMalloc(&arr1_d,size);
        cudaMalloc(&arr2_d,size);
        cudaMalloc(&arr3_d,size);
        cudaMemcpy(arr1_d,arr1_h,size,cudaMemcpyHostToDevice);

            gd=vertices/bd;
            dim3 grid(gd,gd);
            dim3 block(bd,bd);
	    cudaEventRecord(start);
            MatrixMulKernel<<< grid,block >>>(arr1_d,arr1_d,arr2_d,tile_width,vertices);

            MatrixMulKernel<<< grid,block >>>(arr2_d,arr1_d,arr3_d,tile_width,vertices);
        
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);
        cudaMemcpy(arr1_h,arr3_d,size,cudaMemcpyDeviceToHost);
        float cc=0;
        for(int i=0;i<vertices;i++){
        if(degree_h[i]>=2){
            cc=cc+((float(arr1_h[i*vertices+i]/2))/((degree_h[i]*(degree_h[i]-1))/2));
        }
    }
    cudaEventElapsedTime(&milliseconds,start,stop);
    cc=cc/original_vertices;
    cout<<cc<<endl;
    cout<<milliseconds;

    

    return 0;
}
