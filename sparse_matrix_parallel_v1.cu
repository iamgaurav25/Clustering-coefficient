#include<bits/stdc++.h>
using namespace std;

bool sortcol( const int* v1, 
               const int* v2 ) { 
               /*if(v1[1]>v2[1]){
               printf("Pakda gaya\n");
               }*/
 return v1[1] < v2[1]; 
} 

void my_custom_sort(int * &input1,int size){

	int **list1;
	list1=new int*[size];
	for(int i=0;i<size;i++){
		list1[i]=new int[3];
		list1[i][0]=input1[i*3+0];
		list1[i][1]=input1[i*3+1];
		list1[i][2]=input1[i*3+2];
	}
	sort(list1, list1+size,sortcol);
	for(int i=0;i<size;i++){
		input1[i*3+0]=list1[i][0];
		input1[i*3+1]=list1[i][1];
		input1[i*3+2]=list1[i][2];
	}

	for( int i = 0 ; i < size ; i++ )
	{
    	delete[] list1[i]; // delete array within matrix
	}

	delete[] list1;

	}

bool sortcol1( const int* v1, 
               const int* v2 ) { 
 return v1[0] < v2[0]; 
}




void my_custom_sort2(int * &input1,int size){

	
	int **list1;
	list1=new int*[size];
	//printf("cs2\n");
	for(int i=0;i<size;i++){
		list1[i]=new int[3];
	}
	
	for(int i=0;i<size;i++){
		list1[i][0]=input1[i*3+0];
		list1[i][1]=input1[i*3+1];
		list1[i][2]=input1[i*3+2];
	}
	
	sort(list1, list1+size,sortcol1);
	//printf("cs2\n");
	for(int i=0;i<size;i++){
		input1[i*3+0]=list1[i][0];
		input1[i*3+1]=list1[i][1];
		input1[i*3+2]=list1[i][2];
	}
	
	for( int i = 0 ; i < size ; i++ )
	{
    	delete[] list1[i]; // delete array within matrix
	}

	delete[] list1;
	
	}

void transpose(int* input, int size){
	for(int i=0;i<size;i++){
		int tmp = input[i*3+0];
		input[i*3+0] = input[i*3+1];
		input[i*3+1] = tmp;
	}
}

__global__ void transpose_parallel(int * input,int size){

	int tx=(blockIdx.x*256)+threadIdx.x;
	if((tx*3+1)<size){
	int temp=input[tx*3+0];
	input[tx*3+0] = input[tx*3+1];
	input[tx*3+1] = temp;
	}

}

void copy(int* dest, int* src, int size){
	for(int i=0;i<size;i++)
		dest[i] = src[i];
}


void insert(int* output, int row, int col, int val, int &size){
	for(int i=0;i<size;i++)
		if(output[i*3+0]==row && output[i*3+1]==col){
			output[i*3+2]+=val;
			return;
		}
	//output[size] = new int[3];	
	output[size*3+0] = row;
	output[size*3+1] = col;
	output[size*3+2] = val;
	size++;
}

__global__ void oddeven(int* x,int I,int n)
{
	int id=(blockIdx.x*256)+threadIdx.x;
	if(I==0 && ((id*6+4)< n)){
		if(x[id*6+1]>x[id*6+4]){
			int X=x[id*6+1];
			x[id*6+1]=x[id*6+4];
			x[id*6+4]=X;

			X=x[id*6];
			x[id*6]=x[id*6+3];
			x[id*6+3]=X;

			X=x[id*6+2];
			x[id*6+2]=x[id*6+5];
			x[id*6+5]=X;
		}
	}
	if(I==1 && ((id*6+7)< n)){
		if(x[id*6+4]>x[id*6+7]){
			int X=x[id*6+4];
			x[id*6+4]=x[id*6+7];
			x[id*6+7]=X;

			X=x[id*6+3];
			x[id*6+3]=x[id*6+6];
			x[id*6+6]=X;

			X=x[id*6+5];
			x[id*6+5]=x[id*6+8];
			x[id*6+8]=X;
		}
	}
}

