unit metodos_proyecto_pid_vha;

{$mode objfpc}{$H+}

interface

uses
		Classes, SysUtils, Dialogs,Math;
type
  	// variables
  	matrizRGB = Array of Array of Array of Byte; // Matriz de MxN para cada canal R,G,B

  	// procedimientos
	procedure filtro_negativo(alto, ancho : Integer; var matriz: matrizRGB);

    procedure filtro_grises_global(alto,ancho : Integer; var matriz: matrizRGB);
    procedure filtro_grises_r(alto,ancho : Integer; var matriz: matrizRGB);
    procedure filtro_grises_g(alto,ancho : Integer; var matriz: matrizRGB);
    procedure filtro_grises_b(alto,ancho : Integer; var matriz: matrizRGB);

    procedure filtro_correcion_gamma(alto,ancho:Integer; var matriz: matrizRGB);

    procedure zoom_in(nuevo_alto,nuevo_ancho : Integer; var matriz : matrizRGB);
    procedure zoom_out(alto,ancho : Integer ; var matriz : matrizRGB);
    procedure girar_izq(alto,ancho : Integer ; var matriz : matrizRGB);
    procedure girar_der(alto,ancho : Integer ; var matriz : matrizRGB);
var
    avance, contador_avance, progreso : Integer;

    // funciones

implementation

procedure filtro_negativo(alto, ancho : Integer; var matriz: matrizRGB);
var
    i,j : Integer;
    k   : Byte;
begin
    // Realizar la operacion del filtro Negativo
    for i:=0 to alto-1 do begin
        for j:=0 to ancho-1 do begin
            for k:=0 to 2 do begin
            	matriz[i,j,k] := 255-matriz[i,j,k]; // Resta de los canales RGB
			end;
		end;
	end;
end; // fin filtro_negativo

procedure filtro_grises_global(alto,ancho : Integer; var matriz: matrizRGB);
var
    i,j,suma,resultado : Integer;
    k   : Byte;
begin
	// Realizar la operacion del filtro en Escala de Grises Global
    for i:=0 to alto-1 do begin
        for j:=0 to ancho-1 do begin
            suma := 0;
            for k:=0 to 2 do begin
            	suma := suma + matriz[i,j,k]; // Resta de los canales RGB
			end;
            resultado := suma div 3;
            matriz[i,j,1] := resultado;
            matriz[i,j,0] := resultado;
            matriz[i,j,2] := resultado;
		end;
	end;
end; // fin filtro_grises_global

procedure filtro_grises_r(alto,ancho : Integer; var matriz: matrizRGB);
var
    i,j : Integer;
    k   : Byte;
begin
	// Realizar la operacion del filtro en Escala de Grises Global
    for i:=0 to alto-1 do begin
        for j:=0 to ancho-1 do begin
            for k:=1 to 2 do begin
            	matriz[i,j,k] := matriz[i,j,0]; // Asigna el canal R
			end;
		end;
	end;
end; // fin filtro_grises_r

procedure filtro_grises_g(alto,ancho : Integer; var matriz: matrizRGB);
var
	i,j : Integer;
	k   : Byte;
begin
    // Realizar la operacion del filtro en Escala de Grises Global
    for i:=0 to alto-1 do begin
        for j:=0 to ancho-1 do begin
            for k:=1 to 2 do begin
            	matriz[i,j,k] := matriz[i,j,1]; // Asigna el Canal G
			end;
    	end;
	end;
end; // fin filtro_grises_g

procedure filtro_grises_b(alto,ancho : Integer; var matriz: matrizRGB);
var
    i,j : Integer;
    k   : Byte;
begin
	// Realizar la operacion del filtro en Escala de Grises Global
    for i:=0 to alto-1 do begin
        for j:=0 to ancho-1 do begin
            for k:=1 to 2 do begin
            	matriz[i,j,k] := matriz[i,j,2]; // Asigna el canal B
			end;
		end;
	end;
end; // fin filtro_grises_b

procedure filtro_correcion_gamma(alto,ancho:Integer; var matriz: matrizRGB);
var
    i,j   :Integer;
    gamma : Double;
    k  	  : Byte;
begin
    gamma := 0.1;
	for i:=0 to alto-1 do begin
        for j:= 0 to ancho-1 do begin
            for k:=0 to 2 do begin
                matriz[i,j,k] := trunc(power(matriz[i,j,k]/255,gamma)*255);
			end;
		end;
	end;
end;

procedure zoom_in(nuevo_alto,nuevo_ancho : Integer; var matriz : matrizRGB);
var
    matriz_aux : matrizRGB;
    i,j,k,y,z,pr,pa,pd : Integer;
    // variables para la diferencia de color
    alto,ancho : Integer;
