//	=================================================================================
//
//	Starling Framework - Particle System Extension
//	Copyright 2012 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
//  Pascal conversion by Daniel England, 2017.
//	Modifications Copyright (c) 2017, Daniel England.  All Rights Reserved.
//
//	=================================================================================

unit PDParticleSystem;

interface

uses
	System.UITypes, System.Classes, FMX.Graphics, ParticleSystem;

type
	TColorARGB = class(TObject)
	public
		red,
		green,
		blue,
		alpha: Single;

		constructor Create(const ARed: Single = 0; const AGreen: Single = 0;
				const ABlue: Single = 0; const AAlpha: Single = 0);

		class function CopyFromRGB(const AColor: TColor): TColorARGB;
		class function CopyFromARGB(const AColor: TAlphaColor): TColorARGB;

		function  ToRGB: TColor;
		function  ToARGB: TAlphaColor;
		procedure FromRGB(const AColor: TColor);
		procedure FromARGB(const AColor: TAlphaColor);

		procedure CopyFrom(const AARGB: TColorARGB);
	end;

	TPDParticle = class(TParticle)
		public
		ColorArgb: TColorARGB;
		ColorArgbDelta: TColorARGB;
		startX,
		startY: Single;
		velocityX,
		velocityY: Single;
		radialAcceleration: Single;
		tangentialAcceleration: Single;
		emitRadius,
		emitRadiusDelta: Single;
		emitRotation,
		emitRotationDelta: Single;
		rotationDelta: Single;
		scaleDelta: Single;

		constructor Create;
		destructor  Destroy; override;
	end;

	TPDParticleEmitterType = (petGravity = 0, petRadial = 1);

	TPDParticleSystem = class(TParticleSystem)
	private
//      Emitter configuration
		FEmitterType: TPDParticleEmitterType;
		FEmitterXVariance,
		FEmitterYVariance: Single;

//      Particle configuration
		FMaxNumParticles: Integer;
		FLifespan: Single;
		FLifespanVariance: Single;
		FStartSize: Single;
		FStartSizeVariance: Single;
		FEndSize: Single;
		FEndSizeVariance: Single;
		FEmitAngle: Single;
		FEmitAngleVariance: Single;
		FStartRotation: Single;
		FStartRotationVariance: Single;
		FEndRotation: Single;
		FEndRotationVariance: Single;

//      Gravity configuration
		FSpeed: Single;
		FSpeedVariance: Single;
		FGravityX,
		FGravityY,
		FRadialAcceleration,
		FRadialAccelerationVariance,
		FTangentialAcceleration,
		FTangentialAccelerationVariance: Single;

//      Radial configuration
		FMaxRadius,
		FMaxRadiusVariance,
		FMinRadius,
		FMinRadiusVariance,
		FRotatePerSecond,
		FRotatePerSecondVariance: Single;

