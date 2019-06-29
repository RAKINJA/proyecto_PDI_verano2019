unit codigo_pdi_proyecto_vha;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ExtCtrls, stdCtrls,
  ExtDlgs, LCLintf, ComCtrls, funciones_control, metodos_proyecto_pid_vha, ventana_histograma,
  ventana_umbral,ventana_gamma,ventana_contraste;

type

  { Tformulario_principal }

	matrizRGB = Array of Array of Array of Byte; // Matriz de MxN para cada canal R,G,B

  Tformulario_principal = class(TForm)
    grafico: TImage;
    lista_imagenes: TImageList;
    opcion_contraste: TMenuItem;
    opcion_guardar_como: TMenuItem;
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
    cuadro_salvar: TSavePictureDialog;
    barra_opciones: TToolBar;
    girarizq: TToolButton;
    girarder: TToolButton;
    zoomin: TToolButton;
    zoomout: TToolButton;

    procedure FormCreate(Sender: TObject);
    procedure girarderClick(Sender: TObject);
    procedure opcion_guardar_comoClick(Sender: TObject);
	procedure opcion_gammaClick(Sender: TObject);
    procedure opcion_guardar_imagenClick(Sender: TObject);
	procedure opcion_originalClick(Sender: TObject);
	procedure opcion_histogramaClick(Sender: TObject);
	procedure opcion_umbralClick(Sender: TObject);
    procedure opcion_abrir_imagenClick(Sender: TObject);
	procedure opcion_grises_bClick(Sender: TObject);
	procedure opcion_grises_gClick(Sender: TObject);
	procedure opcion_grises_globalClick(Sender: TObject);
	procedure opcion_grises_rClick(Sender: TObject);
	procedure opcion_negativoClick(Sender: TObject);
    procedure girarizqClick(Sender: TObject);
    procedure zoominClick(Sender: TObject);
    procedure zoomoutClick(Sender: TObject);

  private

  public



  end;

var
	formulario_principal: Tformulario_principal;

	// VARIABLES
	bitmap,bitmap_original		: Tbitmap;
	matRGB          			: matrizRGB;
	alto_img, ancho_img, avance : Integer; // alto y ancho de la imagen

    histograma_nuevo : Boolean;

implementation

{$R *.lfm}

{ Tformulario_principal }
procedure Tformulario_principal.FormCreate(Sender: TObject);
begin
	// Asignacion de tamaño del ScrollBox
	cuadro_scroll.SetBounds(5,30,500,420);

	grafico.Enabled:=false;
    bitmap := TBitmap.Create; // creacion del objeto de tipo Bitmap
    bitmap_original := TBitmap.Create;

    barra_estado.Panels[0].Width:=200;

    // inhabilita los menus
    menu_edicion.Enabled		  := false;
    menu_filtros.Enabled 		  := false;
    menu_ventana.Enabled          := false;
    opcion_guardar_imagen.Enabled := false;
    opcion_guardar_como.Enabled   := false;

    barra_opciones.Enabled := false;
end;

procedure Tformulario_principal.opcion_originalClick(Sender: TObject);
begin
    grafico.Picture.Assign(bitmap_original);
end;

procedure Tformulario_principal.opcion_abrir_imagenClick(Sender: TObject);
begin
	if abrir_imagen.Execute then begin

        barra_estado.Panels[0].Text:='Cargando Imagen. Por favor Espere';

        bitmap.LoadFromFile(abrir_imagen.FileName); // cargar imagen

        if bitmap.PixelFormat<> Pf24bit then //si no es de 8 bits por canal
    	begin
       		bitmap.PixelFormat:=Pf24bit;
    	end;

        alto_img := bitmap.Height; ancho_img := bitmap.Width; // Se actualiza el alto y ancho del bitmap conforme a la imagen
        grafico.Height := alto_img; grafico.Width := ancho_img; // Se actualiza el alto y ancho del Canvas conforme a la imagen
		SetLength(matRGB,alto_img,ancho_img,3); // Reserva el espacio para la matrizRGB

        grafico.Enabled:=True; // habilitar el TImage

		cpBMtoMatriz(alto_img,ancho_img,matRGB,bitmap); // llama a la funcion para asignar los datos del bitmap a la matriz
        grafico.Picture.Assign(bitmap);
        bitmap_original.Assign(grafico.Picture.Bitmap);

        metodos_proyecto_pid_vha.avance:=(alto_img*ancho_img) div 100;
        barra_estado.Panels[0].Text:='Imagen Cargada';

        barra_opciones.Enabled:=true;

        menu_edicion.Enabled := true;
    	menu_filtros.Enabled := true;
	    menu_ventana.Enabled := true;

        opcion_guardar_imagen.Enabled := true; // habilita la opcion de guardar
        opcion_guardar_como.Enabled   := true;

        histograma_nuevo := true;
    end;
