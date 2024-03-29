unit Main;

{
  Daleks O Culto de Skaro
  Prot�tipo de jogo de navinha (Shooter)
  Dev. F�bio Furious
  fmftessari@gmail.com

  In�cio 2017
  - Delphi Berlin

  undelphix_1_15_0

  # Controles
  ... Setas
  ... Z - Dispara

}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Menus, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB;

type
  TGameScene = (gsNone, gsTitle, gsMain, gsGameOver);

  TMainForm = class(TDXForm)
    DXTimer: TDXTimer;
    DXDraw: TDXDraw;
    SpriteEngine: TDXSpriteEngine;
    DXInput: TDXInput;
    ImageList: TDXImageList;
    DXWaveList: TDXWaveList;
    DXSound: TDXSound;
    MainMenu: TMainMenu;
    GameMenu: TMenuItem;
    GameStart: TMenuItem;
    GamePause: TMenuItem;
    GameExit: TMenuItem;
    OptionMenu: TMenuItem;
    OptionFullScreen: TMenuItem;
    OptionSound: TMenuItem;
    OptionShowFPS: TMenuItem;
    N4: TMenuItem;
    N3: TMenuItem;
    N1: TMenuItem;
    Sobre1: TMenuItem;
    procedure DXDrawFinalize(Sender: TObject);
    procedure DXDrawInitialize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DXTimerTimer(Sender: TObject; LagCount: Integer);
    procedure DXTimerActivate(Sender: TObject);
    procedure DXTimerDeactivate(Sender: TObject);
    procedure OptionFullScreenClick(Sender: TObject);
    procedure DXDrawInitializing(Sender: TObject);
    procedure GameStartClick(Sender: TObject);
    procedure GamePauseClick(Sender: TObject);
    procedure GameExitClick(Sender: TObject);
    procedure OptionSoundClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OptionShowFPSClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormHide(Sender: TObject);
    procedure Sobre1Click(Sender: TObject);
  private
    FScene: TGameScene;
    FNextScene: TGameScene;
    FBlink: DWORD;
    FBlinkTime: DWORD;
    FEnemyAdventPos: Integer;
    FFrame: Integer;
    FScore: Integer;
    procedure BlinkStart;
    procedure BlinkUpdate;
    procedure PlaySound(const Name: string; Wait: Boolean);
    procedure PalleteAnim(Col: TRGBQuad; Time: Integer);
    procedure StartScene(Scene: TGameScene);
    procedure StartSceneTitle;
    procedure StartSceneMain;
    procedure StartSceneGameOver;
    procedure EndScene;
    procedure EndSceneTitle;
    procedure EndSceneMain;
    procedure EndSceneGameOver;
    procedure SceneTitle;
    procedure SceneMain;
    procedure SceneGameOver;
  end;

var
  MainForm: TMainForm;
  Path: string;

implementation

Uses USobre;

{$R *.DFM}

type
  TPlayerSprite = class(TImageSprite)
  private
    FCounter: Integer;
    FMode: Integer;
    FTamaCount: Integer;
    FOldTamaTime: Integer;
  protected
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
    procedure DoMove(MoveCount: Integer); override;
  public
    constructor Create(AParent: TSprite); override;
  end;

  TTamaSprite = class(TImageSprite)
  private
    FPlayerSprite: TPlayerSprite;
  protected
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
    procedure DoMove(MoveCount: Integer); override;
  public
    constructor Create(AParent: TSprite); override;
    destructor Destroy; override;
  end;

  TScrollBackground = class(TBackgroundSprite)
  private
    FSpeed: Double;
  protected
    procedure DoMove(MoveCount: Integer); override;
  end;

  TBakuhatu = class(TImageSprite)
  protected
    procedure DoMove(MoveCount: Integer); override;
  public
    constructor Create(AParent: TSprite); override;
  end;

  TEnemy = class(TImageSprite)
  private
    FCounter: Integer;
    FLife: Integer;
    FMode: Integer;
    procedure Hit; virtual;
  protected
    procedure HitEnemy(Deaded: Boolean); virtual;
  end;

  TEnemyTama = class(TEnemy)
  private
    FPlayerSprite: TSprite;
  protected
    procedure DoMove(MoveCount: Integer); override;
  public
    constructor Create(AParent: TSprite); override;
  end;

  TEnemyUFO = class(TEnemy)
  protected
    procedure DoMove(MoveCount: Integer); override;
    procedure HitEnemy(Deaded: Boolean); override;
  public
    constructor Create(AParent: TSprite); override;
  end;

  TEnemyAttacker = class(TEnemy)
  protected
    procedure DoMove(MoveCount: Integer); override;
    procedure HitEnemy(Deaded: Boolean); override;
  public
    constructor Create(AParent: TSprite); override;
  end;

  TEnemyBoss = class(TEnemy)
  private
    FCounter: Integer;
    FTamaF: Integer;
    FTamaT: Integer;
    FPutTama: Boolean;
  protected
    procedure DoMove(MoveCount: Integer); override;
    procedure HitEnemy(Deaded: Boolean); override;
  public
    constructor Create(AParent: TSprite); override;
  end;

  // Tabela de enimigos
  TSpriteClass = class of TSprite;

  TEnemyAdvent = record
    f: Integer; // Frame No
    c: TSpriteClass; // Class
    x: Integer; // eixo X
    y: Integer; // eixo Y
  end;

