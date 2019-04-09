/*MSTC MBA Sean, port from mtk sdk 5010, for stainfo*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <dirent.h>
#include <time.h>
#include <sys/ioctl.h>
#include <arpa/inet.h>
#include <net/route.h>
#include "oid.h"
#include <linux/wireless.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#define WLAN1_CONF		"2860"
#define WLAN2_CONF		"rtdev"
#define LOGFILE	"/dev/console"

#define DBG_MSG(fmt, arg...)	do {	FILE *log_fp = fopen(LOGFILE, "w+"); \
						if(log_fp == NULL) break;\
						fprintf(log_fp, "%s:%s:%d:" fmt "\n", __FILE__, __func__, __LINE__, ##arg); \
						fclose(log_fp); \
					} while(0)

void StaInfo(char *argv[])
{
	int i, s;
	struct iwreq iwr;
	RT_802_11_MAC_TABLE table = {0};
#if defined (RT2860_TXBF_SUPPORT) || defined (RTDEV_TXBF_SUPPORT)
	char tmpBuff[32];
	char *phyMode[4] = {"CCK", "OFDM", "MM", "GF"};
#endif
	char client_list_array[32] = "";
	char ifname[5];

	s = socket(AF_INET, SOCK_DGRAM, 0);
	/*
	if (!strcmp(argv[1], WLAN2_CONF))
		strncpy(iwr.ifr_name, "rai0", 4);
	else
		strncpy(iwr.ifr_name, "ra0", 4);
	*/
	strncpy(iwr.ifr_name, argv[1], 4);
	
	iwr.u.data.pointer = (caddr_t) &table;

	if (s < 0) {
		DBG_MSG("open socket fail!");
		return;
	}

	if (ioctl(s, RTPRIV_IOCTL_GET_MAC_TABLE_STRUCT, &iwr) < 0) {
		DBG_MSG("ioctl -> RTPRIV_IOCTL_GET_MAC_TABLE_STRUCT fail!");
		close(s);
		return;
	}

	close(s);
	
	if( strncmp(argv[1], "ra0", 4) == 0 ) {
		strncpy(client_list_array, "client_list_2g", 14);
	} else {
		strncpy(client_list_array, "client_list_5g", 14);
	}
	
#if ! defined (RT2860_TXBF_SUPPORT) || ! defined (RTDEV_TXBF_SUPPORT)
	if( table.Num !=0 )
		printf("var %s = [];\n", client_list_array);
	
	for (i = 0; i < table.Num; i++) {
		
		printf("%s", client_list_array);
		
		printf(".push({ apIdx: \"%d\", mac: \"%02X:%02X:%02X:%02X:%02X:%02X\"",
		table.Entry[i].ApIdx, 
		table.Entry[i].Addr[0], table.Entry[i].Addr[1],
		table.Entry[i].Addr[2], table.Entry[i].Addr[3],
		table.Entry[i].Addr[4], table.Entry[i].Addr[5]);
		
		printf(", aid: \"%d\", psm: \"%d\", mimops: \"%d\", mcs: \"%d\", bw: \"%s\", shortgi: \"%d\", stbc: \"%d\", idle: %d, });",
		table.Entry[i].Aid, table.Entry[i].Psm, table.Entry[i].MimoPs,
		table.Entry[i].TxRate.field.MCS,
		(table.Entry[i].TxRate.field.BW == 0)? "20M":"40M",
		table.Entry[i].TxRate.field.ShortGI, table.Entry[i].TxRate.field.STBC,
		table.Entry[i].NoDataIdleCount);
		
		/* MSTC MBA Sean, we don't need this
		printf("ApIdx: %d", table.Entry[i].ApIdx);
		printf("<tr><td>%02X:%02X:%02X:%02X:%02X:%02X</td>",
				table.Entry[i].Addr[0], table.Entry[i].Addr[1],
				table.Entry[i].Addr[2], table.Entry[i].Addr[3],
				table.Entry[i].Addr[4], table.Entry[i].Addr[5]);
		printf("<td>%d</td><td>%d</td><td>%d</td>",
				table.Entry[i].Aid, table.Entry[i].Psm, table.Entry[i].MimoPs);
		printf("<td>%d</td><td>%s</td><td>%d</td><td>%d</td></tr>",
				table.Entry[i].TxRate.field.MCS,
				(table.Entry[i].TxRate.field.BW == 0)? "20M":"40M",
				table.Entry[i].TxRate.field.ShortGI, table.Entry[i].TxRate.field.STBC);
		*/
	}
	return;
#endif
}

int main(int argc, char *argv[])
{
	
	if ( argc == 2 ) {
		StaInfo(argv);
	}
	else {
		fprintf(stderr,
			"Usage:\n"
			"	%s ifname\n",
				argv[0]
		);
	}
	
	return 1;
}
