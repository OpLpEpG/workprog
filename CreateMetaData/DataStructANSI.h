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


#	define LEN_MS 682

#pragma pack(push, 1)
typedef struct
{
	int16_t d0[679];
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

#pragma pack(push, 1)
typedef struct
{
	int16_t gk; /// ��
} gamma_t;
#pragma pack(pop)
/*    ��������� ������� ������������ � 1 ����,
    �������� ��������� � ������� ���������� ���������. */

#pragma pack(push, 1)
typedef struct
{
	float T;
	uint16_t AmpH;  /// �����������
	gamma_t GR;     /// ��|GK1
	accel_t accel;  /// accel|CLA1
	fkd_t fkd;
} Caliper_t ;
#pragma pack(pop)

#pragma pack(push, 1)
typedef struct
{
	uint8_t automat;   /// �������|AU
	int32_t Time;      /// �����|WT
	Caliper_t Caliper;
} DataStructW_t ;
#pragma pack(pop)

#pragma pack(push, 1)
typedef struct
{
#   define RAM_SIZE 16000 /// varRamSize
	int32_t Time;         /// �����|WT
	Caliper_t Caliper;
} DataStructR_t ;
#pragma pack(pop)

#pragma pack(push, 1)
typedef struct
{
#	define ADDRESS_PROC 7         /// var_adr
#	define DEV_INFO  "__DATE__ ���������� v3" /// var_info
#	define CHIP_NUMBER 2       		   /// varChip
#	define SERIAL_NUMBER 1    		   /// varSerial
   DataStructW_t Wrk; /// WRK
   DataStructR_t Ram; /// RAM
} AllDataStruct_t; /// Calip3
#pragma pack(pop)




