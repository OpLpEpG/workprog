#pragma  once
#include <stdint.h>

#pragma pack(push, 1)
//-name=accel
//-metr=CLA1
typedef struct
{
    int16_t X;
    int16_t Y;
    int16_t Z;
} accel_t;
#pragma pack(pop)


#	define LEN_MS 682  // simple comment
#	define LEN_MS1 0x2A7  // simple comment

#pragma pack(push, 1)
typedef struct
{
	int16_t d0[LEN_MS1];
	int16_t d1[LEN_MS];
	int16_t d2[LEN_MS];
	int16_t d3[LEN_MS];
	int16_t d4[LEN_MS];
	int16_t d5[LEN_MS];
	int16_t d6[LEN_MS];
	int16_t d7[LEN_MS];
    int16_t d8[LEN_MS];
} fkd_t;
#pragma pack(pop)

//-name=ГК
//- metr=GK1
#pragma pack(push, 1)
typedef struct
{
	//-name=гк
	int16_t gk;
} gamma_t;
#pragma pack(pop)

/*    Установка размера выравнивания в 1 байт,
    описание структуры и возврат предыдущей настройки. */

#pragma pack(push, 1)
typedef struct
{
	//- varDigits=4
	//- varPrecision=1
	float T;
	//- name=потребление
	uint16_t AmpH;
	//-structname
	gamma_t GR;
	//-structname
	accel_t accel;
	fkd_t fkd;
} Caliper_t ;
#pragma pack(pop)

#pragma pack(push, 1)
typedef struct
{
	//- name= автомат
	//- metr = AU
	uint8_t automat;
	//- name= время
	//- metr= WT
	int32_t Time;
	Caliper_t Caliper;
} DataStructW_t ;
#pragma pack(pop)

#pragma pack(push, 1)
typedef struct __attribute__((packed))
{
  //- name= время
  //- metr =WT
	int32_t Time;
	Caliper_t Caliper;
} DataStructR_t ;
#pragma pack(pop)

#define ADR_PROC 7

#pragma pack(push, 1)
//- var_adr = ADR_PROC
//- var_info = "__DATE__ __TIME__ Профилемер v3"
//- varChip = 9
//- varSerial = 529
//- varExtNoPowerDataCount = 33
//- name = Calip3
//- varSupportUartSpeed = 0xE0
//- export
typedef struct
{
 //- WRK
//- noname
   DataStructW_t Wrk;
   //- varRamSize =65000
   //- RAM
   //- noname
   DataStructR_t Ram;
} AllDataStruct_t;
#pragma pack(pop)