begin

	alto  := nuevo_alto*2;
    ancho := nuevo_ancho*2;
    SetLength(matriz_aux,alto,ancho,3);
    //ShowMessage('el tamaño de AUX es '+IntToStr(alto)+' y '+IntToStr(ancho));
    // llenado de la matriz auxiliar
    for i:=0 to nuevo_alto-1 do begin
        for j:=0 to nuevo_ancho-1 do begin
        	for k:=0 to 2 do begin
				y := i*2;
                z := j*2;

                if (i = nuevo_alto-1) and (j < nuevo_ancho-1) then begin
                    pr := (matriz[i,j,k]+matriz[i,j+1,k])div 2;
                    pa := matriz[i,j,k];
                    pd := pr;
                end;

                if (i < nuevo_alto-1) and (j = nuevo_ancho-1) then begin
                    pa := (matriz[i,j,k]+matriz[i+1,j,k]) div 2;
                    pr := matriz[i,j,k];
                	pd := pa

                end;

                if (i < nuevo_alto-1) and (j < nuevo_ancho-1) then begin
                  	pr := (matriz[i,j,k] + matriz [i,j+1,k]) div 2;
                	pa := (matriz[i,j,k] + matriz [i+1,j,k]) div 2;
                	pd := (matriz[i,j,k] + matriz [i+1,j+1,k]) div 2;
                end;

                if (i = nuevo_alto-1) and (j = nuevo_alto-1) then begin
                	pr := matriz[i,j,k] + (matriz[i,j,k]-matriz[i-1,j,k]);
                    pa := matriz[i,j,k] + (matriz[i,j,k]-matriz[i,j-1,k]);
                    pd := matriz[i,j,k] + (matriz[i,j,k]-matriz[i-1,j-1,k]);
                end;

                matriz_aux[y,z,k]     := matriz[i,j,k];
               	matriz_aux[y,z+1,k]   := pr;
               	matriz_aux[y+1,z,k]   := pa;
				matriz_aux[y+1,z+1,k] := pd;

                //ShowMessage('-> [ '+IntToStr(i)+' | '+IntToStr(j)+' | '+IntToStr(k)+' ]= '+IntToStr(matriz_aux[y,z,k])+' | '+IntToStr(matriz_aux[y,z+1,k])+' | '+IntToStr(matriz_aux[y+1,z,k])+' | '+IntToStr(matriz_aux[y+1,z+1,k]));
            end;
        end;
    end;

    // reescalar la matriz principal
    SetLength(matriz,nuevo_alto*2,nuevo_ancho*2,3);
    //ShowMessage('el tamaño de la MATRIZ PRINCIPAL ES '+IntToStr(alto)+' y '+IntToStr(ancho));
    // copiar matriz_aux a matriz principal
    for i:=0 to alto-1 do begin
        for j:=0 to ancho-1 do begin
            for k:=0 to 2 do begin
                matriz[i,j,k] := matriz_aux[i,j,k];
                //ShowMessage('-> [ '+IntToStr(i)+' | '+IntToStr(j)+' | '+IntToStr(k)+' ]= '+IntToStr(matriz_aux[i,j,k]));
            end;
        end;
	end;

end;

procedure zoom_out(alto,ancho : Integer ; var matriz : matrizRGB);
var
    matriz_aux : matrizRGB;
    i,j,k,y,z  : Integer;
    nuevo_alto,nuevo_ancho : Integer;
begin

    nuevo_alto  := alto div 2;
    nuevo_ancho := ancho div 2;
    SetLength(matriz_aux,(nuevo_alto), (nuevo_ancho), 3);
	ShowMessage('el tamaño de AUX es '+IntToStr(nuevo_alto)+' y '+IntToStr(nuevo_ancho));
	for i:=0 to nuevo_alto-1 do begin
		for j:= 0 to nuevo_ancho-1 do begin
            for k:=0 to 2 do begin
                y := 2*i;
                z := 2*j;
            	matriz_aux[i,j] := matriz[y,z];
            end;
        end;
    end;

    SetLength(matriz,(alto div 2),(ancho div 2),3);

    for i:=0 to nuevo_alto-1 do begin
		for j:= 0 to nuevo_ancho-1 do begin
            for k:=0 to 2 do begin
            	matriz[i,j] := matriz_aux[i,j];
            end;
        end;
    end;
end;

procedure girar_izq(alto,ancho : Integer ; var matriz : matrizRGB);
var
    matriz_aux : matrizRGB;
    i,j,k,X : Integer;
    al,an : Integer;
begin

    al := ancho;
    an := alto;

    SetLength(matriz_aux,al,an,3);
    for i:=0 to al-1 do begin
        for j:=0 to an-1 do begin
            for k:=0 to 2 do begin
                X := (ancho-1)-i;
            	matriz_aux[i,j,k] := matriz[j,X,k];
            end;
            //ShowMessage('-> [ '+IntToStr(i)+' | '+IntToStr(j)+' ]= '+IntToStr(j)+' | '+IntToStr(X));
        end;
    end;

    SetLength(matriz,al,an,3);
    for i:=0 to al-1 do begin
        for j:=0 to an-1 do begin
            for k:=0 to 2 do begin
                matriz[i,j,k] := matriz_aux[i,j,k];
            end;
        end;
    end;
end;

procedure girar_der(alto,ancho : Integer ; var matriz : matrizRGB);
var
	matriz_aux : matrizRGB;
    i,j,k,X : Integer;
    al,an : Integer;
begin

    al := ancho;
    an := alto;

    SetLength(matriz_aux,al,an,3);

    for i:=0 to al-1 do begin
    	for j:=0 to an-1 do begin
            for k:=0 to 2 do begin
                X := (alto-1)-j;
                //ShowMessage('-> [ '+IntToStr(i)+' | '+IntToStr(j)+' ]= '+IntToStr(i)+' | '+IntToStr(j));
            	matriz_aux[i,j,k] := matriz[X,i,k];
            end;
        end;
    end;

    SetLength(matriz,al,an,3);
    for i:=0 to al-1 do begin
        for j:=0 to an-1 do begin
            for k:=0 to 2 do begin
                matriz[i,j,k] := matriz_aux[i,j,k];
            end;
        end;
    end;
end;

end.

