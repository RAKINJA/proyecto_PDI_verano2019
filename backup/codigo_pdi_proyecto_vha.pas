unit codigo_pdi_proyecto_vha;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ExtCtrls, stdCtrls,
  ExtDlgs, LCLintf, ComCtrls,metodos_proyecto_pid_vha;

type

  { Tformulario_principal }

	matrizRGB = Array of Array of Array of Byte; // Matriz de MxN para cada canal R,G,B

  Tformulario_principal = class(TForm)
    grafico: TImage;
    MenuItem1: TMenuItem;
	MenuItem2: TMenuItem;
	MenuItem3: TMenuItem;
	MenuItem4: TMenuItem;
	MenuItem5: TMenuItem;
    opcion_abrir_imagen: TMenuItem;
	opcion_grises_b: TMenuItem;
	opcion_grises_g: TMenuItem;
	opcion_grises_global: TMenuItem;
	opcion_grises_r: TMenuItem;
    opcion_guardar_imagen: TMenuItem;
    menu_filtros: TMenuItem;
    opcion_negativo: TMenuItem;
    opcion_grises: TMenuItem;
    menu_principal: TMainMenu;
    abrir_imagen: TOpenPictureDialog;
    cuadro_scroll: TScrollBox;
	barra_estado: TStatusBar;

    procedure FormCreate(Sender: TObject);
	procedure MenuItem5Click(Sender: TObject);
    procedure opcion_abrir_imagenClick(Sender: TObject);
	procedure opcion_grises_bClick(Sender: TObject);
	procedure opcion_grises_gClick(Sender: TObject);
	procedure opcion_grises_globalClick(Sender: TObject);
	procedure opcion_grises_rClick(Sender: TObject);
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
	bitmap,bitmap_original:Tbitmap;
	matRGB : matrizRGB;
	alto_img, ancho_img : Integer; // alto y ancho de la imagen

implementation

{$R *.lfm}

{ Tformulario_principal }
procedure Tformulario_principal.FormCreate(Sender: TObject);
begin
	// Asignacion de tamaño del ScrollBox
	cuadro_scroll.SetBounds(0,0,600,500);

	grafico.Enabled:=false;
    bitmap := TBitmap.Create; // creacion del objeto de tipo Bitmap
end;

procedure Tformulario_principal.MenuItem5Click(Sender: TObject);
begin
	cpBMtoMatriz(alto_img,ancho_img,matRGB,bitmap_original);
    cpMatriztoCanv(alto_img,ancho_img);
end;

procedure Tformulario_principal.opcion_abrir_imagenClick(Sender: TObject);
begin
	if abrir_imagen.Execute then begin
		grafico.Enabled:=True; // habilitar el TImage

        bitmap.LoadFromFile(abrir_imagen.FileName); // cargar imagen


        if bitmap.PixelFormat<> Pf24bit then //si no es de 8 bits por canal
    	begin
       		bitmap.PixelFormat:=Pf24bit;
    	end;

        ShowMessage(IntToStr(bitmap.Height));
        ShowMessage(IntToStr(bitmap.Width));

        alto_img := bitmap.Height; ancho_img := bitmap.Width; // Se actualiza el alto y ancho del bitmap conforme a la imagen
        grafico.Height := alto_img; grafico.Width := ancho_img; // Se actualiza el alto y ancho del Canvas conforme a la imagen

        ShowMessage(IntToStr(grafico.Height));
        ShowMessage(IntToStr(grafico.Width));

		SetLength(matRGB,alto_img,ancho_img,3); // Reserva el espacio para la matrizRGB

		cpBMtoMatriz(alto_img,ancho_img,matRGB,bitmap); // llama a la funcion para asignar los datos del bitmap a la matriz
        //grafico.Picture.Assign(bitmap); // Asigna el contenido del bitmap a Canvas del TImage
        cpMatriztoCanv(alto_img,ancho_img);

        //bitmap_original.Assign(grafico.Picture); // carga la imagen al bitmap de respaldo original que guarda la imagen original
    end;
end;

procedure Tformulario_principal.opcion_grises_globalClick(Sender: TObject);
begin
	cpCanvtoMatriz(alto_img,ancho_img,matRGB); // Cargar la informacion de la Imagen en el Bitmap

    filtro_grises_global(alto_img,ancho_img,matRGB);

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap); // Carga la matriz al Bitmap
    cpMatriztoCanv(alto_img,ancho_img);
end;

