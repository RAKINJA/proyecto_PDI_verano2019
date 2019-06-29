unit funciones_control;

{$mode objfpc}{$H+}

interface

uses
	Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
	ExtCtrls,LCLintf;

type

  	matrizRGB = Array of Array of Array of Byte; // Matriz de MxN para cada canal R,G,B

    procedure cpCanvtoMatriz(alto,ancho:Integer; var matriz:matrizRGB; grafico:TImage);
	procedure cpMatriztoCanv(alto,ancho:Integer; var matriz:matrizRGB; image:TImage);

	procedure cpBMtoMatriz(alto, ancho:Integer ; var Matriz:matrizRGB; bmp:TBitmap);
	procedure cpMatriztoBM(alto, ancho:Integer ; Matriz:matrizRGB; var bmp:TBitmap);

implementation


{
	PROCEDIMIENTOS DE COPIADO
}

procedure cpCanvtoMatriz(alto,ancho:Integer; var matriz:matrizRGB; grafico:TImage);
var
    i,j : Integer;
    cl  : TColor;
begin
    ShowMessage('Copiar Canvas -> Matriz');
	for i:=0 to alto-1 do begin
        for j:=0 to ancho-1 do begin

            cl            := grafico.Canvas.Pixels[j,i];
			matriz[i,j,0] := GetRValue(cl); // Valor del Canal R
            matriz[i,j,1] := GetGValue(cl); // Valor del Canal G
            matriz[i,j,2] := GetBValue(cl); // Valor del Canal B
		end;
	end;
end;

procedure cpMatriztoCanv(alto,ancho:Integer; var matriz:matrizRGB; image:TImage);
var
    i,j : Integer;
    cl  : TColor;
begin
    ShowMessage('Copiar Matriz -> Canvas');
	for i:=0 to alto-1 do begin
        for j:=0 to ancho-1 do begin
        	cl 						 := RGB(matriz[i,j,0],matriz[i,j,1],matriz[i,j,2]);
            image.Canvas.Pixels[j,i] := cl;
		end;
	end;
end;

procedure cpBMtoMatriz(alto, ancho:Integer ; var matriz:matrizRGB; bmp:TBitmap);
var
	i,j,k    : Integer;
	pArrByte : PByte;
begin
    ShowMessage('Copiar Bitmap -> Matriz');
	for i:=0 to alto-1 do begin // recorre las filas
		bmp.BeginUpdate;
        	pArrByte := bmp.ScanLine[i]; // obtiene la posicion de memoria del primer elemento de la matriz
		bmp.EndUpdate;                   // cada elemento, al ser un arreglo de 3 dimensiones, contiene el arreglo de los valores RGB

		for j:=0 to ancho-1 do begin // recorre las columnas
			k := 3*j;
			matriz[i,j,0] := pArrByte[k];
			matriz[i,j,1] := pArrByte[k+1];
			matriz[i,j,2] := pArrByte[k+2];
        end;
    end;
end; // Fin copia Bitmap -> Matriz

procedure cpMatriztoBM(alto, ancho:Integer; matriz:matrizRGB; var bmp:TBitmap);
var
    i,j,k      : Integer;
    pArrayByte : PByte;
begin
    ShowMessage('Copiar Matriz -> Bitmap');
    for i:=0 to alto-1 do begin
        bmp.BeginUpdate;
        	pArrayByte := bmp.ScanLine[i];
        bmp.EndUpdate;

        for j:=0 to ancho-1 do begin
			k := 3*j;
            pArrayByte[k]   := matriz[i,j,0];
            pArrayByte[k+1] := matriz[i,j,1];
            pArrayByte[k+2] := matriz[i,j,2];
		end;
	end;
end; // fin copia Matriz -> Bitmap

end.

