unit Unit5_Dav;
  ca1 := Dpar[4]*Dpar[1]+Dpar[6]*Dpar[2];
  ca2 := Dpar[3]*Dpar[1]+Dpar[5]*Dpar[2];

  SV := TPrimeIgps5File.Create;
  SV.LoadFromFile(AA.PathName);
  AA.RecCount := SV.RecCount;
  k := SV.RecCount-1;
  for i:= 0 to k do begin
      AA.Depth[i] := SV[k-i].Dep;
      AA[i] := 0;
      Uor:= SV[i].Par[25];
      if Uor <> 0 then begin
        P1 := SV[i].Par[26];
        P2 := SV[i].Par[27];
        Rm := 5*P1/(0.06*Uor);
        Rp := (5+5*P2/(4*Uor))/0.0006;
        a3 := Dpar[1]+Dpar[2]-Rp;
        if (ca2*ca2-4*ca1*a3) >= 0 then begin
          dT := (-ca2+SQRT(ca2*ca2-4*ca1*a3))/(2*ca1);
          a1 := Rm-Dpar[1]*(1+Dpar[3]*dT+Dpar[4]*dT*dT)+Dpar[2]*(1+Dpar[5]*dT+Dpar[6]*dT*dT);
          a2 := Dpar[1]*Dpar[7]*(1+Dpar[9]*dT)*(1+Dpar[3]*dT+Dpar[4]*dT*dT);
          a3 := Dpar[2]*Dpar[8]*(1+Dpar[10]*dT)*(1+Dpar[5]*dT+Dpar[6]*dT*dT);
          if a2 <> a3
           then AA[i] := a1/(a2-a3);
        end;
      end;
    end;
end.

//-Температура

      Uor:= SV[k-i].Par[25];
      Nx := SV[k-i].Par[28];
      if Uor <> 0
        then Rt := Rop/2+25*Nx/Uor
        else Rt := 0;
      AA[i] := (Rt-100)/0.385;

  //-Резистивиметр
  MNK(UIr, RSo, AVm, BVm, 0,  5);
    for i:= 0 to SV.RecCount-1 do begin
      AA.Depth[i] := SV[i].Dep;
      if SV[i].Par[24] <> 0
        then X := SV[i].Par[23]/SV[i].Par[24]
        else X := 0;
      AA[i] := AVm + BVm*X;
    end;


  Sgx := Met[0];  Sgy := Met[1];  Sgz := Met[2];
  Kgx := Met[3];  Kgy := Met[4];  Kgz := Met[5];
  Gxy := Pi*Met[6]/180;
  Gxz := Pi*Met[7]/180;
  Gyz := Pi*Met[8]/180;
  Gzx := Pi*Met[9]/180;
  Gzy := Pi*Met[10]/180;
  AA.RecCount := B10.RecCount;
  Count := B10.RecCount-1;
  if AA.format = 'PSK2'
     then Kff := 1
     else Kff := 8;
  for i := 0 to Count do begin
    AA.Depth[i] := B10.Depth[i];
    Gx := (B10.Value[i]-Sgx*Kff)/Kgx;  //Sgx*8 - для ПСК-3
    Gy := (B14.Value[i]-Sgy*Kff)/Kgy;  //Sgy*8 - для ПСК-3
    Gz := (B5.Value[i]-Sgz*Kff)/Kgz;   //Sgz*8 - для ПСК-3

