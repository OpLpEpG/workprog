unit PSKFormats;

interface

uses System.SysUtils, Xml.XMLIntf, Xml.XMLDoc;

const
   ADR_USO = 100;
   ADR_GLUBIONMER = 101;
   ADR_AP = 102;
   ADR_AK_XMEGA_LOC_NOISE = 103;
   ADR_PSK4 = 104;
   ADR_AK60 = 105;


   //��������� ������ ������
   //��� 8 ���� ������� ���� ������
   // ������� �������
   PRO_SWAP = $80;
   // ������ ������ 01 - FE - ������
   PRO_H_01 = 1;
   // ������ ������ 01 - FE 01 - 01 - ������
   PRO_H_02 = 2;

   //��� 8 ���� ������� ���� ������
   // ����������� ���������
   PRO_L_STD = 1;
   // ��������� �� ��������
   PRO_L_APW = 2;
   // ����������
   PRO_L_GLU = 3;

   //��������� ������ ������
   PRO_D_STD = 1;
   PRO_D_USO = 2;
   PRO_D_GLU = 3;

function GetPSKInfo(Addr: Byte): IXMLNode;

implementation

uses tools, Parser;

{$REGION 'DeviceInfo'}

type
 DeviceInfoIndex = class
  class function Create(  Root: IXMLNode; adr: Integer; const DevName, Info: string): IXMLNode;
  class function AddTree(Root: IXMLNode; const TreeName: string; const format: string = ''; size: Integer = 0): IXMLNode;
  class procedure AddParam(Root: IXMLNode; const ParName: string; varType, Index: Integer; const format: string = ''; ArZize: Integer =0 );
 end;

{ DeviceInfo }

class function DeviceInfoIndex.Create(Root: IXMLNode; adr: Integer; const DevName, Info: string): IXMLNode;
begin
  Result := Root.AddChild(DevName);
  Result.Attributes[AT_SIZE] := 0;
  Result.Attributes[AT_ADDR] := adr;
  Result.Attributes[AT_INFO] := Info;
end;

class procedure DeviceInfoIndex.AddParam(Root: IXMLNode; const ParName: string; varType, Index: Integer; const format: string = ''; ArZize: Integer =0 );
 var
  r, d: IXMLNode;
begin
  r := Root.AddChild(ParName);
  if format <> '' then r.Attributes[AT_METR] := format;
  if ArZize > 0 then r.Attributes[AT_ARRAY] := ArZize;
  d := r.AddChild(T_DEV);
  d.Attributes[AT_TIP] := varType;
  d.Attributes[AT_INDEX] := Index;
end;

class function DeviceInfoIndex.AddTree(Root: IXMLNode; const TreeName: string; const format: string = ''; size: Integer = 0): IXMLNode;
begin
  Result := Root.AddChild(TreeName);
  Result.Attributes[AT_SIZE] := size;
  if format <> '' then Result.Attributes[AT_METR] := format;
end;
{$ENDREGION}




