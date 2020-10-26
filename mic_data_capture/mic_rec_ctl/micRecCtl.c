#include <stdint.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>
#include <time.h>
#include <errno.h>

#define	FN1 				"cic_m1.txt"
#define	FN2 				"cic_m2.txt"
#define	FN3 				"cicFir_m1.txt"
#define	FN4 				"cicFir_m2.txt"
#define	FN5 				"cicHp_m1.txt"
#define	FN6 				"cicHp_m2.txt"
#define	FN7 				"cicFirHp_m1.txt"
#define	FN8 				"cicFirHp_m2.txt"

#define FS 					48000
#define FIFOSIZE 			4096
#define	NUM_CHAN			8
#define	BYTES_PER_CH 		2

// global variables
static const char *device = "/dev/spidev0.0";
static uint8_t mode;
static uint8_t bits = 8;
static uint32_t speed = 15000000;
static uint16_t delay;

// standard error message
void pabort(const char *s)
{
	abort();
	perror(s);
}

// learn the contols and write the data to file
void saveData(uint8_t * rxData, int dataSize) {

	// open file to write data to
	FILE * fp1; fp1 = fopen(FN1, "w");
	FILE * fp2; fp2 = fopen(FN2, "w");
	FILE * fp3; fp3 = fopen(FN3, "w");
	FILE * fp4; fp4 = fopen(FN4, "w");
	FILE * fp5; fp5 = fopen(FN5, "w");
	FILE * fp6; fp6 = fopen(FN6, "w");
	FILE * fp7; fp7 = fopen(FN7, "w");
	FILE * fp8; fp8 = fopen(FN8, "w");

	uint16_t rxWord;

	for (int ni = 0; ni < dataSize; ni++) {

		// 1st word
		rxWord = *(rxData + ni);
		rxWord |= *(rxData + ++ni) << 8;
		fprintf(fp1, "%d\n",(int16_t)rxWord);

		// 2nd word
		rxWord = *(rxData + ++ni);
		rxWord |= *(rxData + ++ni) << 8;
		fprintf(fp2, "%d\n",(int16_t)rxWord);

		// 3rd word
		rxWord = *(rxData + ++ni);
		rxWord |= *(rxData + ++ni) << 8;
		fprintf(fp3, "%d\n",(int16_t)rxWord);

		// 4th word
		rxWord = *(rxData + ++ni);
		rxWord |= *(rxData + ++ni) << 8;
		fprintf(fp4, "%d\n",(int16_t)rxWord);

		// 5th word
		rxWord = *(rxData + ++ni);
		rxWord |= *(rxData + ++ni) << 8;
		fprintf(fp5, "%d\n",(int16_t)rxWord);

		// 6th word
		rxWord = *(rxData + ++ni);
		rxWord |= *(rxData + ++ni) << 8;
		fprintf(fp6, "%d\n",(int16_t)rxWord);

		// 7th word
		rxWord = *(rxData + ++ni);
		rxWord |= *(rxData + ++ni) << 8;
		fprintf(fp7, "%d\n",(int16_t)rxWord);

		// 8th word
		rxWord = *(rxData + ++ni);
		rxWord |= *(rxData + ++ni) << 8;
		fprintf(fp8, "%d\n",(int16_t)rxWord);

	}

	// close file
	fclose(fp1);
	fclose(fp2);
	fclose(fp3);
	fclose(fp4);
	fclose(fp5);
	fclose(fp6);
	fclose(fp7);
	fclose(fp8);

}

// spi transfer
uint8_t * transfer(int fd, int noBytes, uint8_t txData)
{	
	uint8_t * rx;
	uint8_t * tx;

	rx = (uint8_t*) malloc(sizeof(uint8_t) * noBytes);
	tx = (uint8_t*) malloc(sizeof(uint8_t) * noBytes);

	// create tx data array
	*tx = txData;

	// spi transfer structure
	struct spi_ioc_transfer tr = {
		.tx_buf = (unsigned long)tx,
		.rx_buf = (unsigned long)rx,
		.len = noBytes,
		.delay_usecs = delay,
		.speed_hz = speed,
		.bits_per_word = bits,
	};

	// initiate spi transfer, then error check
	int ret;
	ret = ioctl(fd, SPI_IOC_MESSAGE(1), &tr);
	if (ret < 1) {
		pabort("ERROR: can't send spi message");
	}

	return rx;

}

// sleep function
int msleep(long msec)
{
    struct timespec ts;
    int res;

    if (msec < 0)
    {
        errno = EINVAL;
        return -1;
    }

    ts.tv_sec = msec / 1000;
    ts.tv_nsec = (msec % 1000) * 1000000;

    do {
        res = nanosleep(&ts, &ts);
    } while (res && errno == EINTR);

    return res;
}

