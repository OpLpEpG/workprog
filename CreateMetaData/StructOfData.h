
#include <stdint.h>


typedef __packed struct
{
  int16_t X;
  int16_t Y;
  int16_t Z;
} accel_t __attribute__((aligned));

typedef __packed struct
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
} fkd_t __attribute__((aligned));


typedef __packed struct
{
	  uint16_t gk;   /// гк
} gk_t __attribute__((aligned));

typedef __packed struct
{
	uint8_t automat; ///  автомат|AU
	int32_t Time;    ///  время|WT
	accel_t accel;   /// accel|CLA1
	float T;
	uint16_t AmpH;
	gk_t GR;         /// ГК|GK1
	fkd_t fkd;

} DataStruct_w;

typedef __packed struct
{
#	define RAM_SIZE	 1000 	/// varRamSize
	int32_t Time;    		///  время|WT
	accel_t accel;   		/// accel|CLA1
	float T;
	uint16_t AmpH;
	gk_t GR;         		/// ГК|GK1
	fkd_t fkd;

} DataStruct_r;

typedef struct
{
#	define ADDRESS_PROCESSOR 7         /// var_adr
#	define DEV_INFO  "__DATE__ Прфилемер v2" /// var_info
#	define CHIP_NUMBER 3       		   /// varChip
#	define SERIAL_NUMBER 2    		   /// varSerial
   DataStruct_w Wrk; /// WRK
   DataStruct_r Ram; /// RAM
} AllDataStruct_t; /// Caliper2




















