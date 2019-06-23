unit ventana_histograma;

{$mode objfpc}{$H+}
interface

uses
	Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

	{ Tformulario_histograma }

	Tformulario_histograma = class(TForm)
		grafico_histograma: TImage;
		valor_minimo: TLabel;
		valor_maximo: TLabel;
		titulo_histograma: TLabel;
		procedure FormCreate(Sender: TObject);
		private

		public
	end;

var
	formulario_histograma: Tformulario_histograma;

implementation

{$R *.lfm}

{ Tformulario_histograma }

procedure Tformulario_histograma.FormCreate(Sender: TObject);
begin
    formulario_histograma.Height:=200;
	formulario_histograma.Width:=350;

    grafico_histograma.SetBounds(5,25,340,140);
    grafico_histograma.Canvas.Rectangle(0,0,grafico_histograma.Width,grafico_histograma.Height);
end;

end.