// pole fifo
void poleFifo(int fd) {

	uint8_t * rxPoleData;
	rxPoleData = (uint8_t*) malloc(sizeof(uint8_t));

	// pole fifo
	while (*rxPoleData != 0x40) {	
		// msleep(1);
		rxPoleData = transfer(fd, 1, 0x33); // TODO - does this need to be set to a value?
		
		// basic error checking
		if (*rxPoleData != 0x40) {
			if (*rxPoleData != 0x80) {
				fprintf(stderr, "ERROR: the pole data is incorrect");
				pabort("ERROR!");
			}
		}
	}

}

// open spi device
int spiSetup() {

	int ret = 0;
	int fd;

	// open spi device
	fd = open(device, O_RDWR);
	if (fd < 0)
		pabort("can't open device");

	// set spi mode
	ret = ioctl(fd, SPI_IOC_WR_MODE, &mode);
	if (ret == -1)
		pabort("can't set spi mode");
	ret = ioctl(fd, SPI_IOC_RD_MODE, &mode);
	if (ret == -1)
		pabort("can't get spi mode");

	// set spi bits
	ret = ioctl(fd, SPI_IOC_WR_BITS_PER_WORD, &bits);
	if (ret == -1)
		pabort("can't set bits per word");
	ret = ioctl(fd, SPI_IOC_RD_BITS_PER_WORD, &bits);
	if (ret == -1)
		pabort("can't get bits per word");

	// set max spi speed
	ret = ioctl(fd, SPI_IOC_WR_MAX_SPEED_HZ, &speed);
	if (ret == -1)
		pabort("can't set max speed hz");
	ret = ioctl(fd, SPI_IOC_RD_MAX_SPEED_HZ, &speed);
	if (ret == -1)
		pabort("can't get max speed hz");

	return fd;

}

// usage statement
void usage(char * progName) {

	printf("Usage: %s [time]\n", progName);
	puts("");
	printf("[option]\n");
	printf("  time  	- no. of second to record for\n");
	puts("");

	exit(1);

}

// general usage error statement when parsing input arguments
void usageErr (char * progName) {

	fprintf(stderr, "ERROR: incorrect usage\n");	
	usage(progName);

}

// parse input arguments
int parseArgs (int argc, char *argv[]) {

	if (argc != 2) {
		usageErr(argv[0]);
	}

	if (!strcmp(argv[1],"usage")) {
		usage(argv[0]);
	}

	int recTime = atoi(argv[1]);

	if (recTime==0) {
		printf("ERROR: incorrect time format\n");
		usageErr(argv[0]);
	}

	return recTime;

}

// main function
int main(int argc, char *argv[])
{
	// parse input arguments
	int recTime = parseArgs(argc, argv);

	// open and setup spi device
	int fd = spiSetup();

	// calc total number of samples
	int totBytes = recTime * FS * NUM_CHAN * BYTES_PER_CH;
	// int totBytes = FIFOSIZE + 4;
	int divInt = totBytes / FIFOSIZE;
	int divFra = totBytes % FIFOSIZE;
	
	uint8_t * rxReadData;	
	uint8_t * rxFull;
	rxReadData = (uint8_t*) malloc(sizeof(uint8_t) * FIFOSIZE);
	rxFull = (uint8_t*) malloc(sizeof(uint8_t) * totBytes);

	int rxMinIndex;

	// start recording
	printf("... recording started\n");
	transfer(fd, 1, 0xaa);

	// read full fifo data
	for (int ni = 0; ni < divInt; ni++) {

		// pole fifo
		poleFifo(fd);

		// reads full fifo data
		// msleep(1);
		rxReadData = transfer(fd, FIFOSIZE, 0x00);

		// concatenate data into large array
	    rxMinIndex = ni * FIFOSIZE;
		for (int nii = 0; nii < FIFOSIZE; nii++) {
			*(rxFull+rxMinIndex+nii) = *(rxReadData + nii);
		}

	}

	// reads from the fifo if there is a fractional amount of sample remaining
	if (divFra != 0) {

		// pole fifo
		poleFifo(fd);

		// reads last bytes
		// msleep(1);
		rxReadData = transfer(fd, divFra, 0x00);

		// concatenate data into large array
		rxMinIndex = rxMinIndex + FIFOSIZE;
		for (int nii = 0; nii < divFra; nii++) {
			*(rxFull+rxMinIndex+nii) = *(rxReadData + nii);
		}
	}

	// stop recording
	msleep(1);
	transfer(fd, 1, 0x0f);
	printf("... recording stopped\n");

	// save data
	printf("... saving data\n");
	saveData(rxFull, totBytes);

	printf("... finished\n");

	return(EXIT_SUCCESS);
}
