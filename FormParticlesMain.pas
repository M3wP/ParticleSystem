unit FormParticlesMain;

interface

uses
	System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
	FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.MaterialSources,
	ParticleSystem, PDParticleSystem, FMX.Controls.Presentation, FMX.ScrollBox,
	FMX.Memo;

type
	TForm1 = class(TForm)
		TextureMaterialParticle: TTextureMaterialSource;
		Memo1: TMemo;
		procedure FormCreate(Sender: TObject);
		procedure FormPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
		procedure FormDestroy(Sender: TObject);
	private
		FLastTime: Single;
		FParticles: TParticleSystem;
		FPDParticles: TPDParticleSystem;

		procedure DoIdle(Sender: TObject; var Done: Boolean);
	public
		{ Public declarations }
	end;

var
	Form1: TForm1;

implementation

{$R *.fmx}

{ TForm1 }

procedure TForm1.DoIdle(Sender: TObject; var Done: Boolean);
	var
	t: Single;
	th,
	tm,
	ts,
	tms: Word;

	begin
	DecodeTime(GetTime, th, tm, ts, tms);
	t:= th * 3600 + tm * 60 + ts + tms / 1000;

	FParticles.AdvanceTime(t - FLastTime);
	FPDParticles.AdvanceTime(t - FLastTime);

	FLastTime:= t;

	Invalidate;
	end;

procedure TForm1.FormCreate(Sender: TObject);
	var
	th,
	tm,
	ts,
	tms: Word;

	begin
	Randomize;

	FParticles:= TParticleSystem.Create(TextureMaterialParticle.Texture, 10);
	FPDParticles:= TPDParticleSystem.Create(Memo1.Lines, TextureMaterialParticle.Texture);

	FParticles.EmitterX:= Width / 2;
	FParticles.EmitterY:= 0;

	FPDParticles.EmitterX:= Width / 2;
	FPDParticles.EmitterY:= Height / 2;

	FParticles.Start;
	FParticles.Populate(5);

	FPDParticles.Start;
	FPDParticles.Populate(5);

	Application.OnIdle:= DoIdle;

	DecodeTime(GetTime, th, tm, ts, tms);
	FLastTime:= th * 3600 + tm * 60 + ts + tms / 1000;
	end;

procedure TForm1.FormDestroy(Sender: TObject);
	begin
	FPDParticles.Stop(True);
	FPDParticles.Free;

	FParticles.Stop(True);
	FParticles.Free;
	end;

procedure TForm1.FormPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
	begin
	if  Canvas.BeginScene then
		begin
		Canvas.Clear($FF000000);

		FParticles.Render(Canvas);
		FPDParticles.Render(Canvas);

		Canvas.EndScene;
		end;
	end;

end.
