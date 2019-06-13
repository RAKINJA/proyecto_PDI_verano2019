unit metodos_proyecto_pid_vha;

{$mode objfpc}{$H+}

interface

uses
		Classes, SysUtils, Dialogs;
type
  	// variables
  	matrizRGB = Array of Array of Array of Byte; // Matriz de MxN para cada canal R,G,B

  	// procedimientos
	procedure filtro_negativo(alto, ancho : Integer; var matriz: matrizRGB);

    procedure filtro_grises_global(alto,ancho : Integer; var matriz: matrizRGB);
    procedure filtro_grises_r(alto,ancho : Integer; var matriz: matrizRGB);
    procedure filtro_grises_g(alto,ancho : Integer; var matriz: matrizRGB);
    procedure filtro_grises_b(alto,ancho : Integer; var matriz: matrizRGB);

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
end;

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
end;

procedure filtro_grises_r(alto,ancho : Integer; var matriz: matrizRGB);
begin
	var
    i,j : Integer;
    k   : Byte;
begin
	// Realizar la operacion del filtro en Escala de Grises Global
    for i:=0 to alto-1 do begin
        for j:=0 to ancho-1 do begin
            for k:=0 to 2 do begin
            	matriz[i,j,k] := matriz[i,j,0]; // Asigna el canal R
			end;
		end;
	end;
end;

procedure filtro_grises_g(alto,ancho : Integer; var matriz: matrizRGB);
var
	i,j : Integer;
	k   : Byte;
begin
    // Realizar la operacion del filtro en Escala de Grises Global
    for i:=0 to alto-1 do begin
        for j:=0 to ancho-1 do begin
            for k:=0 to 2 do begin
            	matriz[i,j,k] := matriz[i,j,1]; // Asigna el Canal G
			end;
    	end;
	end;
end;

procedure filtro_grises_b(alto,ancho : Integer; var matriz: matrizRGB);
var
    i,j : Integer;
    k   : Byte;
begin
	// Realizar la operacion del filtro en Escala de Grises Global
    for i:=0 to alto-1 do begin
        for j:=0 to ancho-1 do begin
            for k:=0 to 2 do begin
            	matriz[i,j,k] := matriz[i,j,2]; // Asigna el canal B
			end;
		end;
	end;
end;

end.

