//BOOL GradientFill(
//  HDC hdc,                   // handle to DC
//  PTRIVERTEX pVertex,        // array of vertices
//  ULONG dwNumVertex,         // number of vertices
//  PVOID pMesh,               // array of gradients
//  ULONG dwNumMesh,           // size of gradient array
//  ULONG dwMode               // gradient fill mode
//);


//typedef struct _TRIVERTEX {
//  LONG        x;
//  Long        y;
//  COLOR16     Red;
//  COLOR16     Green;
//  COLOR16     Blue;
//  COLOR16     Alpha;
//}TRIVERTEX, *PTRIVERTEX;


//typedef struct _GRADIENT_RECT {
//  ULONG    UpperLeft;
//  ULONG    LowerRight;
//}GRADIENT_RECT, *PGRADIENT_RECT;
   


Unit Gradients;

Interface
Uses Windows, Graphics, SysUtils;
Function GradientRect(Dc: THandle; ColorArray: Array Of TColor; aRect: TRect;
  Direction: Integer): Boolean;
Function GradientTriangle(Dc: THandle; ColorArray: Array Of TColor; aRect:
  TRect): Boolean;

Implementation

{$IFNDEF VER170}
Type
{$EXTERNALSYM COLOR16}
  COLOR16 = Word;

  PTriVertex = ^TTriVertex;
  
{$EXTERNALSYM _TRIVERTEX}
  _TRIVERTEX = Packed Record
    X,Y : Longint;
    Red, Green, Blue, Alpha: COLOR16;
  End;
  TTriVertex = _TRIVERTEX;
{$EXTERNALSYM TRIVERTEX}
  TRIVERTEX = _TRIVERTEX;

Function GradientFill(DC: HDC; Vertex: PTriVertex; NumVertex: ULONG; Mesh:
  Pointer; NumMesh, Mode: ULONG): BOOL; Stdcall;
  External 'msimg32.dll' name 'GradientFill';
{$ENDIF}

{*******************************************************************************
        structure qui contient les différentes séquences
              permettant de dessiner les triangles
********************************************************************************}
Var
  TriSequence         : Array[1..8] Of Array Of TGRADIENTTRIANGLE;
{*******************************************************************************
          Modification par F0xi
********************************************************************************}
procedure PointTVX(out TVX : TTriVertex; const aX,aY : LongInt); forward;
Procedure ColorTVX(out TVX : TTriVertex; const aRed,aGreen,aBlue : COLOR16; const aAlpha : COLOR16 = 0); overload; forward;
Procedure ColorTVX(out TVX : TTriVertex; const aCol : TColor; const aAlpha : COLOR16 = 0); overload; forward;
procedure TriVertexP(out TVX : TTriVertex; const aX,aY : LongInt;const aRed,aGreen,aBlue : COLOR16; const aAlpha : COLOR16 = 0); overload; forward;
procedure TriVertexP(out TVX : TTriVertex; const aX,aY : LongInt;const aCol : Tcolor; const aAlpha : COLOR16 = 0); overload; forward;
function TriVertexF(const aX,aY : LongInt;const aRed,aGreen,aBlue : COLOR16; const aAlpha : COLOR16 = 0) : TTriVertex; overload; forward;
function TriVertexF(const aX,aY : LongInt;const aCol : Tcolor; const aAlpha : COLOR16 = 0) : TTriVertex; overload; forward;

// ajouté sur une idée de F0xi
//  permet de calculer la largeur d'un rectangle
Function GetRectWidth(aRect : TRect):Integer;
Begin
  Result := aRect.Right - aRect.Left;
End;


//  permet de calculer la longueur d'un rectangle
Function GetRectHeight(aRect : TRect):Integer;
Begin
  Result := aRect.Bottom - aRect.Top;
End;

// permet de definir rapidement les coordonées
procedure PointTVX(out TVX : TTriVertex; const aX,aY : LongInt);
begin
  TVX.X := aX;
  TVX.Y := aY;
end;

// permet de definir rapidement la couleur
Procedure ColorTVX(out TVX : TTriVertex; const aRed,aGreen,aBlue : COLOR16; const aAlpha : COLOR16 = 0);
begin
  With TVX do begin
    Red   := aRed;
    Green := aGreen;
    Blue  := aBlue;
    Alpha := aAlpha
  end;
end;

