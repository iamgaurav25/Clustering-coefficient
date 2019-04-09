#include <stdio.h>
#include <stdlib.h>

int getRandomVertex(int nVertices)
{
	int randomVertex = rand() % nVertices;

	return(randomVertex);
}

//------------------------------------------------------------------------------------------------------------------

int main()
{
	int nVertices,degree,triangle;
	int headIndex=0;

	FILE *fp = fopen("graph.txt","w");

	scanf("%d %d %d",&nVertices,&degree,&triangle);

	int graph[(degree*nVertices*triangle)][2];

	//fprintf(fp, "%d %d\n",0,1);
	graph[headIndex][0]=0;
	graph[headIndex++][1]=1;
	//printf("Check1");
	int i;
	for(i=2;i<nVertices;i++)
	{

		int vVertex = getRandomVertex(nVertices);
//------------------------------------------------------------------------------------------------------------------
		//int min = ((i-1)>=degree)?degree:(i-1);
		int min = degree;
		int* neighbourVertex = (int*)malloc(min*sizeof(int));
		int index =0,flag=0,flag1=0;

		for(int k=0;k<min;k++)
			neighbourVertex[k]=nVertices+22 ;
		//printf("m%d\n",min);
//------------------------------------------------------------------------------------------------------------------
		for(int j=0;j<min;j++)
		{
			int uVertex = getRandomVertex(nVertices);
			flag=0;
			while(uVertex==vVertex)
				uVertex = getRandomVertex(nVertices);
			//printf("Check2");
			while(1){
				flag = 0;
				for(int k=0;k<index;k++)
				{
					if(uVertex == neighbourVertex[k])
						flag=1;
				}
				if(!flag)
					break;
				else
					uVertex = getRandomVertex(nVertices);

			}
			//printf("Check3");
			neighbourVertex[index]=uVertex;
			index++;

			for(int k=0;k<headIndex;k++)
			{

					if((graph[k][0]==uVertex && graph[k][1]==vVertex) || (graph[k][0]==vVertex && graph[k][1]==uVertex))
						flag1=1;

			}

			if(flag1==0)
			{
				graph[headIndex][0]=uVertex;
				graph[headIndex++][1]=vVertex;
			}

			flag1=0;

			//fprintf(fp, "%d %d\n",uVertex,vVertex);

		}

//------------------------------------------------------------------------------------------------------------------

		for(int j=0;j<triangle;j++)
		{
				//printf("Check5 %d\n",index);
			int uIndex = rand()%index;
			int wIndex = rand()%index;
			while(neighbourVertex[uIndex]==neighbourVertex[wIndex]){
				//printf("%d %d\n",uIndex,wIndex);
				wIndex = rand()%index;
			}
			//printf("Check6");

			for(int k=0;k<headIndex;k++)
			{

					if((graph[k][0]==neighbourVertex[uIndex] && graph[k][1]==neighbourVertex[wIndex]) || (graph[k][0]==neighbourVertex[wIndex] && graph[k][1]==neighbourVertex[uIndex]))
						flag1=1;

			}

			if(flag1==0)
			{
				graph[headIndex][0]=neighbourVertex[uIndex];
				graph[headIndex++][1]=neighbourVertex[wIndex];
			}

			flag1=0;
			//fprintf(fp,"%d %d\n",neighbourVertex[uIndex],neighbourVertex[wIndex]);
		}

		printf("Check4");

	}

fprintf(fp,"not repeated..\n");
	for(int i=0;i<headIndex;i++)
		fprintf(fp,"%d %d\n",graph[i][0],graph[i][1]);

fclose(fp);
	return 0;
}

