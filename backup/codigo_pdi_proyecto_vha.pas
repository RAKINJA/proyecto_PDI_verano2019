unit codigo_pdi_proyecto_vha;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ExtCtrls, stdCtrls,
  ExtDlgs, LCLintf, ComCtrls, funciones_control, metodos_proyecto_pid_vha, ventana_histograma,
  ventana_umbral,ventana_gamma,ventana_contraste,ventana_segmentacion;

type

  { Tformulario_principal }

	matrizRGB = Array of Array of Array of Byte; // Matriz de MxN para cada canal R,G,B

  	cambio = record
		alto, ancho : Integer;
        imagen : TBitmap;
	end;

  Tformulario_principal = class(TForm)
    grafico: TImage;
    lista_imagenes: TImageList;
	opcion_segmentacion: TMenuItem;
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
    procedure graficoMouseMove(Sender: TObject; Shift: TShiftState; X,
        Y: Integer);
	procedure menu_edicionClick(Sender: TObject);
	procedure opcion_deshacerClick(Sender: TObject);
	procedure opcion_rehacerClick(Sender: TObject);
	procedure opcion_segmentacionClick(Sender: TObject);
    procedure opcion_contrasteClick(Sender: TObject);
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

    histograma_nuevo,activo_original : Boolean;

    cambios : Array of cambio;
    contador_cambios, maximo_cambios : Integer;

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

    // inhabilita elementos y menus
    menu_edicion.Enabled		  := false;
    menu_filtros.Enabled 		  := false;
    menu_ventana.Enabled          := false;
    opcion_guardar_imagen.Enabled := false;
    opcion_guardar_como.Enabled   := false;
    barra_opciones.Enabled := false;

    // variables
    activo_original  := false;
    contador_cambios := 0;
    maximo_cambios   := 0;
end;

procedure Tformulario_principal.opcion_originalClick(Sender: TObject);
begin
    if not activo_original then begin
    	grafico.Picture.Assign(bitmap_original);
        opcion_original.Caption:='Ocultar Original';
		activo_original := true;
	end else begin
		grafico.Picture.Assign(bitmap);
        opcion_original.Caption:='Mostrar Original';
        activo_original := false;
	end;
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

        inc(contador_cambios);
        inc(maximo_cambios);
        SetLength(cambios,contador_cambios);// Agrega la imagen original al arreglo de cambios

        grafico.Enabled:=True; // habilitar el TImage

		cpBMtoMatriz(alto_img,ancho_img,matRGB,bitmap); // llama a la funcion para asignar los datos del bitmap a la matriz
        grafico.Picture.Assign(bitmap);
        bitmap_original.Assign(grafico.Picture.Bitmap);

        metodos_proyecto_pid_vha.avance:=(alto_img*ancho_img) div 100;

        barra_opciones.Enabled:=true;

        menu_edicion.Enabled := true;
    	menu_filtros.Enabled := true;
	    menu_ventana.Enabled := true;

        opcion_guardar_imagen.Enabled := true; // habilita la opcion de guardar
        opcion_guardar_como.Enabled   := true;

        histograma_nuevo := true;

        barra_estado.Panels[0].Text:='Imagen Cargada';
    end;
end;

procedure Tformulario_principal.opcion_histogramaClick(Sender: TObject);
begin
    formulario_histograma.imagen_intensidad.Assign(grafico.Picture.Graphic);    // se le asigna la imagen
	                                                                                // al bitmap del histograma
    formulario_histograma.show;
    if histograma_nuevo then begin
    	formulario_histograma.crear_histograma(alto_img,ancho_img,matRGB);
        formulario_histograma.dibujar_histograma(formulario_histograma.grafico_histograma);
        histograma_nuevo := false;
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

    // actualiza el histograma
    formulario_histograma.imagen_intensidad.Assign(grafico.Picture.Graphic);
    formulario_histograma.crear_histograma(alto_img,ancho_img,matRGB);
    formulario_histograma.dibujar_histograma(formulario_histograma.grafico_histograma);

    // actualiza los cambios
    SetLength(cambios,contador_cambios);
    maximo_cambios := contador_cambios;

    cambios[contador_cambios].imagen.Assign(bitmap);
    cambios[contador_cambios].alto := alto_img;
    cambios[contador_cambios].ancho := ancho_img;

    barra_estado.Panels[0].Text:='Efecto Aplicado';
end;

