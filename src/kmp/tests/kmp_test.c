#include <stdio.h>
#include "kmp.h"

char* srcStr= "Just to do it rigxxrigtxxrrrrightrighri rrrrighrighrightrighright now";
char* pattern = "righright";

int main(void)
{
	int offset = kmp_substr(srcStr, pattern);
	if (offset == -1)
		printf("Can't find the pattern\n");
	else
		printf("Good, offset: %d\n", offset);
}

