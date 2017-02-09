Pascal (Delphi FMX) Conversion of Starling Particle System Extension
====================================================================

Copyright 2011 Gamua. All rights reserved.

This is a conversion of the Starling Particle System Extension by 
Daniel England.

Modifications Copyright 2017 Daniel England.  All Rights Reserved.

See LICENSE.md for further details.

The original readme has been included as "STARLING README.md".


Introduction
------------

The units ParticleSystem.pas and PDParticleSystem.pas provide a somewhat simplified version of the Starling Particle System extension.

I have had to leave out the blending functions functionality because it relied on features of ActionScript/Flash/AIR that I could not replicate in Delphi FMX.

Also, I have had to use the built-in colour remapping functionality of FMX which relies on the CPU instead of the pixel shaders used in the Starling version.  This is because I simply do not currently have the technical know-how to implement the shaders.  I have tried to enhance the performance with a texture cache but depending upon the particles generated, it may or may not grant much of an improvement.

The "high quality" option of the DrawBitmap function has been set to False but this could be configured using a reimplementation of the "Smoothing" property.

The performance is, overall, lower than I was hoping.  Running on a modern-ish Windows machine, I get fairly decent performance but none of my Android machines could get a stable frame rate.

I have included a simple stress-test type demo.

The original code extensively used the "Number" type which technically translates to Double but I have used Single in keeping with the FMX standard.

One thing to note is that the Starling (and Flash/AIR) system uses fractions of a second/seconds ("Number") values for the measuring the passage of time.  This is different to how it is usually done in Delphi where you would use "ticks" (Cardinal).  See the demo for how this is handled.


Usage
-----

You would normally model your particle system with a tool such as the one at:

	<http://onebyonedesign.com/flash/particleeditor/>

Then, create an instance of TPDParticleSystem passing the .pex file strings and required texture.  You need to set the EmitterX and EmitterY properties to the required location and call the Start method.  As you require updates, call the AdvanceTime method and to paint the results, call the Render method.

See the included demo for a simple way to handle all of this.


Compiling
---------

Presently, only Delphi and FMX (FireMonkey) are supported.  I am using Delphi XE8 and I am unsure of the minimum required version.  I imagine that it will compile and run with the latest version, as well.

The demo project can be run on any platform supported by Delphi but as already mentioned, the performance may leave a lot to be desired on mobile platforms.


Contact
-------

I can be contacted for further information regarding this tool at the following address:

        mewpokemon {you know what goes here} hotmail {and here} com

Please include the word "Particle System" in the subject line.


Daniel England.