// en incluant les traitements
Procedure ColorTVX(out TVX : TTriVertex; const aCol : TColor; const aAlpha : COLOR16 = 0);
begin
  With TVX do begin
    Red   := GetRValue(aCol) Shl 8;
    Green := GetGValue(aCol) Shl 8;
    Blue  := GetBValue(aCol) Shl 8;
    Alpha := aAlpha
  end;
end;

// permet de definir rapidement un element TTriVertex

procedure TriVertexP(out TVX : TTriVertex; const aX,aY : LongInt;const aRed,aGreen,aBlue : COLOR16; const aAlpha : COLOR16 = 0);
begin
  PointTVX(TVX,aX,aY);
  ColorTVX(TVX,aRed,aGreen,aBlue,aAlpha);
end;

procedure TriVertexP(out TVX : TTriVertex; const aX,aY : LongInt;const aCol : TColor; const aAlpha : COLOR16 = 0);
begin
  PointTVX(TVX,aX,aY);
  ColorTVX(TVX,aCol,aAlpha);
end;

function TriVertexF(const aX,aY : LongInt;const aRed,aGreen,aBlue : COLOR16; const aAlpha : COLOR16 = 0) : TTriVertex;
begin
  PointTVX(result,aX,aY);
  ColorTVX(result,aRed,aGreen,aBlue,aAlpha);
end;

function TriVertexF(const aX,aY : LongInt;const aCol : TColor; const aAlpha : COLOR16 = 0) : TTriVertex;
begin
  PointTVX(result,aX,aY);
  ColorTVX(result,aCol,aAlpha);
end;

//ajout de methode pour TGRADIENTTRIANGLE :
procedure GradientTriP(out aGT : TGRADIENTTRIANGLE; const Vx1, Vx2, Vx3 : cardinal);
begin
  aGT.Vertex1 := Vx1;
  aGT.Vertex2 := Vx2;
  aGT.Vertex3 := Vx3;
end;

function GradientTriF(const Vx1, Vx2, Vx3 : cardinal) : TGRADIENTTRIANGLE;
begin
  result.Vertex1 := Vx1;
  result.Vertex2 := Vx2;
  result.Vertex3 := Vx3;
end;

//Ajout de methodes pour le type TGRADIENTRECT :
procedure GrdRect(out aGR : TGRADIENTRECT; const aUL,aLR : cardinal);
begin
  aGR.UpperLeft := aUL;
  aGR.LowerRight:= aLR;
end;

{*******************************************************************************
          Function qui realise un dégradé en Hozizontal où Vertical
********************************************************************************}
Function GradientRect(Dc: THandle; ColorArray: Array Of TColor; aRect: TRect; Direction: Integer): Boolean;
Var Idx, aHeight, aWidth, nbCycle,pX,pY : Integer;
  Vert  : Array Of TTrivertEx;
  gRect : Array Of TGRADIENTRECT;
  //aCanvas : TCanvas;
  aBrush: TBrush;
Begin
  nbCycle := Length(ColorArray);

  If NbCycle < 2 Then
  Begin
//    aCanvas := TCanvas.Create;
//    aCanvas.Handle := DC;
    If NbCycle = 1 Then
    begin
      aBrush := TBrush.Create;
      try
        aBrush.Color := ColorArray[0];
        //aCanvas.FillRect(aRect);
        FillRect(Dc, aRect, aBrush.Handle);
      finally
        aBrush.Free;
      end;
    end;
//    aCanvas.Free;
  Exit;
  End;

  SetLength(Vert, nbCycle);
  SetLength(gRect, nbCycle - 1);

  aHeight := GetRectHeight(aRect);
  aWidth  := GetRectWidth(aRect);
  PX := 0;
  PY := 0;

  For Idx := 0 To High(Vert) Do begin
      Case Direction Of
        GRADIENT_FILL_RECT_V : Begin
           If Idx Mod 2 = 0 Then pX := 0 Else pX := aWidth;
           pY := Round(aHeight / (nbCycle - 1) * Idx);
        End;
        GRADIENT_FILL_RECT_H : Begin
           If Idx Mod 2 = 0 Then pY := 0 Else pY := aHeight;
           pX := Round(aWidth / (nbCycle - 1) * Idx);
        End;
      End;
      TriVertexP(Vert[Idx],PX,PY, ColorArray[Idx]);
  End;

  For Idx := 0 To High(gRect) Do
      GrdRect(gRect[Idx],Idx,Idx + 1);

  Result := GradientFill( Dc, PTRIVERTEX(vert), nbCycle, PGradientRect(gRect), nbCycle-1, Direction);
