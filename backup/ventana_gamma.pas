unit ventana_gamma;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
    ExtCtrls, ComCtrls, Math;

type

    { Tformulario_gamma }

    matrizRGB = Array of Array of Array of Byte;

    Tformulario_gamma = class(TForm)
        btn_ok: TBitBtn;
        btn_cancelar: TBitBtn;
        grafico_gamma: TImage;
        titulo_gamma: TLabel;
        apertura_gamma: TTrackBar;
        valor_gamma: TLabel;
        scroll_gamma: TScrollBox;
        procedure FormCreate(Sender: TObject);
    private


    public
        procedure filtro_correcion_gamma(alto,ancho:Integer; var matriz: matrizRGB);
    end;

var
    formulario_gamma: Tformulario_gamma;

implementation

{$R *.lfm}

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

{ Tformulario_gamma }

procedure Tformulario_gamma.FormCreate(Sender: TObject);
begin

end;

procedure Tformulario_gamma.filtro_correcion_gamma(alto, ancho: Integer;
    var matriz: matrizRGB);
begin

end;

end.

