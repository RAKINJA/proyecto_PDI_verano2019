unit ventana_gamma;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
    ExtCtrls, ComCtrls, Math,funciones_control;

type

    { Tformulario_gamma }

    matrizRGB = Array of Array of Array of Byte;

    Tformulario_gamma = class(TForm)
        btn_ok: TBitBtn;
        btn_cancelar: TBitBtn;
        grafico_gamma: TImage;
        Label1: TLabel;
        Label2: TLabel;
        estado_gamma: TStatusBar;
        titulo_gamma: TLabel;
        apertura_gamma: TTrackBar;
        valor_gamma: TLabel;
        scroll_gamma: TScrollBox;
        procedure apertura_gammaChange(Sender: TObject);
        procedure apertura_gammaMouseUp(Sender: TObject; Button: TMouseButton;
            Shift: TShiftState; X, Y: Integer);
        procedure FormCreate(Sender: TObject);
        procedure FormShow(Sender: TObject);
    private


    public
        // variables
        imagen_original : TBitmap;
        matriz_gamma : matrizRGB;

        procedure filtro_correcion_gamma(matriz: matrizRGB);
    end;

var
    formulario_gamma: Tformulario_gamma;
    alto, ancho : Integer;
    gamma : Double;

implementation

{$R *.lfm}

{ Tformulario_gamma }

procedure Tformulario_gamma.FormCreate(Sender: TObject);
begin
	imagen_original := TBitmap.Create;
end;

procedure Tformulario_gamma.FormShow(Sender: TObject);
begin
    alto  := grafico_gamma.Height;
    ancho := grafico_gamma.Width;

    SetLength(matriz_gamma,alto,ancho,3);

    imagen_original.Assign(grafico_gamma.Picture.Graphic);


end;

procedure Tformulario_gamma.apertura_gammaChange(Sender: TObject);
begin
    case apertura_gamma.Position of
    	1: begin
            gamma := 0;
    		valor_gamma.Caption := FloatToStr(gamma);
        end;

        2: begin
            gamma := 1/512;
            valor_gamma.Caption := FloatToStr(gamma);
        end;

        3: begin
            gamma := 1/256;
            valor_gamma.Caption := FloatToStr(gamma);
        end;

        4: begin
            gamma := 1/128;
            valor_gamma.Caption:= FloatToStr(gamma);
        end;

        5: begin
            gamma := 1/64;
            valor_gamma.Caption:= FloatToStr(gamma);
        end;

        6: begin
            gamma := 1/32;
            valor_gamma.Caption:= FloatToStr(gamma);
        end;

        7: begin
            gamma := 1/16;
            valor_gamma.Caption:= FloatToStr(gamma);
        end;

        8: begin
            gamma := 1/8;
            valor_gamma.Caption:= FloatToStr(gamma);
        end;

        9 : begin
            gamma := 1/4;
            valor_gamma.Caption:= FloatToStr(gamma);
        end;

        10 : begin
            gamma := 1/2;
            valor_gamma.Caption:=FloatToStr(gamma);
        end

        else begin
            gamma := apertura_gamma.Position-10;
            valor_gamma.Caption:= FloatToStr(gamma);
        end;
    end;
end;

procedure Tformulario_gamma.apertura_gammaMouseUp(Sender: TObject;
    Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	estado_gamma.Panels[0].Text:='Aplicando efecto, por favor espere...';

	grafico_gamma.Picture.Assign(imagen_original);
    cpBMtoMatriz(alto,ancho,matriz_gamma,imagen_original);
    filtro_correcion_gamma(matriz_gamma);
    cpMatriztoCanv(alto,ancho,matriz_gamma,grafico_gamma);

    estado_gamma.Panels[0].Text:='Efecto Aplicado';
end;

procedure Tformulario_gamma.filtro_correcion_gamma(matriz: matrizRGB);
var
    i,j   :Integer;
    frag : double;
    k  	  : Byte;
begin
	for i:=0 to alto-1 do begin
        for j:= 0 to ancho-1 do begin
            for k:=0 to 2 do begin
                frag := 255*power(matriz[i,j,k]/255,gamma);
                //ShowMessage('Flotante '+FloatToStr(frag));
                matriz_gamma[i,j,k] := byte(trunc(frag));
				//ShowMessage('Byte '+FloatToStr(matriz[i,j,k]));
			end;
		end;
	end;
end;

end.