function GetAK60Info(): IXMLNode;
type
EnumAK60 = (akSP,
  akNlo, akNhi,
  akGK, akNNK1, akNNk2, akNGK,
  akKUFKD, akNop,
  akUop,
  akUp1,
  akUp2,
  akUtemp,
  akGx,
  akGy,
  akGz,
  akFKD1,
  akSP2=$200, akNlo2, akNhi2,

  akGK_2, akNNK1_2, akNNk2_2, akNGK_2,
  akKUFKD_2, akNop_2,
  akUop_2,
  akUp1_2,
  akUp2_2,
  akUtemp_2,
  akHx,
  akHy,
  akHz,
  akFKD2, akFKD2End=$3FF,  // ��� ��� ������� � ��������� �����
  // ������ � ������
  akSP3=$400, akKUNiose16m,
  akNoise16m,
  akSP4=$600,
  akKUNiose05s,
  akNoise05s,
  akMax=$800);
 var
  GDoc: IXMLDocument;
  Root, Wrk, lev1, lev2: IXMLNode;
  procedure AddAllWork(FlowInt: Integer);
  begin
    with DeviceInfoIndex, TPars do
     begin
      Wrk.Attributes[AT_SP_HI] := $80;
      Wrk.Attributes[AT_WRKP] := PRO_D_STD;
      Wrk.Attributes[AT_FLOWINTERVAL] := FlowInt;
        AddParam(Wrk, '�����', var_ui2_kadr_all, Integer(akNhi), 'WT');
          lev1 := AddTree(Wrk, '��');
            AddParam(lev1, '��', var_ui2_14b, Integer(akGK));
            AddParam(lev1, '��_2', var_ui2_14b, Integer(akGK_2));
            AddParam(lev1, '���1', var_ui2_14b, Integer(akNNK1));
            AddParam(lev1, '���1_2', var_ui2_14b, Integer(akNNK1_2));
            AddParam(lev1, '���2', var_ui2_14b, Integer(akNNK2));
            AddParam(lev1, '���2_2', var_ui2_14b, Integer(akNNK2_2));
            AddParam(lev1, '���', var_ui2_14b, Integer(akNGK));
            AddParam(lev1, '���_2', var_ui2_14b, Integer(akNGK_2));
          lev1 := AddTree(Wrk, 'U');
            AddParam(lev1, '�����', var_ui2_14b, Integer(akUop));
            AddParam(lev1, '�����_2', var_ui2_14b, Integer(akUop_2));
            AddParam(lev1, '������1', var_ui2_14b, Integer(akUp1));
            AddParam(lev1, '������1_2', var_ui2_14b, Integer(akUp1_2));
            AddParam(lev1, '������2', var_ui2_14b, Integer(akUp2));
            AddParam(lev1, '������2_2', var_ui2_14b, Integer(akUp2_2));
            AddParam(lev1, '����', var_i2_10b, Integer(akUtemp));
            AddParam(lev1, '����_2', var_i2_10b, Integer(akUtemp_2));
          lev1 := AddTree(Wrk, 'Inclin');
            lev2 := AddTree(lev1, 'Accel');
              AddParam(lev2, 'X', var_i2_14b, Integer(akGx));
              AddParam(lev2, 'Y', var_i2_14b, Integer(akGy));
              AddParam(lev2, 'Z', var_i2_14b, Integer(akGz));
            lev2 := AddTree(lev1, 'Magnit');
              AddParam(lev2, 'X', var_i2_14b, Integer(akHx));
              AddParam(lev2, 'Y', var_i2_14b, Integer(akHy));
              AddParam(lev2, 'Z', var_i2_14b, Integer(akHz));
      AddParam(Wrk, '���1', var_ui2_14b, Integer(akFKD1), '',Integer(akSP2)-Integer(akFKD1));
      AddParam(Wrk, '���2', var_ui2_14b, Integer(akFKD2), '',Integer(akFKD2End)-Integer(akFKD2));
     end;
  end;
begin
   GDoc := NewXMLDocument();
   GDoc.DocumentElement := GDoc.AddChild('DEVICE');
   GDoc.DocumentElement.Attributes[AT_SIZE] := 0;
   with DeviceInfoIndex, TPars do
    begin
     Root := DeviceInfoIndex.Create(GDoc.DocumentElement, ADR_AK60, 'AK60', 'AK60 �������� ���������');
     Root.Attributes[AT_DELAYDV] := 256;
     Root.Attributes[AT_WORKTIME] := 1;
     Wrk := AddTree(Root,'WRK', '', Integer(akSP3)*2);
     AddAllWork(500);
     Wrk := AddTree(Root,'RAM', '', Integer(akMax)*2);
     Wrk.Attributes[AT_RAMSIZE] := 1000;
     Wrk.Attributes[AT_RAMHP] := PRO_H_01 or PRO_SWAP;
     Wrk.Attributes[AT_RAMLP] := PRO_L_STD;
     AddAllWork(400);
     AddParam(Wrk, '��_�1', var_ui2_8b, Integer(akKUNiose16m));
     AddParam(Wrk, '��_�2', var_ui2_8b, Integer(akKUNiose05s));
     AddParam(Wrk, '����1', varWord, Integer(akNoise16m), '',Integer(akSP4)-Integer(akNoise16m));
     AddParam(Wrk, '����2', varWord, Integer(akNoise05s), '',Integer(akMax)-Integer(akNoise05s));
    end;
  Result := GDoc.DocumentElement;
  GDoc.SaveToFile(ExtractFilePath(ParamStr(0)) + 'AK60Info.xml');
end;

