/*Compilador NoName*/
#include<string.h>
#include<iostream>
#include<stdio.h>

using namespace std;


int temp2;
int temp3;
int temp4;
int temp1;
int temp0;
int temp10;
int temp11;
int temp12;
int temp13;
int temp5;
int temp6;
int temp7;
int temp8;
int temp9;


int main(void)
{
	temp0 = 10;
	temp1 = temp0;


	temp5 = 3;

	temp2 = temp5;

	temp6 = 5;

	temp3 = temp6;

	temp10 = 2;
	temp12 = (temp1 ==temp10);
	temp7 = 1;
	temp9 = (temp1 ==temp7);



	if (!temp9) goto bloco3;

	temp8 = temp2 + temp3;

	temp4 = temp8;

	goto bloco1;



	bloco3:


	if (!temp12) goto bloco5;

	temp11 = temp2 - temp3;

	temp4 = temp11;

	goto bloco1;



	bloco5:

	temp13 = temp2 * temp3;

	temp4 = temp13;

	goto bloco1;



	bloco1:

	cout << temp4 << endl;
	return 0;
}
