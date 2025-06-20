/*========================================
lights.qc taken from c0burn's Slipgate mod -- dumptruck_ds
========================================*/

float START_OFF		= 1;
float FADE_IN_OUT	= 2;
float SILENT_TORCH = 4; // for silent torch -- dumptruck_ds

/*QUAKED info_null (0 0.5 0) (-4 -4 -4) (4 4 4) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY

Used as a positional target for spotlights, etc.
*/
void() info_null = {
	remove(self);
};

/*QUAKED info_notnull (0 0.5 0) (-4 -4 -4) (4 4 4) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY

Never used in the or
*/
void() info_notnull = {};

/*==========
lightstyle_lookup
==========*/
float LIGHTSTYLES_MAX = 17; // If new styles are added change this const

string(float num) lightstyle_lookup =
{
	switch (num)
	{
		// 0 normal
		case 0:
			return "m";
			break;
		// 1 FLICKER (first variety)
		case 1:
			return "mmnmmommommnonmmonqnmmo";
			break;
		// 2 SLOW STRONG PULSE
		case 2:
			return "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba";
			break;
		// 3 CANDLE (first variety)
		case 3:
			return "mmmmmaaaaammmmmaaaaaabcdefgabcdefg";
			break;
		// 4 FAST STROBE
		case 4:
			return "mamamamamama";
			break;
		// 5 GENTLE PULSE 1
		case 5:
			return "jklmnopqrstuvwxyzyxwvutsrqponmlkj";
			break;
		// 6 FLICKER (second variety)
		case 6:
			return "nmonqnmomnmomomno";
			break;
		// 7 CANDLE (second variety)
		case 7:
			return "mmmaaaabcdefgmmmmaaaammmaamm";
			break;
		// 8 CANDLE (third variety)
		case 8:
			return "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa";
			break;
		// 9 SLOW STROBE (fourth variety)
		case 9:
			return "aaaaaaaazzzzzzzz";
			break;
		// 10 FLUORESCENT FLICKER
		case 10:
			return "mmamammmmammamamaaamammma";
			break;
		// 11 SLOW PULSE NOT FADE TO BLACK
		case 11:
			return "abcdefghijklmnopqrrqponmlkjihgfedcba";
			break;

		// johnfitz new lightstyles
		// 12 ALARM PULSE
		case 12:
			return "zxvtrpnlj";	
			break;
		// 13 STROBE-PULSE COMBO (first variety)
		case 13:
			return "jalanaparatavaxazaxavatarapanala";
			break;
		// 14 STROBE-PULSE COMBO (second variety)
		case 14:
			return "zaxavatarapanalajalanaparatavaxa";
			break;
		// 15 VANITY
		case 15:
			return "johnfitzgibbons";
			break;
		// 16 LANDING BEACON STROBE
		case 16:
			return "mmaammaammaammaa";
			break;
		// end johnfitz new lightstyles

		// 17 GENERAL BLINK OFF / ON (can be synced with animated textures, e.g. +0light and +1light)
		case 17:
			return "aamm";
			break;

		// DEFAULT
		default:
			return "a";
			break;
	}
};

/*==========
setup_lightstyles

Setup light animation tables. 'a' is total darkness, 'z' is maxbright.
Styles 32+ are assigned by the light program for switchable lights,
but that value can be changed with the _compilerstyle_start worldspawn key.

==========*/

void() setup_lightstyles = {
	for (float i = 0; i <= LIGHTSTYLES_MAX; i++) {
		lightstyle(i, lightstyle_lookup(i));
	}
};

/*==========
lightstyle_fade_lookup
==========*/
string(float num) lightstyle_fade_lookup =
{
	switch (num)
	{
		case 0:
			return "a";
			break;
		case 1:
			return "b";
			break;
		case 2:
			return "c";
			break;
		case 3:
			return "d";
			break;
		case 4:
			return "e";
			break;
		case 5:
			return "f";
			break;
		case 6:
			return "g";
			break;
		case 7:
			return "h";
			break;
		case 8:
			return "i";
			break;
		case 9:
			return "j";
			break;
		case 10:
			return "k";
			break;
		case 11:
			return "l";
			break;
		case 12:
			return "m";
			break;
		default:
			error("count out of range\n");
			break;
	}
};