const
  EnemyAdventTable: array [0 .. 27] of TEnemyAdvent = ((f: 100; c: TEnemyUFO; x: 0; y: 0), (f: 100; c: TEnemyUFO; x: 0; y: 120), (f: 100; c: TEnemyUFO; x: 0; y: 240), (f: 100; c: TEnemyUFO;
    x: 0; y: 360),

    (f: 200; c: TEnemyUFO; x: 0; y: 60), (f: 200; c: TEnemyUFO; x: 0; y: 180), (f: 200; c: TEnemyUFO; x: 0; y: 300), (f: 200; c: TEnemyUFO; x: 0; y: 420),

    (f: 300; c: TEnemyUFO; x: 0; y: - 60), (f: 300; c: TEnemyUFO; x: 0; y: 60), (f: 300; c: TEnemyUFO; x: 0; y: 180), (f: 300; c: TEnemyUFO; x: 0; y: 300),

    (f: 400; c: TEnemyAttacker; x: 0; y: 100), (f: 420; c: TEnemyAttacker; x: 0; y: 200), (f: 440; c: TEnemyAttacker; x: 0; y: 300), (f: 450; c: TEnemyAttacker; x: 0; y: 200), (f: 455;
    c: TEnemyAttacker; x: 0; y: 100),

    (f: 460; c: TEnemyUFO; x: 0; y: 240), (f: 470; c: TEnemyUFO; x: 0; y: 240), (f: 480; c: TEnemyUFO; x: 0; y: 240), (f: 490; c: TEnemyUFO; x: 0; y: 240), (f: 500; c: TEnemyUFO; x: 0; y: 240),

    (f: 520; c: TEnemyAttacker; x: 0; y: 240), (f: 530; c: TEnemyAttacker; x: 0; y: 240), (f: 540; c: TEnemyAttacker; x: 0; y: 240), (f: 550; c: TEnemyAttacker; x: 0; y: 240), (f: 560;
    c: TEnemyAttacker; x: 0; y: 240),

    (f: 600; c: TEnemyBoss; x: 0; y: 200));

  // TPlayerSprite

constructor TPlayerSprite.Create(AParent: TSprite);
begin
  inherited Create(AParent);
  Image := MainForm.ImageList.Items.Find('Machine');
  Width := Image.Width;
  Height := Image.Height;

  x := 20;
  y := 240 - Height div 2;
  Z := 2;

  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := 15 / 1000;
end;

procedure TPlayerSprite.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  if Sprite is TEnemy then
  begin
    MainForm.PlaySound('Explosion', False);
    Collisioned := False;
    FCounter := 0;
    FMode := 1;
    Done := False;

    // Image - efeitos
    Image := MainForm.ImageList.Items.Find('Explosion');
    Width := Image.Width;
    Height := Image.Height;

    AnimCount := Image.PatternCount;
    AnimLooped := False;
    AnimSpeed := 15 / 1000;
    AnimPos := 0;
  end;
