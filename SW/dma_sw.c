#include <stdio.h>
#include "xparameters.h"
#include "xparameters_ps.h"
#include "platform.h"
#include "xaxidma.h"
#include "input.h"
#include "xscugic.h"
#include "xtime_l.h"

#define LEN 134
#define INPUT_BASE      0x11000000
#define OUTPUT_BASE     0x12000000
#define IP_FOR_DMA_BASE 0x44A00000

void DMA_transfer(int in_addr, int out_addr, int len);
void DMA_Setup();


XAxiDma DMA0;

XTime start, stop;
XTime start1, stop1;
XTime start2, stop2;
XTime start3, stop3;
XTime start4, stop4;
XTime start5, stop5;

int i;
int tmp, tmp1;
int input_array[LEN] = {0,};
int output_array[LEN] = {0,};
char o[LEN][32];

int main(){
    xil_printf("main start.\n");

    init_platform();

    for(i = 0; i <LEN; i++){
        Xil_Out32(INPUT_BASE + i*4, 0);
        Xil_Out32(OUTPUT_BASE + i*4, 0);
    }

    for(i = 0; i< LEN; i++){
        tmp = inReal[i] <<16;
        tmp1 = (0x0000FFFF & inImag[i]);
        input_array[i] =  tmp + tmp1;
    }

    Xil_Out32(INPUT_BASE,0x7fffffff);
    for(i=0; i<LEN; i++){
        Xil_Out32(INPUT_BASE+4+(i*4),inReal[i]);
    }

    //Dma설정    
    DMA_Setup();

    XTime_GetTime((XTime*)&start);    

    //DMA전송    
    DMA_transfer(INPUT_BASE, OUTPUT_BASE, LEN);

    XTime_GetTime((XTime*)&stop);
    printf("DMA transfer %0.3fus \n\n", ((float)stop - (float)start)/COUNTS_PER_SECOND);
    printf("Cache flush %0.3fus \n\n", ((float)stop1 - (float)start1)/COUNTS_PER_SECOND);
    printf("DMA addr setup %0.3fus \n\n", ((float)stop2 - (float)start2)/COUNTS_PER_SECOND);
    printf("DMA start %0.3fus \n\n", ((float)stop3 - (float)start3)/COUNTS_PER_SECOND);
    printf("Accleratio in&out %0.3fus \n\n", ((float)stop4 - (float)start4)/COUNTS_PER_SECOND);
    printf("Cache invalidate %0.3fus \n\n", ((float)stop5 - (float)start5)/COUNTS_PER_SECOND);
    

    for(int i = 0; i < LEN; i++)
	{
		for(int j=0;j<32;j++)
			if ((output_array[i]>>(31-j))&0x00000001)
				o[i][j] = '1';
			else
				o[i][j] = '0';
	}


	for(int i = 0; i < LEN; i++)
	{
		xil_printf("%3d: ",i);
		for(int j=0;j<16;j++)
			xil_printf("%c",o[i][j]);
		xil_printf(" ");
		for(int j=16;j<32;j++)
			xil_printf("%c",o[i][j]);
		xil_printf("\n");
	}
}

void DMA_Setup(){
    XAxiDma_config* cfg;
    cfg = XAxiDma_LookupConfig(XPAR_AXI_DMA_0_DEVICE_ID);
    XAxiDma_CfgInitialize(&DMA0,cfg);

    //polling방식 인터럽트 처리 위해 irq는 disable
    XAxiDma_IntrDisable(&DMA0,XAXIDMA_IRQ_ALL_MASK,XAXIDMA_DMA_TO_DEVICE);
    XAxiDma_IntrDisable(&DMA0,XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
}

void DMA_transfer(int in_addr, int out_addr, int len){
    int RxBdRing = 0;

    //DMA Flush(DDR <= Cpu_Cache)
    Xil_DCacheFlushRange(in_addr, len*4);

    //DMA0의 PL-> DDR설정(S2Mm)----------------------------------------------------------------------------------
    //1. DDR주소 가져오기
    XAxiDma_WriteReg(&DMA0.RxBdRing->ChanBase,XAXIDMA_DESTADDR_OFFSET,in_addr);

    //2. DMA_Set
    XAxiDma_WriteReg(&DMA0.RxBdRing->ChanBase,XAXIDMA_CR_OFFSET,
                        XAxiDma_ReadReg(&DMA0.RxBdRing->ChanBase,XAXIDMA_CR_OFFSET)|XAXIDMA_CR_RUNSTOP_MASK);

    //3. DMA 전달 Data Length설정
    XAxiDma_WriteReg(&DMA0.RxBdRing->ChanBase,XAXIDMA_BUFFLEN_OFFSET,len*4);
    //----------------------------------------------------------------------------------------------------------    


    //DMA0의 DDR->PL(Mm2S)--------------------------------------------------------------------------------------
    //1. DDR Src주소 가져오기
    XAxiDma_WriteReg(&DMA0.TxBdRing.ChanBase,XAXIDMA_SRCADDR_OFFSET,OUTPUT_BASE);

    //2 DMA Ctrl[0] run/stop Set
    XAxiDma_WriteReg(&DMA0.TxBdRing.ChanBase,XAXIDMA_CR_OFFSET,
                        XAxiDma_ReadReg(&DMA0.TxBdRing.ChanBase,XAXIDMA_CR_OFFSET)|XAXIDMA_CR_RUNSTOP_MASK);
    //3. DMA전달 len설정
    XAxiDma_WriteReg(&DMA0.TxBdRing.ChanBase,XAXIDMA_BUFFLEN_OFFSET,len*4);

    //Mm2S를 완료할때까지 polling
    while((XAxiDma_Busy(&DMA0,XAXIDMA_DMA_TO_DEVICE)));
    //S2Mm을 완료할때까지 polling
    while((XAxiDma_Busy(&DMA0,XAXIDMA_DEVICE_TO_DMA)));

    //CPU에서 DDR읽기 직전에
    //최신화돤 data를 cache에 가지고 있지 않기 때문에 DDR에서 가져오기 위해서는
    //cache 초기화가 필요함.
    Xil_DCacheInvalidateRange(out_addr, len*4 + 32);
}
