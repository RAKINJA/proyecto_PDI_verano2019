unit ventana_contraste;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, Buttons,
    ExtCtrls, StdCtrls;

type

    { Tformulario_contraste }

    matrizRGB = Array of Array of Array of Byte;

    Tformulario_contraste = class(TForm)
        btn_ok: TBitBtn;
        btn_cancelar: TBitBtn;
        grafico_contraste: TImage;
        titulo_contraste: TLabel;
        valor_contraste: TLabel;
        scroll_contraste: TScrollBox;
        apertura_contraste: TTrackBar;
        procedure apertura_contrasteChange(Sender: TObject);
        procedure apertura_contrasteMouseUp(Sender: TObject;
            Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    private
        procedure filtro_contraste(matriz : matrizRGB);

    public
        // variables
        matriz_contraste : matrizRGB;
        imagen_original : TBitmap;


        // procedimientos


    end;

var
    formulario_contraste: Tformulario_contraste;

implementation

{$R *.lfm}

{ Tformulario_contraste }

procedure Tformulario_contraste.apertura_contrasteChange(Sender: TObject);
begin
	filtro_contraste(matriz_contraste);
end;

procedure Tformulario_contraste.apertura_contrasteMouseUp(Sender: TObject;
    Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure Tformulario_contraste.filtro_contraste(matriz : matrizRGB);
var
    i,j,k : Integer;
begin
end;

end.