procedure Tformulario_principal.opcion_grises_rClick(Sender: TObject);
begin
    barra_estado.Panels[0].Text:='Aplicando Efecto. Por favor Espere';

	cpCanvtoMatriz(alto_img,ancho_img,matRGB,grafico); // Cargar la informacion de la Imagen en el Bitmap

    filtro_grises_r(alto_img,ancho_img,matRGB);

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap); // Carga la matriz al Bitmap
    cpMatriztoCanv(alto_img,ancho_img,matRGB,grafico);

    formulario_histograma.imagen_intensidad.Assign(grafico.Picture.Graphic);
    formulario_histograma.crear_histograma(alto_img,ancho_img,matRGB);
    formulario_histograma.dibujar_histograma(formulario_histograma.grafico_histograma);

    // actualiza los cambios
    SetLength(cambios,contador_cambios);
    maximo_cambios := contador_cambios;

    cambios[contador_cambios].imagen.Assign(bitmap);
    cambios[contador_cambios].alto := alto_img;
    cambios[contador_cambios].ancho := ancho_img;

    barra_estado.Panels[0].Text:='Efecto Aplicado';
end;

procedure Tformulario_principal.opcion_grises_gClick(Sender: TObject);
begin
    barra_estado.Panels[0].Text:='Aplicando Efecto. Por favor Espere';

    cpCanvtoMatriz(alto_img,ancho_img,matRGB,grafico); // Cargar la informacion de la Imagen en el Bitmap

    filtro_grises_g(alto_img,ancho_img,matRGB);

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap); // Carga la matriz al Bitmap
    cpMatriztoCanv(alto_img,ancho_img,matRGB,grafico);

    formulario_histograma.imagen_intensidad.Assign(grafico.Picture.Graphic);
    formulario_histograma.crear_histograma(alto_img,ancho_img,matRGB);
    formulario_histograma.dibujar_histograma(formulario_histograma.grafico_histograma);

    // actualiza los cambios
    SetLength(cambios,contador_cambios);
    maximo_cambios := contador_cambios;

    cambios[contador_cambios].imagen.Assign(bitmap);
    cambios[contador_cambios].alto := alto_img;
    cambios[contador_cambios].ancho := ancho_img;

    barra_estado.Panels[0].Text:='Efecto Aplicado';
end;

procedure Tformulario_principal.opcion_grises_bClick(Sender: TObject);
begin
    barra_estado.Panels[0].Text:='Aplicando Efecto. Por favor Espere';

	cpCanvtoMatriz(alto_img,ancho_img,matRGB,grafico); // Cargar la informacion de la Imagen en el Bitmap

    filtro_grises_b(alto_img,ancho_img,matRGB);

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap); // Carga la matriz al Bitmap
    cpMatriztoCanv(alto_img,ancho_img,matRGB,grafico);

    formulario_histograma.imagen_intensidad.Assign(grafico.Picture.Graphic);
    formulario_histograma.crear_histograma(alto_img,ancho_img,matRGB);
    formulario_histograma.dibujar_histograma(formulario_histograma.grafico_histograma);

    // actualiza los cambios
    SetLength(cambios,contador_cambios);
    maximo_cambios := contador_cambios;

    cambios[contador_cambios].imagen.Assign(bitmap);
    cambios[contador_cambios].alto := alto_img;
    cambios[contador_cambios].ancho := ancho_img;

    barra_estado.Panels[0].Text:='Efecto Aplicado';
end;

procedure Tformulario_principal.opcion_negativoClick(Sender: TObject);
begin
    barra_estado.Panels[0].Text:='Aplicando Efecto. Por favor Espere';

    filtro_negativo(alto_img,ancho_img,matRGB);

    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap); // Carga la matriz al Bitmap
    grafico.Picture.Assign(bitmap);

    formulario_histograma.imagen_intensidad.Assign(grafico.Picture.Graphic);
    formulario_histograma.crear_histograma(alto_img,ancho_img,matRGB);
    formulario_histograma.dibujar_histograma(formulario_histograma.grafico_histograma);

    // actualiza los cambios
    SetLength(cambios,contador_cambios);
    maximo_cambios := contador_cambios;

    cambios[contador_cambios].imagen.Assign(bitmap);
    cambios[contador_cambios].alto := alto_img;
    cambios[contador_cambios].ancho := ancho_img;

    barra_estado.Panels[0].Text:='Efecto Aplicado';
end;