//      Color configuration
		FStartColor,
		FStartColorVariance,
		FEndColor,
		FEndColorVariance: TColorARGB;

        procedure ParseConfig(const AConfig: TStrings);
		procedure UpdateEmissionRate;

	protected
		function  CreateParticle: TParticle; override;
		procedure InitParticle(AParticle: TParticle); override;
		procedure AdvanceParticle(AParticle: TParticle; const APassedTime: Single); override;

		procedure SetMaxNumParticles(const AValue: Integer);
		procedure SetLifeSpan(const AValue: Single);
		procedure SetStartColor(const AValue: TColorARGB);
		procedure SetStartColorVariance(const AValue: TColorARGB);
		procedure SetEndColor(const AValue: TColorARGB);
		procedure SetEndColorVariance(const AValue: TColorARGB);

	public
		constructor Create(const AConfig: TStrings; const ATexture: TBitmap);
		destructor  Destroy; override;

		property  EmitterType: TPDParticleEmitterType read FEmitterType write FEmitterType;
		property  EmitterXVariance: Single read FEmitterXVariance write FEmitterXVariance;
		property  EmitterYVariance: Single read FEmitterYVariance write FEmitterYVariance;
		property  MaxNumParticles: Integer read FMaxNumParticles write SetMaxNumParticles;
		property  LifeSpan: Single read FLifespan write SetLifeSpan;
		property  LifeSpanVariance: Single read FLifespanVariance write FLifespanVariance;
		property  StartSize: Single read FStartSize write FStartSize;
		property  StartSizeVariance: Single read FStartSizeVariance write FStartSizeVariance;
		property  EndSize: Single read FEndSize write FEndSize;
		property  EndSizeVariance: Single read FEndSizeVariance write FEndSizeVariance;
		property  EmitAngle: Single read FEmitAngle write FEmitAngle;
		property  EmitAngleVariance: Single read FEmitAngleVariance write FEmitAngleVariance;
		property  StartRotation: Single read FStartRotation write FStartRotation;
		property  StartRotationVariance: Single read FStartRotationVariance
				write FStartSizeVariance;
		property  EndRotation: Single read FEndRotation write FEndRotation;
		property  EndRotationVariance: Single read FEndRotationVariance
				write FEndRotationVariance;
		property  Speed: Single read FSpeed write FSpeed;
		property  SpeedVariance: Single read FSpeedVariance write FSpeedVariance;
		property  GravityX: Single read FGravityX write FGravityX;
		property  GravityY: Single read FGravityY write FGravityY;
		property  RadialAcceleration: Single read FRadialAcceleration
				write FRadialAcceleration;
		property  RadialAccelerationVariance: Single read FRadialAccelerationVariance
				write FRadialAccelerationVariance;
		property  TangentialAcceleration: Single read FTangentialAcceleration
				write FTangentialAcceleration;
		property  TangentialAccelerationVariance: Single
				read FTangentialAccelerationVariance write FTangentialAccelerationVariance;
		property  MaxRadius: Single read FMaxRadius write FMaxRadius;
		property  MaxRadiusVariance: Single read FMaxRadiusVariance write FMaxRadiusVariance;
		property  MinRadius: Single read FMinRadius write FMinRadius;
		property  MinRadiusVariance: Single read FMinRadiusVariance write FMinRadiusVariance;
		property  RotatePerSecond: Single read FRotatePerSecond write FRotatePerSecond;
		property  RotatePerSecondVariance: Single read FRotatePerSecondVariance
				write FRotatePerSecondVariance;
		property  StartColor: TColorARGB read FStartColor write SetStartColor;
		property  StartColorVariance: TColorARGB read FStartColorVariance
				write SetStartColorVariance;
		property  EndColor: TColorARGB read FEndColor write SetEndColor;
		property  EndColorVariance: TColorARGB read FEndColorVariance
				write SetEndColorVariance;
	end;

implementation

uses
	System.Math, XML.XMLDom, XML.OmniXMLDom, XML.XMLIntf, XML.XMLDoc;


{ TColorARGB }

procedure TColorARGB.CopyFrom(const AARGB: TColorARGB);
	begin
	red:= AARGB.red;
	green:= AARGB.green;
	blue:= AARGB.blue;
	alpha:= AARGB.alpha;
	end;

class function TColorARGB.CopyFromARGB(const AColor: TAlphaColor): TColorARGB;
	begin
	Result:= TColorARGB.Create;
	Result.FromRGB(AColor);
	end;

class function TColorARGB.CopyFromRGB(const AColor: TColor): TColorARGB;
	begin
	Result:= TColorARGB.Create;
	Result.FromRGB(AColor);
	end;

constructor TColorARGB.Create(const ARed, AGreen, ABlue, AAlpha: Single);
	begin
	red:= ARed;
	green:= AGreen;
	blue:= ABlue;
	alpha:= AAlpha;
	end;

procedure TColorARGB.FromARGB(const AColor: TAlphaColor);
	var
	c: TAlphaColorRec;

	begin
	c.Color:= AColor;
	red:= c.R / 255;
	green:= c.G / 255;
	blue:= c.B / 255;
	alpha:= c.A / 255;
	end;

procedure TColorARGB.FromRGB(const AColor: TColor);
	var
	c: TColorRec;

	begin
	c.Color:= AColor;
	red:= c.R / 255;
	green:= c.G / 255;
	blue:= c.B / 255;
	end;