__global__ void oddeven2(int* x,int I,int n)
{
	int id=(blockIdx.x*256)+threadIdx.x;
	if(I==0 && ((id*6+3)< n)){
		if(x[id*6]>x[id*6+3]){
			int X=x[id*6+1];
			x[id*6+1]=x[id*6+4];
			x[id*6+4]=X;

			X=x[id*6];
			x[id*6]=x[id*6+3];
			x[id*6+3]=X;

			X=x[id*6+2];
			x[id*6+2]=x[id*6+5];
			x[id*6+5]=X;
		}
	}
	if(I==1 && ((id*6+6)< n)){
		if(x[id*6+3]>x[id*6+6]){
			int X=x[id*6+4];
			x[id*6+4]=x[id*6+7];
			x[id*6+7]=X;

			X=x[id*6+3];
			x[id*6+3]=x[id*6+6];
			x[id*6+6]=X;

			X=x[id*6+5];
			x[id*6+5]=x[id*6+8];
			x[id*6+8]=X;
		}
	}
}

void multiply2(int* &input1, int* &input2, int* &output,int &size1, int &size2, int &size3, int vertices){
	
	int *list1_d,*list2_d;
	//my_custom_sort2(input1, size1);
	cudaMalloc(&list1_d,size1*3*sizeof(int));
	cudaMemcpy(list1_d,input1,size1*3*sizeof(int),cudaMemcpyHostToDevice);
	int gd1,gd2,bd1,bd2;
	gd1=size1/(2*256);
	gd1=gd1+1;
	bd1=256;
	gd2=size2/(2*256);
	gd2=gd2+1;
	bd2=256;
	
	for(int i=0;i<size1;i++){

		//int size=n/2;

		oddeven2<<<gd1,bd1>>>(list1_d,i%2,size1*3);
		
		
	}

	//my_custom_sort2(input2, size2);
	cudaMalloc(&list2_d,size2*3*sizeof(int));
	cudaMemcpy(list2_d,input2,size2*3*sizeof(int),cudaMemcpyHostToDevice);
	for(int i=0;i<size2;i++){

		//int size=n/2;

		oddeven2<<<gd2,bd2>>>(list2_d,i%2,size2*3);
		/*cudaError_t err = cudaGetLastError();
	if (err != cudaSuccess) 
    printf("Error: %s\n", cudaGetErrorString(err));*/
		
	}

	cudaMemcpy(input1,list1_d,size1*3*sizeof(int),cudaMemcpyDeviceToHost);
	cudaMemcpy(input2,list2_d,size2*3*sizeof(int),cudaMemcpyDeviceToHost);
	
	output = new int[vertices];
	int outputSize=0;
	int kOld=0;
	int kNew=0;		
	for(int i=0;i<size1;i++){
		int ans=0;		
		int row1= input1[i*3+0];
		int col1= input1[i*3+1];
		int j;
		if(i!=0 && row1==input1[(i-1)*3+0])
			j=kOld;
		else{
			j=kNew;
			kOld = kNew; 		
		}
		while(j<size2){
			int row2 = input2[j*3+0];
			int col2 = input2[j*3+1];			
			if(row1==row2 && col1==col2){				
				insert(output, row1, row2, input1[i*3+2]*input2[j*3+2], outputSize);
				j++;
			}
			else if(row1==row2 && col1!=col2)
				j++;
			else
				break;
		}
		kNew=j;
	}
	
	size3 = outputSize;	
}

