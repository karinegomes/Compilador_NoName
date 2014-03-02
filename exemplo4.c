/*Compilador NoName*/
#include<string.h>
#include<iostream>
#include<stdio.h>

using namespace std;



int temp6;
int temp7;
int temp8;
int temp9;

int temp2;
int temp1;
int temp3;
int temp4;
int temp5;
int temp0[5];


int main(void)
{



	temp3 = 0;

	temp1 = temp3;
	temp4 = 10;
	temp5 = !(temp1 < temp4);

	bloco0:
	if (temp5) goto bloco1;

	temp6 = 4;
	temp7 = !(temp1 > temp6);

	if (temp7) goto bloco2;

	goto bloco1;

	bloco2:

	temp8 = 5;
	temp9 = temp1 + temp8;
	temp0[temp1] = temp9;

	temp1 = temp1 + 1;
	goto bloco0;

	bloco1:


	temp2 = temp0[0];

	cout << temp2 << endl;

	temp2 = temp0[4];

	cout << temp2 << endl;
	return 0;
}

