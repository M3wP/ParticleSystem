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

unit ParticleSystem;

interface

uses
	System.Types, System.UITypes, System.Math, System.Generics.Collections,
	FMX.Graphics;

const
	VAL_MAX_NUM_PARTICLES = 16383;
	VAL_MAX_NUM_CACHE = VAL_MAX_NUM_PARTICLES div 4;

type
	TParticleCache = class(TObject)
	private
		FTexture: TBitmap;
		FTextures: TList<TBitmap>;
		FColorMap: TDictionary<TAlphaColor, Integer>;
		FIndexMap: TDictionary<Integer, TAlphaColor>;
//		FHitMap: TDictionary<Integer, Integer>;

	public
		constructor Create(const ATexture: TBitmap);
		destructor  Destroy; override;

		function  GetTextureForColor(const AColor: TAlphaColor): TBitmap;
	end;

	TParticle = class(TObject)
	public
		x,
		y,
		scale,
		rotation: Single;
		color: TAlphaColor;
		alpha,
		currentTime,
		totalTime: Single;

		constructor Create;
	end;

	TParticleSystem = class(TObject)
	private
		FCache: TParticleCache;

		FTexture: TBitmap;
		FParticles: array of TParticle;
		FFrameTime: Single;

		FNumParticles: Integer;
		FMaxCapacity: Integer;
		FEmissionRate: Single;
		FEmissionTime: Single;

		procedure RaiseCapacity(AByAmount: Integer);

	protected
		FEmitterX: Single;
		FEmitterY: Single;
//		FPremultipliedAlpha: Boolean;
//		FBlendFactorSource: string;
//		FBlendFactorDestination: string;
//		FSmoothing: string;

		function  CreateParticle: TParticle; virtual;
		procedure InitParticle(AParticle: TParticle); virtual;
		procedure AdvanceParticle(AParticle: TParticle; const APassedTime: Single); virtual;

		function  GetIsEmitting: Boolean;
		function  GetCapacity: Integer;
		procedure SetMaxCapacity(const AValue: Integer);
		procedure SetTexture(const AValue: TBitmap);

	public
		constructor Create(const ATexture: TBitmap; const AEmissionRate: Single;
				const AInitialCapacity: Integer = 128;
				const AMaxCapacity: Integer = VAL_MAX_NUM_PARTICLES{;
				const ABlendFactorSource: string = '';
				const ABlendFactorDest: string = ''});
		destructor  Destroy; override;

		procedure Start(const ADuration: Single = MaxSingle);
		procedure Stop(const AClearParticles: Boolean = False);
		procedure Clear;
		procedure AdvanceTime(const APassedTime: Single);
		procedure Render(const ADestCanvas: TCanvas);
		procedure Populate(const ACount: Integer);

		property  IsEmitting: Boolean read GetIsEmitting;
		property  Capacity: Integer read GetCapacity;
		property  NumParticles: Integer read FNumParticles;
		property  MaxCapacity: Integer read FMaxCapacity write SetMaxCapacity;
		property  EmissionRate: Single read FEmissionRate write FEmissionRate;
		property  EmitterX: Single read FEmitterX write FEmitterX;
		property  EmitterY: Single read FEmitterY write FEmitterY;
		property  Texture: TBitmap read FTexture write SetTexture;
	end;


implementation

uses
	System.SysUtils, System.Math.Vectors;


{ TParticleCache }

constructor TParticleCache.Create(const ATexture: TBitmap);
	begin
	FTexture:= ATexture;

	FTextures:= TList<TBitmap>.Create;
	FColorMap:= TDictionary<TAlphaColor, Integer>.Create;
//	FHitMap:= TDictionary<Integer, Integer>.Create;
	FIndexMap:= TDictionary<Integer, TAlphaColor>.Create;
	end;

destructor TParticleCache.Destroy;
	var
	i: Integer;

	begin
	for i:= FTextures.Count - 1 downto 0 do
		begin
		FTextures[i].Free;
		FTextures.Delete(i);
		end;

	FTextures.Free;

//	FHitMap.Free;
	FColorMap.Free;
	FIndexMap.Free;

	inherited;
	end;

function TParticleCache.GetTextureForColor(const AColor: TAlphaColor): TBitmap;
	var
	idx: Integer;
//	sortHits: TList<Integer>;
	c1,
	c2: TAlphaColor;
	cr: TAlphaColorRec;

	begin
	cr.Color:= AColor;
	cr.A:= $FF;

	c1:= cr.Color;

	if  FColorMap.ContainsKey(c1) then
		begin
		idx:= FColorMap[c1];

//		FHitMap[idx]:= FHitMap[idx] + 1;

		Result:= FTextures[idx];
		end
	else
		begin
		if  FTextures.Count = VAL_MAX_NUM_CACHE then
			begin