function GetAKXLNInfo(): IXMLNode;
type
EnumAKXmega_Lok_Noise = (akSP,
  akNlo, akNhi,
  akGK, akNNK1, akNNk2, akNGK,
  akKUFKD, akKUNoise,
  akUbat,
  akWorkTime,
  akDelay,
  akUtemp,
  akRezerv1,
  akRezerv2,
  akRezerv3,
  akFKD1,
  akSP2=$200, akNlo2, akNhi2,
  akA24,akA32,akA40,akA48,akA56,akA64,akA72,akA80,
  akB0,
  akA8t, akA16t, akA24t, akA32t,
  akFKD2, akFKD2End=$3FF,
  akSP3=$400, akNlo3, akNhi3,
  akFKD3,
  akOnes=1987, akMax=2048
//  akSP4=$400, akNlo4, akNhi4,
//  akNoise,
//  akMax=$C00
);
 var
  GDoc: IXMLDocument;
  Root, Wrk, lev1: IXMLNode;
  procedure AddAllWork;
  begin
    with DeviceInfoIndex, TPars do
     begin
      Wrk.Attributes[AT_SP_HI] := $80;
      Wrk.Attributes[AT_WRKP] := PRO_D_STD;
      Wrk.Attributes[AT_FLOWINTERVAL] := 1200;
        AddParam(Wrk, '�����', var_ui2_kadr_all, Integer(akNhi), 'WT');
          lev1 := AddTree(Wrk, '��');
            AddParam(lev1, '��', var_ui2_14b, Integer(akGK));
            AddParam(lev1, '���1', var_ui2_14b, Integer(akNNK1));
            AddParam(lev1, '���2', var_ui2_14b, Integer(akNNK2));
            AddParam(lev1, '���', var_ui2_14b, Integer(akNGK));
          lev1 := AddTree(Wrk, '�������');
            AddParam(lev1, 'B0', var_i2_10b, Integer(akB0));
            AddParam(lev1, 'A8t', var_i2_10b, Integer(akA8t));
            AddParam(lev1, 'A16t', var_i2_10b, Integer(akA16t));
            AddParam(lev1, 'A24t', var_i2_10b, Integer(akA24t));
            AddParam(lev1, 'A32t', var_i2_10b, Integer(akA32t));
            AddParam(lev1, 'A24', var_i2_10b, Integer(akA24));
            AddParam(lev1, 'A32', var_i2_10b, Integer(akA32));
            AddParam(lev1, 'A40', var_i2_10b, Integer(akA40));
            AddParam(lev1, 'A48', var_i2_10b, Integer(akA48));
            AddParam(lev1, 'A56', var_i2_10b, Integer(akA56));
            AddParam(lev1, 'A64', var_i2_10b, Integer(akA64));
            AddParam(lev1, 'A72', var_i2_10b, Integer(akA72));
            AddParam(lev1, 'A80', var_i2_10b, Integer(akA80));
        AddParam(Wrk, '��_���', var_ui2_8b, Integer(akKUFKD));
        AddParam(Wrk, '��_���', var_ui2_8b, Integer(akKUNoise));
        AddParam(Wrk, 'U_���', var_i2_14b_z_inv, Integer(akUbat));
        AddParam(Wrk, '�����_������', var_i2_14b_z_inv, Integer(akWorkTime));
        AddParam(Wrk, '��������', var_i2_14b_z_inv, Integer(akDelay));
        AddParam(Wrk, 'U_����', var_i2_14b_z, Integer(akUtemp));
          lev1 := AddTree(Wrk, 'rezerv');
            AddParam(lev1, 'R1', var_ui2_14b, Integer(akRezerv1));
            AddParam(lev1, 'R2', var_ui2_14b, Integer(akRezerv2));
            AddParam(lev1, 'R3', var_ui2_14b, Integer(akRezerv3));
      AddParam(Wrk, '���1', var_ui2_14b, Integer(akFKD1), '', Integer(akSP2)-Integer(akFKD1));
      AddParam(Wrk, '���2', var_ui2_14b, Integer(akFKD2), '', Integer(akFKD2End)-Integer(akFKD2));
     end;
  end;
