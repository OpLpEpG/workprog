
  MPBKFileFormat = Record
    Dep: LongInt;                    //�����
    Par: Array [0..61] of LongInt;   //������ K-6
  end;


  FS_Import.Caption := '���� ���������� MPBK';
  FS_Import.CLList.Clear;
{0}   FS_Import.CLList.Add('Gz1');
{1}   FS_Import.CLList.Add('Gz2');
{2}   FS_Import.CLList.Add('Gz3');
{3}   FS_Import.CLList.Add('Gz4');
{4}   FS_Import.CLList.Add('Gz5');
{5}   FS_Import.CLList.Add('Gz6');
{6}   FS_Import.CLList.Add('���,��');
{7}   FS_Import.CLList.Add('PS1,��');

{8}   FS_Import.CLList.Add('Gx,��');
{9}   FS_Import.CLList.Add('Gy,��');
{10}  FS_Import.CLList.Add('Gz,��');
{11}  FS_Import.CLList.Add('Hx,��');
{12}  FS_Import.CLList.Add('Hy,��');
{13}  FS_Import.CLList.Add('Hz,��');
{14}  FS_Import.CLList.Add('��,���/2c');
{15}  FS_Import.CLList.Add('����-25,���/2c');
{16}  FS_Import.CLList.Add('����-50,���/2c');
{17}  FS_Import.CLList.Add('���,���/2c');

{18}  FS_Import.CLList.Add('Ur'); //-U ��������
{19}  FS_Import.CLList.Add('Ir'); //-I ��������
{20}  FS_Import.CLList.Add('Uor');//-U�� ��������
{21}  FS_Import.CLList.Add('P1'); //-U ���1
{22}  FS_Import.CLList.Add('P2'); //-U ���2
{23}  FS_Import.CLList.Add('T');  //-U ����

{24}  FS_Import.CLList.Add('gz1'); //- �������� ����   }
{25}  FS_Import.CLList.Add('gz2'); //- �������� ����   }
{26}  FS_Import.CLList.Add('gz3'); //- �������� ����   } ������ ��������
{27}  FS_Import.CLList.Add('gz4'); //- �������� ����   }
{28}  FS_Import.CLList.Add('gz5'); //- �������� ����   }
{29}  FS_Import.CLList.Add('gz6'); //- �������� ����   }

{30}  FS_Import.CLList.Add('U0'); //-��
{31}  FS_Import.CLList.Add('I10');//-��������
{32}  FS_Import.CLList.Add('I20');//-��������
{33}  FS_Import.CLList.Add('I11');//-�� 1
{34}  FS_Import.CLList.Add('I21');//-�� 1
{35}  FS_Import.CLList.Add('I12');//-�� 2
{36}  FS_Import.CLList.Add('I22');//-�� 2
{37}  FS_Import.CLList.Add('I13');//-�� 3
{38}  FS_Import.CLList.Add('I23');//-�� 3
{39}  FS_Import.CLList.Add('I14');//-�� 4
{40}  FS_Import.CLList.Add('I24');//-�� 4
{41}  FS_Import.CLList.Add('I15');//-�� 5
{42}  FS_Import.CLList.Add('I25');//-�� 5
{43}  FS_Import.CLList.Add('I16');//-�� 6
{44}  FS_Import.CLList.Add('I26');//-�� 6

{45}  FS_Import.CLList.Add('IK1');//-T5 ��-42. ��������� ������� � ������ ����� (L=0.5�) U100k��
{46}  FS_Import.CLList.Add('IK2');//-T1 ��-42. ��������� ������� � �������� ����� (L=1�) U50k��
{47}  FS_Import.CLList.Add('Uo'); //-To ��-42. ��������� U �����
{48}  FS_Import.CLList.Add('Ust');//-T2 ��-42. ��������� ��������-������� �������� ����� U��������_50���
{49}  FS_Import.CLList.Add('Ut'); //-T3 ��-42. ��������� ����������� Ut
{50}  FS_Import.CLList.Add('Ur2');//-T4 ��-42. ��������� ������� � �������������� Up

{51}  FS_Import.CLList.Add('PS2,��');
{52}  FS_Import.CLList.Add('PS3,��');
{53}  FS_Import.CLList.Add('dPS,��');
{54}  FS_Import.CLList.Add('Ti');//-T ��
{55}  FS_Import.CLList.Add('U���,�');
{56}  FS_Import.CLList.Add('Uop');//-��� ��

{57}  FS_Import.CLList.Add('Iop');//-
{58}  FS_Import.CLList.Add('Nop');//-
{59}  FS_Import.CLList.Add('Tzad');//-����� ��������

