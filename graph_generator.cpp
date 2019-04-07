#include<bits/stdc++.h> 
using namespace std;

int main()
{ 
	set<pair<int, int>> container; 
	set<pair<int, int>>::iterator it; 
 
	srand(time(NULL)); 

	int vertices;  
	int edges;  
 	
 	cin>>vertices>>edges;

		printf("%d %d\n", vertices,edges); 

		 
		for (int j=1; j<=edges; j++) 
		{ 
			int a = rand() % vertices; 
			int b = rand() % vertices; 
			pair<int, int> p = make_pair(a, b); 
			pair<int, int> reverse_p = make_pair(b, a); 

			 
			while (container.find(p) != container.end() || 
					container.find(reverse_p) != container.end()|| a==b) 
			{ 
				a = rand() % vertices; 
				b = rand() % vertices; 
				p = make_pair(a, b); 
				reverse_p = make_pair(b, a); 
			} 
			container.insert(p); 
		} 

		for (it=container.begin(); it!=container.end(); ++it) 
			printf("%d %d\n", it->first, it->second); 

		container.clear(); 
		 
		 
	return(0); 
} 
