#include<bits/stdc++.h>
using namespace std;

void print2DVector(vector<vector<int> > input, int size){
	for(int i=0;i<size;i++)
		cout<< input[i][0]<<" "<<input[i][1]<<" "<<input[i][2]<<endl;
	cout<<endl;
} 

bool sortcol( const vector<int>& v1, 
               const vector<int>& v2 ) { 
 return v1[1] < v2[1]; 
} 

void transpose(vector<vector<int> > &input, int size){
	for(int i=0;i<size;i++){
		int tmp = input[i][0];
		input[i][0] = input[i][1];
		input[i][1] = tmp;
	}
}

void multiply(vector<vector<int> > &output,vector<vector<int> > &input1, vector<vector<int> > &input2, int size1, int size2, int &size3, int vertices){
	transpose(input2, size2);
//	print2DVector(input2, size2);	
	output.clear();	
	output.resize(vertices*vertices);
	for(int i=0;i<(vertices*vertices);i++){
		output[i].resize(3);
		output[i][0]= i/vertices;
		output[i][1]= i%vertices;
		output[i][2]= 0;		
	}			
	
	for(int i=0;i<size1;i++){
		int ans=0;		
		int row1= input1[i][0];
		int col1= input1[i][1];
		for(int j=0;j<size2;j++){
			int row2 = input2[j][0];
			int col2 = input2[j][1];			
			if(col1==col2)
				output[row1*vertices+row2][2]+= input1[i][2]*input2[j][2];
		}
	}

//	print2DVector(output, vertices*vertices);	

	int i=0;
	int outputSize = vertices*vertices;
	while(i<outputSize){
		while(i<(outputSize) && output[i][2]== 0){
			output.erase(output.begin()+i);
			outputSize--;		
		}
		if(i>=outputSize)
			break;	
		i++;		
	}
	size3 = outputSize;	
}




int main(int argc, char** argv){
	
	ifstream infile("output.txt");
	vector<vector<int> > list1, list2, list3;
	vector<int> degree;
	int size3, size4;
	int a,b,vertices,edges,f=0, index1=0, index2=0;
	while(infile>>a>>b){
		//cout<<a<<" "<<b<<endl;
		if(f==0){
			vertices=a;
			edges=b;
			list1.resize(2*edges);
			list2.resize(2*edges);			
			degree.resize(vertices);
			for (int i = 0; i < vertices; ++i)
			{
				degree[i]=0;
			}
			for(int i=0;i<(2*edges);i++){
				list1[i].resize(3);
				list2[i].resize(3);
				for(int j=0;j<3;j++){
					list1[i][j]=0;
					list2[i][j]=0;
				}
			}

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

//	auto start = high_resolution_clock::now();
	multiply(list3, list1,list2, 2*edges, 2*edges, size3, vertices);	
	multiply(list2, list3,list1, size3, 2*edges, size4, vertices);	

/*	auto stop = high_resolution_clock::now();
	auto duration = duration_cast<milliseconds>(stop - start);
*/	
	int **arr1=new int*[vertices];
	for(int i=0;i<vertices;i++){
		arr1[i]=new int[vertices];
		for(int j=0;j<vertices;j++)
			arr1[i][j] = 0;
	}

	for(int i=0;i<size4;i++){
		arr1[list2[i][0]][list2[i][1]] = list2[i][2];
	}

	float cc=0;
	for(int i=0;i<vertices;i++){
		if(degree[i]>=2){
			cc=cc+((float(arr1[i][i]/2))/((degree[i]*(degree[i]-1))/2));
		}
	}
	cc=cc/vertices;

	printf("%f\n",cc);
	//cout << duration.count() << endl;
	
	return 0;

}
