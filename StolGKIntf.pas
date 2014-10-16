unit StolGKIntf;

interface

uses System.SysUtils,
     DeviceIntf, tools;

const
    ADR_STOL_GK = 2413;

type
  TAnswer = record
   text: string;
   Str: AnsiString;
  end;

  const
   STOL_GK_AVAIL_ACSWER: array[0..5] of TAnswer = (
   (text: '������� ������� � ���������'; Str: 'E10*'),
   (text: '������� ��������'; Str: 'E12*'),
   (text: '������� ���������'; Str: 'E14*'),
   (text: '������ ��� �����'; Str: 'E15*'),
   (text: '������ �������'; Str: 'E16*'),
   (text: '������ ������ �������'; Str: 'E19*'));

type
 TEventStol = (
//      esSync, // �������������
      esWait, // ��������
      esTerminateCmd, // ���������� ������������� ������ �������������
      esEndCmd, // �����
      esErrCmd,      // ������
      esTimeOut);   // TimeOut

const
  STOL_GK_EVENT_INFO: array[TEventStol] of string = ('��������', '����������', '�����', '������', '�������');

type
 TStatusStol = set of (ssSync, ssRun);

 TStolRes = reference to procedure (AEvent: TEventStol; const LastAns: AnsiString);

 IStolGK = interface(IDevice)
 ['{B7975DC0-FA19-479F-84FF-18CBA4074DE2}']
   procedure Stop(Res: TStolRes);
   function Commands: TArray<string>;
   procedure Run(const Cmd: string; Res: TStolRes);
   procedure Actuator(Position: Boolean; Res: TStolRes);

   function GetPosition: Integer;
   function GetStatusStol: TStatusStol;

   property Position: Integer read GetPosition;
   property StatusStol: TStatusStol read GetStatusStol;
 end;


implementation

end.
