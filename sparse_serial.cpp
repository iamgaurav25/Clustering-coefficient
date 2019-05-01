#include<bits/stdc++.h>
using namespace std;
using namespace std::chrono;

void print2DVector(int** input, int size){
	for(int i=0;i<size;i++)
		cout<< input[i][0]<<" "<<input[i][1]<<" "<<input[i][2]<<endl;
	cout<<endl;
} 

bool sortcol( const int* v1, 
               const int* v2 ) { 
 return v1[1] < v2[1]; 
} 

bool sortcol1( const int* v1, 
               const int* v2 ) { 
 return v1[0] < v2[0]; 
} 

void transpose(int** input, int size){
	for(int i=0;i<size;i++){
		int tmp = input[i][0];
		input[i][0] = input[i][1];
		input[i][1] = tmp;
	}
}

void copy(int** dest, int** src, int size){
	for(int i=0;i<size;i++)
		dest[i] = src[i];
}


void insert(int** output, int row, int col, int val, int &size){
	for(int i=0;i<size;i++)
		if(output[i][0]==row && output[i][1]==col){
			output[i][2]+=val;
			return;
		}
	output[size] = new int[3];	
	output[size][0] = row;
	output[size][1] = col;
	output[size][2] = val;
	size++;
}

void multiply2(int** &input1, int** &input2, int** &output, int &size1, int &size2, int &size3, int vertices){

	sort(input1, input1+size1, sortcol1);
	sort(input2, input2+size2, sortcol1);
	output = new int*[vertices];
	int outputSize=0;
	int kOld=0;
	int kNew=0;		
	for(int i=0;i<size1;i++){
		int ans=0;		
		int row1= input1[i][0];
		int col1= input1[i][1];
		int j;
		if(i!=0 && row1==input1[i-1][0])
			j=kOld;
		else{
			j=kNew;
			kOld = kNew; 		
		}
		while(j<size2){
			int row2 = input2[j][0];
			int col2 = input2[j][1];			
			if(row1==row2 && col1==col2){				
				insert(output, row1, row2, input1[i][2]*input2[j][2], outputSize);
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

void multiply1(int** &input1, int** &input2, int** &output, int &size1, int &size2, int &size3, int vertices){
	
	transpose(input2, size2);
	sort(input2, input2+size2,sortcol);
	copy(input1, input2,size1);
	output = new int*[vertices*vertices];
	int outputSize=0;
	int kOld=0;
	int kNew=0;		
	for(int i=0;i<size1;i++){
		int ans=0;		
		int row1= input1[i][0];
		int col1= input1[i][1];
		int j;
		if(i!=0 && col1==input1[i-1][1])
			j=kOld;
		else{
			j=kNew;
			kOld = kNew; 		
		}
		while(j<size2){
			int row2 = input2[j][0];
			int col2 = input2[j][1];			
			if(col1==col2){				
				insert(output, row1, row2, input1[i][2]*input2[j][2], outputSize);
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
	
	ifstream infile(argv[1]);
	int **list1,**list2,**list3;
	int* degree;	
	int size1, size2, size3;
	int a,b,vertices,edges,f=0, index1=0, index2=0;
	while(infile>>a>>b){
		if(f==0){
			vertices=a;
			edges=b;
			list1=new int*[2*edges];
			list2=new int*[2*edges];
			for(int i=0;i<(2*edges);i++){
				list1[i]=new int[2*edges];
				list2[i]=new int[2*edges];
			}
			degree=new int[vertices];
			for(int i=0;i<vertices;i++)
				degree[i] = 0;
			f=1;
		}
		else{
			list1[index1][0]=a;
			list1[index1][1]=b;			
			list1[index1++][2]=1;
			list1[index1][0]=b;
			list1[index1][1]=a;			
			list1[index1++][2]=1;
			list2[index2][0]=a;
			list2[index2][1]=b;			
			list2[index2++][2]=1;
			list2[index2][0]=b;
			list2[index2][1]=a;			
			list2[index2++][2]=1;
			degree[a]++;
			degree[b]++;
		}
	}
	size1= size2=2*edges;
	auto start = high_resolution_clock::now();
	multiply1(list1,list2, list3, size1, size2, size3, vertices);	
	multiply2(list3,list2, list1, size3, size2, size1, vertices);	
	auto stop = high_resolution_clock::now();
	auto duration = duration_cast<milliseconds>(stop - start);

	float cc=0;
		
	for(int i=0;i<size1;i++){
		if(list1[i][0]==list1[i][1]){
			if(degree[list1[i][0]]>=2){				
				cc=cc+((float(list1[i][2]/2))/((degree[list1[i][0]]*(degree[list1[i][0]]-1))/2));
			}
		}		
	}
	cc=cc/vertices;
	printf("%f\n",cc);
	cout << duration.count() << endl;

	return 0;

}