function TColorARGB.ToARGB: TAlphaColor;
	var
	a,
	r,
	g,
	b: Single;
	c: TAlphaColorRec;

	begin
	if  alpha < 0 then
		a:= 0
	else if alpha > 1 then
		a:= 1
	else
		a:= alpha;

	if  red < 0 then
		r:= 0
	else if red > 1 then
		r:= 1
	else
		r:= red;

	if  green < 0 then
		g:= 0
	else if green > 1 then
		g:= 1
	else
		g:= green;

	if  blue < 0 then
		b:= 0
	else if blue > 1 then
		b:= 1
	else
		b:= blue;

	c.A:= Round(a * 255);
	c.R:= Round(r * 255);
	c.G:= Round(g * 255);
	c.B:= Round(b * 255);

	Result:= c.Color;
	end;

function TColorARGB.ToRGB: TColor;
	var
	r,
	g,
	b: Single;
	c: TColorRec;

	begin
	if  red < 0 then
		r:= 0
	else if red > 1 then
		r:= 1
	else
		r:= red;

	if  green < 0 then
		g:= 0
	else if green > 1 then
		g:= 1
	else
		g:= green;

	if  blue < 0 then
		b:= 0
	else if blue > 1 then
		b:= 1
	else
		b:= blue;

//dengland I think this is necessary??
	c.A:= 0;

	c.R:= Round(r * 255);
	c.G:= Round(g * 255);
	c.B:= Round(b * 255);

	Result:= c.Color;
	end;

{ TPDParticle }

constructor TPDParticle.Create;
	begin
//dengland I think I'll include these, just in case.
	x:= 0;
	y:= 0;
	rotation:= 0;
	currentTime:= 0;
	totalTime:= 1;
	alpha:= 1;
	scale:= 1;
	color:= TAlphaColorRec.White;

	ColorARGB:= TColorARGB.Create;
	ColorArgbDelta:= TColorARGB.Create;
	end;

destructor TPDParticle.Destroy;
	begin
	ColorArgbDelta.Free;
	ColorARGB.Free;

	inherited;
	end;

{ TPDParticleSystem }

procedure TPDParticleSystem.AdvanceParticle(AParticle: TParticle;
		const APassedTime: Single);
	var
	particle: TPDParticle;
	restTime: Single;
	passedTime: Single;
	distanceX,
	distanceY,
	distanceScalar: Single;
	radialX,
	radialY,
	tangentialX,
	tangentialY: Single;
	newY: Single;

	begin
	if  APassedTime <= 0 then
		Exit;

	particle:= aParticle as TPDParticle;

	restTime:= particle.totalTime - particle.currentTime;

	if  restTime > APassedTime then
		passedTime:= APassedTime
	else
		passedTime:= restTime;

	particle.currentTime:= particle.currentTime + passedTime;

	if  FEmitterType = petRadial then
		begin
		particle.emitRotation:= particle.emitRotation +
				particle.emitRotationDelta * passedTime;
		particle.emitRadius:= particle.emitRadius +
				particle.emitRadiusDelta * passedTime;
		particle.x:= FEmitterX - Cos(particle.emitRotation) * particle.emitRadius;
		particle.y:= FEmitterY - Sin(particle.emitRotation) * particle.emitRadius;
		end
	else
		begin
		distanceX:= particle.x - particle.startX;
		distanceY:= particle.y - particle.startY;
		distanceScalar:= Sqrt(distanceX * distanceX + distanceY * distanceY);
		if  distanceScalar < 0.01 then
			distanceScalar:= 0.01;

		radialX:= distanceX / distanceScalar;
		radialY:= distanceY / distanceScalar;
		tangentialX:= radialX;
		tangentialY:= radialY;

		radialX:= radialX * particle.radialAcceleration;
		radialY:= radialY * particle.radialAcceleration;

		newY:= tangentialX;
		tangentialX:= -tangentialY * particle.tangentialAcceleration;
		tangentialY:= newY * particle.tangentialAcceleration;

		particle.velocityX:= particle.velocityX +
				passedTime * (FGravityX + radialX + tangentialX);
		particle.velocityY:= particle.velocityY +
				passedTime * (FGravityY + radialY + tangentialY);
		particle.x:= particle.x + particle.velocityX * passedTime;
		particle.y:= particle.y + particle.velocityY * passedTime;
		end;

	particle.scale:= particle.scale + particle.scaleDelta * passedTime;
	particle.rotation:= particle.rotation + particle.rotationDelta * passedTime;

	particle.colorArgb.red:= particle.colorArgb.red +
			particle.colorArgbDelta.red * passedTime;
	particle.colorArgb.green:= particle.colorArgb.green +
			particle.colorArgbDelta.green * passedTime;
	particle.colorArgb.blue:= particle.colorArgb.blue +
			particle.colorArgbDelta.blue * passedTime;
	particle.colorArgb.alpha:= particle.colorArgb.alpha +
			particle.colorArgbDelta.alpha * passedTime;

	particle.color:= particle.colorArgb.ToARGB;
	particle.alpha:= particle.colorArgb.alpha;
	end;