end;

procedure TPlayerSprite.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  if FMode = 0 then
  begin
    // detecta movimento
    if isUp in MainForm.DXInput.States then
      y := y - (250 / 1000) * MoveCount;

    if isDown in MainForm.DXInput.States then
      y := y + (250 / 1000) * MoveCount;

    if isLeft in MainForm.DXInput.States then
      x := x - (250 / 1000) * MoveCount;

    if isRight in MainForm.DXInput.States then
      x := x + (250 / 1000) * MoveCount;

    if x < 0 then
      x := 0;
    if x > 640 - Width then
      x := 640 - Width;
    if y < 0 then
      y := 0;
    if y > 480 - Height then
      y := 480 - Height;

    if isButton1 in MainForm.DXInput.States then
    begin
      // Bounce
      if (FTamaCount < 8) and (FCounter - FOldTamaTime >= 100) then
      begin
        Inc(FTamaCount);
        with TTamaSprite.Create(Engine) do
        begin
          FPlayerSprite := Self;
          x := Self.x + Self.Width;
          y := Self.y + Self.Height div 2 - Height div 2;
          Z := 10;
        end;

        FOldTamaTime := FCounter;
      end;
    end;

    Collision;
  end
  else if FMode = 1 then
  begin
    // morte
    if FCounter > 200 then
    begin
      FCounter := 0;
      FMode := 2;
      Visible := False;
    end;
  end
  else if FMode = 2 then
  begin
    // Game over!! :(
    if FCounter > 1500 then
    begin
      MainForm.FNextScene := gsGameOver;

      MainForm.PlaySound('SceneMov', False);
      MainForm.PalleteAnim(RGBQuad(0, 0, 0), 300);
      Sleep(200);
    end;
  end;

  FCounter := FCounter + MoveCount;
end;

constructor TTamaSprite.Create(AParent: TSprite);
begin
  inherited Create(AParent);
  Image := MainForm.ImageList.Items.Find('Bounce');
  MainForm.PlaySound('laser', False);
  Z := 2;
  Width := Image.Width;
  Height := Image.Height;

  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := 15 / 1000;
end;

destructor TTamaSprite.Destroy;
begin
  Dec(FPlayerSprite.FTamaCount);
  inherited Destroy;
end;

procedure TTamaSprite.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  if (Sprite is TEnemy) and (not(Sprite is TEnemyTama)) then
  begin
    TEnemy(Sprite).Hit;
    Dead;
  end;
  Done := False;
end;

procedure TTamaSprite.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
  x := x + (800 / 1000) * MoveCount;

  if x >= 640 then
    Dead;

  Collision;
end;

procedure TScrollBackground.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
  x := x - MoveCount * (60 / 1000) * FSpeed;
end;

constructor TBakuhatu.Create(AParent: TSprite);
begin
  inherited Create(AParent);
  Image := MainForm.ImageList.Items.Find('Explosion');
  Width := Image.Width;
  Height := Image.Height;

  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := 15 / 1000;
  AnimPos := Random(AnimCount);
end;

procedure TBakuhatu.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
end;

constructor TEnemyTama.Create(AParent: TSprite);
begin
  inherited Create(AParent);
  Image := MainForm.ImageList.Items.Find('Bounce');
  Width := Image.Width;
  Height := Image.Height;

  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := 15 / 1000;
end;

procedure TEnemyTama.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
  x := x - MoveCount * (600 / 1000);

  if x < -Width then
    Dead;
end;

procedure TEnemy.Hit;
begin
  Dec(FLife);
  if FLife <= 0 then
  begin
    Collisioned := False;
    HitEnemy(True);
  end
  else
    HitEnemy(False);
end;

procedure TEnemy.HitEnemy(Deaded: Boolean);
begin
  if Deaded then
    MainForm.PlaySound('Explosion', False);
end;

constructor TEnemyUFO.Create(AParent: TSprite);
begin
  inherited Create(AParent);
  Image := MainForm.ImageList.Items.Find('Enemy-disk');
  Width := Image.Width;
  Height := Image.Height;

  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := 15 / 1000;
end;

