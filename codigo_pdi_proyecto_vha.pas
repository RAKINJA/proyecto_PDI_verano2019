unit codigo_pdi_proyecto_vha;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ExtCtrls, stdCtrls,
  ExtDlgs, LCLintf, ComCtrls;

type

  { Tformulario_principal }

	matrizRGB = Array of Array of Array of Byte; // Matriz de MxN para cada canal R,G,B

  Tformulario_principal = class(TForm)
    grafico: TImage;
    MenuItem1: TMenuItem;
    opcion_abrir_imagen: TMenuItem;
    opcion_guardar_imagen: TMenuItem;
    menu_filtros: TMenuItem;
    opcion_negativo: TMenuItem;
    opcion_grises: TMenuItem;
    menu_principal: TMainMenu;
    abrir_imagen: TOpenPictureDialog;
    cuadro_scroll: TScrollBox;
    procedure FormCreate(Sender: TObject);
    procedure opcion_abrir_imagenClick(Sender: TObject);
	procedure opcion_negativoClick(Sender: TObject);

  private

  public

	procedure cpCanvtoMatriz(alto,ancho:Integer; var Matriz:matrizRGB);
	procedure cpMatriztoCanv(alto,ancho:Integer);

	procedure cpBMtoMatriz(alto, ancho:Integer ; var Matriz:matrizRGB; bmp:TBitmap);
	procedure cpMatriztoBM(alto, ancho:Integer ; Matriz:matrizRGB; var bmp:TBitmap);

  end;

var
  formulario_principal: Tformulario_principal;

	// VARIABLES
	bitmap:Tbitmap;
	matRGB : matrizRGB;
	alto_img, ancho_img : Integer; // alto y ancho de la imagen

implementation

{$R *.lfm}

{ Tformulario_principal }
procedure Tformulario_principal.FormCreate(Sender: TObject);
begin
	// Asignacion de tamaño del ScrollBox
	cuadro_scroll.SetBounds(0,0,600,500);

	// Asignacion de tamaño del IImage
	grafico.Width:=600;
	grafico.Height:=450;

	bitmap := TBitmap.Create; // creacion del objeto de tipo Bitmap
end;

procedure Tformulario_principal.opcion_abrir_imagenClick(Sender: TObject);
begin
	if abrir_imagen.Execute then begin
		grafico.Enabled:=True; // habilitar el TImage
        if bitmap.PixelFormat<> Pf24bit then //si no es de 8 bits por canal
    	begin
       		bitmap.PixelFormat:=Pf24bit;
    	end;

        bitmap.LoadFromFile(abrir_imagen.FileName); // cargar imagen

        alto_img := bitmap.Height; ancho_img := bitmap.Width; // Se actualiza el alto y ancho del bitmap conforme a la imagen
        grafico.Height := bitmap.Height;; grafico.Width := bitmap.Width; // Se actualiza el alto y ancho del Canvas conforme a la imagen

		SetLength(matRGB,alto_img,ancho_img,3); // Reserva el espacio para la matrizRGB

		cpBMtoMatriz(alto_img,ancho_img,matRGB,bitmap); // llama a la funcion para cargar la Imagen al Bitmap
        grafico.Picture.Assign(bitmap); // Asigna el contenido del bitmap a Canvas del TImage
    end;
end;

procedure Tformulario_principal.opcion_negativoClick(Sender: TObject);
var
    i,j : Integer;
    k   : Byte;
begin
	cpCanvtoMatriz(alto_img,ancho_img,matRGB); // Cargar la informacion de la Imagen en el Bitman

    // Realizar la operacion del filtro Negativo
    for i:=0 to alto_img-1 do begin
        for j:=0 to ancho_img-1 do begin
            for k:=0 to 2 do begin
            	matRGB[i,j,k] := 255-matRGB[i,j,k]; // Resta de los canales RGB
			end;
		end;
	end;

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap); // Carga la matriz al Bitmap
    //grafico.Picture.Assign(bitmap); // Carga la matriz al Canvas para su visualizacion
    cpMatriztoCanv(alto_img,ancho_img);
end;

procedure Tformulario_principal.cpCanvtoMatriz(alto,ancho:Integer; var Matriz:matrizRGB);
var
    i,j : Integer;
    cl  : TColor;
begin
	for i:=0 to alto-1 do begin
        for j:=0 to ancho-1 do begin
            cl            := grafico.Canvas.Pixels[i,j];
			Matriz[i,j,0] := GetRValue(cl); // Valor del Canal R
            Matriz[i,j,1] := GetGValue(cl); // Valor del Canal G
            Matriz[i,j,2] := GetBValue(cl); // Valor del Canal B
		end;
	end;
end;

procedure Tformulario_principal.cpMatriztoCanv(alto,ancho:Integer);
var
    i,j : Integer;
    cl  : TColor;
begin
	for i:=0 to alto-1 do begin
        for j:=0 to ancho-1 do begin
        	cl := RGB(matRGB[i,j,0],matRGB[i,j,1],matRGB[i,j,2]);
            grafico.Canvas.Pixels[i,j]:=cl;
		end;
	end;
end;

procedure Tformulario_principal.cpBMtoMatriz(alto, ancho:Integer ; var Matriz:matrizRGB; bmp:TBitmap);
var
	i,j,k    : Integer;
	pArrByte : PByte;
begin
	for i:=0 to alto-1 do begin // recorre las filas
		bmp.BeginUpdate;
        	pArrByte := bmp.ScanLine[i]; // obtiene la posicion de memoria del primer elemento de la matriz
		bmp.EndUpdate;                   // cada elemento, al ser un arreglo de 3 dimensiones, contiene el arreglo de los valores RGB
		for j:= 0 to ancho-1 do begin // recorre las columnas
			k := 3*j;
			Matriz[i,j,0] := pArrByte[k];
			Matriz[i,j,1] := pArrByte[k+1];
			Matriz[i,j,2] := pArrByte[k+2];
        end; // end j
    end; // end i
end;

procedure Tformulario_principal.cpMatriztoBM(alto, ancho:Integer ; Matriz:matrizRGB; var bmp:TBitmap);
var
    i,j,k      : Integer;
    pArrayByte : PByte;
begin
    for i:= 0 to alto-1 do begin
        bmp.BeginUpdate;
        	pArrayByte := bmp.ScanLine[i];
        bmp.EndUpdate;
        for j:=0 to ancho-1 do begin
			k := 3*j;
            pArrayByte[k]   := Matriz[i,j,0];
            pArrayByte[k+1] := Matriz[i,j,1];
            pArrayByte[k+2] := Matriz[i,j,2];
		end;
	end;
end;

end.

