unit piMain;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type

  { TMainForm }

  TMainForm = class(TForm)
    Bevel1: TBevel;
    TxtCount: TLabel;
    TxtHits: TLabel;
    BtnExec: TButton;
    TxtPi: TLabel;
    Panel1: TPanel;
    PaintBox1: TPaintBox;
    BtnQuit: TButton;
    CbUpdate: TCheckBox;
    TxtTime: TLabel;
    Image1: TImage;
    Panel2: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure BtnExecClick(Sender: TObject);
    procedure BtnExecMouseDown(Sender: TObject; {%H-}Button: TMouseButton;
      {%H-}Shift: TShiftState; {%H-}X, {%H-}Y: Integer);
    procedure PaintBox1Paint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnQuitClick(Sender: TObject);
  private
    { Private-Deklarationen }
    Count : cardinal;
    Hits : cardinal;
    t : cardinal;
    Started : boolean;
    Aborted : boolean;
    bmp : TBitmap;
    procedure DisplayResults;
    procedure DrawShapes;
  public
    { Public-Deklarationen }
  end;

var
  MainForm: TMainForm;

implementation

{$IFnDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

function Log10(x:double) : double;
const
  Log10E = 0.4342944819032518276511;      // 1/Ln(10)
begin
  result := Ln(x) * Log10E;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if Assigned(bmp) then bmp.Free;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  TxtCount.Caption := 'Shots:';
  TxtHits.Caption := 'Hits:';
  TxtTime.caption := 'Calculation time: ';
  TxtPi.Caption := ' ';
  TxtTime.Hide;
  bmp := TBitmap.Create;
  bmp.Width := Paintbox1.Width;
  bmp.Height := Paintbox1.Height;
  DrawShapes;
end;

procedure TMainForm.BtnExecClick(Sender: TObject);
var
  i,j : integer;
  x, y : double;
begin
  Started := not Started;
  if Started then begin
    TxtTime.Show;
    BtnExec.Caption := 'Stop';
    BtnQuit.Enabled := false;
    Aborted := false;
    Count := 0;
    Hits := 0;
    DrawShapes;
    t := GetTickCount64;
    while not Aborted do begin
      x := random;
      y := random;
      if sqr(x-0.5)+sqr(y-0.5)<=0.25 then inc(Hits);
      inc(Count);
      if count mod 1000 = 0 then begin
        if CbUpdate.Checked then begin
          DisplayResults;
          if Hits>0 then begin
            i := round(x*bmp.Width);
            j := round((1-y)*bmp.Height);
            bmp.canvas.Pixels[i,j] := clBlack;
            Paintbox1Paint(nil);
          end;
        end;
        Application.ProcessMessages;
      end;
    end;
  end else begin
    BtnExec.Caption := 'Start';
    BtnQuit.Enabled := true;
    DisplayResults;
  end;
end;

procedure TMainForm.BtnExecMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Started then Aborted := true;
end;

procedure TMainForm.PaintBox1Paint(Sender: TObject);
begin
  Paintbox1.Canvas.Draw(0, 0, bmp);
end;

procedure TMainForm.DrawShapes;
begin
  with bmp.Canvas do begin
    Brush.Color := clMoneyGreen;
    Rectangle(0, 0, bmp.Width, bmp.Height);
    Brush.Color := clYellow;
    Ellipse(0, 0, bmp.Width, bmp.Height);
  end;
end;

procedure TMainForm.BtnQuitClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.DisplayResults;
const
  fmt = '%%0.%df';
var
  myPi : double;
  PiErr : double;
  RelErr : double;
  _t : cardinal;
  mask : string;
  PiStr : string;
  PiErrStr : string;
begin
  MyPi := 4.0*Hits/Count;
  if Hits>0 then begin
    RelErr := sqrt(Hits);
    PiErr := MyPi/RelErr;
  end else begin;
    mask := '';
  end;
  _t := (GetTickCount64 - t) div 1000;
  TxtCount.Caption := Format('Shots: %0.0n', [1.0*Count]);
  TxtHits.Caption := Format('Hits: %0.0n', [1.0*Hits]);
  txtTime.Caption := Format('Running time: %0.2d:%0.2d', [_t div 60, _t mod 60]);
  if Hits>0 then begin
    mask := Format(fmt, [round(Log10(RelErr)+1)]) ;
    PiStr := Format(mask, [MyPi]);
    PiErrStr := Format(mask, [PiErr]);
    TxtPi.Caption := Format('pi = %s +/- %s', [PiStr, PiErrStr]);
  end else
    TxtPi.Caption := Format('pi = %f', [MyPi]);
end;

end.
