unit USobre;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, jpeg, ExtCtrls;

type
  TFSobre = class(TForm)
    btnFechar: TBitBtn;
    logo: TImage;
    Panel1: TPanel;
    StaticText6: TStaticText;
    StaticText4: TStaticText;
    StaticText3: TStaticText;
    StaticText2: TStaticText;
    StaticText1: TStaticText;
    procedure btnFecharClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FSobre: TFSobre;

implementation

{$R *.dfm}

procedure TFSobre.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFSobre.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then
    Close;
end;

end.