/*==========
light_fade_in
==========*/
void() light_fade_in = {
	if (self.count < 0)
		self.count = 0;
	if (self.count > 12)
		self.count = 12;

	lightstyle(self.style, lightstyle_fade_lookup(self.count));
	self.count = self.count + 1;
	if (self.count > 12)
		return;

	self.think = light_fade_in;
	self.nextthink = time + self.speed;
};

/*==========
light_fade_out
==========*/
void() light_fade_out = {
	if (self.count < 0)
		self.count = 0;
	if (self.count > 12)
		self.count = 12;

	lightstyle(self.style, lightstyle_fade_lookup(self.count));
	self.count = self.count - 1;
	if (self.count < 0)
		return;

	self.think = light_fade_out;
	self.nextthink = time + self.speed;
};

/*==========
light_use

using a light will turn it on and off
==========*/
void() light_use =
{
	if (self.estate == STATE_INACTIVE) {
		self.estate = STATE_ACTIVE;
		if (self.spawnflags & FADE_IN_OUT && !self.style2)
			light_fade_in();
		else
			lightstyle(self.style, lightstyle_lookup(self.style2));
	}
	else {
		self.estate = STATE_INACTIVE;
		if (self.spawnflags & FADE_IN_OUT && !self.style2)
			light_fade_out();
		else
			lightstyle(self.style, "a");
	}
};

void(float newstate, float stateflags) light_setstate = {
	if (newstate == STATE_ACTIVE) {
		if (self.spawnflags & FADE_IN_OUT && !self.style2)
			light_fade_in();
		else
			lightstyle(self.style, lightstyle_lookup(self.style2));
	}
	else {
		if (self.spawnflags & FADE_IN_OUT && !self.style2)
			light_fade_out();
		else
			lightstyle(self.style, "a");
	}
	self.estate = newstate;
}