End;

{*******************************************************************************
          Fin des Modifications par F0xi
********************************************************************************}


{*******************************************************************************
          Function qui realise un dégradé en Hozizontal où Vertical
********************************************************************************}

{Function GradientRect(Dc: THandle; ColorArray: Array Of TColor; aRect: TRect;
  Direction: Integer): Boolean;
Var Idx, aHeight, aWidth, nbCycle: Integer;
  Vert                : Array Of TTrivertEx;
    // Structure contenant les informations de couleurs et de positions
  gRect               : Array Of TGRADIENTRECT;
    // Structure specifiant deux Index de vertex repesentant le coin superieur gauche et inferieur droit

Begin
  nbCycle := Length(ColorArray);
  SetLength(Vert, nbCycle); // on specifie la taille du tableau de TriVertEx
  SetLength(gRect, nbCycle - 1);
    // on specifie la taille du tableau de TGradientRect
  aHeight := aRect.Bottom - aRect.Top;
  aWidth := aRect.Right - aRect.Left;
  For Idx := 0 To High(Vert) Do
    With Vert[Idx] Do
      Begin
        Case Direction Of
          // Calcule de taille et de position des rectangles en fonction de la direction
          GRADIENT_FILL_RECT_V:
            Begin
              If Idx Mod 2 = 0 Then x := 0
              Else X := aWidth;
              Y := Round(aHeight / (nbCycle - 1) * Idx);
            End;
          GRADIENT_FILL_RECT_H:
            Begin
              If Idx Mod 2 = 0 Then Y := 0
              Else Y := aHeight;
              X := Round(aWidth / (nbCycle - 1) * Idx);
            End;
        End;
        Red := GetRValue(ColorArray[Idx]) Shl 8; // shl 8 où * 256 parce que
        Blue := GetBValue(ColorArray[Idx]) Shl 8;
          // l'intervale doit se situer entre 256 et 65280
        Green := GetGValue(ColorArray[Idx]) Shl 8;
          // où en Hexa entre $100 et $FF00
      End;

  For Idx := 0 To High(gRect) Do // et on affecte les TriVertEx à TGradientRect
    Begin
      gRect[Idx].UpperLeft := Idx; // le premier etant le Vert[0]
      gRect[Idx].LowerRight := Idx + 1; // et le Vert[1] et ansi de suite
    End;
  Result := GradientFill(Dc, PTRIVERTEX(vert), nbCycle, PGradientRect(gRect),
    nbCycle - 1,
    Direction);
End;
}

{*******************************************************************************
                  Initialisation des différentes séquences possibles
                               Mofifier Par F0xi
********************************************************************************}
Procedure InitTriSequence;
Var I : Integer;
Begin
  For I := 1 To High(TriSequence) Do Begin
      SetLength(TriSequence[I], I);
  End;

  For I := 1 To 8 Do Begin
      if I in [1..8]    then GradientTriP(TriSequence[I][0],0,1,2);
      if I in [2,6..8]  then GradientTriP(TriSequence[I][1],0,2,3);
      if I in [3..5]    then GradientTriP(TriSequence[I][1],1,2,3);
      if I in [4..8]    then GradientTriP(TriSequence[I][2],2,3,4);
      if I in [5..8]    then GradientTriP(TriSequence[I][3],2,4,5);
      if I in [6..8]    then GradientTriP(TriSequence[I][4],2,5,6);
      if I in [7,8]     then GradientTriP(TriSequence[I][5],2,6,7);
      if I in [3,4]     then GradientTriP(TriSequence[I][I-1],0,2,4);
      if I in [5..8]    then GradientTriP(TriSequence[I][I-1],0,2,I);
  End;
  GradientTriP(TriSequence[8][6],2,7,8);
End;
{*******************************************************************************
                  Initialisation des différentes séquences possibles
********************************************************************************}