end;

procedure Tformulario_principal.opcion_histogramaClick(Sender: TObject);
begin
    formulario_histograma.show;
    if histograma_nuevo then begin
    	formulario_histograma.crear_histograma(alto_img,ancho_img,matRGB);
        formulario_histograma.dibujar_histograma(formulario_histograma.grafico_histograma);
        histograma_nuevo := false;
    end;
end;

procedure Tformulario_principal.opcion_umbralClick(Sender: TObject);
begin
    filtro_grises_global(alto_img,ancho_img,matRGB);

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap);

    formulario_umbral.grafico_umbral.Picture.Assign(bitmap); // Asigna el bitmap al TImage de la ventana de Umbral
    formulario_umbral.promedio_umbral := formulario_umbral.umbral_promedio(alto_img,ancho_img,matRGB); // Obtiene el promedio y lo guarda en la variable
																									   // del formuario de Umbral
    formulario_umbral.showModal; // Muestra el Umbral

    if formulario_umbral.ModalResult = MrOk then begin
        cpMatriztoBM(alto_img,ancho_img,formulario_umbral.matriz_umbral,bitmap);
        //grafico.Picture.Assign(bitmap);
        cpBmtoMatriz(alto_img,ancho_img,matRGB,bitmap);
        cpMatriztoCanv(alto_img,ancho_img,matRGB,grafico);

        formulario_histograma.crear_histograma(alto_img,ancho_img,matRGB);
        formulario_histograma.dibujar_histograma(formulario_histograma.grafico_histograma);
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

    formulario_histograma.crear_histograma(alto_img,ancho_img,matRGB);
    formulario_histograma.dibujar_histograma(formulario_histograma.grafico_histograma);

    barra_estado.Panels[0].Text:='Efecto Aplicado';
end;

procedure Tformulario_principal.opcion_grises_rClick(Sender: TObject);
begin
    barra_estado.Panels[0].Text:='Aplicando Efecto. Por favor Espere';

	cpCanvtoMatriz(alto_img,ancho_img,matRGB,grafico); // Cargar la informacion de la Imagen en el Bitmap

    filtro_grises_r(alto_img,ancho_img,matRGB);

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap); // Carga la matriz al Bitmap
    cpMatriztoCanv(alto_img,ancho_img,matRGB,grafico);

    formulario_histograma.crear_histograma(alto_img,ancho_img,matRGB);
    formulario_histograma.dibujar_histograma(formulario_histograma.grafico_histograma);

    barra_estado.Panels[0].Text:='Efecto Aplicado';
end;

procedure Tformulario_principal.opcion_grises_gClick(Sender: TObject);
begin
    barra_estado.Panels[0].Text:='Aplicando Efecto. Por favor Espere';

    cpCanvtoMatriz(alto_img,ancho_img,matRGB,grafico); // Cargar la informacion de la Imagen en el Bitmap

    filtro_grises_g(alto_img,ancho_img,matRGB);

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap); // Carga la matriz al Bitmap
    cpMatriztoCanv(alto_img,ancho_img,matRGB,grafico);

    formulario_histograma.crear_histograma(alto_img,ancho_img,matRGB);
    formulario_histograma.dibujar_histograma(formulario_histograma.grafico_histograma);

    barra_estado.Panels[0].Text:='Efecto Aplicado';
end;