procedure TEnemyUFO.HitEnemy(Deaded: Boolean);
begin
  if Deaded then
  begin
    MainForm.PlaySound('Explosion', False);
    FMode := 2;
    FCounter := 0;

    Inc(MainForm.FScore, 1000);

    // Image - efeito
    Image := MainForm.ImageList.Items.Find('Explosion');
    Width := Image.Width;
    Height := Image.Height;

    AnimCount := Image.PatternCount;
    AnimLooped := False;
    AnimSpeed := 15 / 1000;
    AnimPos := 0;
  end;
end;

procedure TEnemyUFO.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  if FMode = 0 then
  begin
    // Movimento
    x := x - MoveCount * (300 / 1000);
    y := y + Cos256(FCounter div 15) * 2;

    if x < -Width then
      Dead;
  end
  else if FMode = 2 then
  begin
    // Morte
    x := x - MoveCount * (300 / 1000);
    if FCounter > 200 then
      Dead;
  end;

  FCounter := FCounter + MoveCount;
end;

constructor TEnemyAttacker.Create(AParent: TSprite);
begin
  inherited Create(AParent);
  Image := MainForm.ImageList.Items.Find('Enemy-Attacker');
  Width := Image.Width;
  Height := Image.Height;

  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := 15 / 1000;
end;

procedure TEnemyAttacker.HitEnemy(Deaded: Boolean);
begin
  if Deaded then
  begin
    MainForm.PlaySound('Explosion', False);
    FMode := 2;
    FCounter := 0;

    Inc(MainForm.FScore, 1000);

    // img - efeito
    Image := MainForm.ImageList.Items.Find('Explosion');
    Width := Image.Width;
    Height := Image.Height;

    AnimCount := Image.PatternCount;
    AnimLooped := False;
    AnimSpeed := 15 / 1000;
    AnimPos := 0;
  end;
end;

procedure TEnemyAttacker.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  if FMode = 0 then
  begin
    // movimento
    x := x - MoveCount * (300 / 1000) - FCounter div 128;

    if x < -Width then
      Dead;
  end
  else if FMode = 2 then
  begin
    // morte
    x := x - MoveCount * (300 / 1000);
    if FCounter > 200 then
      Dead;
  end;

  FCounter := FCounter + MoveCount;
end;

constructor TEnemyBoss.Create(AParent: TSprite);
begin
  inherited Create(AParent);
  Image := MainForm.ImageList.Items.Find('Enemy-boss');
  Width := Image.Width;
  Height := Image.Height;

  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := 15 / 1000;
  PixelCheck := True;

  Collisioned := False;

  FLife := 20;
end;

procedure TEnemyBoss.HitEnemy(Deaded: Boolean);
begin
  if Deaded then
  begin
    MainForm.PlaySound('Explosion', False);
    FMode := 2;
    FCounter := 0;

    Inc(MainForm.FScore, 100000);
  end
  else
  begin
    MainForm.PlaySound('kan!!', False);
    Inc(MainForm.FScore, 100);
  end;
end;

procedure TEnemyBoss.DoMove(MoveCount: Integer);
var
  i: Integer;
