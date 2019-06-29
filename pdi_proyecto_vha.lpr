program pdi_proyecto_vha;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, codigo_pdi_proyecto_vha, metodos_proyecto_pid_vha,
  ventana_histograma, funciones_control, ventana_umbral, ventana_gamma, ventana_contraste
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
		Application.Title:='Proyecto PDI - VHA';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(Tformulario_principal, formulario_principal);
		Application.CreateForm(Tformulario_histograma, formulario_histograma);
    Application.CreateForm(Tformulario_umbral, formulario_umbral);
    Application.CreateForm(Tformulario_gamma, formulario_gamma);
    Application.CreateForm(Tformulario_contraste, formulario_contraste);
  Application.Run;
end.