begin
   GDoc := NewXMLDocument();
   GDoc.DocumentElement := GDoc.AddChild('DEVICE');
   GDoc.DocumentElement.Attributes[AT_SIZE] := 0;
   with DeviceInfoIndex, TPars do
    begin
     Root := DeviceInfoIndex.Create(GDoc.DocumentElement, ADR_AK_XMEGA_LOC_NOISE, 'AK_XMEGA', 'AK_XMEGA �������� ���������');
     Root.Attributes[AT_DELAYDV] := 256;
     Root.Attributes[AT_WORKTIME] := 1;
     Wrk := AddTree(Root,'WRK', '', Integer(akSP3)*2);
     AddAllWork();
     Wrk := AddTree(Root,'RAM', '', Integer(akMax)*2);
     Wrk.Attributes[AT_RAMSIZE] := 1000;
     Wrk.Attributes[AT_RAMHP] := PRO_H_01 or PRO_SWAP;
     Wrk.Attributes[AT_RAMLP] := PRO_L_STD;
     AddAllWork();
     AddParam(Wrk, '���3', var_ui2_14b, Integer(akFKD3), '', Integer(akOnes)-Integer(akFKD3));
    // AddArray(Wrk, '����', varWord, Integer(akNoise), Integer(akMax)-Integer(akNoise));
    end;
  Result := GDoc.DocumentElement;
  GDoc.SaveToFile(ExtractFilePath(ParamStr(0)) + 'AKXMEGALNInfo.xml');
end;

function GetAPInfo(): IXMLNode;
type
EnumAPWave = (apSP,
  apNlo, apNhi,
  apGK,
  apGGKmz, apGGKcz, apGGKbz,
  apViz, apTemp,apUb,apMaxWrk,
  apKDF0=56,
  apKDF1=$100,
  apKDF2=$200,
  apKDF3=$300,
  apKDF4=$400,
  apKDF5=$500,
  apKDF6=$600,
  apKDF7=$700,
  apKDF8=$800,
  apMax =$900);
 var
  GDoc: IXMLDocument;
  Root, Wrk: IXMLNode;
  procedure AddAllWork;
  begin
    with DeviceInfoIndex, TPars do
     begin
      Wrk.Attributes[AT_SP_HI] := 0;
      Wrk.Attributes[AT_WRKP] := PRO_D_STD;
        AddParam(Wrk, '�����', var_ui2_kadr_all, Integer(apNhi), 'WT');
        AddParam(Wrk, '��', var_ui2_14b, Integer(apGk));
        AddParam(Wrk, '����_��', var_ui2_15b, Integer(apGGKmz));
        AddParam(Wrk, '����_��', var_ui2_15b, Integer(apGGKcz));
        AddParam(Wrk, '����_��', var_ui2_15b, Integer(apGGKbz));
        AddParam(Wrk, 'Viz', var_i2_15b, Integer(apViz));
        AddParam(Wrk, 'Temp', var_ui2_15b, Integer(apTemp));
        AddParam(Wrk, 'Ub', var_ui2_15b, Integer(apUb));
     end;
  end;
begin
   GDoc := NewXMLDocument();
   GDoc.DocumentElement := GDoc.AddChild('DEVICE');
   GDoc.DocumentElement.Attributes[AT_SIZE] := 0;
   with DeviceInfoIndex, TPars do
    begin
     Root := DeviceInfoIndex.Create(GDoc.DocumentElement, ADR_AP, 'AP', '������������ ����������, �������� ���������');
      Wrk := AddTree(Root,'WRK', '',Integer(apMaxWrk)*2);
      Wrk.Attributes[AT_FLOWINTERVAL] := 1200;
      AddAllWork();
      Wrk := AddTree(Root,'RAM', '', Integer(apMax)*2);
      Wrk.Attributes[AT_RAMSIZE] := 5;
      Wrk.Attributes[AT_RAMHP] := PRO_H_01 or PRO_SWAP;
      Wrk.Attributes[AT_RAMLP] := PRO_L_APW or PRO_SWAP;
      Wrk.Attributes[AT_FLOWINTERVAL] := 1200;
      AddAllWork();
      AddParam(Wrk, '���0', var_i2_15b, Integer(apKDF0), '', Integer(apKDF1)-Integer(apKDF0));
      AddParam(Wrk, '���1', var_i2_15b, Integer(apKDF1), '', $100);
      AddParam(Wrk, '���2', var_i2_15b, Integer(apKDF2), '', $100);
      AddParam(Wrk, '���3', var_i2_15b, Integer(apKDF3), '', $100);
      AddParam(Wrk, '���4', var_i2_15b, Integer(apKDF4), '', $100);
      AddParam(Wrk, '���5', var_i2_15b, Integer(apKDF5), '', $100);
      AddParam(Wrk, '���6', var_i2_15b, Integer(apKDF6), '', $100);
      AddParam(Wrk, '���7', var_i2_15b, Integer(apKDF7), '', $100);
      AddParam(Wrk, '���8', var_i2_15b, Integer(apKDF8), '', $100);
    end;
  Result := GDoc.DocumentElement;
  GDoc.SaveToFile(ExtractFilePath(ParamStr(0)) + 'APInfo.xml');