void multiply1(int* &input1, int* &input2, int* &output,int* &list1_d ,int &size1, int &size2, int &size3, int vertices){
	
	//transpose(input2, size2);
	int bd,gd;
	if(size1>256){
		gd=size1/256;
		gd=gd+1;
	}
	else{
		gd=1;
		bd=size1;
	}
	cudaMalloc(&list1_d,size1*3*sizeof(int));
	cudaMemcpy(list1_d,input2,size1*3*sizeof(int),cudaMemcpyHostToDevice);
	transpose_parallel<<< gd,bd >>> (list1_d,size1*3);
	//cudaMemcpy(input2,list1_d,size1*3*sizeof(int),cudaMemcpyDeviceToHost);

	
	//my_custom_sort(input2,size2);
	gd=size1/(2*256);
	gd=gd+1;
	bd=256;

	for(int i=0;i<size1;i++){

		//int size=n/2;

		oddeven<<<gd,bd>>>(list1_d,i%2,size1*3);
		
	}
	printf("Final Ans: ");

	
	cudaMemcpy(input2,list1_d,size1*3*sizeof(int),cudaMemcpyDeviceToHost);
	/*for(int i=0;i<size1;i++){
	printf("%d\n",input2[i*3+1]);
	}*/
	//my_custom_sort(input2,size2);

	copy(input1, input2,size1*3);
	output = new int[3*vertices*vertices];
	int outputSize=0;
	int kOld=0;
	int kNew=0;		
	for(int i=0;i<size1;i++){
		int ans=0;		
		int row1= input1[i*3+0];
		int col1= input1[i*3+1];
		int j;
		if(i!=0 && col1==input1[(i-1)*3+1])
			j=kOld;
		else{
			j=kNew;
			kOld = kNew; 		
		}
		while(j<size2){
			int row2 = input2[j*3+0];
			int col2 = input2[j*3+1];			
			if(col1==col2){				
				insert(output, row1, row2, input1[i*3+2]*input2[j*3+2], outputSize);
				j++;
			}
			else
				break;
		}
		kNew=j;
	}
	size3 = outputSize;	
	multiply2(output, input2, input1, size3, size2, size1, vertices);	
}




int main(int argc, char** argv){


	cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
	ifstream infile(argv[1]);
	int *list1,*list2,*list3,*list1_d;
	int* degree;	
	int size1, size2, size3;
	int a,b,vertices,edges,f=0, index1=0, index2=0;
	while(infile>>a>>b){
		if(f==0){
			vertices=a;
			edges=b;
			list1=new int[6*edges];
			list2=new int[6*edges];
			degree=new int[vertices];
			for(int i=0;i<vertices;i++)
				degree[i] = 0;
			f=1;
		}
		else{
			list1[index1*3+0]=a;
			list1[index1*3+1]=b;			
			list1[index1*3+2]=1;
			index1++;
			list1[index1*3+0]=b;
			list1[index1*3+1]=a;			
			list1[index1*3+2]=1;
			index1++;
			list2[index2*3+0]=a;
			list2[index2*3+1]=b;			
			list2[index2*3+2]=1;
			index2++;
			list2[index2*3+0]=b;
			list2[index2*3+1]=a;			
			list2[index2*3+2]=1;
			index2++;
			degree[a]++;
			degree[b]++;
		}
	}
	size1= size2=2*edges;
	//auto start = high_resolution_clock::now();
	float milliseconds;
	cudaEventRecord(start);
	multiply1(list1,list2, list3,list1_d, size1, size2, size3, vertices);
	cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&milliseconds,start,stop);


	//multiply2(list3,list2, list1, size3, size2, size1, vertices);	
	//auto stop = high_resolution_clock::now();
	//auto duration = duration_cast<milliseconds>(stop - start);

	float cc=0;
		
	for(int i=0;i<size1;i++){
		if(list1[i*3+0]==list1[i*3+1]){
			if(degree[list1[i*3+0]]>=2){				
				cc=cc+((float(list1[i*3+2]/2))/((degree[list1[i*3+0]]*(degree[list1[i*3+0]]-1))/2));
			}
		}		
	}
	//printf("sdfg\n");
	
	cc=cc/vertices;
	printf("%f\n",cc);
	printf("%f\n",milliseconds);
	//cout << duration.count() << endl;

	return 0;

}
