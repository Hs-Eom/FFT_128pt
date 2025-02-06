#define LENGTH		133 + 128 +1


#include <stdio.h>
#include "platform.h"
#include "xscugic.h"


#include "input.h"

#define IP_FOR_PS_BASE	0x43C00000


int main()
{
	int i=0, j, tmp, tmp1;
	int input_array[LENGTH];
	int output_array[LENGTH]={0,};
	char o[LENGTH][32];

	xil_printf("main start.\n");


	Xil_Out32(IP_FOR_PS_BASE,0x7FFFFFFF);

	for(i = 0; i < 262; i++)
	{
		tmp  = inReal[i]<<16;
		tmp1 = (0x0000FFFF & inImag[i]);
		input_array[i] = tmp + tmp1;
	}

	for(i = 0; i < 262; i++)
	{
		Xil_Out32(IP_FOR_PS_BASE, input_array[i]);
		output_array[i] = Xil_In32(IP_FOR_PS_BASE + 4*i);
	}

	for(i = 0; i < 262; i++)
	{
		for(j=0;j<32;j++)
			if ((output_array[i]>>(31-j))&0x00000001)
				o[i][j] = '1';
			else
				o[i][j] = '0';
	}


	for(i = 0; i < 262; i++)
	{
		xil_printf("%3d: ",i);
		for(j=0;j<16;j++)
			xil_printf("%c",o[i][j]);
		xil_printf(" ");
		for(j=16;j<32;j++)
			xil_printf("%c",o[i][j]);
		xil_printf("\r\n");
	}


	xil_printf("\n\nmain end.\n");
	return 0;

}
