UNIT UnitProgressForm;

INTERFACE

USES
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls;

TYPE
  TProgressform = CLASS(TForm)
    ProgressBar1: TProgressBar;
    Label1: TLabel;
  PRIVATE
    { D�clarations priv�es }
  PUBLIC
    { D�clarations publiques }
  END;

VAR
  Progressform: TProgressform;

IMPLEMENTATION

{$R *.dfm}

END.

