#include "log.h"

void log_vInt(int mod, char *pPromt, int *pInt, int len)
{
	int i;
	printf("%s: ", pPromt);
	for (i = 0; i < len; ++i)
	{
		printf("%d ", pInt[i]);
	}
	printf("\n");
}
