(
~path = thisProcess.nowExecutingPath.dirname;
s.waitForBoot({

	/* begin */
	var buttons, timeline, savebutton, startbutton, pausebutton, stopbutton, savedialog, pathtext;
	var pos = 0, step = 1, length = 30, time = 0, speed = 0.8, inrecord = false;
	var out_synths, synth_options, colors, themeA, themeB, themeC, theme;
	Window.closeAll;

	/* Output synths definition */
	out_synths = Array2D.new(length, 3);   // output synths function
	synth_options = Array2D.new(4,4);      // synths options provided
	colors = Array2D.new(4,4);

	//1
	SynthDef(\Ding) { |out=0, pan=0, freq=440, attack=0.005, sustain=0.1, decay=0.5, amp=1|
		var level, plickLevel, pulse, pulse2, saw, reverb, reverb2, pan2;
		level = EnvGen.kr(Env([0,amp,amp,0], [attack,sustain,decay]), 1, doneAction: 2);
		plickLevel = EnvGen.kr(Env([0,amp,amp,0], [attack,0.05,decay]), 1);
		saw = Saw.kr(10, 0.75);
		pulse = Pulse.ar(freq, 0.5, plickLevel);
		pulse2 = Pulse.ar(freq * 0.75, 0.5, plickLevel * saw);
		reverb = FreeVerb.ar(pulse, 0.5, 1, 1);
		reverb2 = FreeVerb.ar(pulse2, 0.5, 1, 0.5);
		pan2 = Pan2.ar(reverb + reverb2, pan);
		Out.ar(out, pan2 * level);
	}.add;

	//2
	SynthDef(\Hit) { |out=0, freq=1200, decay=0.5, amp=1, pan=0|
		var sust, osc, rvrb, pan2;
		sust = EnvGen.kr(Env.perc(0.005, decay, amp), 1, doneAction: 2);
		osc = Pulse.ar(freq, 0.5, 1) - WhiteNoise.kr(1);
		rvrb = FreeVerb.ar(osc, 0, 1, 0.5);
		pan2 = Pan2.ar(rvrb, pan);
		Out.ar(out, pan2*sust);
	}.add;

	//3

	SynthDef(\sinegrain, {|pan = 1, freq = 1000, amp = 1|
		var grain;
		grain = SinOsc.ar(freq, 0, amp) * (XLine.kr(1.001,0.001,0.1,doneAction:2)-0.001);
		Out.ar(0,Pan2.ar(grain, pan))
	}).add;

	//4
	SynthDef(\snareDrum) { |out=0, freq=1000, decay=0.25, amp=1, pan=0|
		var aEnv = EnvGen.kr(Env.perc(0.005, decay, amp), 1, doneAction: 2),
		drum = SinOsc.ar(freq, 0, WhiteNoise.ar(aEnv*0.15)),
		rvrb = FreeVerb.ar(drum, 0.75, 1, 0.75) + WhiteNoise.ar(aEnv*0.5),
		pan2 = Pan2.ar(rvrb, pan);
		Out.ar(out, pan2);
	}.add;

	//5
	SynthDef(\noiseSnare) { |out=0, pan=0, freq=440, attack=0.005, sustain=0.05, decay=0.15, amp=1|
		var level, hitLevel, noise, reverb, pan2;
		level = EnvGen.kr(Env([0,amp,amp,0], [attack,sustain,decay]), 1, doneAction: 2);
		hitLevel = EnvGen.kr(Env([0,amp,amp,0], [attack,0.05,decay]), 1);
		noise = LFNoise0.ar(freq, hitLevel) + LFNoise0.ar(freq / 1.618, hitLevel);
		reverb = FreeVerb.ar(noise, 0, 1, 0.5);
		pan2 = Pan2.ar(reverb, pan);
		Out.ar(out, pan2 * level);
	}.add;

	//6
	SynthDef(\bomb) { |out=0, pan=0, freq=440, attack=0.005, sustain=0.1, decay=0.2, amp=1|
		var level, plickLevel, pulse, reverb, pan2;
		level = EnvGen.kr(Env([0,amp,amp,0], [attack,sustain,decay]), 1, doneAction: 2);
		plickLevel = EnvGen.kr(Env([0,amp,amp,0], [attack,0.05,decay]), 1);
		pulse = Pulse.ar(freq, 0.5, WhiteNoise.kr(1));
		reverb = FreeVerb.ar(pulse, 0.5, 1, 1);
		pan2 = Pan2.ar(reverb, pan);
		Out.ar(out, pan2 * level);
	}.add;


	//7
	SynthDef(\dong) { |out=0, freq=150, sustain=0.5, pan=0, amp=1|
		var level, pulse1, pulse2, pan2;
		level = EnvGen.kr(Env([1, 1, 0], [0.1, 0.05]), 1, doneAction: 2);
		pulse1 = Pulse.ar(XLine.kr(freq, freq/4, 0.1, 0.5, amp));
		pulse2 = pulse1 - Pulse.kr(freq/4/2, 0.5, 0.75);
		pan2 = Pan2.ar(pulse2, pan);
		Out.ar(out, pan2 * level);
	}.add;



	//8
	SynthDef(\sawSine) { |out=0, imp=5, freq=150, sustain=0.25, pan=0, amp=1|
		var aEnv = EnvGen.kr(Env([0,amp,amp,0], [sustain*0.75, sustain*0.25, 0.25], [-2.5,0,0]), 1, doneAction: 2),
		saw  = Saw.ar(imp, aEnv),
		sine = SinOsc.ar(freq, 0, saw),
		rvrb = sine + FreeVerb.ar(sine, 0.25, 0.5, 0.25),
		pan2 = Pan2.ar(rvrb, pan);
		Out.ar(out, pan2);
	}.add;


	//9
	SynthDef(\envSine) { |out=0, pan=0, fadeIn=0.1, sustain=0.5, fadeOut=0.1, sFreq=100, eFreq=440, amp=0.5|
		var sEnv = EnvGen.kr(Env([0, 1, 1, 0], [fadeIn, sustain, fadeOut]), 1, doneAction: 2),
		fEnv = EnvGen.kr(Env([sFreq, eFreq], [fadeIn+(sustain/2)], 0, eFreq), 1),
		sine = SinOsc.ar(fEnv, 0, amp) * sEnv,
		pan2 = Pan2.ar(sine, pan);

		Out.ar(out, pan2);
	}.add;


	//10
	SynthDef(\electric) { |out=0, freq=150, imp=1, sustain=1, amp=0.5|
		var sust = EnvGen.kr(Env([1,1,0], [sustain, 0.75]), 1, doneAction: 2),
		vSaw = VarSaw.ar(freq, 0, LFTri.kr(imp).range(0, 1), amp),
		pan2 = Pan2.ar(vSaw, FSinOsc.kr(imp*2)*0.25),
		rvrb = FreeVerb.ar(pan2, 0.25, 1, 0.75);

		Out.ar(out, rvrb*sust);
	}.add;


	//11
	SynthDef(\weng) { |out=0, sFreq=100, eFreq=200, imp=1, fadein=0.1, sustain=0.5, fadeout=0.5, curve=5, amp=0.5|
		var sust = EnvGen.kr(Env([0,1,1,0], [fadein,sustain,fadeout], [curve,0,curve]), 1, doneAction: 2),
		freq = EnvGen.kr(Env([sFreq, eFreq], [fadein], [curve]), 1),
		saw  = Saw.ar(freq, Saw.kr(50, amp/2)),
		vSaw = VarSaw.ar(freq, 0, FSinOsc.kr(imp).range(0.4, 0.7), amp/2),
		pan2 = Pan2.ar(vSaw+saw, FSinOsc.kr(fadein/2)/2);

		Out.ar(out, pan2*sust);
	}.add;


	//12
	SynthDef(\eDrum) { |out=0, freq=150, sustain=0.25, pan=0, amp=2|
		var env  = EnvGen.kr(Env([1, 1, 0], [sustain, 0.05]), 1, doneAction: 2),
		sine = SinOsc.ar(XLine.kr(freq, freq/3, sustain), 0, amp)*env,
		sqr  = Pulse.ar(XLine.kr(freq, freq/3, sustain), 0.5)*(amp*0.25)*env,
		pan2 = Pan2.ar(sine+sqr, pan);

		Out.ar(out, pan2);
	}.add;


	//13
	SynthDef(\ring) { |out=0, freq=440, amp=1, sustain=0.5|
		var sine, ring;

		sine = SinOsc.ar(
			freq,
			0,
			Trig.kr(Line.kr(1, 0, sustain), sustain)
		);
		ring = Ringz.ar(sine, 2000, sustain, amp);
		Out.ar(out, ring);
	}.add;

	//14
	SynthDef(\clock) { |out=0, freq=1000, amp=2, atk=0.005, dec=1|
		var sine  = SinOsc.ar(freq, 0, 0.25),
		saw   = Saw.ar(freq*1.25, 0.25),
		env   = EnvGen.kr(Env.perc(atk, dec*1.5), 1, doneAction: 2),
		eSine = sine*env,
		eSaw  = saw*(env*0.5),
		rvrb  = AllpassC.ar(eSine+eSaw, 0.025, 0.001, dec);

		Out.ar(out, rvrb);
	}.add;

	//15
	SynthDef(\smooth, { |out, freq = 440, sustain = 0.5, amp = 0.5|
		var sig;
		sig = SinOsc.ar(freq, 0, amp) * EnvGen.kr(Env.linen(0.05, sustain, 0.1), doneAction: 2);
		Out.ar(out, sig ! 2)
	}).add;

	//16
	SynthDef(\machine) { |out=0, freq=400, atk=0.005, sustain=0.5, dec=0.005, pan=0, amp=0.25|
		var env, osc, osc2, panning, reverb;
		env = EnvGen.kr(Env.linen(atk, sustain, dec, amp, 0), doneAction: 2);
		osc = Pulse.ar(freq, 0.5, 1);
		osc2 = Pulse.ar(freq*2, 0.5, 1);
		panning = Pan2.ar(osc+osc2, pan);
		reverb = FreeVerb.ar(panning, 0.5, 1, 0.5) * env;
		Out.ar(out, reverb);
	}.add;


	//17
	SynthDef(\zhi, {|sFreq = 500, eFreq = 1250, curve = -5, dur = 0.5, amp = 0.5, out = 0|
		var osc, freq, env;
		env = EnvGen.kr(Env.linen(0.005, 0.005, dur, amp, 0), doneAction: 2);
		freq = EnvGen.kr(Env([sFreq, eFreq], [dur], [curve]), 1);
		osc = Saw.ar(freq, env);
		Out.ar(out, osc);
	}).add;

	SynthDef(\cosmos) { |out=0, pan=0, freq=100, attack=0.005, sustain=0.1, decay=0.005, amp=1|
		var sine, pan2;

		sine = SinOsc.ar(
			freq,
			0,
			EnvGen.kr(Env([0,amp,amp,0], [attack,sustain,decay]), 1, doneAction: 2)
		);
		pan2 = Pan2.ar(sine, pan);

		Out.ar(out, pan2);
	}.add;

	SynthDef(\tech) { |out=0, imp=5, freq=150, sustain=0.25, attack=0.75, decay=0.25, pan=0, amp=0.5|
		var aEnv, saw, sine, rvrb, pan2;

		aEnv = EnvGen.kr(
			Env.linen(sustain*attack, sustain*(1-attack), decay, amp, [-2.5,0,0]),
			1,
			doneAction: 2
		);
		saw  = Saw.ar(imp, aEnv);
		sine = SinOsc.ar(freq, 0, saw).min(amp).max(0-amp);
		rvrb = sine + FreeVerb.ar(sine, 0.5, 1, 0.5);
		pan2 = Pan2.ar(rvrb, pan);

		Out.ar(out, pan2);
	}.add;

	// Theme background music
	themeA = Pbind(
		\instrument, \cosmos,
		\freq, Pswitch(
			[
				Pseq([28,35,40, 30,42,\r,\r,\r,\r,\r,\r,\r, 31,38,43, 30,37,\r,\r,\r,\r,\r,\r,\r].midicps),
				Pseq([31, 35, 40,33, 38, 42].midicps)
			],
			Pstutter(
				Pseq([2,1], inf),
				Pseq([0,1], inf) // loops = inf
			)
		) * 8,
		\dur, Pswitch(
			[
				Pseq([0.5,0.5,1] / 2)
			],
			Pstutter(
				Pseq([14], inf),
				Pseq([0], inf) // loops = inf
			)
		),
		\legato, 0.7,
		\attack, 0.005,
		\decay, 2,
		\amp, 0.125,
		\imp, 0.125,
		\pan, 0
	);

	SynthDef(\bass) { |out=0, freq=440, amp=1, pan=0, sustain=1|
		var sust, osc, osc2, pan2;

		sust = EnvGen.kr(Env([1, 1, 0], [sustain, 0.05]), 1, doneAction: 2);

		osc = SinOsc.ar(XLine.kr(freq, freq/1.05, sustain), 0, amp);
		osc2 = osc + SinOsc.kr(freq/16.18, 0, amp);
		pan2 = Pan2.ar(osc2, pan);

		Out.ar(out, pan2*sust);
	}.add;

	themeB = Pbind(
		\instrument, \bass,
		\freq, Pstutter(
			Pseq([16, 1, 8, 1, 8, 1], inf),
			Pseq([49, 48, 51, 48, 53, 48].midicps, inf)
		),
		\dur, Pstutter(
			Pseq([16], inf),
			Pseq([0.25], inf)
		),
		\amp, 0.7,
		\out, [0,1]
	);

	SynthDef(\deep) { |out=0, freq=150, filMin=0.1, filMax=0.95, imp=1, gate=1, amp=0.5|
		var sust = Linen.kr(gate, releaseTime: 0.25, doneAction: 2),
		vSaw = VarSaw.ar(
			freq,
			0,
			EnvGen.kr(Env([filMin,filMax,filMin], [0.25*imp,0.75*imp], [-5,-5], 2), gate),
			amp
		),
		pan2 = Pan2.ar(vSaw, FSinOsc.kr(imp*2)*0.25),
		rvrb = FreeVerb.ar(pan2, 0.25, 1, 0.75);

		Out.ar(out, rvrb*sust);
	}.add;

	themeC = Pbind(
		\instrument, \deep,
		\freq, Pstutter(
			Pseq([16], inf),
			Pseq([22, 23, 25].midicps*4, inf)
		),
		\dur, 0.125,
		\legato, 1,
		\filMax, 0.1,
		\imp, 0.5,
		\amp, 1
	);


	// Initialize the sound synths
	synth_options[0,0] = 'Ding';
	synth_options[0,1] = 'Hit';
	synth_options[0,2] = 'sinegrain';
	synth_options[0,3] = 'snareDrum';
	synth_options[1,0] = 'noiseSnare';
	synth_options[1,1] = 'bomb';
	synth_options[1,2] = 'dong';
	synth_options[1,3] = 'sawSine';
	synth_options[2,0] = 'envSine';
	synth_options[2,1] = 'electric';
	synth_options[2,2] = 'weng';
	synth_options[2,3] = 'eDrum';
	synth_options[3,0] = 'ring';
	synth_options[3,1] = 'clock';
	synth_options[3,2] = 'smooth';
	synth_options[3,3] = 'machine';

	// Initialize the grid color
	colors[0,0] = Color.black;
	colors[0,1] = Color.gray;
	colors[0,2] = Color.grey;
	colors[0,3] = Color.red;
	colors[1,0] = Color.green;
	colors[1,1] = Color.blue;
	colors[1,2] = Color.cyan;
	colors[1,3] = Color.magenta;
	colors[2,0] = Color.yellow;
	colors[2,1] = Color.new(0.96, 0, 0);
	colors[2,2] = Color.new(0.43, 0.5, 0.41);
	colors[2,3] = Color.new(0.7,0.8,0.9);
	colors[3,0] = Color.new(0.5,0.5,0.5);
	colors[3,1] = Color.new(0.3, 0.9, 0.2);
	colors[3,2] = Color.new(0.5, 0.1, 0.9);
	colors[3,3] = Color.new(1.0, 0.5, 0.7);

	///////////////
	// Main GUI Design
	///////////////

	w = Window.new("AIST Project", bounds: 580@600);
	f = FlowView.new(w, bounds: 580@600, margin: 10@10, gap: 10@10).background_(Color.white);
	w.onClose = {s.freeAll; CmdPeriod.run; "Window Closed".postln; };
	CmdPeriod.doOnce({Window.closeAll});

	//timeline
	t = FlowView.new(f, 560@150, margin: 10@10).background_(Color.yellow(0.9, 0.5));
	StaticText.new(t, 150@30).string_("Timeline").align_(\topLeft).font_(Font("Verdana", 14, true));
	timeline = UserView(t, bounds:560@150);
	timeline.drawFunc = {
		Pen.fillColor = Color.new255(240, 248, 255);
		Pen.addRect(Rect(0, 40, 540, 10));
		Pen.fill;

		length.do({ |i|
			if (out_synths[i,0]!=nil, {
				Pen.fillColor = out_synths[i,0].color;
				Pen.addRect(Rect(18*i+4, 5, 10, 10));
				Pen.fill;
			});
			if (out_synths[i,1]!=nil, {
				Pen.fillColor = out_synths[i,1].color;
				Pen.addRect(Rect(18*i+4, 20, 10, 10));
				Pen.fill;
			});
			if (out_synths[i,2]!=nil, {
				Pen.fillColor = out_synths[i,2].color;
				Pen.addRect(Rect(18*i+4, 55, 10, 10));
				Pen.fill;
			});
		});

		Pen.moveTo(time@20);
		Pen.lineTo(time@70);
		Pen.strokeColor_(Color.green(0.8, 1.0));
		Pen.stroke;
	};
	//theme button
	theme = themeA.play;
	k = Button.new(f,bounds: 80@30).states_([["A"],["B"],["C"]]).action_({ |butt|
		if (butt.value == 0) { "Theme A".postln;  theme.stop; theme=themeA.play; };
		if (butt.value == 1) { "Theme B".postln;  theme.stop; theme=themeB.play; };
		if (butt.value == 2) { "Theme C".postln;  theme.stop; theme=themeC.play; };
	});
	//remaining space
	r = FlowView.new(f,bounds: 470@30).background_(Color.grey);

	// CompositeView for Stethoscope
	y = CompositeView.new(f, Rect(0, 0, 250, 250));
	// .background_(Color.yellow(0.5));
	// Scope
	Stethoscope.new(s, view: y);
	// Scope Label (and hiding space for scope options)
	k = CompositeView.new(y, Rect(2, 0, 250, 25)).background_(Color.white);
	// Label: Input (sine wave)
	StaticText.new(k , 230@30).string_("output waveform").align_(\top).font_(Font("Verdana", 14, true));

	//play block
	p = FlowView.new(f, bounds: 300@300, margin: 10@10, gap: 10@10).background_(Color.green(0.4, 0.5));
	StaticText.new(p, 300@20).string_("click to play").align_(\topLeft).font_(Font("Verdana", 14, true));

	//play buttons
	buttons = Array.fill(4, { |i|
		Array.fill(4, { |j|
			Button(p, bounds: 62@50).icon_(Image.open(~path+/+"pic"++i++j++".png")).iconSize_(30)
			.mouseDownAction_({
				if (out_synths[pos, 0] == nil, {
					out_synths[pos, 0] = (name:synth_options[i, j], color:colors[i,j]);
					Synth(synth_options[i,j]);
				}, {
					if (out_synths[pos, 1] == nil, {
						out_synths[pos, 1] = (name:synth_options[i, j], color:colors[i,j]);
						Synth(synth_options[i,j]);
					}, {
						if (out_synths[pos, 2] == nil, {
							out_synths[pos, 2] = (name:synth_options[i, j], color:colors[i,j]);
							Synth(synth_options[i,j]);
						});
					});
				});
			});
		});
	});

	////////////////
	// Audio Saving
	////////////////
	c = CompositeView(f, 580@80);
	savebutton = Button(c, Rect(190, 5, 200, 30))
	.string_("Record and Save the sound")
	.action_({ arg butt;
		if (inrecord != true, {
			var recording = false, path = ~path++"/sound.wav";
			inrecord = true;
			savedialog = Window.new("Sounder recorder", bounds: 500@110);
			savedialog.onClose = {inrecord = false; };
			pathtext = EZText(savedialog, Rect(10,10,480,40), "Path:",
				{|ez| path=ez.value.asString; path.postln; s.prepareForRecord(path); }, path, false);
			//s.recHeaderFormat_("wav");
			s.prepareForRecord(path);
			Button(savedialog, Rect(65, 60, 80, 40)).string_("Record").action_({
				if (recording==false, {
					recording = true;
					"start recording".postln;
					s.record;
				});
			});
			Button(savedialog, Rect(210, 60, 80, 40)).string_("Pause").action_({
				if (recording==true, {
					recording = false;
					"pause recording".postln;
					s.pauseRecording;
				});
			});
			Button(savedialog, Rect(355, 60, 80, 40)).string_("Stop").action_({
				if (recording==true, {
					recording = false;
					"stop recording".postln;
					s.stopRecording;
				});
			});
			savedialog.front;
		});
	});

	/* Audio loop task*/
	Task({
		inf.do({
			time = (time + step).mod(540);
			if (time.mod(18)==0, {
				pos = (pos + step).mod(length);
				pos.postln;
				if(out_synths[pos, 0] != nil, {Synth(out_synths[pos, 0].name);});
				if(out_synths[pos, 1] != nil, {Synth(out_synths[pos, 1].name);});
				if(out_synths[pos, 2] != nil, {Synth(out_synths[pos, 2].name);});
			});
			timeline.refresh;
			(speed/24.0).yield;
		});
	}, AppClock).play(quant:[0]);

	w.front;
})
)

