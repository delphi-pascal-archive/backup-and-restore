program BackupRestore;

uses
  Forms,
  MBackupRestore in 'MBackupRestore.pas' {FBackupRestore},
  UThread in 'UThread.pas',
  Gradients in 'Gradients.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFBackupRestore, FBackupRestore);
  Application.Run;
end.
