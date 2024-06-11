#pragma  once

namespace adxl354gk
{
	
typedef struct __attribute__((packed))
{
	uint16_t gk; ///��
} Gk_t ;

typedef struct __attribute__((packed))
{
	Gk_t GR1; /// ��|GK1
} EepData_t;
	
typedef struct __attribute__((packed))
{
	int16_t X;
	int16_t Y;
	int16_t Z;
} Dat_t;

typedef struct __attribute__((packed))
{
	Dat_t accel;
	Dat_t magnit;
	int16_t T;
	float Zenit; /// �����
	float Azimut; /// ������
	float Gtf; /// �����������
	float Mtf; /// ���_������
	int16_t Gtot; /// ������_accel
	int16_t Mtot; /// ������_magnit
} InclW_t;

typedef struct __attribute__((packed))
{
	Dat_t accel;
	Dat_t magnit;
	int16_t T;
} InclR_t_old;

typedef  struct __attribute__((packed))
{
	uint8_t AppState; ///  �������|AU
	int32_t time;    ///  �����|WT
	InclW_t dat;	/// Inclin|INKLGK
	Gk_t gk;        /// ��|GK1
} WorkData_t;

typedef struct __attribute__((packed))
{
#	define RAM_SIZE 32 /// varRamSize
	int32_t ramtime;    ///  �����|WT
	InclW_t dat;  /// Inclin|INKLGK
	Gk_t gk;        /// ��|GK1
} RamData_t;

typedef struct __attribute__((packed))
{
#	define ADDRESS_PROC 3			/// var_adr
#	define DEV_INFO  "__DATE__ ADXL354 GK" /// var_info
#	define CHIP_NUMBER 4       		   /// varChip
#	define SERIAL_NUMBER 1    		   /// varSerial
#	define UART_SPEED_MASK 192 /// varSupportUartSpeed
   WorkData_t Wrk; /// WRK
   RamData_t Ram; /// RAM
   EepData_t Eep; /// EEP
} AllDataStruct_t; /// InclGK1
}
