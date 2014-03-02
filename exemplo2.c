/*Compilador NoName*/
#include<string.h>
#include<iostream>
#include<stdio.h>

using namespace std;


char temp0[8];
char temp1[8];
char temp2[7];
char temp3[7];
char temp4[15];
char temp5[15];


int main(void)
{
	strcpy(temp0, "teste1 ");
	strcpy(temp1, temp0);

	strcpy(temp2, "teste2");
	strcpy(temp3, temp2);

	strcpy(temp4, temp1);
	strcat(temp4, temp3);
	strcpy(temp5, temp4);

	cout << temp5 << endl;
	return 0;
}