{    Gx0:= Gx*(1+Gyz*Gzy)-Gy*(Gxy-Gxz*Gzy)+Gz*(Gxy*Gyz+Gxz);
    Gy0:= Gx*Gyz*Gzx+Gy*(1+Gxz*Gzx)-Gz*Gyz;
    Gz0:=-Gx*Gzx+Gy*(Gxy*Gzx+Gzy)+Gz;}

    Gx0:= Gx - Gy*Gxy + Gz*Gxz;
    Gy0:= Gy - Gz*Gyz;
    Gz0:= Gz - Gx*Gzx + Gy*Gzy;

    G0 := Sqrt(Gx0*Gx0+Gy0*Gy0);



  Sgx := Met[0];
  Sgy := Met[1];
  Sgz := Met[2];
  Kgx := Met[3];
  Kgy := Met[4];
  Kgz := Met[5];
  Gxy := Met[6];    Gxy := Pi*Gxy/180;
  Gxz := Met[7];    Gxz := Pi*Gxz/180;
  Gyz := Met[8];    Gyz := Pi*Gyz/180;
  Gzx := Met[9];    Gzx := Pi*Gzx/180;
  Gzy := Met[10];   Gzy := Pi*Gzy/180;
  Shx := Met[11];
  Shy := Met[12];
  Shz := Met[13];
  Khx := Met[14];
  Khy := Met[15];
  Khz := Met[16];
  Hxy := Met[17];   Hxy := Pi*Hxy/180;
  Hxz := Met[18];   Hxz := Pi*Hxz/180;
  Hyx := Met[19];   Hyx := Pi*Hyx/180;
  Hyz := Met[20];   Hyz := Pi*Hyz/180;
  Hzx := Met[21];   Hzx := Pi*Hzx/180;
  Hzy := Met[22];   Hzy := Pi*Hzy/180;



  if AA.format = 'PSK2'
     then Kff := 1
     else Kff := 8;
  for i := 0 to Count do begin
    AA.Depth[i] := B11.Depth[i];
    Hx:=(B13.Value[i]-Shx)/Khx;
    Hy:=(B11.Value[i]-Shy)/Khy;
    Hz:=(B12.Value[i]-Shz)/Khz;

    Gx := (B10.Value[i]-Sgx*Kff)/Kgx;
    Gy := (B14.Value[i]-Sgy*Kff)/Kgy;
    Gz := (B5.Value[i]-Sgz*Kff)/Kgz;
    Gx0:= Gx - Gy*Gxy + Gz*Gxz;
    Gy0:= Gy - Gz*Gyz;
    Gz0:=-Gx*Gzx + Gy*Gzy + Gz;
    G0 := Sqrt(Gx0*Gx0+Gy0*Gy0);

    Hx0:= Hx - Hy*Hxy + Hz*Hxz;
    Hy0:= Hx*Hyx + Hy - Hz*Hyz;
    Hz0:=-Hx*Hzx + Hy*Hzy + Hz;

    if (G0<=abs(Gz0))and (Gz0>0)  then Zenit:=arctan(G0/abs(Gz0));
    if (G0>abs(Gz0)) and (Gz0>=0) then Zenit:=Pi/2-arctan(abs(Gz0)/G0);
    if (G0>abs(Gz0)) and (Gz0<0)  then Zenit:=Pi/2+arctan(abs(Gz0)/G0);
    if (G0<=abs(Gz0))and (Gz0<0)  then Zenit:=Pi-arctan(G0/abs(Gz0));

    if (Gy0=0) and (Gx0=0)  then Wiz:=0;
    if (Gy0>=0)and (Gx0<0)  then Wiz:=arctan(abs(Gy0/Gx0));
    if (Gy0>0) and (Gx0>=0) then Wiz:=Pi/2+arctan(abs(Gx0/Gy0));
    if (Gy0<=0)and (Gx0>0)  then Wiz:=Pi+arctan(abs(Gy0/Gx0));
    if (Gy0<0) and (Gx0<=0) then Wiz:=3*Pi/2+arctan(abs(Gx0/Gy0));

    H1:=-Hx0*Sin(Wiz)-Hy0*cos(Wiz);
    H2:= Hz0*sin(Zenit)-(-Hx0*cos(Wiz)+Hy0*sin(Wiz))*cos(Zenit);
    if (H1>=0)and (H2>0)  then Azim:=arcTan(abs(H1/H2));
    if (H1>0) and (H2<=0) then Azim:=arcTan(abs(H2/H1))+Pi/2;
    if (H1<=0)and (H2<0)  then Azim:=arcTan(abs(H1/H2))+Pi;
    if (H1<0) and (H2>=0) then Azim:=arcTan(abs(H2/H1))+3*Pi/2;

    AA.Value[i] := (180/Pi)*Azim;