/*QUAKED light (0 1 0) (-8 -8 -8) (8 8 8) START_OFF FADE_IN_OUT X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY

Light

==========
Spawnflags
==========
START_OFF - switchable lights only - light is off by default
FADE_IN_OUT - switchable lights only - light fades in and out. can't be combined with animated lights.

==========
Keys
==========
"light" "n"
Set the light intensity. Negative values are also allowed and will cause the entity to subtract light cast by other entities. Default 300.

"wait" "n"
Scale the fade distance of the light by "n". Values of n > 1 make the light fade more quickly with distance, and values < 1 make the light fade more slowly (and thus reach further). Default 1.

"delay" "n"
Select an attenuation formaula for the light:
0 => Linear attenuation (default)
1 => 1/x attenuation
2 => 1/(x^2) attenuation
3 => No attenuation (same brightness at any distance)
4 => "local minlight" - No attenuation and like minlight,
it won't raise the lighting above it's light value.
Unlike minlight, it will only affect surfaces within
line of sight of the entity.
5 => 1/(x^2) attenuation, but slightly more attenuated and
without the extra bright effect that "delay 2" has
near the source.

"_falloff" "n"
Sets the distance at which the light drops to 0, in map units.
In this mode, "wait" is ignored and "light" only controls the brightness at the center of the light, and no longer affects the falloff distance.
Only supported on linear attenuation (delay 0) lights currently.

"_color" "r g b"
Specify red(r), green(g) and blue(b) components for the colour of the light. RGB component values are between 0 and 255 (between 0 and 1 is also accepted). Default is white light ("255 255 255").

"target" "name"
Turns the light into a spotlight, with the direction of light being towards another entity with it�s "targetname" key set to "name".
"mangle" "yaw pitch roll"
Turns the light into a spotlight and specifies the direction of light using yaw, pitch and roll in degrees. Yaw specifies the angle around the Z-axis from 0 to 359 degrees and pitch specifies the angle from 90 (straight up) to -90 (straight down). Roll has no effect, so use any value (e.g. 0). Often easier than the "target" method.

"angle" "n"
Specifies the angle in degrees for a spotlight cone. Default 40.

"_softangle" "n"
Specifies the angle in degrees for an inner spotlight cone (must be less than the "angle" cone. Creates a softer transition between the full brightness of the inner cone to the edge of the outer cone. Default 0 (disabled).

"targetname" "name"
Turns the light into a switchable light, toggled by another entity targeting it�s name.

"speed" "n"
If the light is switchable and FADE_IN_OUT is set, the speed at which the light transitions. Default 0.1.

"style" "n"
Set the animated light style. Default 0.

"style2" "n"
Set the animated light style for a switchable light, because style will be overriden if a targetname is set. Default 0.

"_anglescale" "n" | "_anglesense" "n"
Sets a scaling factor for how much influence the angle of incidence of light on a surface has on the brightness of the surface. n must be between 0.0 and 1.0. Smaller values mean less attenuation, with zero meaning that angle of incidence has no effect at all on the brightness. Default 0.5.

"_dirtscale" "n" | "_dirtgain" "n"
Override the global "_dirtscale" or "_dirtgain" settings to change how this light is affected by dirtmapping (ambient occlusion). See descriptions of these keys in the worldspawn section.

"_dirt" "n"
Overrides the worldspawn setting of "_dirt" for this particular light. -1 to disable dirtmapping (ambient occlusion) for this light, making it illuminate the dirtmapping shadows. 1 to enable ambient occlusion for this light. Default is to defer to the worldspawn setting.

"_deviance" "n"
Split up the light into a sphere of randomly positioned lights within radius "n" (in world units). Useful to give shadows a wider penumbra. "_samples" specifies the number of lights in the sphere. The "light" value is automatically scaled down for most lighting formulas (except linear and non-additive minlight) to attempt to keep the brightness equal. Default is 0, do not split up lights.

"_samples" "n"
Number of lights to use for "_deviance". Default 16 (only used if "_deviance" is set).

"_surface" "texturename"
Makes surfaces with the given texture name emit light, by using this light as a template which is copied across those surfaces. Lights are spaced about 128 units (though possibly closer due to bsp splitting) apart and positioned 2 units above the surfaces.

"_surface_offset" "n"
Controls the offset lights are placed above surfaces for "_surface". Default 2.

"_surface_spotlight" "n"
For a surface light template (i.e. a light with "_surface" set), setting this to "1" makes each instance into a spotlight, with the direction of light pointing along the surface normal. In other words, it automatically sets "mangle" on each of the generated lights.

"_project_texture" "texture"
Specifies that a light should project this texture. The texture must be used in the map somewhere.

"_project_mangle" "yaw pitch roll"
Specifies the yaw/pitch/roll angles for a texture projection (overriding mangle).

"_project_fov" "n"
Specifies the fov angle for a texture projection. Default 90.

"_bouncescale" "n"
Scales the amount of light that is contributed by bounces. Default is 1.0, 0.0 disables bounce lighting for this light.

"_sun" "n"
Set to 1 to make this entity a sun, as an alternative to using the sunlight worldspawn keys. If the light targets an info_null entity, the direction towards that entity sets sun direction. The light itself is disabled, so it can be placed anywhere in the map.

The following light properties correspond to these sunlight settings:
light => _sunlight
mangle => _sunlight_mangle
deviance => _sunlight_penumbra
_color => _sunlight_color
_dirt => _sunlight_dirt
_anglescale => _anglescale
*/
void() light = {

	if (!SUB_InitEntity()) return;
	
	// non-switchable light
	if (self.targetname == "") {
		remove(self);
		return;
	}

	// switchable light
	if (self.style > LIGHTSTYLES_MAX) {
		entity e = find(world, targetname, self.targetname);
		while (e){
			if (e.classname == "light" && e != self) {
				// copy settings from one light to the other if possible
				if (self.style2 && !e.style2) {
					dprint5("Warning: light at (", vtos(e.origin), ") inheriting style2 key from light at (", vtos(self.origin), ")\n");
					e.style2 = self.style2;
				}
				else if (self.style2 != e.style2) {
					dprint5("Warning: lights at (", vtos(e.origin), ") and (", vtos(self.origin), ") with differing style2 keys\n");
				}

				if (self.speed && e.speed == 0.1){
					dprint5("Warning: light at (", vtos(e.origin), ") inheriting speed key from light at (", vtos(self.origin), ")\n");
					e.speed = self.speed;
				}

				if (self.spawnflags && !e.spawnflags){
					dprint5("Warning: lights at (", vtos(e.origin), ") and (", vtos(self.origin), ") with differing spawnflags\n");
				}

				remove(self);
				return;
			}
			e = find(e, targetname, self.targetname);
		}

		self.use = light_use;
		self.th_setstate = light_setstate;

		if (self.spawnflags & START_OFF) {
			self.estate = STATE_INACTIVE;
			self.count = 0;
			lightstyle(self.style, "a");
		}
		else {
			self.count = 12;
			lightstyle(self.style, lightstyle_lookup(self.style2));
		}
	}

	if (self.speed <= 0)
		self.speed = 0.1;
	// default speed for fading in/out

};