end;

function GetPSK4Info(): IXMLNode;
type
// ������ ���4
  EnumPSK4kadr = (ekSP,
  ekKS1_4, ekNlo,
  ekKS2_4, ekNhi,
  ekKS3_4, ekKS1,
  ekKS4_4, ekKS2,
  ekIKT0 , ekKS3,
  ekIKT1 , ekKS4,
  ekIKT2 ,  ekI,
  ekIKT3 ,  ekTinkl,
  ekIKT4 ,  ekGx,
  ekIKT5 ,  ekGy,
  ekProfT0, ekGz,
  ekProfA0, ekHx,
  ekProfT1, ekHy,
  ekProfA1, ekHz,
  ekProfT2, ekGK,
  ekProfA2, ekNNK1,
  ekProfT3, ekNNK2,
  ekProfA3, ekNGK,
  ekProfT4, ekPS2,
  ekProfA4, ekPS3,
  ekProfT5, ekPS4,
  ekProfA5, ekPS1,
  ekProfT6, ekUGnd,
  ekProfA6, ekURefADC,
  ekProfT7, ekKodkor,
  ekProfA7,  ekURefRes,
  ekProfT8,  ekUpre1,
  ekProfA8,  ekUpre2,
  ekRezerv1, ekUtemp,
  ekRezerv2, ekUres,
  ekRezerv3, ekIres,
  ekRezerv4, psk4Max);
 var
  GDoc: IXMLDocument;
  Root, Wrk, lev1, lev2: IXMLNode;
  procedure AddAllWork;
  begin
    with DeviceInfoIndex, TPars do
     begin
      Wrk.Attributes[AT_SP_HI] := 0;
      Wrk.Attributes[AT_WRKP] := PRO_D_STD;
      Wrk.Attributes[AT_FLOWINTERVAL] := 1200;
        AddParam(Wrk, '�����', var_ui2_kadr_psk4, Integer(ekNhi),'WT');
          lev1 := AddTree(Wrk, '��');
            lev2 := AddTree(lev1, '�����');
              AddParam(lev2, 'Z1', var_i2_15b, Integer(ekKS1));
              AddParam(lev2, 'Z2', var_i2_15b, Integer(ekKS2));
              AddParam(lev2, 'Z3', var_i2_15b, Integer(ekKS3));
              AddParam(lev2, 'Z4', var_i2_15b, Integer(ekKS4));
            lev2 := AddTree(lev1, '�����');
              AddParam(lev2, 'Z1', var_i2_15b, Integer(ekKS1_4));
              AddParam(lev2, 'Z2', var_i2_15b, Integer(ekKS2_4));
              AddParam(lev2, 'Z3', var_i2_15b, Integer(ekKS3_4));
              AddParam(lev2, 'Z4', var_i2_15b, Integer(ekKS4_4));
            lev2 := AddTree(lev1, '��');
              AddParam(lev2, 'Z1', var_i2_15b, Integer(ekPS1));
              AddParam(lev2, 'Z2', var_i2_15b, Integer(ekPS2));
              AddParam(lev2, 'Z3', var_i2_15b, Integer(ekPS3));
              AddParam(lev2, 'Z4', var_i2_15b, Integer(ekPS4));
            AddParam(lev1, 'I', var_i2_15b, Integer(ekI));
          lev1 := AddTree(Wrk, '��');
            AddParam(lev1, 'T0', var_i2_15b, Integer(ekIKT0));
            AddParam(lev1, 'T1', var_i2_15b, Integer(ekIKT1));
            AddParam(lev1, 'T2', var_i2_15b, Integer(ekIKT2));
            AddParam(lev1, 'T3', var_i2_15b, Integer(ekIKT3));
            AddParam(lev1, 'T4', var_i2_15b, Integer(ekIKT4));
            AddParam(lev1, 'T5', var_i2_15b, Integer(ekIKT5));
          lev1 := AddTree(Wrk, 'Inclin');
            lev2 := AddTree(lev1, 'accel');
              AddParam(lev2, 'X', var_i2_15b, Integer(ekGx));
              AddParam(lev2, 'Y', var_i2_15b, Integer(ekGy));
              AddParam(lev2, 'Z', var_i2_15b, Integer(ekGz));
            lev2 := AddTree(lev1, 'magnit');
              AddParam(lev2, 'X', var_i2_15b, Integer(ekHx));
              AddParam(lev2, 'Y', var_i2_15b, Integer(ekHy));
              AddParam(lev2, 'Z', var_i2_15b, Integer(ekHz));
            AddParam(lev1, 'T', var_i2_15b, Integer(ekTinkl));
          lev1 := AddTree(Wrk, 'Res');
            AddParam(lev1, 'Uref', var_i2_15b, Integer(ekURefRes));
            AddParam(lev1, 'U', var_i2_15b, Integer(ekUres));
            AddParam(lev1, 'I', var_i2_15b, Integer(ekIres));
          lev1 := AddTree(Wrk, 'Pre');
            AddParam(lev1, 'P1', var_i2_15b, Integer(ekUpre1));
            AddParam(lev1, 'P2', var_i2_15b, Integer(ekUpre2));
          lev1 := AddTree(Wrk, '��');
            AddParam(lev1, '��', var_i2_15b, Integer(ekGK));
            AddParam(lev1, '���1', var_ui2_15b, Integer(ekNNK1));
            AddParam(lev1, '���2', var_ui2_15b, Integer(ekNNK2));
            AddParam(lev1, '���', var_ui2_15b, Integer(ekNGK));
        AddParam(Wrk, 'Utemp', var_i2_15b, Integer(ekUtemp));
        AddParam(Wrk, 'UGng', var_ui2_15b, Integer(ekUGnd));
        AddParam(Wrk, 'URefADC', var_ui2_15b, Integer(ekURefADC));
        AddParam(Wrk, 'KodKor', var_ui2_15b, Integer(ekKodkor));
          lev1 := AddTree(Wrk, 'Prof');
            AddParam(lev1, 'T0', var_ui2_15b, Integer(ekProfT0));
            AddParam(lev1, 'A0', var_ui2_15b, Integer(ekProfA0));
            AddParam(lev1, 'T1', var_ui2_15b, Integer(ekProfT1));
            AddParam(lev1, 'A1', var_ui2_15b, Integer(ekProfA1));
            AddParam(lev1, 'T2', var_ui2_15b, Integer(ekProfT2));
            AddParam(lev1, 'A2', var_ui2_15b, Integer(ekProfA2));
            AddParam(lev1, 'T3', var_ui2_15b, Integer(ekProfT3));
            AddParam(lev1, 'A3', var_ui2_15b, Integer(ekProfA3));
            AddParam(lev1, 'T4', var_ui2_15b, Integer(ekProfT4));
            AddParam(lev1, 'A4', var_ui2_15b, Integer(ekProfA4));
            AddParam(lev1, 'T5', var_ui2_15b, Integer(ekProfT5));
            AddParam(lev1, 'A5', var_ui2_15b, Integer(ekProfA5));
            AddParam(lev1, 'T6', var_ui2_15b, Integer(ekProfT6));
            AddParam(lev1, 'A6', var_ui2_15b, Integer(ekProfA6));
            AddParam(lev1, 'T7', var_ui2_15b, Integer(ekProfT7));
            AddParam(lev1, 'A7', var_ui2_15b, Integer(ekProfA7));
            AddParam(lev1, 'T8', var_ui2_15b, Integer(ekProfT8));
            AddParam(lev1, 'A8', var_ui2_15b, Integer(ekProfA8));
          lev1 := AddTree(Wrk, 'rezerv');
            AddParam(lev1, 'R1', var_ui2_15b, Integer(ekRezerv1));
            AddParam(lev1, 'R2', var_ui2_15b, Integer(ekRezerv2));
            AddParam(lev1, 'R3', var_ui2_15b, Integer(ekRezerv3));
            AddParam(lev1, 'R4', var_ui2_15b, Integer(ekRezerv4));
     end;
  end;
