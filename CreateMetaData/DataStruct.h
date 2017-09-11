#pragma  once
#include <stdint.h>

#pragma pack(push, 1)
typedef struct
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

#pragma pack(push, 1)
typedef struct
{
	int16_t gk; ///гк
} gamma_t;
#pragma pack(pop)
/*    Установка размера выравнивания в 1 байт,
    описание структуры и возврат предыдущей настройки. */

#pragma pack(push, 1)
typedef struct
{
	float T;
	uint16_t AmpH;  /// потребление
	gamma_t GR;     /// ГК|GK1
	accel_t accel;  /// accel|CLA1
	fkd_t fkd;
} Caliper_t ;
#pragma pack(pop)

#pragma pack(push, 1)
typedef struct
{
	uint8_t automat;   /// автомат|AU
	int32_t Time;      /// время|WT
	Caliper_t Caliper;
} DataStructW_t ;
#pragma pack(pop)

#pragma pack(push, 1)
typedef struct
{
#   define RAM_SIZE 16000 /// varRamSize
	int32_t Time;         /// время|WT
	Caliper_t Caliper;
} DataStructR_t ;
#pragma pack(pop)

#pragma pack(push, 1)
typedef struct
{
#	define ADDRESS_PROC 7         /// var_adr
#	define DEV_INFO  "__DATE__ Профилемер v3" /// var_info
#	define CHIP_NUMBER 2       		   /// varChip
#	define SERIAL_NUMBER 1    		   /// varSerial
   DataStructW_t Wrk; /// WRK
   DataStructR_t Ram; /// RAM
} AllDataStruct_t; /// Calip3
#pragma pack(pop)




