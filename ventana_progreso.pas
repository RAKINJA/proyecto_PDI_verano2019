unit ventana_progreso;

{$mode objfpc}{$H+}

interface

uses
 Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
 StdCtrls;

type

 { Tformulario_progreso }

 Tformulario_progreso = class(TForm)
  barra_progreso: TProgressBar;
  pasos: TLabel;
  titulo_progreso: TLabel;
  procedure FormCreate(Sender: TObject);
 private
  { private declarations }
 public
  { public declarations }
 end;

var
 formulario_progreso: Tformulario_progreso;

implementation

{$R *.lfm}

{ Tformulario_progreso }

procedure Tformulario_progreso.FormCreate(Sender: TObject);
begin
	formulario_progreso.Width  := 350;
    formulario_progreso.Height := 100;

    barra_progreso.SetBounds(10,60,330,30);

    barra_progreso.Min:=0;
    //barra_progreso.Max:=;
end;

end.