{Procedure InitTriSequence;
Var I               : Integer;
Begin
  For I := 1 To High(TriSequence) Do
    Begin
      SetLength(TriSequence[I], I);
      Case I Of
        1: Begin
            TriSequence[I][0].Vertex1 := 0;
            TriSequence[I][0].Vertex2 := 1;
            TriSequence[I][0].Vertex3 := 2;
          End;
        2: Begin
            TriSequence[I][0] := TriSequence[1][0];
            TriSequence[I][1].Vertex1 := 0;
            TriSequence[I][1].Vertex2 := 2;
            TriSequence[I][1].Vertex3 := 3;
          End;
        3: Begin
            TriSequence[I][0] := TriSequence[1][0];
            TriSequence[I][1] := TriSequence[2][1];
            TriSequence[I][1].Vertex1 := 1;
            TriSequence[I][2].Vertex1 := 0;
            TriSequence[I][2].Vertex2 := 2;
            TriSequence[I][2].Vertex3 := 4;
          End;
        4: Begin
            TriSequence[I][0] := TriSequence[1][0];
            TriSequence[I][1] := TriSequence[3][1];
            TriSequence[I][2].Vertex1 := 2;
            TriSequence[I][2].Vertex2 := 3;
            TriSequence[I][2].Vertex3 := 4;
            TriSequence[I][3].Vertex1 := 0;
            TriSequence[I][3].Vertex2 := 2;
            TriSequence[I][3].Vertex3 := 4;
          End;
        5: Begin
            TriSequence[I][0] := TriSequence[1][0];
            TriSequence[I][1] := TriSequence[3][1];
            TriSequence[I][2] := TriSequence[4][2];
            TriSequence[I][3].Vertex1 := 2;
            TriSequence[I][3].Vertex2 := 4;
            TriSequence[I][3].Vertex3 := 5;
            TriSequence[I][4].Vertex1 := 0;
            TriSequence[I][4].Vertex2 := 2;
            TriSequence[I][4].Vertex3 := 5;
          End;
        6: Begin
            TriSequence[I][0] := TriSequence[1][0];
            TriSequence[I][1] := TriSequence[2][1];
            TriSequence[I][2] := TriSequence[5][2];
            TriSequence[I][3] := TriSequence[5][3];
            TriSequence[I][4].Vertex1 := 2;
            TriSequence[I][4].Vertex2 := 5;
            TriSequence[I][4].Vertex3 := 6;
            TriSequence[I][5].Vertex1 := 0;
            TriSequence[I][5].Vertex2 := 2;
            TriSequence[I][5].Vertex3 := 6;
          End;
        7: Begin
            TriSequence[I][0] := TriSequence[1][0];
            TriSequence[I][1] := TriSequence[2][1];
            TriSequence[I][2] := TriSequence[5][2];
            TriSequence[I][3] := TriSequence[5][3];
            TriSequence[I][4] := TriSequence[6][4];
            TriSequence[I][5].Vertex1 := 2;
            TriSequence[I][5].Vertex2 := 6;
            TriSequence[I][5].Vertex3 := 7;
            TriSequence[I][6].Vertex1 := 0;
            TriSequence[I][6].Vertex2 := 2;
            TriSequence[I][6].Vertex3 := 7;
          End;
        8: Begin
            TriSequence[I][0] := TriSequence[1][0];
            TriSequence[I][1] := TriSequence[2][1];
            TriSequence[I][2] := TriSequence[5][2];
            TriSequence[I][3] := TriSequence[5][3];
            TriSequence[I][4] := TriSequence[6][4];
            TriSequence[I][5] := TriSequence[7][5];
            TriSequence[I][6].Vertex1 := 2;
            TriSequence[I][6].Vertex2 := 7;
            TriSequence[I][6].Vertex3 := 8;
            TriSequence[I][7].Vertex1 := 0;
            TriSequence[I][7].Vertex2 := 2;
            TriSequence[I][7].Vertex3 := 8;
          End;
      End;
    End;
End;
}
{*******************************************************************************
               Calcule des points servant à dessiner les triangles
               en fonction du nombres de couleurs et de la surface
               à dessiner
                               Mofifier Par F0xi
********************************************************************************}
Procedure GetVertPos(Var Vert: Array Of TTrivertEx; aRect: TRect);
Var nbCycle, aHeight, aWidth: Integer;
Begin
  aHeight := GetRectHeight(aRect);
  aWidth  := GetRectWidth(aRect);
  nbCycle := Length(Vert);

  PointTVX(Vert[0],aRect.Left,aRect.Top);

  if nbCycle IN [3..5] then begin
     PointTVX(Vert[1],aRect.Right,aRect.Top);
  end;

  if nbCycle IN [3..4] then begin
     PointTVX(Vert[2],aRect.Right,aRect.Bottom);
  end;

  if nbCycle IN [5..9] then begin
     PointTVX(Vert[2],aWidth Div 2,aHeight Div 2);
  end;

  if nbCycle IN [6..9] then begin
     PointTVX(Vert[1],aWidth Div 2,aRect.Top);
     PointTVX(Vert[3],aRect.Right,aRect.Top);
  end;

  if nbCycle IN [7..9] then begin
     PointTVX(Vert[4],aRect.Right,aHeight Div 2);
     PointTVX(Vert[5],aRect.Right,aRect.Bottom);
  end;

  if nbCycle IN [8..9] then begin
     PointTVX(Vert[6],aWidth Div 2,aRect.Bottom);
     PointTVX(Vert[7],aRect.Left,aRect.Bottom);
  end;

  if nbCycle = 4 then
     PointTVX(Vert[3],aRect.Left,aRect.Bottom);

  if nbCycle = 5 then begin
     PointTVX(Vert[3],aRect.Right,aRect.Bottom);
     PointTVX(Vert[4],aRect.Left,aRect.Bottom);
  End;

  if nbCycle = 6 then begin
        PointTVX(Vert[4],aRect.Right,aRect.Bottom);
        PointTVX(Vert[5],aRect.Left,aRect.Bottom);
  End;

  if nbCycle = 7 then
     PointTVX(Vert[6],aRect.Left,aRect.Bottom);

  if nbCycle = 9 then begin
     PointTVX(Vert[6],aWidth Div 2,aRect.Bottom);
     PointTVX(Vert[8],aRect.Left,aHeight Div 2);
  End;
