unit ventana_umbral;

{$mode objfpc}{$H+}

interface

uses
	Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
	ExtCtrls, Buttons, Menus, LCLintf, funciones_control;

type

	{ Tformulario_umbral }

    matrizRGB = Array of Array of Array of Byte; // Matriz de MxN para cada canal R,G,B


	Tformulario_umbral = class(TForm)
		boton_ok: TBitBtn;
		boton_ok1: TBitBtn;
		boton_color1: TColorButton;
		boton_color2: TColorButton;
		grafico_umbral: TImage;
		color1_text: TLabel;
		color2_text: TLabel;
        estado_umbral: TStatusBar;
		valor_umbral_tag: TLabel;
		scroll_umbral: TScrollBox;
		StaticText1: TStaticText;
		StaticText2: TStaticText;
		ventana_umbral_titulo: TLabel;
		apertura_umbral: TTrackBar;
   		procedure apertura_umbralChange(Sender: TObject);
		procedure apertura_umbralMouseUp(Sender: TObject; Button: TMouseButton;
				Shift: TShiftState; X, Y: Integer);
		procedure boton_color1ColorChanged(Sender: TObject);
		procedure boton_color2ColorChanged(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure FormShow(Sender: TObject);

    	private

		public

        promedio_umbral : Integer;
        imagen_original : TBitmap;
        matriz_umbral   : matrizRGB;

    	procedure actualizar_grafico(nuevo_bitmap:TBitmap);
        procedure filtro_umbral(alto,ancho:Integer; matriz:matrizRGB);

        function umbral_promedio(alto, ancho: Integer; var matriz: MatrizRGB):Integer;
	end;

var
	formulario_umbral: Tformulario_umbral;

    alto_img,ancho_img : Integer;
    valor_umbral  : Integer;
    cl1, cl2 : TColor;

implementation
{$R *.lfm}

{ Tformulario_umbral }

procedure Tformulario_umbral.FormCreate(Sender: TObject);
begin
	cl1 := Clblack;
    cl2 := Clwhite;

    boton_color1.ButtonColor := cl1;
    boton_color2.ButtonColor := cl2;

    imagen_original := TBitmap.Create;
end;

procedure Tformulario_umbral.FormShow(Sender: TObject);
begin
    alto_img  := grafico_umbral.Picture.Height;
    ancho_img := grafico_umbral.Picture.Width;

    apertura_umbral.Position := promedio_umbral;
    valor_umbral 			 := promedio_umbral;

    SetLength(matriz_umbral,alto_img,ancho_img,3); // Asigna el tamaño a la Matriz

    cpCanvtoMatriz(alto_img,ancho_img,matriz_umbral,grafico_umbral);  // Carga el contenido del Canvas a la Matriz
    imagen_original.Assign(grafico_umbral.Picture.Graphic);			  // Asigna la imagen original en el bitmap auxiliar

    cpBMtoMatriz(alto_img,ancho_img,matriz_umbral,imagen_original);
    filtro_umbral(alto_img,ancho_img,matriz_umbral);
    cpMatriztoCanv(alto_img,ancho_img,matriz_umbral,grafico_umbral);

end;

procedure Tformulario_umbral.apertura_umbralChange(Sender: TObject);
begin
	valor_umbral := apertura_umbral.Position;
    valor_umbral_tag.Caption:=IntToStr(valor_umbral);
end;

procedure Tformulario_umbral.apertura_umbralMouseUp(Sender: TObject;
		Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    estado_umbral.Panels[0].Text:='Aplicando Efecto, por favor espere...';

	cpBMtoMatriz(alto_img,ancho_img,matriz_umbral,imagen_original);
    filtro_umbral(alto_img,ancho_img,matriz_umbral);
    cpMatriztoCanv(alto_img,ancho_img,matriz_umbral,grafico_umbral);

    estado_umbral.Panels[0].Text:='Listo...';
end;

procedure Tformulario_umbral.boton_color1ColorChanged(Sender: TObject);
begin
	cl1 := boton_color1.ButtonColor;
end;

procedure Tformulario_umbral.boton_color2ColorChanged(Sender: TObject);
begin
	cl2 := boton_color2.ButtonColor;
end;

procedure Tformulario_umbral.actualizar_grafico(nuevo_bitmap: TBitmap);
begin
	grafico_umbral.picture.Assign(nuevo_bitmap);
end;

function Tformulario_umbral.umbral_promedio(alto, ancho: Integer; var matriz: MatrizRGB): Integer;
var
	i,j,total_pxls : Integer;
    k              : Byte;
begin
    total_pxls := alto * ancho;

	for i:=0 to alto-1 do begin
		for j:=0 to ancho-1 do begin
        	promedio_umbral := promedio_umbral + matriz[i,j,0];
		end;
	end;

    promedio_umbral := promedio_umbral div total_pxls;
    umbral_promedio := promedio_umbral; // retorna el valor de la funcion
end;

procedure Tformulario_umbral.filtro_umbral(alto,ancho:Integer; matriz:matrizRGB);
var
    i,j : Integer;
begin
    for i:=0 to alto-1 do begin
        for j:=0 to ancho-1 do begin

            if (matriz[i,j,0]<=valor_umbral) then begin
            	matriz[i,j,0] := GetRvalue(cl1);
                matriz[i,j,1] := GetGvalue(cl1);
                matriz[i,j,2] := GetBvalue(cl1);
			end else begin
            	matriz[i,j,0] := GetRvalue(cl2);
                matriz[i,j,1] := GetGvalue(cl2);
                matriz[i,j,2] := GetBvalue(cl2);
			end;
		end;
	end;
end;

end.