/*QUAKED light_fluoro (0 1 0) (-8 -8 -8) (8 8 8) START_OFF FADE_IN_OUT X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY

Non-displayed light.
Makes steady fluorescent humming sound.
See the "light" entity for a full description.
*/
void() light_fluoro = {
	if (!SUB_InitEntity()) return;
	
	ambient_light_buzz();
	light();
};

/*QUAKED light_fluorospark (0 1 0) (-8 -8 -8) (8 8 8) START_OFF FADE_IN_OUT X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY

Non-displayed light.
Makes sparking, broken fluorescent sound.
Can't be toggled.
Default style is 10.
See the "light" entity for a full description.
*/
void() light_fluorospark = {
	if (!SUB_InitEntity()) return;
	
	if (!self.style)
		self.style = 10;
	ambient_flouro_buzz();
	remove(self);
};

/*QUAKED light_globe (0 1 0) (-8 -8 -8) (8 8 8) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
Sphere globe light.
Can't be toggled.
See the "light" entity for a full description.
*/
void() light_globe = {
	if (!SUB_InitEntity()) return;
	
	precache_model("progs/s_light.spr");
	setmodel(self, "progs/s_light.spr");
	makestatic(self);
};

/*QUAKED light_torch_small_walltorch (0 .5 0) (-10 -10 -20) (10 10 20) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
{	model ("progs/flame.mdl");	}
Short wall torch
See the "light" entity for a full description.
*/
void() light_torch_small_walltorch = {
	if (!SUB_InitEntity()) return;
	
	precache_model("progs/flame.mdl");
	//precache_body_model("progs/flame.mdl");
	setmodel(self, "progs/flame.mdl");
	//body_model("progs/flame.mdl");
	if !(self.spawnflags && SILENT_TORCH) // for silent torch -- dumptruck_ds
	FireAmbient();
	makestatic(self);
};

/*QUAKED light_flame_large_yellow (0 1 0) (-10 -10 -12) (12 12 18) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
{	model ( { "path" : "progs/flame2.mdl", "frame" : 1 } );	}
Large yellow flame
See the "light" entity for a full description.
*/
void() light_flame_large_yellow = {
	if (!SUB_InitEntity()) return;
	
	precache_model("progs/flame2.mdl");
	setmodel (self, "progs/flame2.mdl");
	self.frame = 1;
	FireAmbient();
	makestatic(self);
};

/*QUAKED light_flame_small_yellow (0 1 0) (-8 -8 -8) (8 8 8) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
{	model ("progs/flame2.mdl");	}
Small yellow flame
See the "light" entity for a full description.
*/
void() light_flame_small_yellow = {
	if (!SUB_InitEntity()) return;
	
	precache_model("progs/flame2.mdl");
	setmodel(self, "progs/flame2.mdl");
	FireAmbient();
	makestatic(self);
};

/*QUAKED light_flame_small_white (0 1 0) (-8 -8 -8) (8 8 8) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
{	model ("progs/flame2.mdl");	}
Left for compatability
Identical to "light_flame_small_yellow"
*/
void() light_flame_small_white = {
	if (!SUB_InitEntity()) return;
	
	light_flame_small_yellow();
};




