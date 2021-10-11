UNIT UThread;

INTERFACE

USES
  Classes, SysUtils, Windows, Forms, Controls, UnitProgressForm, Dialogs, MBackupRestore;

TYPE
  TMyThread = CLASS(TThread)
  PRIVATE
    { Déclarations privées }
    PROCEDURE OnTerminateProcedure(Sender: TObject);
    PROCEDURE LancerBackupRestore;

  PROTECTED
    PROCEDURE Execute; OVERRIDE;
  PUBLIC
    CONSTRUCTOR Create(Suspended: Boolean);
  END;

IMPLEMENTATION

CONSTRUCTOR TMyThread.Create(Suspended: Boolean);
BEGIN
  BRActif := true;
  FreeOnTerminate := True;
  INHERITED Create(Suspended);
  OnTerminate := OnTerminateProcedure;
END;

PROCEDURE TMyThread.Execute;
BEGIN
  LancerBackupRestore;
END;

PROCEDURE TMyThread.OnTerminateProcedure(Sender: TObject);
BEGIN
  BRActif := false;
END;

PROCEDURE TMyThread.LancerBackupRestore;
BEGIN
  TRY
    Screen.Cursor := CrHourGlass;
    TRY
      FBackupRestore.EServer.Enabled := false;
      FBackupRestore.EUserName.Enabled := false;
      FBackupRestore.EPassword.Enabled := false;
      FBackupRestore.RGChoixBase.Enabled := false;
      FBackupRestore.RGProtocol.Enabled := false;
      FBackupRestore.BBBackupRestore.Enabled := false;
      FBackupRestore.BBRecupLOG.Enabled := false;
      FBackupRestore.TMAfficheLOG.Clear;
      FBackupRestore.Backup;
      FBackupRestore.Restore;
      Application.MESSAGEBOX('L''opération Backup Restore est terminée !',
        'Fin', MB_OK + MB_ICONINFORMATION);
    EXCEPT
      Application.MESSAGEBOX('Une erreur s''est produite, l''opération est annulée..',
        'Fin', MB_OK + MB_ICONWARNING);
    END;
  FINALLY
    FBackupRestore.EServer.Enabled := true;
    FBackupRestore.EUserName.Enabled := true;
    FBackupRestore.EPassword.Enabled := true;
    FBackupRestore.RGChoixBase.Enabled := true;
    FBackupRestore.RGProtocol.Enabled := true;
    FBackupRestore.BBBackupRestore.Enabled := true;
    FBackupRestore.BBRecupLOG.Enabled := true;
    FBackupRestore.BBRecupLOG.SetFocus;
    Screen.Cursor := CrDefault;
  END;
END;


END.