begin
  inherited DoMove(MoveCount);

  if FMode = 0 then
  begin
    if x > 450 then
      x := x - MoveCount * (300 / 1000)
    else
    begin
      Collisioned := True;
      FMode := 1;
      FPutTama := True;
    end;

    y := y + Cos256(FCounter div 15) * 5;
  end
  else if FMode = 1 then
  begin
    // Attack!
    y := y + Cos256(FCounter div 15) * 5;

    if FPutTama then
    begin
      if FTamaT > 100 then
      begin
        // Bounce
        with TEnemyTama.Create(Engine) do
        begin
          FPlayerSprite := Self;
          Z := 1;
          x := Self.x - Width;
          y := Self.y + Self.Height div 2 - Height div 2;
        end;

        Inc(FTamaF);
        if FTamaF > Random(30) then
          FPutTama := False;

        FTamaT := 0;
      end;

      FTamaT := FTamaT + MoveCount;
    end
    else
    begin
      FTamaT := FTamaT + MoveCount;
      if FTamaT > 2000 + Random(500) then
      begin
        FPutTama := True;
        FTamaF := 0;
        FTamaT := 0;
      end;
    end;
  end
  else if FMode = 2 then
  begin
    // Morte
    for i := 0 to 20 do
    begin
      with TBakuhatu.Create(Engine) do
      begin
        Z := 10;
        x := Self.x + Random(Self.Width) - 16;
        y := Self.y + Random(Self.Height) - 16;
      end;

      Inc(MainForm.FScore, 1000);
    end;

    FMode := 3;
  end
  else if FMode = 3 then
  begin
    // Game clear!! // limpar tudo
    if FCounter > 3000 then
    begin
      MainForm.FNextScene := gsGameOver;

      MainForm.PlaySound('SceneMov', False);
      MainForm.PalleteAnim(RGBQuad(0, 0, 0), 300);
      Sleep(200);
    end;
  end;

  FCounter := FCounter + MoveCount;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  // Caminho para a diret�rio raiz
  Path := ExtractFilePath(Application.ExeName) + 'engine\';

  // Imgs Load
  ImageList.Items[0].Picture.LoadFromFile(Path + 'imgs\stars.bmp');
  ImageList.Items[1].Picture.LoadFromFile(Path + 'imgs\en_disk.bmp');
  ImageList.Items[2].Picture.LoadFromFile(Path + 'imgs\en_attk.bmp');
  ImageList.Items[3].Picture.LoadFromFile(Path + 'imgs\en_boss.bmp');
  ImageList.Items[4].Picture.LoadFromFile(Path + 'imgs\bounce.bmp');
  ImageList.Items[5].Picture.LoadFromFile(Path + 'imgs\explod.bmp');
  ImageList.Items[6].Picture.LoadFromFile(Path + 'imgs\mach_dalek.bmp');
  ImageList.Items[7].Picture.LoadFromFile(Path + 'imgs\logo.bmp');

  // audio Load
  DXWaveList.Items.Add;
  DXWaveList.Items[0].Wave.LoadFromFile(Path + 'audios\SceneMov.wav');
  DXWaveList.Items[0].Name := 'SceneMov';
  DXWaveList.Items.Add;
  DXWaveList.Items[1].Wave.LoadFromFile(Path + 'audios\explod.wav');
  DXWaveList.Items[1].Name := 'Explosion';
  DXWaveList.Items.Add;
  DXWaveList.Items[2].Wave.LoadFromFile(Path + 'audios\kan.wav');
  DXWaveList.Items[2].Name := 'kan!!';
  DXWaveList.Items.Add;
  DXWaveList.Items[3].Wave.LoadFromFile(Path + 'audios\laser.wav');
  DXWaveList.Items[3].Name := 'laser';
  DXWaveList.Items.Add;
  DXWaveList.Items[4].Wave.LoadFromFile(Path + 'audios\theme.wav');
  DXWaveList.Items[4].Name := 'theme';

  DXDraw.Enabled := True;

  DXDraw.ColorTable := ImageList.Items.ColorTable;
  DXDraw.DefColorTable := ImageList.Items.ColorTable;
  DXDraw.UpdatePalette;

  // Window mode
  OptionFullScreen.Checked := True;
  OptionFullScreenClick(OptionFullScreen);

  // Sound on
  OptionSound.Checked := False;
  OptionSoundClick(OptionSound);
  DXWaveList.Items[4].Volume := -500;

  GameStartClick(GameStart);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  DXTimer.Enabled := False;
end;

procedure TMainForm.FormHide(Sender: TObject);
begin
  Release;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (ssAlt in Shift) and (Key = VK_RETURN) then
  begin
    OptionFullScreenClick(OptionFullScreen)
  end;

  if Key = 27 then // ESC
    Close;
end;

procedure TMainForm.GameStartClick(Sender: TObject);
begin
  StartScene(gsTitle);
end;

procedure TMainForm.GamePauseClick(Sender: TObject);
begin
  // Pause
  GamePause.Checked := not GamePause.Checked;
  DXTimer.Enabled := not GamePause.Checked;
end;

