unit ventana_histograma;

{$mode objfpc}{$H+}
interface

uses
	Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

	{ Tformulario_histograma }

    matrizRGB     = Array of Array of Array of Byte;
    arreglo_color = Array [0..255] of Integer;
    histogramaRGB = Array [0..2] of arreglo_color;
    altura_histograma = Array [0..2] of arreglo_color;

	Tformulario_histograma = class(TForm)
		grafico_histograma: TImage;
        hs_rgb: TRadioButton;
        hs_r: TRadioButton;
        hs_g: TRadioButton;
        hs_b: TRadioButton;
		valor_minimo: TLabel;
		valor_maximo: TLabel;
		titulo_histograma: TLabel;
		procedure FormCreate(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure hs_bChange(Sender: TObject);
        procedure hs_gChange(Sender: TObject);
        procedure hs_rChange(Sender: TObject);
        procedure hs_rgbChange(Sender: TObject);
		private

		public
        // variables
        maximo : Integer;


		// PROCEDIMIENTOS
        procedure crear_histograma(alto,ancho : Integer; matriz: matrizRGB);
        procedure histograma_cero();
        procedure inicializar_histograma(alto,ancho : Integer; matriz: matrizRGB; var hs:histogramaRGB);
        procedure asignar_alturas();


        procedure dibujar_histograma(grafico: TImage);
        procedure dibujar_hs_r(grafico: TImage);
        procedure dibujar_hs_g(grafico: TImage);
        procedure dibujar_hs_b(grafico: TImage);

        // FUNCIONES
	end;

var
	formulario_histograma: Tformulario_histograma;

    matriz_histograma : histogramaRGB;
	altura : histogramaRGB;

implementation

{$R *.lfm}

{ Tformulario_histograma }

procedure Tformulario_histograma.FormCreate(Sender: TObject);
begin
    formulario_histograma.Height:=250;
	formulario_histograma.Width:=300;

    grafico_histograma.SetBounds(20,25,255,140);
    grafico_histograma.Canvas.Rectangle(0,0,grafico_histograma.Width,grafico_histograma.Height);
end;

procedure Tformulario_histograma.FormShow(Sender: TObject);
begin
	grafico_histograma.Canvas.Rectangle(0,0,grafico_histograma.Width,grafico_histograma.Height);
    dibujar_histograma(grafico_histograma);
end;

{
	ACCIONES DE RADIO BUTTONS
}

procedure Tformulario_histograma.hs_rgbChange(Sender: TObject);
begin
	grafico_histograma.Canvas.Rectangle(0,0,grafico_histograma.Width,grafico_histograma.Height);
    dibujar_histograma(grafico_histograma);
end;

procedure Tformulario_histograma.hs_rChange(Sender: TObject);
begin
	grafico_histograma.Canvas.Rectangle(0,0,grafico_histograma.Width,grafico_histograma.Height);
    dibujar_hs_r(grafico_histograma);
end;

procedure Tformulario_histograma.hs_gChange(Sender: TObject);
begin
	grafico_histograma.Canvas.Rectangle(0,0,grafico_histograma.Width,grafico_histograma.Height);
    dibujar_hs_g(grafico_histograma);
end;

procedure Tformulario_histograma.hs_bChange(Sender: TObject);
begin
	grafico_histograma.Canvas.Rectangle(0,0,grafico_histograma.Width,grafico_histograma.Height);
    dibujar_hs_b(grafico_histograma);
end;

{
	PROCEDIMIENTOS DE CALCULO Y DIBUJADO
}

procedure Tformulario_histograma.crear_histograma(alto,ancho : Integer; matriz: matrizRGB);
begin
    histograma_cero();
    inicializar_histograma(alto,ancho,matriz,matriz_histograma);
    asignar_alturas();
end;

procedure Tformulario_histograma.histograma_cero();
var
    i,j : Integer;
begin
	for i:=0 to 2 do begin
     	for j:=0 to 255 do begin
			matriz_histograma[i,j] := 0;
            altura[i,j]            := 0;
        end;
    end;
end;

procedure Tformulario_histograma.inicializar_histograma(alto,ancho : Integer; matriz: matrizRGB; var hs:histogramaRGB);
var
    i,j,k,l : Integer;
begin
	for k:=0 to 2 do begin

            for i:=0 to alto-1 do begin
                for j:=0 to ancho-1 do begin
                    l := matriz[i,j,k];
                    matriz_histograma[k,l] := matriz_histograma[k,l]+1;

                    if (matriz_histograma[k,l] > maximo) then maximo := matriz_histograma[k,l];
                end; // end for j
            end; // end for i

    end; // end for k

    ShowMessage('El valor maximo es : '+IntToStr(maximo));
end;

procedure Tformulario_histograma.asignar_alturas();
var
    i,j,k : Integer;
    frag : Double;
begin
	// proceso de calcular altura para cada punto en el arreglo
	for i:= 0 to 2 do begin
        for j:= 0 to 255 do begin
            frag := 1-(matriz_histograma[i,j] / maximo);
            //ShowMessage('Frag  ['+IntToStr(i)+' | '+IntToStr(j)+'] = '+FloatToStr(frag));
            altura[i,j] := trunc(140*(frag));

        end;
	end;
end;

procedure Tformulario_histograma.dibujar_histograma(grafico: TImage);
begin
	grafico_histograma.Canvas.Rectangle(0,0,grafico_histograma.Width,grafico_histograma.Height);
    dibujar_hs_r(grafico);
    dibujar_hs_g(grafico);
    dibujar_hs_b(grafico);
end;

procedure Tformulario_histograma.dibujar_hs_r(grafico: TImage);
var
    j,ant_x,ant_y : Integer;
begin
    grafico_histograma.Canvas.Pen.Color:=Clred;
    ant_x := 0; ant_y := grafico_histograma.Height;;

	for j:=0 to 255 do begin
		grafico.Canvas.Line(ant_x,ant_y,j,altura[0,j]);
        //ShowMessage('Punto ['+IntToStr(ant_x)+' | '+IntToStr(ant_y)+'] --> ['+IntToStr(j)+' | '+IntToStr(altura[0,j]));
        ant_x := j;
        ant_y := altura[0,j];
    end;
    grafico_histograma.Canvas.Pen.Color:=Clblack;
end;

procedure Tformulario_histograma.dibujar_hs_g(grafico: TImage);
var
    j,ant_x,ant_y : Integer;
begin
	grafico_histograma.Canvas.Pen.Color:=Clgreen;
    ant_x := 0; ant_y := grafico_histograma.Height;

	for j:=0 to 255 do begin
		grafico.Canvas.Line(ant_x,ant_y,j,altura[1,j]);

        ant_x := j;
        ant_y := altura[1,j];
    end;
	grafico_histograma.Canvas.Pen.Color:=Clblack;
end;

procedure Tformulario_histograma.dibujar_hs_b(grafico: TImage);
var
    j,ant_x,ant_y : Integer;
begin
	grafico_histograma.Canvas.Pen.Color:=Clblue;
    ant_x := 0; ant_y := grafico_histograma.Height;;

	for j:=0 to 255 do begin
		grafico.Canvas.Line(ant_x,ant_y,j,altura[2,j]);

        ant_x := j;
        ant_y := altura[2,j];
    end;
    grafico_histograma.Canvas.Pen.Color:=Clblack;
end;

end.

