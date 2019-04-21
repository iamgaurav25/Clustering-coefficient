#include<bits/stdc++.h>
using namespace std;
using namespace std::chrono;

class sparse_matrix { 
	public:	
	int max; 
	int **data; 
	int row, col; 
	int len; 

	sparse_matrix() 
	{ 
	} 

	void init(int r, int c){
		row = r; 
		col = c; 
		len = 0; 
		max = r*c;
		data = new int*[max];
		for(int i=0;i<max;i++)
			data[i] = new int[3];	
	}

	sparse_matrix(int r,int c) 
	{ 
		row = r; 
		col = c; 
		len = 0; 
		max = r*c;
		data = new int*[max];
		for(int i=0;i<max;i++)
			data[i] = new int[3];
	} 

	void insert(int r, int c, int val) 
	{ 
		if (r >= row || c >= col) { 
			return;
		} 
		else { 
		for(int i=0;i<len;i++)
			if(data[i][0]==r && data[i][1]==c){
				data[i][2]+=val;
				return;
			}
			data[len][0] = r; 
			data[len][1] = c; 
			data[len][2] = val; 
			len++; 
		} 
	} 

	sparse_matrix transpose() 
	{ 
		sparse_matrix result(col,row); 
		result.len = len; 
		int* count = new int[col]; 
		for (int i = 0; i < col; i++) 
			count[i] = 0; 
		for (int i = 0; i < len; i++) 
			count[data[i][1]]++; 
		int* index = new int[col];  
		index[0] = 0;  
		for (int i = 1; i < col; i++) 
			index[i] = index[i - 1] + count[i - 1]; 
		for (int i = 0; i < len; i++) {  
			int rpos = index[data[i][1]]++; 
			result.data[rpos][0] = data[i][1]; 
			result.data[rpos][1] = data[i][0]; 
			result.data[rpos][2] = data[i][2]; 
		} 
		return result; 
	}

	sparse_matrix sort() 
	{ 
		sparse_matrix result(row, col); 
		result.len = len; 
		int* count = new int[col]; 
		for (int i = 0; i < col; i++) 
			count[i] = 0; 
		for (int i = 0; i < len; i++) 
			count[data[i][0]]++; 
		int* index = new int[col];  
		index[0] = 0;  
		for (int i = 1; i < col; i++) 
			index[i] = index[i - 1] + count[i - 1]; 
		for (int i = 0; i < len; i++) {  
			int rpos = index[data[i][0]]++; 
			result.data[rpos][0] = data[i][0]; 
			result.data[rpos][1] = data[i][1]; 
			result.data[rpos][2] = data[i][2]; 
		} 
		return result; 
	} 

	sparse_matrix multiply(sparse_matrix b) 
	{ 		
				
		if (col != b.row) { 
			return sparse_matrix(0,0); 
		} 
		b = b.transpose(); 
		int apos, bpos; 
		sparse_matrix result(row, b.row); 
		for (apos = 0; apos < len;) { 
			int r = data[apos][0]; 
			for (bpos = 0; bpos < b.len;) { 
				int c = b.data[bpos][0]; 
				int tempa = apos; 
				int tempb = bpos; 
				int sum = 0;  
				while (tempa < len && data[tempa][0] == r 
					&& tempb < b.len && b.data[tempb][0] == c) { 
					if (data[tempa][1] < b.data[tempb][1]) 
						tempa++; 
					else if (data[tempa][1] > b.data[tempb][1])  
						tempb++; 
					else
						sum += data[tempa++][2] * b.data[tempb++][2]; 
				}  
				if (sum != 0) 
					result.insert(r, c, sum); 
				while (bpos < b.len && b.data[bpos][0] == c) 
					bpos++; 
			} 
			while (apos < len && data[apos][0] == r) 
				apos++; 
		} 
		return result; 
	} 
 
	void print() 
	{ 
		cout<<"Dimension: " << row << "x" << col<<endl; 
		cout<<"Sparse Matrix: \nRow Column Value"<<endl; 
		for (int i = 0; i < len; i++)
			cout<<data[i][0] << " " << data[i][1] << " " << data[i][2]<<endl;  
	} 
};

int main(int argc, char** argv) 
{  
	sparse_matrix a,b; 
	ifstream infile(argv[1]);
	vector<int> degree;	
	int size3, size4;
	int a1,b1,vertices,edges,f=0, index1=0, index2=0;
	while(infile>>a1>>b1){
		if(f==0){
			vertices=a1;
			edges=b1;
			a.init(a1, a1);
			b.init(a1, a1);
			degree.resize(vertices);
			for (int i = 0; i < vertices; ++i)
				degree[i]=0;
			f=1;
		}
		else{
			a.insert(a1,b1,1);
			a.insert(b1,a1,1);
			b.insert(a1,b1,1);
			b.insert(b1,a1,1);			
			degree[a1]++;
			degree[b1]++;
		}
	}

	cout<<"\nMultiplication: "<<endl; 
	auto start = high_resolution_clock::now();
	a = a.sort();
//	b = b.sort();	
	sparse_matrix c = a.multiply(b); 
//	c.print();	
	c = c.sort();
	a = a.sort();	
	sparse_matrix d = c.multiply(a);		
	
/*	for(int i=0;i<d.len;i++)
		if(d.data[i][0]==d.data[i][1])
			cout<< d.data[i][0]<<" "<<d.data[i][2]<<endl;*/
		
	auto stop = high_resolution_clock::now();
	auto duration = duration_cast<milliseconds>(stop - start);
	
	d.print();	
	float cc=0;
	for(int i=0;i<d.len;i++)
		if(d.data[i][0]==d.data[i][1]){
			cout<< d.data[i][0]<<" "<<d.data[i][2];
			if(degree[d.data[i][0]]>=2){
				cc=cc+((float(d.data[i][2]/2))/((degree[d.data[i][0]]*(degree[d.data[i][0]]-1))/2));
			}	
		}
	cout<<cc/vertices<<endl;
	cout<<duration.count()<<endl;
	return 0; 
} 
 