procedure Tformulario_principal.opcion_grises_bClick(Sender: TObject);
begin
    barra_estado.Panels[0].Text:='Aplicando Efecto. Por favor Espere';

	cpCanvtoMatriz(alto_img,ancho_img,matRGB,grafico); // Cargar la informacion de la Imagen en el Bitmap

    filtro_grises_b(alto_img,ancho_img,matRGB);

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap); // Carga la matriz al Bitmap
    cpMatriztoCanv(alto_img,ancho_img,matRGB,grafico);

    formulario_histograma.crear_histograma(alto_img,ancho_img,matRGB);
    formulario_histograma.dibujar_histograma(formulario_histograma.grafico_histograma);

    barra_estado.Panels[0].Text:='Efecto Aplicado';
end;

procedure Tformulario_principal.opcion_negativoClick(Sender: TObject);
begin
    barra_estado.Panels[0].Text:='Aplicando Efecto. Por favor Espere';

    filtro_negativo(alto_img,ancho_img,matRGB);

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap); // Carga la matriz al Bitmap
    grafico.Picture.Assign(bitmap);

    formulario_histograma.crear_histograma(alto_img,ancho_img,matRGB);
    formulario_histograma.dibujar_histograma(formulario_histograma.grafico_histograma);

    barra_estado.Panels[0].Text:='Efecto Aplicado';
end;

procedure Tformulario_principal.zoominClick(Sender: TObject);
begin
    // proceso de llenado de pixeles
    zoom_in(alto_img,ancho_img,matRGB);
    alto_img := alto_img *2;
    ancho_img := ancho_img*2;

    bitmap.Height:=alto_img;
    bitmap.Width:=ancho_img;
    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap);
    grafico.Picture.Assign(bitmap);
end;

procedure Tformulario_principal.zoomoutClick(Sender: TObject);
begin
    if (alto_img < 5) and (ancho_img < 5) then begin
        zoom_out(alto_img,ancho_img,matRGB);
	    alto_img := alto_img div 2;
	    ancho_img := ancho_img div 2;

	    bitmap.Height:=alto_img;
	    bitmap.Width:=ancho_img;

	    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap);
	    grafico.Picture.Assign(bitmap);
    end;
end;

procedure Tformulario_principal.girarizqClick(Sender: TObject);
var
    alto_aux : Integer;
begin
	girar_izq(alto_img,ancho_img,matRGB);
    alto_aux  := alto_img;
    alto_img  := ancho_img;
    ancho_img := alto_aux;

    bitmap.Height := alto_img;
    bitmap.Width  := ancho_img;

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap);
    grafico.Picture.Assign(bitmap);
end;

procedure Tformulario_principal.girarderClick(Sender: TObject);
var
    alto_aux : Integer;
begin
	girar_der(alto_img,ancho_img,matRGB);
    alto_aux  := alto_img;
    alto_img  := ancho_img;
    ancho_img := alto_aux;

    bitmap.Height := alto_img;
    bitmap.Width  := ancho_img;

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap);
    grafico.Picture.Assign(bitmap);
end;

procedure Tformulario_principal.opcion_gammaClick(Sender: TObject);
begin
    barra_estado.Panels[0].Text:='Aplicando Efecto. Por favor Espere';
    cpCanvtoMatriz(alto_img,ancho_img,matRGB,grafico); // Cargar la informacion de la Imagen en el Bitmap

	filtro_correcion_gamma(alto_img,ancho_img,matRGB);

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap); // Carga la matriz al Bitmap
    //cpMatriztoCanv(alto_img,ancho_img,matRGB,grafico);
    grafico.Picture.Assign(bitmap);

    formulario_histograma.crear_histograma(alto_img,ancho_img,matRGB);
    formulario_histograma.dibujar_histograma(formulario_histograma.grafico_histograma);

    barra_estado.Panels[0].Text:='Efecto Aplicado';
end;

procedure Tformulario_principal.opcion_guardar_imagenClick(Sender: TObject);
begin
	bitmap.SaveToFile('C:\Users\vk\Desktop\imagen_resultante.bmp');
end;

procedure Tformulario_principal.opcion_guardar_comoClick(Sender: TObject);
begin
	if cuadro_salvar.Execute then begin
		bitmap.SaveToFile(cuadro_salvar.FileName);
    end;
end;

end.