/********************
misc_shadowcontroller

Controls switchable shadows on any bmodel entity (except doors).
Target entity must have set _switchableshadow set to 1.

speed: Controls the time in seconds it takes to fade the shadow in. Default is 0.5, and setting it to -1 disables fading.
speed2: Same as 'speed' but for the fade out animation. If unset it's the same value as 'speed'.
spawnflag 1: target shadow starts as disabled

*********************/

float SHADOWCONTROLLER_STARTOFF = 1;

void() shadow_fade_out = {
	if (self.count < 0)
		self.count = 0;
	if (self.count > 12)
		self.count = 12;

	//dprint(ftos(self.count));dprint("\n");

	lightstyle(self.switchshadstyle, lightstyle_fade_lookup(self.count));
	self.count = self.count + self.dmg;
	if (self.count > 12)
		return;

	self.think = shadow_fade_out;
	self.nextthink = time + self.delay;
};

void() shadow_fade_in = {
	if (self.count < 0)
		self.count = 0;
	if (self.count > 12)
		self.count = 12;

	//dprint(ftos(self.count));dprint("\n");

	lightstyle(self.switchshadstyle, lightstyle_fade_lookup(self.count));
	self.count = self.count - self.dmg;
	if (self.count < 0)
		return;

	self.think = shadow_fade_in;
	self.nextthink = time + self.delay;

};

void(float speed) misc_shadowcontroller_setsteps = {
	// self.delay -> time between steps
	// self.dmg -> step size

	// yeah that's bad, I know
	if (speed >= 0.24) {
		self.delay = (speed/12);
		self.dmg = 1;
	}
	else if (speed >= 0.12) {
		self.delay = (speed/6);
		self.dmg = 2;
	}
	else if (speed >= 0.06) {
		self.delay = (speed/3);
		self.dmg = 4;
	}
	else if (speed >= 0.04) {
		self.delay = (speed/2);
		self.dmg = 6;
	}
	else {
		self.delay = 0;
		self.dmg = 12;
	}

}

void() misc_shadowcontroller_use = {

	if (self.shadowoff) {
		//dprint("Fade in:\n");

		misc_shadowcontroller_setsteps(self.speed);

		shadow_fade_in();

		self.shadowoff = 0;
	} else {
		//dprint("Fade out:\n");

		misc_shadowcontroller_setsteps(self.speed2);

		shadow_fade_out();

		self.shadowoff = 1;
	}
}

void() misc_shadowcontroller_setup = {
	entity t1;

	// doesn't search for a target if switchshadstyle is already set
	// used for built-in shadow controllers
	if (!self.switchshadstyle) {

		// we need to find only the first target entity with switchable shadows set, since shadow lightstyles are bound by targetname
		
		t1 = find(world, targetname2, self.target);
		
		while (t1 != world && !t1.switchshadstyle) {
			t1 = find(t1, targetname2, self.target);
		}
		
		if (t1 == world) {
			t1 = find(world, targetname, self.target);
			
			while (t1 != world && !t1.switchshadstyle) {
				t1 = find(t1, targetname, self.target);
			}
		}


		if (t1 == world) {
			dprint("\b[misc_shadowcontroller]\b _switchableshadow not set in target ");dprint(self.target);dprint("\n");
			return;
		}

		self.switchshadstyle = t1.switchshadstyle;
	}

	if (!self.speed) self.speed = 0.5;
	if (!self.speed2) self.speed2 = self.speed;

	if (self.spawnflags & SHADOWCONTROLLER_STARTOFF) {
		lightstyle(self.switchshadstyle, "m");

		self.shadowoff = 1;
		self.count = 12;

		misc_shadowcontroller_setsteps(self.speed2);
	}
	else {
		lightstyle(self.switchshadstyle, "a");
		self.shadowoff = 0;
		self.count = 0;
		misc_shadowcontroller_setsteps(self.speed);
	}

	self.use = misc_shadowcontroller_use;
};

