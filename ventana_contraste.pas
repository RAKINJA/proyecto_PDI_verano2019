unit ventana_contraste;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, Buttons,
    ExtCtrls, StdCtrls,metodos_proyecto_pid_vha, Math,funciones_control;

type

    { Tformulario_contraste }

    matrizRGB = Array of Array of Array of Byte;

    Tformulario_contraste = class(TForm)
        btn_ok: TBitBtn;
        btn_cancelar: TBitBtn;
        grafico_contraste: TImage;
        Label1: TLabel;
        Label2: TLabel;
        Label3: TLabel;
        estado_contraste: TStatusBar;
        titulo_contraste: TLabel;
        valor_contraste: TLabel;
        scroll_contraste: TScrollBox;
        apertura_contraste: TTrackBar;
        procedure apertura_contrasteChange(Sender: TObject);
        procedure apertura_contrasteMouseUp(Sender: TObject;
            Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
        procedure FormCreate(Sender: TObject);
        procedure FormShow(Sender: TObject);
    private
        procedure filtro_contraste(matriz : matrizRGB);

    public
        // variables
        matriz_contraste : matrizRGB;
        imagen_original,bmp_contraste : TBitmap;

        contraste : Double;
        // procedimientos


    end;

var
    formulario_contraste: Tformulario_contraste;

    alto, ancho : Integer;
implementation

{$R *.lfm}

{ Tformulario_contraste }


procedure Tformulario_contraste.FormCreate(Sender: TObject);
begin
	imagen_original := TBitmap.Create;
end;

procedure Tformulario_contraste.FormShow(Sender: TObject);
begin
	alto  := grafico_contraste.Height;
    ancho := grafico_contraste.Width;

    SetLength(matriz_contraste,alto,ancho,3);

    imagen_original.Assign(grafico_contraste.Picture.Graphic);
end;

procedure Tformulario_contraste.apertura_contrasteChange(Sender: TObject);
begin
    contraste := apertura_contraste.Position;
    valor_contraste.Caption:= FloatToStr(contraste);
end;

procedure Tformulario_contraste.apertura_contrasteMouseUp(Sender: TObject;
    Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    estado_contraste.Panels[0].Text:='Aplicando efecto, por favor espere...';

	//grafico_contraste.Picture.Assign(imagen_original);

    cpBMtoMatriz(alto,ancho,matriz_contraste,imagen_original);
    filtro_contraste(matriz_contraste);
    cpMatriztoCanv(alto,ancho,matriz_contraste,grafico_contraste);

    estado_contraste.Panels[0].Text:='Efecto Aplicado';
end;

procedure Tformulario_contraste.filtro_contraste(matriz : matrizRGB);
var
    i,j,k : Integer;
begin
	for i:=0 to alto-1 do begin
      	for j:= 0 to ancho-1 do begin
            for k:=0 to 2 do begin
            	//matriz[i,j,k] := trunc ( (255 / 2) * (1 + tanh(contraste *((matriz[i,j,k]-255)/ 2) )) );
                matriz[i,j,k] := trunc (matriz[i,j,k] - (contraste * sin( (2*3.1416*matriz[i,j,k]) / 255 ) ) );
            end;
        end;
    end;
end;

end.