End;
{*******************************************************************************
               Calcule des points servant à dessiner les triangles
               en fonction du nombres de couleurs et de la surface
               à dessiner
********************************************************************************}
{Procedure GetVertPos(Var Vert: Array Of TTrivertEx; aRect: TRect);
Var nbCycle, aHeight, aWidth: Integer;
Begin
  aHeight := aRect.Bottom - aRect.Top;
  aWidth := aRect.Right - aRect.Left;
  nbCycle := Length(Vert);
  Case nbCycle Of
    3: Begin
        Vert[0].X := aRect.Left;
        Vert[0].Y := aRect.Top;
        Vert[1].X := aRect.Right;
        Vert[1].Y := aRect.Top;
        Vert[2].X := aRect.Right;
        Vert[2].Y := aRect.Bottom;
      End;
    4: Begin
        Vert[0].X := aRect.Left;
        Vert[0].Y := aRect.Top;
        Vert[1].X := aRect.Right;
        Vert[1].Y := aRect.Top;
        Vert[2].X := aRect.Right;
        Vert[2].Y := aRect.Bottom;
        Vert[3].X := aRect.Left;
        Vert[3].Y := aRect.Bottom;
      End;
    5: Begin
        Vert[0].X := aRect.Left;
        Vert[0].Y := aRect.Top;
        Vert[1].X := aRect.Right;
        Vert[1].Y := aRect.Top;
        Vert[2].X := aWidth Div 2;
        Vert[2].Y := aHeight Div 2;
        Vert[3].X := aRect.Right;
        Vert[3].Y := aRect.Bottom;
        Vert[4].X := aRect.Left;
        Vert[4].Y := aRect.Bottom;
      End;
    6: Begin
        Vert[0].X := aRect.Left;
        Vert[0].Y := aRect.Top;
        Vert[1].X := aWidth Div 2;
        Vert[1].Y := aRect.Top;
        Vert[2].X := aWidth Div 2;
        Vert[2].Y := aHeight Div 2;
        Vert[3].X := aRect.Right;
        Vert[3].Y := aRect.Top;
        Vert[4].X := aRect.Right;
        Vert[4].Y := aRect.Bottom;
        Vert[5].X := aRect.Left;
        Vert[5].Y := aRect.Bottom;
      End;
    7: Begin
        Vert[0].X := aRect.Left;
        Vert[0].Y := aRect.Top;
        Vert[1].X := aWidth Div 2;
        Vert[1].Y := aRect.Top;
        Vert[2].X := aWidth Div 2;
        Vert[2].Y := aHeight Div 2;
        Vert[3].X := aRect.Right;
        Vert[3].Y := aRect.Top;
        Vert[4].X := aRect.Right;
        Vert[4].Y := aHeight Div 2;
        Vert[5].X := aRect.Right;
        Vert[5].Y := aRect.Bottom;
        Vert[6].X := aRect.Left;
        Vert[6].Y := aRect.Bottom;
      End;
    8: Begin
        Vert[0].X := aRect.Left;
        Vert[0].Y := aRect.Top;
        Vert[1].X := aWidth Div 2;
        Vert[1].Y := aRect.Top;
        Vert[2].X := aWidth Div 2;
        Vert[2].Y := aHeight Div 2;
        Vert[3].X := aRect.Right;
        Vert[3].Y := aRect.Top;
        Vert[4].X := aRect.Right;
        Vert[4].Y := aHeight Div 2;
        Vert[5].X := aRect.Right;
        Vert[5].Y := aRect.Bottom;
        Vert[6].X := aWidth Div 2;
        Vert[6].Y := aRect.Bottom;
        Vert[7].X := aRect.Left;
        Vert[7].Y := aRect.Bottom;
      End;
    9: Begin
        Vert[0].X := aRect.Left;
        Vert[0].Y := aRect.Top;
        Vert[1].X := aWidth Div 2;
        Vert[1].Y := aRect.Top;
        Vert[2].X := aWidth Div 2;
        Vert[2].Y := aHeight Div 2;
        Vert[3].X := aRect.Right;
        Vert[3].Y := aRect.Top;
        Vert[4].X := aRect.Right;
        Vert[4].Y := aHeight Div 2;
        Vert[5].X := aRect.Right;
        Vert[5].Y := aRect.Bottom;
        Vert[6].X := aWidth Div 2;
        Vert[6].Y := aRect.Bottom;
        Vert[7].X := aRect.Left;
        Vert[7].Y := aRect.Bottom;
        Vert[8].X := aRect.Left;
        Vert[8].Y := aHeight Div 2;
      End;
  End;
End;
}

