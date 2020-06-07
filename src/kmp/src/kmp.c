#include <stdio.h>
#include <string.h>
#include "kmp.h"
#include "log.h"

static void kmp_genFback(char *pStr, int *pFb, int len)
{
	int i, j;
	pFb[0] = -1;
	j = 0;
	for (i = 1; i < len; i++)
	{
		if (pStr[i] == pStr[j])
		{
			pFb[i] = pFb[j];
			j++;
		}
		else
		{
			pFb[i] = j;
			j = 0;
		}
	}

	log_vInt(0, "KMP Fall Back", pFb, len);
}

int kmp_substr(char *pStr, char *pPatten)
{
	if (!pStr || !pPatten)
	{
		printf("Null parameter: pStr=%p, pPatten=%p\n", pStr, pPatten);
		return -1;
	}

	int strLen = strlen(pStr);
	int ptnLen = strlen(pPatten);

	if (ptnLen > strLen)
		return -1;

	int *fback = (int *) malloc(ptnLen * sizeof(int));
	if (!fback)
	{
		perror("Fail to allocate memory");
		printf("Memory necessary: %d\n", ptnLen*sizeof(int));
		return -1;
	}

	kmp_genFback(pPatten, fback, ptnLen);

	int matchedLen = 0;
	int idx = 0;
	while (matchedLen < ptnLen && idx < strLen)
	{
		printf("idx[%c]: %d,  matchedLen: %d\n", pStr[idx], idx, matchedLen);
		if (pStr[idx] == pPatten[matchedLen])
		{
			matchedLen++;
			idx++;
		}
		else
		{
			matchedLen = fback[matchedLen];
			if (matchedLen == -1)
			{
				matchedLen++;
				idx++;
			}
		}
	}
	if (idx < strLen)
		printf("Last: idx[%c]: %d,  matchedLen: %d\n", pStr[idx], idx, matchedLen);

	free(fback);

	if (matchedLen == ptnLen)
		return idx - ptnLen;
	else
		return -1;
}
