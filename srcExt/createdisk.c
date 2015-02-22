#include <stdio.h>
int main(){
	FILE *f = fopen("disk", "w+");
	short sig = 0x0000;
	fseek(f, 104857600, SEEK_SET);
	fwrite(&sig, sizeof(sig),1,f);
	return 0;
}