procedure TMainForm.GameExitClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.OptionFullScreenClick(Sender: TObject);
begin
  // Screen mode change
  OptionFullScreen.Checked := not OptionFullScreen.Checked;
  RestoreWindow;
  if OptionFullScreen.Checked then
  begin
    // FullScreen mode
    DXDraw.Finalize;

    // if not(doFullScreen in DXDraw.Options) then     RestoreWindow;

    DXDraw.Options := DXDraw.Options + [doFullScreen];
    DXDraw.Display.Width := 800;
    DXDraw.Display.Height := 600;
    DXDraw.Display.BitCount := 32;
    DXDraw.Initialize;
  end
  else
  begin
    // Window mode - Normal
    DXDraw.Finalize;

    // if doFullScreen in DXDraw.Options then     RestoreWindow;

    DXDraw.Options := DXDraw.Options - [doFullScreen];
    DXDraw.Display.Width := 640;
    DXDraw.Display.Height := 480;
    DXDraw.Display.BitCount := 24;
    DXDraw.Initialize;
  end;
end;

procedure TMainForm.OptionSoundClick(Sender: TObject);
begin
  // Sound - efeitos
  OptionSound.Checked := not OptionSound.Checked;

  if OptionSound.Checked then
  begin
    if not DXSound.Initialized then
    begin
      try
        DXSound.Initialize;
      except
        OptionSound.Checked := False;
      end;
    end;
  end
  else
    DXSound.Finalize;
end;

procedure TMainForm.OptionShowFPSClick(Sender: TObject);
begin
  OptionShowFPS.Checked := not OptionShowFPS.Checked;
end;

procedure TMainForm.DXDrawInitializing(Sender: TObject);
begin
  if doFullScreen in DXDraw.Options then
  begin
    BorderStyle := bsNone;
    DXDraw.Cursor := crNone;
  end
  else
  begin
    BorderStyle := bsSingle;
    DXDraw.Cursor := crDefault;
  end;
end;

procedure TMainForm.DXDrawInitialize(Sender: TObject);
begin
  DXTimer.Enabled := True;
end;

procedure TMainForm.DXDrawFinalize(Sender: TObject);
begin
  DXTimer.Enabled := False;
end;

procedure TMainForm.DXTimerActivate(Sender: TObject);
begin
  Caption := Application.Title;
end;

procedure TMainForm.DXTimerDeactivate(Sender: TObject);
begin
  Caption := Application.Title + ' [Pause]';
end;

procedure TMainForm.DXTimerTimer(Sender: TObject; LagCount: Integer);
begin
  if not DXDraw.CanDraw then
    exit;

  DXInput.Update;

  case FScene of
    gsTitle:
      SceneTitle;
    gsMain:
      SceneMain;
    gsGameOver:
      SceneGameOver;
  end;

  if FNextScene <> gsNone then
  begin
    StartScene(FNextScene);
    FNextScene := gsNone;
  end;

  if OptionShowFPS.Checked then
  begin
    // Mostra dispaly de Frame rate
    with DXDraw.Surface.Canvas do
    begin
      Brush.Style := bsClear;
      Font.Color := clWhite;
      Font.Size := 12;
      Textout(0, 0, 'FPS: ' + inttostr(DXTimer.FrameRate));
      Release;
    end;
  end;

  DXDraw.Flip;
end;

procedure TMainForm.BlinkStart;
begin
  FBlink := 0;
  FBlinkTime := GetTickCount;
end;

procedure TMainForm.BlinkUpdate;
begin
  if GetTickCount <> FBlinkTime then
  begin
    FBlink := FBlink + (GetTickCount - FBlinkTime);
    FBlinkTime := GetTickCount;
  end;
end;

procedure TMainForm.PlaySound(const Name: string; Wait: Boolean);
begin
  if OptionSound.Checked then
  begin
    DXWaveList.Items.Find(Name).Play(Wait);
  end;
end;

procedure TMainForm.PalleteAnim(Col: TRGBQuad; Time: Integer);

  function ComposeColor(Dest, Src: TRGBQuad; Percent: Integer): TRGBQuad;
  begin
    with Result do
    begin
      rgbRed := Src.rgbRed + ((Dest.rgbRed - Src.rgbRed) * Percent div 256);
      rgbGreen := Src.rgbGreen + ((Dest.rgbGreen - Src.rgbGreen) * Percent div 256);
      rgbBlue := Src.rgbBlue + ((Dest.rgbBlue - Src.rgbBlue) * Percent div 256);
      rgbReserved := 0;
    end;
  end;

