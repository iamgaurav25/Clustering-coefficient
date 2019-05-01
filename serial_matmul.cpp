#include<bits/stdc++.h>
using namespace std;
using namespace std::chrono;



void multiply(int ** arr1,int ** arr2,int **arr3,int vertices){
	for(int i=0;i<vertices;i++){
		for(int j=0;j<vertices;j++){
			arr3[i][j]=0;
			for(int k=0;k<vertices;k++){
				arr3[i][j]=arr3[i][j]+(arr1[i][k]*arr2[k][j]);
			}
		}
	}
}

int main(int argc, char** argv){
	
	ifstream infile(argv[1]);
	int **arr1,**arr2,**arr3,*degree;
	int a,b,vertices,edges,f=0;
	while(infile >> a >> b){
		//cout<<a<<"  "<<b<<endl;
		if(f==0){
			vertices=a;
			edges=b;
			arr1=new int*[vertices];
			arr2=new int*[vertices];
			arr3=new int*[vertices];
			for(int i=0;i<vertices;i++){
				arr1[i]=new int[vertices];
				arr2[i]=new int[vertices];
				arr3[i]=new int[vertices];
			}
			degree=new int[vertices];
			for (int i = 0; i < vertices; ++i)
			{
				degree[i]=0;
			}
			for(int i=0;i<vertices;i++){
				for(int j=0;j<vertices;j++){
					arr1[i][j]=0;
					arr2[i][j]=0;
					arr3[i][j]=0;
				}
			}

			f=1;
		}
		else{
			arr1[a][b]=1;
			arr1[b][a]=1;
			arr2[a][b]=1;
			arr2[b][a]=1;
			degree[a]++;
			degree[b]++;
		}
	}
	
	

	auto start = high_resolution_clock::now();
	multiply(arr1,arr2,arr3,vertices);
	multiply(arr3,arr2,arr1,vertices);
	
	auto stop = high_resolution_clock::now();
	auto duration = duration_cast<milliseconds>(stop - start);
	//multiply((int *)arr3,(int *)arr2,(int *)arr1,vertices);
	
	float cc=0;
	for(int i=0;i<vertices;i++){
		if(degree[i]>=2){
			cc=cc+((float(arr1[i][i]/2))/((degree[i]*(degree[i]-1))/2));
		}
	}
	cc=cc/vertices;

	printf("%f\n",cc);
	cout << duration.count() << endl;
	
	return 0;

}