constructor TPDParticleSystem.Create(const AConfig: TStrings;
		const ATexture: TBitmap);
	var
	emissionRate: Single;

	begin
	FStartColor:= TColorARGB.Create;
	FStartColorVariance:= TColorARGB.Create;
	FEndColor:= TColorARGB.Create;
	FEndColorVariance:= TColorARGB.Create;

	ParseConfig(AConfig);

	emissionRate:= FMaxNumParticles / FLifespan;

	inherited Create(ATexture, emissionRate, FMaxNumParticles, FMaxNumParticles);
	end;

function TPDParticleSystem.CreateParticle: TParticle;
	begin
	Result:= TPDParticle.Create;
	end;

destructor TPDParticleSystem.Destroy;
	begin
	FEndColorVariance.Free;
	FEndColor.Free;
	FStartColorVariance.Free;
	FStartColor.Free;

	inherited;
	end;

procedure TPDParticleSystem.InitParticle(AParticle: TParticle);
	var
	particle: TPDParticle;
	lifespan,
	angle,
	speed,
	startRadius,
	endRadius,
	startSize,
	endSize: Single;
	startColor,
	colorDelta: TColorARGB;
	endColorRed,
	endColorGreen,
	endColorBlue,
	endColorAlpha: Single;
	startRotation,
	endRotation: Single;

	begin
	particle:= AParticle as TPDParticle;

//	For performance reasons, the random variances are calculated inline instead
//			of calling a function
	lifespan:= FLifespan + FLifespanVariance * (Random * 2 - 1);
	particle.currentTime:= 0;

	if  lifespan > 0 then
		particle.totalTime:= lifespan
	else
		particle.totalTime:= 0;

	if  lifespan <= 0 then
		Exit;

	particle.x:= FEmitterX + FEmitterXVariance * (Random * 2.0 - 1.0);
	particle.y:= FEmitterY + FEmitterYVariance * (Random * 2.0 - 1.0);
	particle.startX:= FEmitterX;
	particle.startY:= FEmitterY;

	angle:= FEmitAngle + FEmitAngleVariance * (Random * 2.0 - 1.0);
	speed:= FSpeed + FSpeedVariance * (Random * 2.0 - 1.0);
	particle.velocityX:= speed * Cos(angle);
	particle.velocityY:= speed * Sin(angle);

	startRadius:= FMaxRadius + FMaxRadiusVariance * (Random * 2.0 - 1.0);
	endRadius:= FMinRadius + FMinRadiusVariance * (Random * 2.0 - 1.0);
	particle.emitRadius:= startRadius;
	particle.emitRadiusDelta:= (endRadius - startRadius) / lifespan;
	particle.emitRotation:= FEmitAngle + FEmitAngleVariance * (Random * 2.0 - 1.0);
	particle.emitRotationDelta:= FRotatePerSecond +
			FRotatePerSecondVariance * (Random * 2.0 - 1.0);
	particle.radialAcceleration:= FRadialAcceleration +
			FRadialAccelerationVariance * (Random * 2.0 - 1.0);
	particle.tangentialAcceleration:= FTangentialAcceleration +
			FTangentialAccelerationVariance * (Random * 2.0 - 1.0);

	startSize:= FStartSize + FStartSizeVariance * (Random * 2.0 - 1.0);
	endSize:= FEndSize + FEndSizeVariance * (Random * 2.0 - 1.0);
	if  startSize < 0.1 then
		startSize:= 0.1;
	if  endSize < 0.1 then
		endSize:= 0.1;
	particle.scale:= startSize / Texture.Width;
	particle.scaleDelta:= ((endSize - startSize) / lifespan) / Texture.Width;

