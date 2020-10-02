#ifndef STRUCTOFDATA_H
#define STRUCTOFDATA_H

#include <stdint.h>

#define ASSERT(cond) typedef int foo[(cond) ? 1 : -1]

typedef enum  __attribute__ ((aligned (1)))                       //флаги конечного автомата
{
	APP_SET_TIME,	             //установка задержки (этот флаг ставится на 1 кадр)
	APP_CLEAR_FLASH,           //идет стирание памяти
	APP_DELAY,	               //прибор на задержке
	APP_WORK,	                 //рабочий режим
	APP_IDLE
	//APP_MAX
} AutomatT ;

///ASSERT( sizeof(AutomatT) == 4 );

#pragma pack(push, 1)
typedef struct
//typedef struct
{
    int16_t X;
    int16_t Y;
    int16_t Z;
} accel_t;
#pragma pack(pop)

#pragma pack(push, 1)
typedef struct
{
    int16_t d0[679];
    int16_t d1[682];
    int16_t d2[682];
    int16_t d3[682];
    int16_t d4[682];
    int16_t d5[682];
    int16_t d6[682];
    int16_t d7[682];
    int16_t d8[682];
} fkd_t;
#pragma pack(pop)

/*    Установка размера выравнивания в 1 байт,
    описание структуры и возврат предыдущей настройки. */

#pragma pack(push, 1)
typedef struct
{
	uint32_t automat;
	int32_t Time;

    accel_t accel;
	float T;
    uint16_t AmpH;
	uint16_t GR;
    fkd_t fkd;
} DataStruct_t ;
#pragma pack(pop)

#pragma pack(push, 1)
typedef struct
{
#	define ADDRESS_PROC 7         /// var_adr
#	define DEV_INFO  "__DATE__ Профилемер v3" /// var_info
#	define CHIP_NUMBER 2       		   /// varChip
#	define SERIAL_NUMBER 1    		   /// varSerial
   DataStruct_t Wrk; /// WRK
} AllDataStruct_t;
#pragma pack(pop)

extern volatile AutomatT  FlagAutomat;

#endif




