#pragma  once
//#include <avr/io.h>


namespace vik108
{
typedef struct 
{
	uint16_t gk; ///��
} gk_t;	

typedef struct 
{
	int32_t H100cm; /// ����1�
	int32_t L100cm; /// ���1�
	int32_t H70cm;  /// ����07�
	int32_t L70cm;  /// ���07�
} Dat_t __attribute__((aligned));

typedef struct
{
	Dat_t faza; /// ����
	Dat_t ampl; /// ���������
} vikData_t;

typedef  struct
{
	uint8_t AppState; ///  �������|AU
	int32_t time;    ///  �����|WT
	gk_t gk;  /// ��|GK1
	vikData_t vik;	/// ���|VIK108
} WorkData_t __attribute__((aligned));

typedef struct 
{
	#define RAM_SIZE   5  /// varRamSize
	int32_t ramtime;    ///  �����|WT
	gk_t gk;  /// ��|GK1
	vikData_t vik;	/// ���|VIK108
} RamData_t __attribute__((aligned));

typedef struct
{
#	define ADDRESS_PROC	8			/// var_adr
#	define DEV_INFO  "__DATE__ VIK108" /// var_info
#	define CHIP_NUMBER 2       		   /// varChip
#	define SERIAL_NUMBER 1    		   /// varSerial
#	define UART_SPEED_MASK 192 /// varSupportUartSpeed
   WorkData_t Wrk; /// WRK
   RamData_t Ram; /// RAM
} AllDataStruct_t; /// Incl3
}