//	colors

	startColor:= particle.colorArgb;
	colorDelta:= particle.colorArgbDelta;

	startColor.red:= FStartColor.red;
	startColor.green:= FStartColor.green;
	startColor.blue:= FStartColor.blue;
	startColor.alpha:= FStartColor.alpha;

	if  FStartColorVariance.red <> 0 then
		startColor.red:= startColor.red + FStartColorVariance.red * (Random * 2.0 - 1.0);
	if  FStartColorVariance.green <> 0 then
		startColor.green:= startColor.green + FStartColorVariance.green * (Random * 2.0 - 1.0);
	if  FStartColorVariance.blue <> 0 then
		startColor.blue:= startColor.blue + FStartColorVariance.blue * (Random * 2.0 - 1.0);
	if  FStartColorVariance.alpha <> 0 then
		startColor.alpha:= startColor.alpha + FStartColorVariance.alpha * (Random * 2.0 - 1.0);

	endColorRed:= FEndColor.red;
	endColorGreen:= FEndColor.green;
	endColorBlue:= FEndColor.blue;
	endColorAlpha:= FEndColor.alpha;

	if  FEndColorVariance.red <> 0 then
		endColorRed:= endColorRed + FEndColorVariance.red * (Random * 2.0 - 1.0);
	if  FEndColorVariance.green <> 0 then
		endColorGreen:= endColorGreen + FEndColorVariance.green * (Random * 2.0 - 1.0);
	if  FEndColorVariance.blue <> 0 then
		endColorBlue:= endColorBlue + FEndColorVariance.blue * (Random * 2.0 - 1.0);
	if  FEndColorVariance.alpha <> 0 then
		endColorAlpha:= endColorAlpha + FEndColorVariance.alpha * (Random * 2.0 - 1.0);

	colorDelta.red:= (endColorRed - startColor.red) / lifespan;
	colorDelta.green:= (endColorGreen - startColor.green) / lifespan;
	colorDelta.blue:= (endColorBlue - startColor.blue) / lifespan;
	colorDelta.alpha:= (endColorAlpha - startColor.alpha) / lifespan;

//	rotation

	startRotation:= FStartRotation + FStartRotationVariance * (Random * 2.0 - 1.0);
	endRotation:= FEndRotation + FEndRotationVariance * (Random * 2.0 - 1.0);

	particle.rotation:= startRotation;
	particle.rotationDelta:= (endRotation - startRotation) / lifespan;
	end;

