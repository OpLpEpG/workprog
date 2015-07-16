
  MPBKFileFormat = Record
    Dep: LongInt;                    //Время
    Par: Array [0..61] of LongInt;   //формат K-6
  end;


  FS_Import.Caption := 'Файл информации MPBK';
  FS_Import.CLList.Clear;
{0}   FS_Import.CLList.Add('Gz1');
{1}   FS_Import.CLList.Add('Gz2');
{2}   FS_Import.CLList.Add('Gz3');
{3}   FS_Import.CLList.Add('Gz4');
{4}   FS_Import.CLList.Add('Gz5');
{5}   FS_Import.CLList.Add('Gz6');
{6}   FS_Import.CLList.Add('Ток,мВ');
{7}   FS_Import.CLList.Add('PS1,мВ');

{8}   FS_Import.CLList.Add('Gx,мВ');
{9}   FS_Import.CLList.Add('Gy,мВ');
{10}  FS_Import.CLList.Add('Gz,мВ');
{11}  FS_Import.CLList.Add('Hx,мВ');
{12}  FS_Import.CLList.Add('Hy,мВ');
{13}  FS_Import.CLList.Add('Hz,мВ');
{14}  FS_Import.CLList.Add('ГК,имп/2c');
{15}  FS_Import.CLList.Add('ННКт-25,имп/2c');
{16}  FS_Import.CLList.Add('ННКт-50,имп/2c');
{17}  FS_Import.CLList.Add('НГК,имп/2c');

{18}  FS_Import.CLList.Add('Ur'); //-U резистив
{19}  FS_Import.CLList.Add('Ir'); //-I резистив
{20}  FS_Import.CLList.Add('Uor');//-Uоп резистив
{21}  FS_Import.CLList.Add('P1'); //-U дав1
{22}  FS_Import.CLList.Add('P2'); //-U дав2
{23}  FS_Import.CLList.Add('T');  //-U темп

{24}  FS_Import.CLList.Add('gz1'); //- Градиент зонд   }
{25}  FS_Import.CLList.Add('gz2'); //- Градиент зонд   }
{26}  FS_Import.CLList.Add('gz3'); //- Градиент зонд   } грубый диапазон
{27}  FS_Import.CLList.Add('gz4'); //- Градиент зонд   }
{28}  FS_Import.CLList.Add('gz5'); //- Градиент зонд   }
{29}  FS_Import.CLList.Add('gz6'); //- Градиент зонд   }

{30}  FS_Import.CLList.Add('U0'); //-БК
{31}  FS_Import.CLList.Add('I10');//-смещение
{32}  FS_Import.CLList.Add('I20');//-смещение
{33}  FS_Import.CLList.Add('I11');//-БК 1
{34}  FS_Import.CLList.Add('I21');//-БК 1
{35}  FS_Import.CLList.Add('I12');//-БК 2
{36}  FS_Import.CLList.Add('I22');//-БК 2
{37}  FS_Import.CLList.Add('I13');//-БК 3
{38}  FS_Import.CLList.Add('I23');//-БК 3
{39}  FS_Import.CLList.Add('I14');//-БК 4
{40}  FS_Import.CLList.Add('I24');//-БК 4
{41}  FS_Import.CLList.Add('I15');//-БК 5
{42}  FS_Import.CLList.Add('I25');//-БК 5
{43}  FS_Import.CLList.Add('I16');//-БК 6
{44}  FS_Import.CLList.Add('I26');//-БК 6

{45}  FS_Import.CLList.Add('IK1');//-T5 ИК-42. Измерение сигнала с малого зонда (L=0.5м) U100kГц
{46}  FS_Import.CLList.Add('IK2');//-T1 ИК-42. Измерение сигнала с большого зонда (L=1м) U50kГц
{47}  FS_Import.CLList.Add('Uo'); //-To ИК-42. Измерение U земли
{48}  FS_Import.CLList.Add('Ust');//-T2 ИК-42. Измерение стандарт-сигнала большого зонда Uстандарт_50кГц
{49}  FS_Import.CLList.Add('Ut'); //-T3 ИК-42. Измерение температуры Ut
{50}  FS_Import.CLList.Add('Ur2');//-T4 ИК-42. Измерение сигнала с резистивиметра Up

{51}  FS_Import.CLList.Add('PS2,мВ');
{52}  FS_Import.CLList.Add('PS3,мВ');
{53}  FS_Import.CLList.Add('dPS,мВ');
{54}  FS_Import.CLList.Add('Ti');//-T ЦП
{55}  FS_Import.CLList.Add('Uбат,В');
{56}  FS_Import.CLList.Add('Uop');//-АЦП БК

{57}  FS_Import.CLList.Add('Iop');//-
{58}  FS_Import.CLList.Add('Nop');//-
{59}  FS_Import.CLList.Add('Tzad');//-Время задержки