var
  i: Integer;
  t, t2: DWORD;
  ChangePalette: Boolean;
  c: Integer;
begin
  if DXDraw.Initialized then
  begin
    c := DXDraw.Surface.ColorMatch(RGB(Col.rgbRed, Col.rgbGreen, Col.rgbBlue));

    // paleta de anima��o
    ChangePalette := False;
    if DXDraw.CanPaletteAnimation then
    begin
      t := GetTickCount;
      while Abs(GetTickCount - t) < Time do
      begin
        t2 := Trunc(Abs(GetTickCount - t) / Time * 255);

        for i := 0 to 255 do
          DXDraw.ColorTable[i] := ComposeColor(Col, DXDraw.DefColorTable[i], t2);

        DXDraw.UpdatePalette;
        ChangePalette := True;
      end;
    end
    else
      Sleep(Time);

    DXDraw.Surface.Fill(c);
    DXDraw.Flip;
    DXDraw.Surface.Fill(c);
    DXDraw.Flip;
    DXDraw.Surface.Fill(c);
    DXDraw.Flip;
    DXDraw.Surface.Fill(c);
    DXDraw.Flip;

    if ChangePalette then
    begin
      DXDraw.ColorTable := DXDraw.DefColorTable;
      DXDraw.UpdatePalette;
    end;

    DXDraw.Surface.Fill(c);
    DXDraw.Flip;
  end;
end;

const
  DXInputButton = [isButton1, isButton2, isButton3, isButton4, isButton5, isButton6, isButton7, isButton8, isButton9, isButton10, isButton11, isButton12, isButton13, isButton14, isButton15,
    isButton16, isButton17, isButton18, isButton19, isButton20, isButton21, isButton22, isButton23, isButton24, isButton25, isButton26, isButton27, isButton28, isButton29, isButton30, isButton31,
    isButton32];

procedure TMainForm.StartScene(Scene: TGameScene);
begin
  EndScene;

  DXInput.States := DXInput.States - DXInputButton;

  FScene := Scene;

  BlinkStart;

  case FScene of
    gsTitle:
      StartSceneTitle;
    gsMain:
      begin
        StartSceneMain;
        DXWaveList.Items[4].Play(False);
      end;
    gsGameOver:
      StartSceneGameOver;
  end;
end;

procedure TMainForm.StartSceneTitle;
begin
  // Beginning
end;

procedure TMainForm.StartSceneMain;
var
  i, j: Integer;
begin
  // Main scene beginning
  FScore := 0;
  FEnemyAdventPos := 0;
  FFrame := 0;

  // Player object
  TPlayerSprite.Create(SpriteEngine.Engine);

  // Background
  with TScrollBackground.Create(SpriteEngine.Engine) do
  begin
    SetMapSize(200, 10);
    Image := ImageList.Items.Find('Star');
    y := 10;
    Z := -13;
    FSpeed := 0.5;
    Tile := True;

    for i := 0 to MapHeight - 1 do
      for j := 0 to MapWidth - 1 do
      begin
        Chips[j, i] := Image.PatternCount - Random(Image.PatternCount div 8);
        if Random(100) < 95 then
          Chips[j, i] := -1;
      end;
  end;

  with TScrollBackground.Create(SpriteEngine.Engine) do
  begin
    SetMapSize(200, 10);
    Image := ImageList.Items.Find('Star');
    y := 30;
    Z := -12;
    FSpeed := 1;
    Tile := True;

    for i := 0 to MapHeight - 1 do
      for j := 0 to MapWidth - 1 do
      begin
        Chips[j, i] := Image.PatternCount - Random(Image.PatternCount div 4);
        if Random(100) < 95 then
          Chips[j, i] := -1;
      end;
  end;

  with TScrollBackground.Create(SpriteEngine.Engine) do
  begin
    SetMapSize(200, 10);
    Image := ImageList.Items.Find('Star');
    y := 40;
    Z := -11;
    FSpeed := 2;
    Tile := True;

    for i := 0 to MapHeight - 1 do
      for j := 0 to MapWidth - 1 do
      begin
        Chips[j, i] := Image.PatternCount - Random(Image.PatternCount div 2);
        if Random(100) < 95 then
          Chips[j, i] := -1;
      end;
  end;