void() misc_shadowcontroller = {
	if (!SUB_InitEntity()) return;
	
	self.think = misc_shadowcontroller_setup;
	self.nextthink = time + 0.1;
};

/*
================
target_lightstyle
from Copper
================
*/

string() target_lightstyle_next = {
	entity tls;
	if (self.owner) tls = self.owner;
	else tls = self;
	
	if (tls.state == 0) {
		if (tls.noise == string_null)
			tls.state = 0;
		else
			tls.state += 1;
		return tls.message;
	}
	else if (tls.state == 1) {
		if (tls.noise1 == string_null)
			tls.state = 0;
		else
			tls.state += 1;
		return tls.noise;
	}
	else if (tls.state == 2) {
		if (tls.noise2 == string_null)
			tls.state = 0;
		else
			tls.state += 1;
		return tls.noise1;
	}
	else if (tls.state == 3) {
		if (tls.noise3 == string_null)
			tls.state = 0;
		else
			tls.state += 1;
		return tls.noise2;
	}
	else if (tls.state == 4) {
		if (tls.noise4 == string_null)
			tls.state = 0;
		else
			tls.state += 1;
		return tls.noise3;
	}
	else if (tls.state == 5) {
		tls.state = 0;
		return tls.noise4;
	}
	return tls.message;
}

void() target_lightstyle_go = {
	float st;
	string newstyle = target_lightstyle_next();
	if (self.style)
	{
		st = zeroconvert(self.style);		
		lightstyle(st, newstyle);
		return;
	}
	
	entity l;
	if (self.target != string_null) {
		l = find(world, targetname, self.target);
		while (l.style == 0 && l != world) {
			l = find(l, targetname, self.target);
		}
		
	}
	if (l) lightstyle(l.style, newstyle);
	
	if (self.target2 != string_null) {
		l = find(world, targetname, self.target2);
		while (l.style == 0 && l != world) {
			l = find(l, targetname, self.target2);		
		}
	}
	if (l) lightstyle(l.style, newstyle);

	if (self.target3 != string_null) {
		l = find(world, targetname, self.target3);
		while (l.style == 0 && l != world) {
			l = find(l, targetname, self.target3);		
		}
	}
	if (l) lightstyle(l.style, newstyle);

	if (self.target4 != string_null) {
		l = find(world, targetname, self.target4);
		while (l.style == 0 && l != world) {
			l = find(l, targetname, self.target4);		
		}
	}
	if (l) lightstyle(l.style, newstyle);
}

void() target_lightstyle_use = {
	entity tls;
	if (self.delay) {
		tls = spawn();
		tls.think = target_lightstyle_go;
		tls.nextthink = time + self.delay;
		SUB_CopyTargets(tls);
		tls.style = self.style;
		tls.owner = self;
	}
	else {
		target_lightstyle_go();
	}

	playercount_convert(count);
	if (self.count > 0) {
		self.count -= 1;
		if (self.count == 0)
			remove(self);
	}
}


/*QUAKED target_lightstyle (.5 .8 .5) (-8 -8 -8) (8 8 8)
This entity changes a global lightstyle when triggered. Set "style" to the lightstyle you want to override, and set "message" to the brightness pattern you want to set it to. If style is not set, and this entity targets any triggerable lights, it sets the brightness pattern of those lights when triggered instead. Note that targeting anything at a light makes it a triggerable light with its own style automatically.

Setting style to -1 will override lightstyle 0, which is all static lights in the entire level.

"count" limit number of uses, 0 = infinite
"delay" pause between trigger and activation
*/
/*FGD
@PointClass base(Appearflags, Targetname, Target) color(128 210 128) = target_lightstyle : 
"Target : Lightstyle
Changes a global lightstyle when triggered."
[
	message(string) : "Brightness pattern"
	style(integer) : "Lightstyle to change (0-63)" : 0
	count(integer) : "Limit uses" : 0
	delay(string) : "Delay before activation" : "0"
]
*/
void() target_lightstyle = {
	if (!SUB_InitEntity()) return;
	
	if (self.message == string_null)
		self.message = "azam";	// suitably garish accidental default
	self.use = target_lightstyle_use;
}