procedure Tformulario_principal.opcion_umbralClick(Sender: TObject);
begin
    filtro_grises_global(alto_img,ancho_img,matRGB);

    //cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap);

    formulario_umbral.grafico_umbral.Picture.Assign(bitmap); // Asigna el bitmap al TImage de la ventana de Umbral
    formulario_umbral.promedio_umbral := formulario_umbral.umbral_promedio(alto_img,ancho_img,matRGB); // Obtiene el promedio y lo guarda en la variable
																									   // del formuario de Umbral
    formulario_umbral.showModal; // Muestra el Umbral

    if formulario_umbral.ModalResult = MrOk then begin
        cpMatriztoBM(alto_img,ancho_img,formulario_umbral.matriz_umbral,bitmap);
        cpBmtoMatriz(alto_img,ancho_img,matRGB,bitmap);
        grafico.Picture.Assign(bitmap);
        //cpMatriztoCanv(alto_img,ancho_img,matRGB,grafico);

        formulario_histograma.imagen_intensidad.Assign(grafico.Picture.Graphic);
        formulario_histograma.crear_histograma(alto_img,ancho_img,matRGB);
        formulario_histograma.dibujar_histograma(formulario_histograma.grafico_histograma);

        // actualiza los cambios
    	SetLength(cambios,contador_cambios);
    	maximo_cambios := contador_cambios;

    	cambios[contador_cambios].imagen.Assign(bitmap);
    	cambios[contador_cambios].alto := alto_img;
	    cambios[contador_cambios].ancho := ancho_img;
	end;
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

    // actualiza los cambios
    SetLength(cambios,contador_cambios);
    maximo_cambios := contador_cambios;

    cambios[contador_cambios].imagen.Assign(bitmap);
    cambios[contador_cambios].alto := alto_img;
    cambios[contador_cambios].ancho := ancho_img;
end;

procedure Tformulario_principal.zoomoutClick(Sender: TObject);
begin
    if (alto_img > 5) and (ancho_img > 5) then begin
        zoom_out(alto_img,ancho_img,matRGB);
	    alto_img := alto_img div 2;
	    ancho_img := ancho_img div 2;

	    bitmap.Height:=alto_img;
	    bitmap.Width:=ancho_img;

	    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap);
	    grafico.Picture.Assign(bitmap);

        // actualiza los cambios
    	SetLength(cambios,contador_cambios);
    	maximo_cambios := contador_cambios;

    	cambios[contador_cambios].imagen.Assign(bitmap);
    	cambios[contador_cambios].alto := alto_img;
    	cambios[contador_cambios].ancho := ancho_img;
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

    // actualiza los cambios
    SetLength(cambios,contador_cambios);
    maximo_cambios := contador_cambios;

    cambios[contador_cambios].imagen.Assign(bitmap);
    cambios[contador_cambios].alto := alto_img;
    cambios[contador_cambios].ancho := ancho_img;
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

    // actualiza los cambios
    SetLength(cambios,contador_cambios);
    maximo_cambios := contador_cambios;

    cambios[contador_cambios].imagen.Assign(bitmap);
    cambios[contador_cambios].alto := alto_img;
    cambios[contador_cambios].ancho := ancho_img;
end;

procedure Tformulario_principal.graficoMouseMove(Sender: TObject;
    Shift: TShiftState; X, Y: Integer);
begin
    barra_estado.Panels[1].Text:='RGB = ('+IntToStr(matRGB[X,Y,2])+','+IntToStr(matRGB[X,Y,1])+','+IntToStr(matRGB[X,Y,0])+')';
end;

procedure Tformulario_principal.menu_edicionClick(Sender: TObject);
begin
    if contador_cambios = maximo_cambios then opcion_rehacer.Enabled:=false;

	if contador_cambios < 2 then opcion_deshacer.Enabled := false;
end;

procedure Tformulario_principal.opcion_deshacerClick(Sender: TObject);
begin
	contador_cambios := contador_cambios-1;
    alto_img  := cambios[contador_cambios].alto;
    ancho_img := cambios[contador_cambios].ancho;

    grafico.Height := alto_img;
    grafico.Width  := ancho_img;

    grafico.Picture.Assign(cambios[contador_cambios].imagen);
    bitmap.Assign(cambios[contador_cambios].imagen);
	cpBMtoMatriz(alto_img,ancho_img,matRGB,bitmap);
end;

