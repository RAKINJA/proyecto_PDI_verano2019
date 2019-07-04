unit ventana_segmentacion;

{$mode objfpc}{$H+}

interface

uses
	  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
	  Buttons, ComCtrls,LCLintf,funciones_control;

type

	{ Tformulario_segmentacion }
    matrizRGB = Array of Array of Array of Byte;

   	Tformulario_segmentacion = class(TForm)
		boton_ok: TBitBtn;
		boton_cancelar: TBitBtn;
		color_fondo: TColorButton;
		grafico_segmentacion: TImage;
		titulo_segmentacion: TLabel;
		valor_segmentacion: TLabel;
		scroll_segmentacion: TScrollBox;
		estado_segmentacion: TStatusBar;
		apertura_segmentacion: TTrackBar;
		valor_segmentacion1: TLabel;

		procedure color_fondoColorChanged(Sender: TObject);
        procedure FormCreate(Sender: TObject);
   		procedure FormShow(Sender: TObject);
		procedure apertura_segmentacionChange(Sender: TObject);
		procedure apertura_segmentacionMouseUp(Sender: TObject;
			  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

	  	private
            // variables
            alto, ancho, segmentacion : Integer;
            fondo : TColor;

            procedure filtro_segmentacion(matriz : matrizRGB);
	  	public
            imagen_original     : TBitmap;
            matriz_segmentacion : matrizRGB;
	end;

var
	formulario_segmentacion: Tformulario_segmentacion;

implementation

{$R *.lfm}

{ Tformulario_segmentacion }

procedure Tformulario_segmentacion.FormCreate(Sender: TObject);
begin
	imagen_original := TBitmap.Create;
    fondo := Clblack;
    segmentacion := 0;
end;

procedure Tformulario_segmentacion.color_fondoColorChanged(Sender: TObject);
begin
	fondo := color_fondo.ButtonColor;
end;

procedure Tformulario_segmentacion.FormShow(Sender: TObject);
begin
	apertura_segmentacion.Position:=0;
    color_fondo.ButtonColor:=fondo;

    alto  := imagen_original.Height;
    ancho := imagen_original.Width;

    grafico_segmentacion.Picture.Assign(imagen_original);

    SetLength(matriz_segmentacion,alto,ancho,3 );
    cpBMtoMatriz(alto,ancho,matriz_segmentacion,imagen_original);
    //cpMatriztoCanv(alto,ancho,matriz_segmentacion,imagen_original);

    // Aplicar efecto
    filtro_segmentacion(matriz_segmentacion);
    cpMatriztoCanv(alto,ancho,matriz_segmentacion,grafico_segmentacion);
end;

procedure Tformulario_segmentacion.apertura_segmentacionChange(Sender: TObject);
begin
	segmentacion := apertura_segmentacion.Position;
    valor_segmentacion.Caption:=IntToStr(segmentacion);
end;

procedure Tformulario_segmentacion.apertura_segmentacionMouseUp(
	  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    estado_segmentacion.Panels[0].Text:='Cargando, por favor espere...';

	cpBMtoMatriz(alto,ancho,matriz_segmentacion,imagen_original);
    filtro_segmentacion(matriz_segmentacion);
    cpMatriztoCanv(alto,ancho,matriz_segmentacion,grafico_segmentacion);
    //grafico_segmentacion.Picture.Assign(imagen_original);

    estado_segmentacion.Panels[0].Text:='Listo';
end;

procedure Tformulario_segmentacion.filtro_segmentacion( matriz : matrizRGB);
var
    i,j : Integer;
begin

	for i:=0 to alto-1 do begin
    	for j:=0 to ancho-1 do begin;
        	if matriz[i,j,0] <= segmentacion then begin
            	matriz[i,j,2] := GetRvalue(fondo);
                matriz[i,j,1] := GetGValue(fondo);
                matriz[i,j,0] := GetBValue(fondo);
			end;
		end;
	end;
end;

end.