//			sortHits:= TList<Integer>.Create(FHitMap.Keys);
//			sortHits.Sort;
//			idx:= sortHits[0];
//			sortHits.Free;

			idx:= Random(FTextures.Count);
			c2:= FIndexMap[idx];

//			for c2 in FColorMap.Keys do
//				if  FColorMap[c2] = idx then
//					begin
					FColorMap.Remove(c2);
//					Break;
//					end;

//			FHitMap.Remove(idx);
			FIndexMap.Remove(idx);
			end
		else
			begin
			idx:= FTextures.Count;
			FTextures.Add(TBitmap.Create);
			end;

		FColorMap.Add(c1, idx);
//		FHitMap.Add(idx, 1);
		FIndexMap.Add(idx, c1);

		Result:= FTextures[idx];

		Result.Assign(FTexture);
		Result.ReplaceOpaqueColor(c1);
		end;
	end;


{ TParticle }

constructor TParticle.Create;
	begin
	x:= 0;
	y:= 0;
	rotation:= 0;
	currentTime:= 0;
	totalTime:= 1;
	alpha:= 1;
	scale:= 1;
	color:= TAlphaColorRec.White;
	end;

{ TParticleSystem }

procedure TParticleSystem.AdvanceParticle(AParticle: TParticle;
		const APassedTime: Single);
	begin
	AParticle.y:= AParticle.y + APassedTime * 250;
	AParticle.alpha:= 1 - AParticle.currentTime / AParticle.totalTime;
	AParticle.scale:= 1 - AParticle.alpha;
	AParticle.currentTime:= AParticle.currentTime + APassedTime;
	end;

procedure TParticleSystem.AdvanceTime(const APassedTime: Single);
	var
	particleIndex: Integer;
	particle,
	nextParticle: TParticle;
	timeBetweenParticles: Single;

	begin
	if  APassedTime <= 0 then
		Exit;

	particleIndex:= 0;

//  Advance existing particles
	while particleIndex < FNumParticles do
		begin
		particle:= FParticles[particleIndex];

		if  particle.currentTime < particle.totalTime then
			begin
			AdvanceParticle(particle, APassedTime);
			Inc(particleIndex);
			end
		else
			begin
			if  particleIndex <> (FNumParticles - 1) then
				begin
				nextParticle:= FParticles[FNumParticles - 1];
				FParticles[FNumParticles - 1]:= particle;
				FParticles[particleIndex]:= nextParticle;
				end;

			Dec(FNumParticles);

//			if  (FNumParticles = 0)
//			and (FEmissionTime = 0) then
//				DispatchEvent(EVENT_COMPLETE);
			end;
		end;

//  Create and advance new particles
	if  FEmissionTime > 0 then
		begin
		timeBetweenParticles:= 1 / FEmissionRate;
		FFrameTime:= FFrameTime + APassedTime;

		while FFrameTime > 0 do
			begin
			if  FNumParticles < FMaxCapacity then
				begin
				if  FNumParticles = Capacity then
					RaiseCapacity(Capacity);

				particle:= FParticles[FNumParticles];
				InitParticle(particle);

//              Particle might be dead at birth
				if  particle.totalTime > 0 then
					begin
					AdvanceParticle(particle, FFrameTime);
					Inc(FNumParticles);
					end;
				end;

			FFrameTime:= FFrameTime - timeBetweenParticles;
			end;

		if  FEmissionTime <> MaxSingle then
			FEmissionTime:= Max(0.0, FEmissionTime - APassedTime);
		end;
	end;

procedure TParticleSystem.Clear;
	begin
	FNumParticles:= 0;
	end;

constructor TParticleSystem.Create(const ATexture: TBitmap;
		const AEmissionRate: Single; const AInitialCapacity, AMaxCapacity: Integer);
	begin
	if  not Assigned(ATexture) then
		raise Exception.Create('Texture must be assigned');

	FTexture:= TBitmap.Create;
	FTexture.Assign(ATexture);

	FCache:= TParticleCache.Create(FTexture);

	FEmissionRate:= AEmissionRate;
	FEmissionTime:= 0;
	FFrameTime:= 0;

	FEmitterX:= 0;
	FEmitterY:= 0;

	FMaxCapacity:= Min(VAL_MAX_NUM_PARTICLES, AMaxCapacity);

	RaiseCapacity(AInitialCapacity);
	end;

function TParticleSystem.CreateParticle: TParticle;
	begin
	Result:= TParticle.Create;
	end;

destructor TParticleSystem.Destroy;
	begin
	FreeAndNil(FCache);
	FreeAndNil(FTexture);

	inherited;
	end;

function TParticleSystem.GetCapacity: Integer;
	begin
	Result:= Length(FParticles);
	end;