{*******************************************************************************
                Function qui realise un dégradé en Triangle
                               Mofifier Par F0xi
********************************************************************************}
Function GradientTriangle(Dc: THandle; ColorArray: Array Of TColor; aRect: TRect): Boolean;
Var Idx, nbCycle, NbTriCycle: Integer;
    Vert : Array Of TTrivertEx;
Begin
  nbCycle := Length(ColorArray);
  If NbCycle < 3 Then
  Begin
    GradientRect(Dc, ColorArray, aRect, 0);
  Exit;
  End;
  If NbCycle > 9 Then NbCycle := 9;
  SetLength(Vert, nbCycle);
  GetVertPos(Vert, aRect);
  For Idx := 0 To High(Vert) Do
      ColorTVX(Vert[Idx],ColorArray[Idx]);

  If NbCycle > 4 Then
     NbTriCycle := NbCycle - 1
  Else
     NbTriCycle := NbCycle - 2;

  Result := GradientFill(Dc, PTRIVERTEX(vert), NbCycle,
  PGRADIENTTRIANGLE(TriSequence[NbTriCycle]), NbTriCycle, GRADIENT_FILL_TRIANGLE);
End;
{*******************************************************************************
                Function qui realise un dégradé en Triangle
********************************************************************************}
{Function GradientTriangle(Dc: THandle; ColorArray: Array Of TColor; aRect:
  TRect): Boolean;
Var Idx,  nbCycle, NbTriCycle: Integer;
  Vert                : Array Of TTrivertEx;
    // Structure contenant les informations de couleurs et de positions
Begin
  nbCycle := Length(ColorArray);
  If NbCycle > 9 Then NbCycle := 9; // 9 Couleurs au maximum pour l'instant
  SetLength(Vert, nbCycle); // on specifie la taille du tableau de TriVertEx
  GetVertPos(Vert, aRect);  // on calcule les positions des points des Triangles
  For Idx := 0 To High(Vert) Do
    With Vert[Idx] Do
      Begin
        Red := GetRValue(ColorArray[Idx]) Shl 8; // shl 8 où * 256 parce que
        Blue := GetBValue(ColorArray[Idx]) Shl 8;// l'intervale doit se situer entre 256 et 65280
        Green := GetGValue(ColorArray[Idx]) Shl 8;// où en Hexa entre $100 et $FF00
      End;

  If NbCycle > 4 Then
    NbTriCycle := NbCycle - 1
  Else
    NbTriCycle := NbCycle - 2;
 Result := GradientFill(dc, PTRIVERTEX(vert), NbCycle,
    PGRADIENTTRIANGLE(TriSequence[NbTriCycle]), NbTriCycle,
    GRADIENT_FILL_TRIANGLE);

End;
}
Initialization
  InitTriSequence;
Finalization
Finalize(TriSequence);
End.