procedure Tformulario_principal.opcion_grises_rClick(Sender: TObject);
begin
    barra_estado.Panels[0].Text:='Aplicando Efecto. Por favor Espere';

	cpCanvtoMatriz(alto_img,ancho_img,matRGB); // Cargar la informacion de la Imagen en el Bitmap

    filtro_grises_r(alto_img,ancho_img,matRGB);

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap); // Carga la matriz al Bitmap
    cpMatriztoCanv(alto_img,ancho_img);

    barra_estado.Panels[0].Text:='Efecto Aplicado';
end;

procedure Tformulario_principal.opcion_grises_gClick(Sender: TObject);
begin
    barra_estado.Panels[0].Text:='Aplicando Efecto. Por favor Espere';

	cpCanvtoMatriz(alto_img,ancho_img,matRGB); // Cargar la informacion de la Imagen en el Bitmap

    filtro_grises_g(alto_img,ancho_img,matRGB);

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap); // Carga la matriz al Bitmap
    cpMatriztoCanv(alto_img,ancho_img);

    barra_estado.Panels[0].Text:='Efecto Aplicado';
end;

procedure Tformulario_principal.opcion_grises_bClick(Sender: TObject);
begin
    barra_estado.Panels[0].Text:='Aplicando Efecto. Por favor Espere';

	cpCanvtoMatriz(alto_img,ancho_img,matRGB); // Cargar la informacion de la Imagen en el Bitmap

    filtro_grises_b(alto_img,ancho_img,matRGB);

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap); // Carga la matriz al Bitmap
    cpMatriztoCanv(alto_img,ancho_img);

    barra_estado.Panels[0].Text:='Efecto Aplicado';
end;

procedure Tformulario_principal.opcion_negativoClick(Sender: TObject);
begin
    barra_estado.Panels[0].Width:=200;
    barra_estado.Panels[0].Text:='Aplicando Efecto. Por favor Espere';

	cpCanvtoMatriz(alto_img,ancho_img,matRGB); // Cargar la informacion de la Imagen en el Bitmap

    filtro_negativo(alto_img,ancho_img,matRGB);

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap); // Carga la matriz al Bitmap
    cpMatriztoCanv(alto_img,ancho_img);

    barra_estado.Panels[0].Text:='Efecto Aplicado';
end;

procedure Tformulario_principal.cpCanvtoMatriz(alto,ancho:Integer; var Matriz:matrizRGB);
var
    i,j : Integer;
    cl  : TColor;
begin
    ShowMessage('Copiar Canvas -> Matriz');
	for i:=0 to alto-1 do begin
        for j:=0 to ancho-1 do begin

            cl            := grafico.Canvas.Pixels[j,i];
			Matriz[i,j,0] := GetRValue(cl); // Valor del Canal R
            Matriz[i,j,1] := GetGValue(cl); // Valor del Canal G
            Matriz[i,j,2] := GetBValue(cl); // Valor del Canal B
            {ShowMessage('i= '+IntToStr(i)+' | j= '+IntToStr(j));
            ShowMessage('Rojo= '+IntToStr(Matriz[i,j,0])+'| Verde= '+IntToStr(Matriz[i,j,1])+' | Azul= '+IntToStr(Matriz[i,j,2]));}
		end;
	end;
end;

procedure Tformulario_principal.cpMatriztoCanv(alto,ancho:Integer);
var
    i,j : Integer;
    cl  : TColor;
begin
    ShowMessage('Copiar Matriz -> Canvas');
	for i:=0 to alto-1 do begin
        for j:=0 to ancho-1 do begin
        	cl := RGB(matRGB[i,j,0],matRGB[i,j,1],matRGB[i,j,2]);
            grafico.Canvas.Pixels[j,i]:=cl;
		end;
	end;
end;

procedure Tformulario_principal.cpBMtoMatriz(alto, ancho:Integer ; var Matriz:matrizRGB; bmp:TBitmap);
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
			Matriz[i,j,0] := pArrByte[k+2];
			Matriz[i,j,1] := pArrByte[k+1];
			Matriz[i,j,2] := pArrByte[k];
            //ShowMessage('Rojo= '+IntToStr(Matriz[i,j,0])+'| Verde= '+IntToStr(Matriz[i,j,1])+' | Azul= '+IntToStr(Matriz[i,j,2]));
        end;
    end;
end; // Fin copia Bitmap -> Matriz

procedure Tformulario_principal.cpMatriztoBM(alto, ancho:Integer; Matriz:matrizRGB; var bmp:TBitmap);
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
            pArrayByte[k]   := Matriz[i,j,0];
            pArrayByte[k+1] := Matriz[i,j,1];
            pArrayByte[k+2] := Matriz[i,j,2];
		end;
	end;
end; // fin copia Matriz -> Bitmap

end.

