/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////// Encha�ner un Backup Restore sur une base  ////////////////////////
///////////////////////  FIREBIRD ou INTERBASE  /////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
///////////////////////// by cantador  //////////////////////////////////////////////////
/////////////////////// pulsar3000@wanadoo.fr  /////////////////////////////////////////
////////////////////////   07 F�vier 2009        /////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

UNIT MBackupRestore;

INTERFACE

USES
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IBServices, StdCtrls, ExtCtrls, Buttons;

TYPE
  TFBackupRestore = CLASS(TForm)
    IBBackupService1: TIBBackupService;
    IBRestoreService1: TIBRestoreService;
    SDChoixBase: TSaveDialog;
    BBRecupLOG: TBitBtn;
    BBBackupRestore: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    RGProtocol: TRadioGroup;
    EUserName: TEdit;
    EPassword: TEdit;
    EServer: TEdit;
    RGChoixBase: TRadioGroup;
    TMAfficheLOG: TMemo;
    PROCEDURE RGChoixBaseClick(Sender: TObject);
    PROCEDURE FormCreate(Sender: TObject);
    PROCEDURE EUserNameChange(Sender: TObject);
    PROCEDURE RGProtocolClick(Sender: TObject);
    PROCEDURE EPasswordChange(Sender: TObject);
    PROCEDURE BBRecupLOGClick(Sender: TObject);
    PROCEDURE BBBackupRestoreClick(Sender: TObject);
    PROCEDURE FormPaint(Sender: TObject);
    PROCEDURE FormCloseQuery(Sender: TObject; VAR CanClose: Boolean);
    PROCEDURE FormResize(Sender: TObject);
  PRIVATE
    { D�clarations priv�es }
    CaptionBtn: TRect;
    PROCEDURE DrawCaptButton;
    PROCEDURE WMNCPaint(VAR Msg: TWMNCPaint); MESSAGE WM_NCPaint;
    PROCEDURE WMNCActivate(VAR Msg: TWMNCActivate); MESSAGE WM_NCACTIVATE;
    PROCEDURE WMSetText(VAR Msg: TWMSetText); MESSAGE WM_SETTEXT;
    PROCEDURE WMNCHitTest(VAR Msg: TWMNCHitTest); MESSAGE WM_NCHITTEST;
    PROCEDURE WMNCLButtonDown(VAR Msg: TWMNCLButtonDown); MESSAGE
      WM_NCLBUTTONDOWN;
    PROCEDURE AfficheBoutonBackupRestore;
    PROCEDURE LancerBackupRestore;
  PUBLIC
    { D�clarations publiques }
    PROCEDURE Backup;
    PROCEDURE Restore;
  END;

VAR
  FBackupRestore: TFBackupRestore;
  FileBackup, FileLog: STRING;
  BRActif: boolean;

CONST
  aColorArray: ARRAY[0..4] OF Tcolor = ($00FFAEAE, $00BBFFBB, $00B3FFFF, $00C1C1FF, $009DE6B9);
  dossierbackup: STRING = 'c:\Temp\';
  dossierrestore: STRING = 'c:\Temp\';
  htCaptionBtn = htSizeLast + 1;

IMPLEMENTATION
USES UThread, Gradients;

{$R *.dfm}

PROCEDURE TFBackupRestore.Backup;
BEGIN
  WITH IBBackupService1 DO
  BEGIN
    ServerName := FBackupRestore.EServer.Text;
    IF FBackupRestore.RGProtocol.ItemIndex = 0 THEN
      Protocol := Local
    ELSE
      Protocol := TCP;
    LoginPrompt := False;
    Params.Add('user_name=' + EUserName.Text); // on stocle le user_name
    Params.Add('password=' + EPassword.Text); // on stocke le mot de passe
    BackupFile.Text := ''; // on vide le backup
    DatabaseName := ''; // on vide la base
    Active := True;
    TRY
      Verbose := true;  // indique que les logs seront visibles
      Options := [NonTransportable, IgnoreLimbo];