begin
   GDoc := NewXMLDocument();
   GDoc.DocumentElement := GDoc.AddChild('DEVICE');
   GDoc.DocumentElement.Attributes[AT_SIZE] := 0;
   with DeviceInfoIndex do
    begin
     Root := DeviceInfoIndex.Create(GDoc.DocumentElement, ADR_PSK4, 'PSK4', 'PSK4 �������� ���������');
      Wrk := AddTree(Root,'WRK', '', Integer(psk4Max)*2);
      AddAllWork();
      Wrk := AddTree(Root,'RAM', '', Integer(psk4Max)*2);
      Wrk.Attributes[AT_RAMSIZE] := 5;
      Wrk.Attributes[AT_RAMLP] := PRO_L_STD;
      AddAllWork();
    end;
  Result := GDoc.DocumentElement;
  GDoc.SaveToFile(ExtractFilePath(ParamStr(0)) + 'PSK4Info.xml');
end;

function GetGLUInfo(): IXMLNode;
 var
  GDoc: IXMLDocument;
  Root, Wrk, lev1: IXMLNode;
begin
  GDoc := NewXMLDocument();
  GDoc.DocumentElement := GDoc.AddChild('DEVICE');
  GDoc.DocumentElement.Attributes[AT_SIZE] := 0;
   with DeviceInfoIndex, TPars do
    begin
     Root := DeviceInfoIndex.Create(GDoc.DocumentElement, ADR_GLUBIONMER, '��45', '��-45 �������� ���������');
      Wrk := AddTree(Root,'WRK', '', 14);
      Wrk.Attributes[AT_WRKP] := PRO_D_GLU;
       AddParam(Wrk, '�����', var_inv_i3, 0, 'WT_GLU_PSK');
          lev1 := AddTree(Wrk, '����������', 'RP45');
          AddParam(lev1, '����������', var_inv_ui3_ltr, 3);
          AddParam(lev1, '��������', var_inv_word, 12);
      Wrk := AddTree(Root,'RAM', '', 14);
      Wrk.Attributes[AT_RAMSIZE] := 5;
      Wrk.Attributes[AT_RAMLP] := PRO_L_GLU;
       AddParam(Wrk, '�����', var_inv_i3, 0, 'WT_GLU_PSK');
          lev1 := AddTree(Wrk, '����������', 'RP45');
          AddParam(lev1, '����������', var_inv_ui3_ltr, 3);
          AddParam(lev1, '��������', var_inv_word, 12);
    end;
  Result := GDoc.DocumentElement;
  GDoc.SaveToFile(ExtractFilePath(ParamStr(0)) + 'GLUInfo.xml');
