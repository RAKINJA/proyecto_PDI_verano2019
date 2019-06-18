unit codigo_pdi_proyecto_vha;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ExtCtrls, stdCtrls,
  ExtDlgs, LCLintf, ComCtrls, funciones_control, metodos_proyecto_pid_vha, ventana_histograma,ventana_umbral;

type

  { Tformulario_principal }

	matrizRGB = Array of Array of Array of Byte; // Matriz de MxN para cada canal R,G,B

  Tformulario_principal = class(TForm)
    grafico: TImage;
	opcion_gamma: TMenuItem;
    menu_archivo: TMenuItem;
	menu_edicion: TMenuItem;
	opcion_deshacer: TMenuItem;
	opcion_rehacer: TMenuItem;
	opcion_original: TMenuItem;
	menu_ventana: TMenuItem;
	opcion_histograma: TMenuItem;
	opcion_umbral: TMenuItem;
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
	procedure opcion_gammaClick(Sender: TObject);
	procedure opcion_originalClick(Sender: TObject);
	procedure opcion_histogramaClick(Sender: TObject);
	procedure opcion_umbralClick(Sender: TObject);
    procedure opcion_abrir_imagenClick(Sender: TObject);
	procedure opcion_grises_bClick(Sender: TObject);
	procedure opcion_grises_gClick(Sender: TObject);
	procedure opcion_grises_globalClick(Sender: TObject);
	procedure opcion_grises_rClick(Sender: TObject);
	procedure opcion_negativoClick(Sender: TObject);

  private

  public



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

    barra_estado.Panels[0].Width:=200;

    // inhabilita los menus
    menu_edicion.Enabled:=false;
    menu_filtros.Enabled:=false;
    menu_ventana.Enabled:=false;
end;

procedure Tformulario_principal.opcion_originalClick(Sender: TObject);
begin
	//cpBMtoMatriz(alto_img,ancho_img,matRGB,bitmap_original);
    //cpMatriztoCanv(alto_img,ancho_img);
end;



procedure Tformulario_principal.opcion_abrir_imagenClick(Sender: TObject);
begin
	if abrir_imagen.Execute then begin
		grafico.Enabled:=True; // habilitar el TImage
        barra_estado.Panels[0].Text:='Cargando Imagen. Por favor Espere';

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
        cpMatriztoCanv(alto_img,ancho_img,matRGB,grafico);

        barra_estado.Panels[0].Text:='Imagen Cargada';

        menu_edicion.Enabled:=true;
    	menu_filtros.Enabled:=true;
	    menu_ventana.Enabled:=true;
    end;
end;

procedure Tformulario_principal.opcion_histogramaClick(Sender: TObject);
begin
    formulario_histograma.show;
end;

procedure Tformulario_principal.opcion_umbralClick(Sender: TObject);
var
	promedio : Integer;
begin
    cpCanvtoMatriz(alto_img,ancho_img,matRGB,grafico);
    filtro_grises_global(alto_img,ancho_img,matRGB);

    formulario_umbral.grafico_umbral.Height:=bitmap.Height;
    formulario_umbral.grafico_umbral.Width:=bitmap.Width;

    cpMatriztoCanv(alto_img,ancho_img,matRGB,formulario_umbral.grafico_umbral);

    promedio := formulario_umbral.umbral_promedio(alto_img,ancho_img,matRGB);
    ShowMessage('PROMEDIO EXTERNO = '+IntToStr(promedio));
    formulario_umbral.promedio_umbral := promedio;



    formulario_umbral.showModal;
    if formulario_umbral.boton_ok.ModalResult = MrOk then begin

	end;
end;

{
		OPCIONES DE FILTROS
}

procedure Tformulario_principal.opcion_grises_globalClick(Sender: TObject);
begin
    barra_estado.Panels[0].Text:='Aplicando Efecto. Por favor Espere';

	cpCanvtoMatriz(alto_img,ancho_img,matRGB,grafico); // Cargar la informacion de la Imagen en el Bitmap

    filtro_grises_global(alto_img,ancho_img,matRGB);

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap); // Carga la matriz al Bitmap
    cpMatriztoCanv(alto_img,ancho_img,matRGB,grafico);

    barra_estado.Panels[0].Text:='Efecto Aplicado';
end;

procedure Tformulario_principal.opcion_grises_rClick(Sender: TObject);
begin
    barra_estado.Panels[0].Text:='Aplicando Efecto. Por favor Espere';

	cpCanvtoMatriz(alto_img,ancho_img,matRGB,grafico); // Cargar la informacion de la Imagen en el Bitmap

    filtro_grises_r(alto_img,ancho_img,matRGB);

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap); // Carga la matriz al Bitmap
    cpMatriztoCanv(alto_img,ancho_img,matRGB,grafico);

    barra_estado.Panels[0].Text:='Efecto Aplicado';
end;

procedure Tformulario_principal.opcion_grises_gClick(Sender: TObject);
begin
    barra_estado.Panels[0].Text:='Aplicando Efecto. Por favor Espere';

    cpCanvtoMatriz(alto_img,ancho_img,matRGB,grafico); // Cargar la informacion de la Imagen en el Bitmap

    filtro_grises_g(alto_img,ancho_img,matRGB);

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap); // Carga la matriz al Bitmap
    cpMatriztoCanv(alto_img,ancho_img,matRGB,grafico);

    barra_estado.Panels[0].Text:='Efecto Aplicado - ';
end;

procedure Tformulario_principal.opcion_grises_bClick(Sender: TObject);
begin
    barra_estado.Panels[0].Text:='Aplicando Efecto. Por favor Espere';

	cpCanvtoMatriz(alto_img,ancho_img,matRGB,grafico); // Cargar la informacion de la Imagen en el Bitmap

    filtro_grises_b(alto_img,ancho_img,matRGB);

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap); // Carga la matriz al Bitmap
    cpMatriztoCanv(alto_img,ancho_img,matRGB,grafico);

    barra_estado.Panels[0].Text:='Efecto Aplicado';
end;

procedure Tformulario_principal.opcion_negativoClick(Sender: TObject);
begin
    barra_estado.Panels[0].Text:='Aplicando Efecto. Por favor Espere';

	cpCanvtoMatriz(alto_img,ancho_img,matRGB,grafico); // Cargar la informacion de la Imagen en el Bitmap

    filtro_negativo(alto_img,ancho_img,matRGB);

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap); // Carga la matriz al Bitmap
    cpMatriztoCanv(alto_img,ancho_img,matRGB,grafico);

    barra_estado.Panels[0].Text:='Efecto Aplicado';
end;

procedure Tformulario_principal.opcion_gammaClick(Sender: TObject);
begin
    barra_estado.Panels[0].Text:='Aplicando Efecto. Por favor Espere';
    cpCanvtoMatriz(alto_img,ancho_img,matRGB,grafico); // Cargar la informacion de la Imagen en el Bitmap

	filtro_correcion_gamma(alto_img,ancho_img,matRGB);

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap); // Carga la matriz al Bitmap
    cpMatriztoCanv(alto_img,ancho_img,matRGB,grafico);

    barra_estado.Panels[0].Text:='Efecto Aplicado';
end;

end.