procedure Tformulario_principal.opcion_rehacerClick(Sender: TObject);
begin
    if contador_cambios < maximo_cambios then begin

	contador_cambios := contador_cambios+1;
    alto_img  := cambios[contador_cambios].alto;
    ancho_img := cambios[contador_cambios].ancho;

    grafico.Height := alto_img;
    grafico.Width  := ancho_img;

    grafico.Picture.Assign(cambios[contador_cambios].imagen);
    bitmap.Assign(cambios[contador_cambios].imagen);
	cpBMtoMatriz(alto_img,ancho_img,matRGB,bitmap);
end;

procedure Tformulario_principal.opcion_segmentacionClick(Sender: TObject);
begin
    filtro_grises_global(alto_img,ancho_img,matRGB); // aplica filtro de grises a la matriz actual
    cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap); // copal la matriz al bitmap

	ventana_segmentacion.formulario_segmentacion.imagen_original.Assign(bitmap);
    ventana_segmentacion.formulario_segmentacion.grafico_segmentacion.Height := alto_img;
	ventana_segmentacion.formulario_segmentacion.grafico_segmentacion.Width  := ancho_img;

    ventana_segmentacion.formulario_segmentacion.ShowModal;

    if ventana_segmentacion.formulario_segmentacion.ModalResult = MrOk then begin
    	cpMatriztoBM(alto_img,ancho_img,formulario_segmentacion.matriz_segmentacion,bitmap);
        cpBmtoMatriz(alto_img,ancho_img,matRGB,bitmap);
        grafico.Picture.Assign(bitmap);

        formulario_histograma.imagen_intensidad.Assign(grafico.Picture.Graphic);
        formulario_histograma.crear_histograma(alto_img,ancho_img,matRGB);
        formulario_histograma.dibujar_histograma(formulario_histograma.grafico_histograma);

        // actualiza los cambios
	    SetLength(cambios,contador_cambios);
    	maximo_cambios := contador_cambios;

	    cambios[contador_cambios].imagen.Assign(bitmap);
	    cambios[contador_cambios].alto := alto_img;
	    cambios[contador_cambios].ancho := ancho_img;
	end;
end;

procedure Tformulario_principal.opcion_contrasteClick(Sender: TObject);
begin
    barra_estado.Panels[0].Text:='Aplicando Efecto. Por favor Espere';

    formulario_contraste.grafico_contraste.Height := bitmap.Height;
    formulario_contraste.grafico_contraste.Width  := bitmap.Width;
    formulario_contraste.grafico_contraste.Picture.Assign(bitmap);

    formulario_contraste.ShowModal;
    if formulario_contraste.ModalResult = MrOk then begin
    	cpMatriztoBM(alto_img,ancho_img,formulario_contraste.matriz_contraste,bitmap);
        cpBmtoMatriz(alto_img,ancho_img,matRGB,bitmap);
        grafico.Picture.Assign(bitmap);

        formulario_histograma.imagen_intensidad.Assign(grafico.Picture.Graphic);
        formulario_histograma.crear_histograma(alto_img,ancho_img,matRGB);
        formulario_histograma.dibujar_histograma(formulario_histograma.grafico_histograma);

        // actualiza los cambios
	    SetLength(cambios,contador_cambios);
	    maximo_cambios := contador_cambios;

	    cambios[contador_cambios].imagen.Assign(bitmap);
	    cambios[contador_cambios].alto := alto_img;
	    cambios[contador_cambios].ancho := ancho_img;
    end;
    barra_estado.Panels[0].Text:='Efecto Aplicado';
end;

procedure Tformulario_principal.opcion_gammaClick(Sender: TObject);
begin
    barra_estado.Panels[0].Text:='Aplicando Efecto, por favor espere..';

    //cpMatriztoBM(alto_img,ancho_img,matRGB,bitmap);
    formulario_gamma.grafico_gamma.Height :=bitmap.Height;
    formulario_gamma.grafico_gamma.Width  :=bitmap.Width;
    formulario_gamma.grafico_gamma.Picture.Assign(bitmap);

    formulario_gamma.ShowModal;
    if formulario_gamma.ModalResult = MrOk then begin
    	cpMatriztoBM(alto_img,ancho_img,formulario_gamma.matriz_gamma,bitmap);
        cpBMtoMatriz(alto_img,ancho_img,matRGB,bitmap);
        grafico.Picture.Assign(bitmap);

        formulario_histograma.imagen_intensidad.Assign(grafico.Picture.Graphic);
        formulario_histograma.crear_histograma(alto_img,ancho_img,matRGB);
        formulario_histograma.dibujar_histograma(formulario_histograma.grafico_histograma);
    end;

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