end;

function GetUSOInfo(): IXMLNode;
 var
  GDoc: IXMLDocument;
  Root, Wrk: IXMLNode;
begin
   GDoc := NewXMLDocument();
   GDoc.DocumentElement := GDoc.AddChild('DEVICE');
   GDoc.DocumentElement.Attributes[AT_SIZE] := 0;
   with DeviceInfoIndex, TPars do
    begin
     Root := DeviceInfoIndex.Create(GDoc.DocumentElement, ADR_USO, '���', '��� �������� ����������� ���������');
     Wrk := AddTree(Root,'WRK', '', 4*2);
     Wrk.Attributes[AT_WRKP] := PRO_D_USO;
       AddParam(Wrk, '�����', varSmallint, 0, 'WT_USO_PSK');
       AddParam(Wrk, '�������_�������', varWord, 1);
       AddParam(Wrk, '�������_������', varWord, 2);
       AddParam(Wrk, '��������', varWord, 3);
    end;
  Result := GDoc.DocumentElement;
  GDoc.SaveToFile(ExtractFilePath(ParamStr(0)) + 'USOInfo.xml');
end;

function GetPSKInfo(Addr: Byte): IXMLNode;
begin
  case addr of
   ADR_USO:                Result := GetUSOInfo();
   ADR_GLUBIONMER:         Result := GetGLUInfo();
   ADR_AP:                 Result := GetAPInfo();
   ADR_AK_XMEGA_LOC_NOISE: Result := GetAKXLNInfo();
   ADR_PSK4:               Result := GetPSK4Info();
   ADR_AK60:               Result := GetAK60Info();
   else                    Result := nil;
  end
end;

{function GetPSKInfo(Addr: Byte): IXMLNode;
 var
  SearchRec: TSearchRec;
  Found: integer;
  GDoc: IXMLDocument;
begin
  Result := nil;
  GDoc := NewXMLDocument();
  Found := FindFirst(ExtractFilePath(ParamStr(0))+ 'Devices' +'\*.xml', faAnyFile, SearchRec);
  while Found = 0 do
   begin
    GDoc.LoadFromFile(SearchRec.Name);
    if Assigned(FindDev(GDoc.DocumentElement, Addr)) then Exit(GDoc.DocumentElement);
    Found := FindNext(SearchRec);
   end;
end;}
end.
