#include <stdio.h>
int main(int argv, char** args) {
	if (argv>2) {
		FILE* disk = fopen(args[1], "r+b");
		FILE* fl = fopen(args[2], "r+b");
		int a = 496;
		short int cluster, minisize;
		long int size = 0, i;
		char temp;
		while(a<32256) {
			a += 16;
			printf("File: %d\n", (int)(a/16)-31);
			fseek(disk, a, SEEK_SET);
			if((temp = fgetc(disk)) == 0) {
				if(a!=512) {
					fseek(disk, a-4, SEEK_SET);
					fread(&size, 2, 1, disk);
					fread(&cluster, 2, 1, disk);
					temp = 1;
					while((size-=4096)>0)
						temp++;
					cluster += (int)temp;
				}
				else
					cluster = 1;

			printf("Cluster: %d\n", cluster);
				for(;*(args[2])!=0;(args[2])++);
				for(;(*(args[2])!='/') && (*(args[2])!='\\');(args[2])--);
				args[2]++;
				fseek(disk, a, SEEK_SET);
				for(i = 0;((*(args[2])!=0)&&i<12); (args[2])++, i++)
					fwrite(args[2], 1, 1, disk);
				temp = 0;

				fwrite(&temp, 1,1, disk);
				fseek(disk, ((cluster+7)*4096), SEEK_SET);
				fseek(fl, 0L, SEEK_END);
				size = ftell(fl);
				if(size>65536)
					size = 65536;
				minisize = (short)size;
				i = size;
			printf("Size: %lu\n", size);
				fseek(fl, 0L, SEEK_SET);
				int progress = ((int)(size/50)), progbar = 0;
				for(i = 0; i<size; i++)
				{
					for(int j = 0; j<10000; j++);
					if((!(i%progress))&&progbar<=50)
					{
						printf("\rProgress: ");
						for (int j = 0; j < progbar; j++)
							printf("#");
						for (int j = 0; j < 50-progbar; j++)
							printf(" ");
						printf(" %d%%", progbar*2);
						fflush(stdout);
						progbar++;
					}
					temp = getc(fl);
					fwrite(&temp, 1, 1, disk);
				}
				printf("\n");
				fseek(disk, a+12, SEEK_SET);
				fwrite(&minisize, 2, 1, disk);
				fwrite(&cluster, 2, 1, disk);
				break;
			}
		}
	}
}