procedure TPDParticleSystem.ParseConfig(const AConfig: TStrings);
	var
	xml: IXMLDocument;
	doc: IXMLNode;

	function ParseFloat(const ANode, AAttrib: string): Single;
		begin
		Result:= doc.ChildNodes[ANode].Attributes[AAttrib];
		end;

	function ParseInt(const ANode, AAttrib: string): Integer;
		begin
		Result:= doc.ChildNodes[ANode].Attributes[AAttrib];
		end;

	function GetIntValue(const ANode: string): Integer;
		begin
		Result:= ParseInt(ANode, 'value');
		end;

	function GetFloatValue(const ANode: string): Single;
		begin
		Result:= ParseFloat(ANode, 'value');
		end;

	begin
	xml:= TXMLDocument.Create(nil);
	try
		xml.XML.Assign(AConfig);
		xml.Active:= True;

		doc:= xml.DocumentElement;

		FEmitterXVariance:= ParseFloat('sourcePositionVariance', 'x');
		FEmitterYVariance:= ParseFloat('sourcePositionVariance', 'y');
		FGravityX:= ParseFloat('gravity', 'x');
		FGravityY:= ParseFloat('gravity', 'y');

		FEmitterType:= TPDParticleEmitterType(GetIntValue('emitterType'));

		FMaxNumParticles:= GetIntValue('maxParticles');

		if  Assigned(doc.ChildNodes.FindNode('particleLifeSpan')) then
			FLifespan:= Max(0.01, GetFloatValue('particleLifeSpan'))
		else
			FLifespan:= Max(0.01, GetFloatValue('particleLifespan'));

		if  Assigned(doc.ChildNodes.FindNode('particleLifespanVariance')) then
			FLifespanVariance:= GetFloatValue('particleLifespanVariance')
		else
			FLifespanVariance:= GetFloatValue('particleLifeSpanVariance');

		FStartSize:= GetFloatValue('startParticleSize');
		FStartSizeVariance:= GetFloatValue('startParticleSizeVariance');
		FEndSize:= GetFloatValue('finishParticleSize');

		if  Assigned(doc.ChildNodes.FindNode('FinishParticleSizeVariance')) then
			FEndSizeVariance:= GetFloatValue('FinishParticleSizeVariance')
		else
			FEndSizeVariance:= GetFloatValue('finishParticleSizeVariance');

		FEmitAngle:= DegToRad(GetFloatValue('angle'));
		FEmitAngleVariance:= DegToRad(GetFloatValue('angleVariance'));
		FStartRotation:= DegToRad(GetFloatValue('rotationStart'));
		FStartRotationVariance:= DegToRad(GetFloatValue('rotationStartVariance'));
		FEndRotation:= DegToRad(GetFloatValue('rotationEnd'));
		FEndRotationVariance:= DegToRad(GetFloatValue('rotationEndVariance'));
		FSpeed:= GetFloatValue('speed');
		FSpeedVariance:= GetFloatValue('speedVariance');
		FRadialAcceleration:= GetFloatValue('radialAcceleration');
		FRadialAccelerationVariance:= GetFloatValue('radialAccelVariance');
		FTangentialAcceleration:= GetFloatValue('tangentialAcceleration');
		FTangentialAccelerationVariance:= GetFloatValue('tangentialAccelVariance');
		FMaxRadius:= GetFloatValue('maxRadius');
		FMaxRadiusVariance:= GetFloatValue('maxRadiusVariance');
		FMinRadius:= GetFloatValue('minRadius');

		if  Assigned(doc.ChildNodes.FindNode('minRadiusVariance')) then
			FMinRadiusVariance:= GetFloatValue('minRadiusVariance')
		else
			FMinRadiusVariance:= 0;

		FRotatePerSecond:= DegToRad(GetFloatValue('rotatePerSecond'));
		FRotatePerSecondVariance:= DegToRad(GetFloatValue('rotatePerSecondVariance'));

		FStartColor.red:= ParseFloat('startColor', 'red');
		FStartColor.green:= ParseFloat('startColor', 'green');
		FStartColor.blue:= ParseFloat('startColor', 'blue');
		FStartColor.alpha:= ParseFloat('startColor', 'alpha');

		FStartColorVariance.red:= ParseFloat('startColorVariance', 'red');
		FStartColorVariance.green:= ParseFloat('startColorVariance', 'green');
		FStartColorVariance.blue:= ParseFloat('startColorVariance', 'blue');
		FStartColorVariance.alpha:= ParseFloat('startColorVariance', 'alpha');

		FEndColor.red:= ParseFloat('finishColor', 'red');
		FEndColor.green:= ParseFloat('finishColor', 'green');
		FEndColor.blue:= ParseFloat('finishColor', 'blue');
		FEndColor.alpha:= ParseFloat('finishColor', 'alpha');

		FEndColorVariance.red:= ParseFloat('finishColorVariance', 'red');
		FEndColorVariance.green:= ParseFloat('finishColorVariance', 'green');
		FEndColorVariance.blue:= ParseFloat('finishColorVariance', 'blue');
		FEndColorVariance.alpha:= ParseFloat('finishColorVariance', 'alpha');

		finally
		xml:= nil;
		end;
	end;

procedure TPDParticleSystem.SetEndColor(const AValue: TColorARGB);
	begin
	FEndColor.CopyFrom(AValue);
	end;

procedure TPDParticleSystem.SetEndColorVariance(const AValue: TColorARGB);
	begin
	FEndColorVariance.CopyFrom(AValue);
	end;

procedure TPDParticleSystem.SetLifeSpan(const AValue: Single);
	begin
	FLifespan:= Max(0.01, AValue);
	UpdateEmissionRate;
	end;

procedure TPDParticleSystem.SetMaxNumParticles(const AValue: Integer);
	begin
	maxCapacity:= AValue;
	FMaxNumParticles:= MaxCapacity;
	UpdateEmissionRate;
	end;

procedure TPDParticleSystem.SetStartColor(const AValue: TColorARGB);
	begin
	FStartColor.CopyFrom(AValue);
	end;

procedure TPDParticleSystem.SetStartColorVariance(const AValue: TColorARGB);
	begin
	FStartColorVariance.CopyFrom(AValue);
	end;

procedure TPDParticleSystem.UpdateEmissionRate;
	begin
	EmissionRate:= FMaxNumParticles / FLifespan;
	end;


initialization
	DefaultDOMVendor:= sOmniXmlVendor;


end.
