unit ventana_histograma;

{$mode objfpc}{$H+}
interface

uses
	Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,metodos_proyecto_pid_vha,
    funciones_control;

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
        hs_i: TRadioButton;
		valor_minimo: TLabel;
		valor_maximo: TLabel;
		titulo_histograma: TLabel;
		procedure FormCreate(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure hs_bChange(Sender: TObject);
        procedure hs_gChange(Sender: TObject);
        procedure hs_iChange(Sender: TObject);
        procedure hs_rChange(Sender: TObject);
        procedure hs_rgbChange(Sender: TObject);
		private

		public
        // variables
        maximo,maximo_r,maximo_b,maximo_g, maximo_intensidad : Integer;
        imagen_intensidad : TBitmap;

		// PROCEDIMIENTOS
        procedure crear_histograma(alto,ancho : Integer; matriz: matrizRGB);
        procedure histograma_cero();
        procedure inicializar_histograma(alto,ancho : Integer; matriz: matrizRGB; var hs:histogramaRGB);
        procedure inicializar_histograma_i(alto,ancho : Integer; matriz: matrizRGB);
        procedure asignar_alturas();
        procedure asignar_alturas_i();


        procedure dibujar_histograma(grafico: TImage);
        procedure dibujar_hs_r(grafico: TImage);
        procedure dibujar_hs_g(grafico: TImage);
        procedure dibujar_hs_b(grafico: TImage);
        procedure dibujar_hs_i(grafico: TImage);

        // FUNCIONES
	end;

var
	formulario_histograma: Tformulario_histograma;

    matriz_histograma : histogramaRGB;
	altura : histogramaRGB;

    intensidad : Array [0..1] of arreglo_color;

    matriz_intensidad : matrizRGB;

implementation

{$R *.lfm}

{ Tformulario_histograma }

procedure Tformulario_histograma.FormCreate(Sender: TObject);
begin
    formulario_histograma.Height:=250;
	formulario_histograma.Width:=300;

    grafico_histograma.SetBounds(20,25,255,140);
    grafico_histograma.Canvas.Rectangle(0,0,grafico_histograma.Width,grafico_histograma.Height);

    imagen_intensidad := TBitmap.Create;
end;

procedure Tformulario_histograma.FormShow(Sender: TObject);
begin
	grafico_histograma.Canvas.Rectangle(0,0,grafico_histograma.Width,grafico_histograma.Height);
    dibujar_histograma(grafico_histograma);

    SetLength(matriz_intensidad,imagen_intensidad.Height,imagen_intensidad.Width,3);
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

procedure Tformulario_histograma.hs_iChange(Sender: TObject);
begin
	grafico_histograma.Canvas.Rectangle(0,0,grafico_histograma.Width,grafico_histograma.Height);
    dibujar_hs_i(grafico_histograma);
end;

{
	PROCEDIMIENTOS DE CALCULO Y DIBUJADO
}

procedure Tformulario_histograma.crear_histograma(alto,ancho : Integer; matriz: matrizRGB);
begin
    histograma_cero();
    inicializar_histograma(alto,ancho,matriz,matriz_histograma);
    asignar_alturas();

    // crear la imagen a escala de grises
    SetLength(matriz_intensidad,imagen_intensidad.Height,imagen_intensidad.Width,3);
    cpBMtoMatriz(imagen_intensidad.Height,imagen_intensidad.Width,matriz_intensidad,imagen_intensidad);

    filtro_grises_global(imagen_intensidad.Height,imagen_intensidad.Width,matriz_intensidad);
    inicializar_histograma_i(alto,ancho,matriz_intensidad);
	asignar_alturas_i();
end;

procedure Tformulario_histograma.histograma_cero();
var
    i,j : Integer;
begin
    maximo := 0; maximo_r :=0; maximo_b :=0; maximo_g :=0; maximo_intensidad := 0;
    for i:=0 to 2 do begin
     	for j:=0 to 255 do begin
            matriz_histograma[i,j] := 0;
            altura[i,j]            := 0;

	    	if i < 2 then begin
				intensidad[i,j] := 0;
            end;
        end;
    end;
end;

procedure Tformulario_histograma.inicializar_histograma(alto,ancho : Integer; matriz: matrizRGB; var hs:histogramaRGB);
var
    i,j,k,l : Integer;
begin
    for i:=0 to 2 do begin
        for j:=0 to 255 do begin
            matriz_histograma[i,j] := 0;
            altura[i,j] := 0;
        end;
    end;

	for k:=0 to 2 do begin

            for i:=0 to alto-1 do begin
                for j:=0 to ancho-1 do begin
                    l := matriz[i,j,k];

                    matriz_histograma[k,l] := matriz_histograma[k,l]+1;

                    if matriz_histograma[k,l] > maximo then maximo := matriz_histograma[k,l];

                end; // end for j
            end; // end for i

        //end // end of j
    end; // end for i

    maximo_r := matriz_histograma[2,0];
    maximo_g := matriz_histograma[1,0];
    maximo_b := matriz_histograma[1,0];

    for i := 0 to 255 do begin
		if maximo_b < matriz_histograma[0,i] then maximo_b := matriz_histograma[0,i];
        if maximo_g < matriz_histograma[1,i] then maximo_g := matriz_histograma[1,i];
        if maximo_r < matriz_histograma[2,i] then maximo_r := matriz_histograma[2,i];
	end;


    ShowMessage('Maximo R '+IntToStr(maximo_r));
    ShowMessage('Maximo G '+IntToStr(maximo_g));
    ShowMessage('Maximo B '+IntToStr(maximo_b));

    //ShowMessage('El valor maximo es : '+IntToStr(maximo));
end;

procedure Tformulario_histograma.asignar_alturas();
var
    i,j,maximo_hs : Integer;
    frag : Double;
begin

    maximo_hs := 0;
	// proceso de calcular altura para cada punto en el arreglo
	for i:= 0 to 2 do begin

        if i = 2 then maximo_hs := maximo_r;
        if i = 1 then maximo_hs := maximo_g;
        if i = 0 then maximo_hs := maximo_b;

        for j:= 0 to 255 do begin
            frag := 1-(matriz_histograma[i,j] / maximo_hs);
            altura[i,j] := trunc(140*(frag));
        end;
	end;
end;

procedure Tformulario_histograma.inicializar_histograma_i(alto,ancho : Integer; matriz: matrizRGB);
var
    i,j,l : Integer;
begin
    ShowMessage('Alto  := '+IntToStr(alto));
    ShowMessage('Ancho := '+IntToStr(ancho));

	for i:=0 to alto-1 do begin
    	for j:=0 to ancho-1 do begin
            ShowMessage('Alto := '+IntToStr(matriz[i,j,0]));
        	l := matriz[i,j,0];
           	intensidad[0,l] :=intensidad[0,l]+1;

            if (intensidad[0,l] > maximo_intensidad) then maximo_intensidad := intensidad[0,l];
        end;
    end;

    //ShowMessage('El valor maximo es : '+IntToStr(maximo_intensidad));
end;

procedure Tformulario_histograma.asignar_alturas_i();
var
    j,k : Integer;
    frag : Double;
begin
	// proceso de calcular altura para cada punto en el arreglo
    for j:= 0 to 255 do begin
        frag := 1-(intensidad[0,j] / maximo);
        //ShowMessage('Frag  ['+IntToStr(1)+' | '+IntToStr(j)+'] = '+FloatToStr(frag));
    	intensidad[1,j] := trunc(140*(frag));

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
        grafico.Canvas.Line(ant_x,ant_y,j,altura[2,j]);
        ant_x := j;
        ant_y := altura[2,j];
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
    ant_x := 0; ant_y := grafico_histograma.Height;

	for j:=0 to 255 do begin
		grafico.Canvas.Line(ant_x,ant_y,j,altura[0,j]);

        ant_x := j;
        ant_y := altura[0,j];
    end;
    grafico_histograma.Canvas.Pen.Color:=Clblack;
end;

procedure Tformulario_histograma.dibujar_hs_i(grafico: TImage);
var
    j,ant_x,ant_y : Integer;
begin
	grafico_histograma.Canvas.Pen.Color:=Clblack;
    ant_x := 0; ant_y := grafico_histograma.Height;

    for j:=0 to 255 do begin
        grafico.Canvas.Line(ant_x,ant_y,j,intensidad[1,j]);

        ant_x := j;
        ant_y := intensidad[1,j];
    end;
end;

end.