function TParticleSystem.GetIsEmitting: Boolean;
	begin
    Result:= (FEmissionTime > 0) and (FEmissionRate > 0);
	end;

procedure TParticleSystem.InitParticle(AParticle: TParticle);
	begin
	AParticle.x:= FEmitterX;
	AParticle.y:= FEmitterY;
	AParticle.currentTime:= 0;
	AParticle.totalTime:= 1;
//dengland I made it $01000000 to include $FFFFFF...
	AParticle.color:= TAlphaColorRec.Alpha or TAlphaColor(Random($01000000));
	end;

procedure TParticleSystem.Populate(const ACount: Integer);
	var
	cnt: Integer;
	p: TParticle;
	i: Integer;

	begin
	cnt:= Min(ACount, FMaxCapacity - FNumParticles);

	if  (FNumParticles + cnt) > Capacity then
		RaiseCapacity(FNumParticles + cnt - Capacity);

	for i:= 0 to cnt - 1 do
		begin
		p:= FParticles[FNumParticles + i];
		InitParticle(p);
		AdvanceParticle(p, Random(Round(p.totalTime * 1000)) / 1000);
		end;

	FNumParticles:= FNumParticles + cnt;
	end;

procedure TParticleSystem.RaiseCapacity(AByAmount: Integer);
	var
	oldCapacity: Integer;
	newCapacity: Integer;
	i: Integer;

	begin
	oldCapacity:= Capacity;
	newCapacity:= Min(FMaxCapacity, Capacity + AByAmount);

	SetLength(FParticles, newCapacity);

	for i:= oldCapacity to newCapacity - 1 do
		begin
		FParticles[i]:= CreateParticle;
		end;
	end;

procedure TParticleSystem.Render(const ADestCanvas: TCanvas);
	var
	i: Integer;
	saveMatrix,
	blitMatrix: TMatrix;
	tmpBmp: TBitmap;
	srcRect,
	destRect,
	boundsRect: TRectF;
	srcPoint: TPointF;

	begin
	if  FNumParticles = 0 then
		Exit;

	srcRect.Left:= 0;
	srcRect.Top:= 0;
	srcRect.Right:= FTexture.Width;
	srcRect.Bottom:= FTexture.Height;

	boundsRect.Left:= 0;
	boundsRect.Top:= 0;
	boundsRect.Right:= ADestCanvas.Width;
	boundsRect.Bottom:= ADestCanvas.Height;

	srcPoint.X:= srcRect.Right / 2;
	srcPoint.Y:= srcRect.Bottom / 2;

	if  ADestCanvas.BeginScene then
		begin
		saveMatrix:= ADestCanvas.Matrix;

//		tmpBmp:= TBitmap.Create;
//		tmpBmp.Assign(FTexture);

		for i:= 0 to FNumParticles - 1 do
			begin
//			tmpBmp.Assign(FTexture);
//			tmpBmp.ReplaceOpaqueColor(FParticles[i].color);

			destRect:= srcRect;
			destRect.Offset(FParticles[i].x, FParticles[i].y);
			destRect.Right:= destRect.Left + srcRect.Right * FParticles[i].scale;
			destRect.Bottom:= destRect.Top + srcRect.Bottom * FParticles[i].scale;

			if  not destRect.IntersectsWith(boundsRect) then
				Continue;

			tmpBmp:= FCache.GetTextureForColor(FParticles[i].Color);

			blitMatrix:= TMatrix.CreateTranslation(-srcPoint.X, -srcPoint.Y) *
					TMatrix.CreateScaling(FParticles[i].scale, FParticles[i].scale) *
					TMatrix.CreateRotation(FParticles[i].rotation) *
					TMatrix.CreateTranslation(srcPoint.X, srcPoint.Y) *
					TMatrix.CreateTranslation(destRect.Left - srcPoint.X, destRect.Top - srcPoint.Y);

			ADestCanvas.SetMatrix(blitMatrix);
			ADestCanvas.DrawBitmap(tmpBmp, srcRect, srcRect, FParticles[i].alpha, True);
			end;

//		tmpBmp.Free;

		ADestCanvas.SetMatrix(saveMatrix);
		ADestCanvas.EndScene;
		end;
	end;

procedure TParticleSystem.SetMaxCapacity(const AValue: Integer);
	begin
	FMaxCapacity:= Min(VAL_MAX_NUM_PARTICLES, AValue);
	end;

procedure TParticleSystem.SetTexture(const AValue: TBitmap);
	begin
	FTexture.Assign(AValue);
	end;

procedure TParticleSystem.Start(const ADuration: Single);
	begin
	if  (FEmissionRate <> 0) then
		FEmissionTime:= ADuration;
	end;

procedure TParticleSystem.Stop(const AClearParticles: Boolean);
	begin
	FEmissionTime:= 0;
	if  AClearParticles then
		Clear;
	end;

end.
