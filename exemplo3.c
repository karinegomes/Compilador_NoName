/*Compilador NoName*/
#include<string.h>
#include<iostream>
#include<stdio.h>

using namespace std;


int temp3;
int temp4;
int temp5;
int temp6;
int temp7;
int temp8;

int temp10;
int temp9;



int temp2(int temp0, int temp1);

int main(void)
{

	temp6 = 3;

	temp3 = temp6;

	temp7 = 5;

	temp4 = temp7;

temp8 = temp2(temp3, temp4);
	temp5 = temp8;

	cout << temp5 << endl;
	return 0;
}



int temp2(int temp0, int temp1) {
	temp9 = temp0 + temp1;
	temp10 = temp9;

	return temp10;
}