{NonTransportable :
Attribuez la valeur true � NonTransportable si vous ne voulez pas que les donn�es soient d�plac�es vers une machine
 avec un syst�me d'exploitation diff�rent de celui sur lequel la sauvegarde a �t� effectu�e.
Si NonTransportable a la valeur false (par d�faut), les donn�es sont enregistr�es dans un format g�n�rique
vous permettant de les restaurer sur toutes les machines qui g�rent InterBase. }

{ IgnoreLimbo :
Les transactions limbo sont g�n�ralement dues � l'�chec d'une validation � deux phases.
Elles peuvent �galement provenir d'un �chec syst�me ou de la pr�paration d'une transaction de base de donn�es unique.
Pour ignorer les transactions limbo lors de la sauvegarde, attribuez la valeur true � IgnoreLimbo.
Si votre application ignore les transactions limbo lors de la sauvegarde, elle ignore toutes les versions d'enregistrements
cr��es par les transactions limbo, recherche la version valid�e la plus r�cente d'un enregistrement et sauvegarde cette version. }


      IF RGChoixBase.ItemIndex = 0 THEN
      BEGIN
        SDChoixBase.Filter := 'Fichiers firebird (*.fdb)|*.fdb';   {permet de filtrer uniquement les .fdb}
        SDChoixBase.DefaultExt := '*.fdb';
        SDChoixBase.Files.Text := '*.fdb';
      END
      ELSE
      BEGIN
        SDChoixBase.Filter := 'Fichiers interbase (*.gdb)|*.gdb';   {permet de filtrer uniquement les .gdb}
        SDChoixBase.DefaultExt := '*.gdb';
        SDChoixBase.Files.Text := '*.gdb';
      END;
      IF SDChoixBase.Execute THEN
      BEGIN
        DatabaseName := SDChoixBase.FileName;
        IF RGChoixBase.ItemIndex = 0 THEN
          FileBackup := dossierbackup + ExtractFileName(ChangeFileExt(DatabaseName, '.fbk')) { Change l'extension }
        ELSE
          FileBackup := dossierbackup + ExtractFileName(ChangeFileExt(DatabaseName, '.gbk'));
      END;

      FileLog := dossierbackup + ExtractFileName(ChangeFileExt(DatabaseName, '.log'));       { Change l'extension }
      IF FileExists(FileBackup) THEN {supprime le fichier backup s'il existe }
        DeleteFile(FileBackup);
      IF FileExists(FileLog) THEN { supprime le fichier log s'il existe }
        DeleteFile(FileLog);
      IF NOT DirectoryExists('c:\Temp') THEN   {cr�e le dossier "tmp' s'il n'existe pas}
        IF NOT CreateDir('c:\Temp') THEN
        BEGIN
          Application.MESSAGEBOX('"BackupRestore" n''a pu cr�er un r�pertoire temporaire et ne peut fonctionner dans ces conditions',
            'Arr�t imm�diat', MB_OK + MB_ICONWARNING);
          exit;
        END;
      BackupFile.Add(FileBackup); // stocke le fichier backup
      
      ServiceStart; // Lance le backup

      WHILE NOT Eof DO
        TMAfficheLOG.Lines.Add(GetNextLine);  {utilsation de la m�thode GerNextLine qui r�cup�re
                                              {directement le script au fur et � mesure }
    FINALLY
      Active := False;
    END;
  END;
END;

PROCEDURE TFBackupRestore.Restore;
BEGIN
  WITH IBRestoreService1 DO
  BEGIN
    ServerName := EServer.Text;
    IF RGProtocol.ItemIndex = 0 THEN
      Protocol := Local
    ELSE
      Protocol := TCP;
    LoginPrompt := False;
    Params.Add('user_name=' + EUserName.Text);
    Params.Add('password=' + EPassword.Text);
    BackupFile.Text := '';
    DataBaseName.Text := '';
    Active := True;
    TRY
      Verbose := true;
      Options := [Replace, UseAllSpace];
{Replace :
Votre application ne peut pas �craser un fichier de base de donn�es,
sauf si vous attribuez la valeur true � Replace.
Si vous essayez d'effectuer une restauration d'une base de donn�es existante
alors que cette option n'est pas d�finie, la restauration �choue.
Important�: Ne restaurez pas un fichier de base de donn�es existant
si des clients l'utilisent.
Renommez ce fichier, restaurez la base de donn�es,
puis d�placez ou archivez l'ancienne base de donn�es, selon le cas.
}

{UseAllSpace
Quand InterBase ou Firebird restaure une base de donn�es,
il remplit par d�faut chaque page de donn�es � 80�% de sa capacit�.
Pour que votre application restaure une base de donn�es avec un coefficient
de remplissage de 100�% sur chaque page de donn�es, attribuez la valeur true
� l'option UseAllSpace.}

      PageBuffers := 3000;
      PageSize := 4096;
      IF RGChoixBase.ItemIndex = 0 THEN
        DatabaseName.Add(dossierrestore + ExtractFileName(ChangeFileExt(FileBackup, '.fdb')))
      ELSE
        DatabaseName.Add(dossierrestore + ExtractFileName(ChangeFileExt(FileBackup, '.gdb')));
      BackupFile.Add(FileBackup);

      ServiceStart;     {lance le restore }

      WHILE NOT Eof DO
        TMAfficheLOG.Lines.Add(GetNextLine);
    FINALLY
      Active := False;
    END;
  END;
END;

PROCEDURE TFBackupRestore.LancerBackupRestore;
VAR
  MyThread_Prioritaire: TMyThread;
BEGIN             { un petit thread pour ne pas bloquer la fen�tre pendant l'op�ration}
  MyThread_Prioritaire := TMyThread.Create(False);
  MyThread_Prioritaire.Priority := tpTimeCritical;
END;

PROCEDURE TFBackupRestore.AfficheBoutonBackupRestore;
BEGIN       { proc�dure pour acc�der au bouton backup Restore sous certaines conditions}
  BBBackupRestore.Enabled := (RGChoixBase.ItemIndex <> -1) AND
    (EUserName.Text <> '') AND (EPassword.Text <> '') AND
    (RGProtocol.ItemIndex <> -1);
  BBRecupLOG.Enabled := false;
END;

PROCEDURE TFBackupRestore.RGChoixBaseClick(Sender: TObject);
BEGIN
  AfficheBoutonBackupRestore;
END;

PROCEDURE TFBackupRestore.FormCreate(Sender: TObject);
BEGIN
  BRActif := false;
  BBBackupRestore.Enabled := false;
  BBRecupLOG.Enabled := false;
  Application.HintPause := 50;           {augmente la vitesse d'appartition des bulles}
  Application.HintHidePause := 3000;     {allonge la dur�e d'affichage des bulles}
END;

PROCEDURE TFBackupRestore.EUserNameChange(Sender: TObject);
BEGIN
  AfficheBoutonBackupRestore;
END;

PROCEDURE TFBackupRestore.RGProtocolClick(Sender: TObject);
BEGIN
  AfficheBoutonBackupRestore;
END;

PROCEDURE TFBackupRestore.EPasswordChange(Sender: TObject);
BEGIN
  AfficheBoutonBackupRestore;
END;

PROCEDURE TFBackupRestore.BBRecupLOGClick(Sender: TObject);
BEGIN
  TRY
    IF TMAfficheLOG.Lines.Count = 0 THEN
    BEGIN
      ShowMessage('Le Memo est vide !');
      exit;
    END;
    Screen.Cursor := CrHourGlass;
    TMAfficheLOG.Lines.SaveToFile(dossierbackup + ExtractFileName(ChangeFileExt(FileBackup, '.log')));
    ShowMessage('logs r�cup�r�s !');
  FINALLY
    Screen.Cursor := CrDefault;
  END;
END;

PROCEDURE TFBackupRestore.BBBackupRestoreClick(Sender: TObject);
BEGIN
  LancerBackupRestore;
END;

PROCEDURE TFBackupRestore.FormPaint(Sender: TObject);
BEGIN
/////////////////////////// cirec  ////////////////////////////////////////////////////
//////////////////////// voir gradients remani� par f0xi //////////////////////////////
  GradientTriangle(Canvas.Handle, aColorArray, ClientRect);
END;

PROCEDURE TFBackupRestore.FormCloseQuery(Sender: TObject;
  VAR CanClose: Boolean);
BEGIN
  IF BRActif THEN
  BEGIN
    Application.MessageBox('Ne fermez pas cette fen�tre avant l''arr�t complet !',
      'Information', MB_OK + MB_ICONWARNING);
    CanClose := false;
  END
  ELSE
    CanClose := true;
END;

PROCEDURE TFBackupRestore.DrawCaptButton; //////////// by FOBEC  ///////////////////
VAR
  xFrame, yFrame, xSize, ySize: Integer;
  R: TRect;
BEGIN
  //Dimension de la barre de titre
  xFrame := GetSystemMetrics(SM_CXFRAME);
  yFrame := GetSystemMetrics(SM_CYFRAME);

  //Dimension des buttons
  xSize := GetSystemMetrics(SM_CXSIZE);
  ySize := GetSystemMetrics(SM_CYSIZE);

  //Position du nouveau button
  CaptionBtn := Bounds(Width - xFrame - 10 * xSize + 2, yFrame + 2, xSize - 8, ySize - 10);

 //Handle du canvas
  Canvas.Handle := GetWindowDC(Self.Handle);

  Canvas.Font.Name := 'Arial';
  Canvas.Font.Color := ClBlack;
  Canvas.Font.Style := [fsBold];
  Canvas.Pen.Color := clYellow;
  Canvas.Brush.Color := clBtnFace;

  TRY
    DrawButtonFace(Canvas, CaptionBtn, 1, bsAutoDetect, False, False, False);
    //Cr�ation du button
    R := Bounds(Width - xFrame - 10 * xSize + 2, yFrame + 3, xSize - 8, ySize - 10);

    WITH CaptionBtn DO
      Canvas.TextRect(R, R.Left + 2, R.Top - 1, ' X');

  FINALLY
    ReleaseDC(Self.Handle, Canvas.Handle);
    Canvas.Handle := 0;
  END;
END;

PROCEDURE TFBackupRestore.WMNCPaint(VAR Msg: TWMNCPaint);
BEGIN
  INHERITED;
  // DrawCaptButton;
END;

PROCEDURE TFBackupRestore.WMNCActivate(VAR Msg: TWMNCActivate);
BEGIN
  INHERITED;
  DrawCaptButton;
END;

PROCEDURE TFBackupRestore.WMSetText(VAR Msg: TWMSetText);
BEGIN
  INHERITED;
  DrawCaptButton;
END;

PROCEDURE TFBackupRestore.WMNCHitTest(VAR Msg: TWMNCHitTest);
BEGIN
  INHERITED;
  WITH Msg DO
    IF PtInRect(CaptionBtn, Point(XPos - Left, YPos - Top)) THEN
      Result := htCaptionBtn;
END;

PROCEDURE TFBackupRestore.WMNCLButtonDown(VAR Msg: TWMNCLButtonDown);
BEGIN
  INHERITED;
  IF (Msg.HitTest = htCaptionBtn) THEN
    Close;
END;

PROCEDURE TFBackupRestore.FormResize(Sender: TObject);
BEGIN
  // Redimension de la form
  // Perform(WM_NCACTIVATE, Word(Active), 0);
END;

END.

