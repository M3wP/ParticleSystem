program Particles;

uses
  System.StartUpCopy,
  FMX.Forms,
  FormParticlesMain in 'FormParticlesMain.pas' {Form1},
  ParticleSystem in 'ParticleSystem.pas',
  PDParticleSystem in 'PDParticleSystem.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