end;

procedure TMainForm.StartSceneGameOver;
begin
  // Game over
end;

procedure TMainForm.EndScene;
begin
  case FScene of
    gsTitle:
      EndSceneTitle;
    gsMain:
      EndSceneMain;
    gsGameOver:
      EndSceneGameOver;
  end;
end;

procedure TMainForm.EndSceneTitle;
begin
  // Title scene end
end;

procedure TMainForm.EndSceneMain;
begin
  // Main scene end
  SpriteEngine.Engine.Clear;
end;

procedure TMainForm.EndSceneGameOver;
begin
  // Game over
end;

procedure TMainForm.SceneTitle;
var
  Logo: TPictureCollectionItem;
begin
  // Title scene
  DXDraw.Surface.Fill(0);

  Logo := ImageList.Items.Find('Logo');
  Logo.DrawWaveX(DXDraw.Surface, 20, 25, Logo.Width, Logo.Height, 0, Trunc(16 - Cos256(FBlink div 60) * 16), 32, -FBlink div 5);

  with DXDraw.Surface.Canvas do
  begin
    Brush.Style := bsClear;
    Font.Color := clRed;
    Font.Size := 40;

    if (FBlink div 300) mod 2 = 0 then
    begin
      Font.Color := clWhite;
      Font.Size := 30;
      Textout(250, 400, 'Precione Z');
    end;

    BlinkUpdate;

    Release;
  end;

  if isButton1 in DXInput.States then
  begin
    PlaySound('SceneMov', False);
    PalleteAnim(RGBQuad(0, 0, 0), 300);
    Sleep(200);

    StartScene(gsMain);
  end;
end;

procedure TMainForm.Sobre1Click(Sender: TObject);
begin
  Try
    Application.CreateForm(TFSobre, FSobre);
    FSobre.showmodal;
  Finally
    FreeandNil(FSobre);
  End;
end;

procedure TMainForm.SceneMain;
var
  Enemy: TSprite;
begin
  // Main scene
  SpriteEngine.Move(1000 div 60);
  SpriteEngine.Dead;

  // Inimigos aparecem
  while (Low(EnemyAdventTable) <= FEnemyAdventPos) and (FEnemyAdventPos <= High(EnemyAdventTable)) and (EnemyAdventTable[FEnemyAdventPos].f <= FFrame) do
  begin
    with EnemyAdventTable[FEnemyAdventPos] do
    begin
      Enemy := c.Create(SpriteEngine.Engine);
      Enemy.x := 640 + x;
      Enemy.y := y;
    end;

    Inc(FEnemyAdventPos);
  end;

  DXDraw.Surface.Fill(0);
  if FNextScene = gsNone then
  begin
    SpriteEngine.Draw;

    with DXDraw.Surface.Canvas do
    begin
      Brush.Style := bsClear;
      Font.Color := clYellow;
      Font.Size := 20;
      Textout(10, 10, inttostr(FScore));
      Release;
    end;
  end;

  Inc(FFrame);
end;

procedure TMainForm.SceneGameOver;
begin
  // Game over scene
  DXDraw.Surface.Fill(0);
  with DXDraw.Surface.Canvas do
  begin
    Brush.Style := bsClear;
    Font.Color := clRed;
    Font.Size := 40;
    Textout(150, 100, 'Game Over :(');

    if (FBlink div 300) mod 2 = 0 then
    begin
      Font.Color := clWhite;
      Font.Size := 30;
      Textout(200, 300, 'Precione Z');
    end;

    BlinkUpdate;

    Release;
  end;

  if isButton1 in DXInput.States then
  begin
    PlaySound('SceneMov', False);
    PalleteAnim(RGBQuad(0, 0, 0), 300);
    Sleep(200);

    StartScene(gsTitle);
  end;
end;

end.
