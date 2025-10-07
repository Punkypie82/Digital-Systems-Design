#include <stdio.h>
#define AXI_ADDR0 0x0400000000
volatile unsigned int *AXIAddr0 = (volatile unsigned int *) AXI_ADDR0;

void generate_random_256bit(uint32_t *array) {
    for (int i = 0; i < 8; i++) {
        array[i] = rand();
    }
}

int main()
{
	unsigned int i;
	unsigned int *mem = AXI_ADDR0;
	uint32_t A[8], B[8];
	uint32_t S;

//	A[0] = 0x11111111;
//	A[1] = 0xF0000001;
//	A[2] = 0x00000002;
//	A[3] = 0x00000003;
//	A[4] = 0x00000004;
//	A[5] = 0x00000005;
//	A[6] = 0x00000006;
//	A[7] = 0x00000007;
//
//	B[0] = 0x12345678;
//	B[1] = 0xF0000001;
//	B[2] = 0x00000002;
//	B[3] = 0x00000003;
//	B[4] = 0x00000004;
//	B[5] = 0x00000005;
//	B[6] = 0x00000006;
//	B[7] = 0x00000007;

	for(;;)
	{
		xil_printf("--------------------------------\n\r");
		xil_printf("Generating Random A & B\n\r");
		generate_random_256bit(A);
		generate_random_256bit(B);

		xil_printf("--------------------------------\n\r");
		xil_printf("Write A:\n\r");
		for(i = 0; i < 8;i ++)
		{
			mem[AXI_ADDR0+i] = A[i];
			xil_printf("M[%d] = 0x%08X\n\r", i, A[i]);
		}
		xil_printf("Write B:\n\r");
		for(i = 0; i < 8;i ++)
		{
			mem[AXI_ADDR0+8+i] = B[i];
			xil_printf("M[%d] = 0x%08X\n\r", i+8, B[i]);
		}

		xil_printf("--------------------------------\n\r");
		xil_printf("Set Start\n\r");
		mem[AXI_ADDR0+16] = 1;
		xil_printf("Release Start\n\r");
		mem[AXI_ADDR0+16] = 0;

//		for(i = 0; i < 8; i++)
//		{
//			S = mem[AXI_ADDR0+i];
//			xil_printf("Read 0x%08X\n\r", S);
//		}
//		for(i = 0; i < 8; i++)
//		{
//			S = mem[AXI_ADDR0+i+8];
//			xil_printf("Read 0x%08X\n\r", S);
//		}

		xil_printf("--------------------------------\n\r");
		xil_printf("Read Done:\n\r");
		S = mem[AXI_ADDR0+25];
		xil_printf("Done = 0x%08X\n\r", S);

		xil_printf("--------------------------------\n\r");
		xil_printf("Read Sum:\n\r");
		for(i = 0; i < 8; i++)
		{
			S = mem[AXI_ADDR0+i+17];
			xil_printf("Sum[%d] = 0x%08X\n\r", i, S);
		}

//		A[0] += 1;
		sleep(5);
	}
}
