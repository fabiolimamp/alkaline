/*
====================

Fog controller originally from Copper
Updated by bmFbr

====================
*/

float FOG_INTERVAL = 0.04166667; //1/24;
//float FOG_INTERVAL = 0.1; //1/24;
/*FGD
@baseclass = Fog [ 
	fog_density(string) : "Fog Density" 
	fog_color(string) : "Fog Color" 
]
@baseclass = FogShift [ 
	fog_density(string) : "Start Fog Density" 
	fog_color(string) : "Start Fog Color" 
	fog_density2(string) : "End Fog Density" 
	fog_color2(string) : "End Fog Color" 
]
*/

/*
================
fog_save
================
*/
void( entity client, float density, vector color ) fog_save =
{
	if (client.classname != "player") return;
	
	// save whatever we set the client's fog to in case of saves/loads
	client.fog_density = density;
	client.fog_color = color;
}

void( entity client, float density, vector color ) fog_save2 =
{
	if (client.classname != "player") return;
	
	client.fog_density2 = density;
	client.fog_color2 = color;
}

void( entity client ) fog_save_to_previous =
{
	if (client.classname != "player") return;
	
	// copies the current fog to the secondary fields to transition from the current fog
	client.fog_density2 = client.fog_density;
	client.fog_color2 = client.fog_color;
}

void( entity client, float density) skyfog_save =
{
	if (client.classname != "player") return;
	
	client.skyfog_density = density;
}

/*
================
fog_setFromEnt
================
*/
void( entity client, entity fogger ) fog_setFromEnt =
{
	dprint("setting fog values\n");
	// don't set the fog if the entity has no values, because it might be a custom map with
	// _fog on the worldspawn instead
	// to actually get an entity to clear the fog, set a color but leave density at 0
	if (!fogger.fog_color)
		if (!fogger.fog_density)
			return;
	
	fog_set(client, fogger.fog_density, fogger.fog_color);
	fog_save(client, fogger.fog_density, fogger.fog_color);
}

/*
================
fog_set
================
*/
void( entity client, float density, vector color) fog_set =
{
	if (client.classname != "player") return;

	//stuffcmd(client, "r_showtris 0\n"); return;
	//dprint("Setting fog: ");dprint(ftos(density));dprint(" ");dprint(ftos(color_x));dprint(" ");dprint(ftos(color_y));dprint(" ");dprint(ftos(color_z));dprint("\n");

	stuffcmd(client, "\nfog ");
	stuffcmd_float(client, density);
	stuffcmd(client, " ");
	stuffcmd_float(client, color_x);
	stuffcmd(client, " ");
	stuffcmd_float(client, color_y);
	stuffcmd(client, " ");
	stuffcmd_float(client, color_z);
	stuffcmd(client, "\n");


	fog_save(client, density, color);
}


void( entity client, float density) skyfog_set =
{
	if (client.classname != "player") return;

	//stuffcmd(client, "r_showtris 0\n"); return;
	//dprint("Setting fog: ");dprint(ftos(density));dprint(" ");dprint(ftos(color_x));dprint(" ");dprint(ftos(color_y));dprint(" ");dprint(ftos(color_z));dprint("\n");

	stuffcmd(client, "\nr_skyfog ");
	stuffcmd_float(client, density);
	stuffcmd(client, "\n");

	skyfog_save(client, density);
}

/*
================
fog_blendTouch
================
*/
void() fog_blendTouch =
{
	if (!CheckValidTouch()) return;
	
	if (self.estate != STATE_ACTIVE)
		return;

	// fix for only first client getting a fog change when multiple coop clients are touching this at once
	if (time != self.rad_time)	// because fog is rad
		if (time < self.attack_finished)
			return;
		
	float f, ldensity, leaving;
	vector dorg, mid, ovel;
	vector lcolor;
	
	// if you run/fall through a fogblend fast enough you can come out the other side 
	// partially blended, so check if player will exit the trigger bounds before the 
	// next touch (same class of bug as leaping through lasers in Q2)
	ovel = other.velocity * FOG_INTERVAL;
	leaving = ( (other.absmax_x + ovel_x < self.absmin_x) ||
				(other.absmax_y + ovel_y < self.absmin_y) ||
				(other.absmax_z + ovel_z < self.absmin_z) ||
				(other.absmin_x + ovel_x > self.absmax_x) ||
				(other.absmin_y + ovel_y > self.absmax_y) ||
				(other.absmin_z + ovel_z > self.absmax_z) );
	
	if (leaving)
	{
		// last chance to set fog correctly, so snap it to the final values
		leaving = other.velocity * self.movedir;
		if (leaving > 0)
		{
			ldensity = self.fog_density2;
			lcolor = self.fog_color2;
		}
		else
		{
			ldensity = self.fog_density;
			lcolor = self.fog_color;
		}
	}
	else
	{
		// in transition, blend proportionally between the two fogs
		mid = (self.mins + self.maxs) * 0.5;
		dorg = other.origin + other.view_ofs - mid;
		
		f = dorg * self.movedir;
		f = (f / self.distance) + 0.5;
		
		ldensity = lerp(self.fog_density, self.fog_density2, f);
		lcolor = lerpVector(self.fog_color, self.fog_color2, f);
	}
	fog_set(other, ldensity, lcolor);
	//fog_save(other, ldensity, lcolor);
	
	self.rad_time = time;
	self.attack_finished = time + FOG_INTERVAL;
	
//	bprint(ftos(f*1000));
//	bprint("\n");
}


/*QUAKED trigger_fogblend (.5 .5 .2) ?
Acts as a smoothly blending portal between two zones of different fog. Sets the fog for any client passing through it, blending their global fog settings between "fog_color"/"fog_density" and "fog_color2"/"fog_density2" proportional to their position within the trigger.
The axis of motion on which the blend happens is defined by "angle", pointing to whatever zone has color2 and density2.  Trigger therefore has two 'sides' - the side that "angle" points to, and the opposite side.  

"distance" - override the length of the blend period in world units - defaults to bounds size 
	on 'angle' otherwise. this is only useful for diagonal triggers.

CAVEATS:
- will 'stuffcmd' 2 dozen times per frame so try not to make these huge
- a bug in most quake engine ports will reset the eye position smoothing that happens when climbing stairs or riding a plat on every frame that a 'stuffcmd' is sent, so fog transitions during upwards motion will cause noticeable stuttering.
*/
/*FGD
@SolidClass base(Appearflags, Targetname, Target, FogShift) = trigger_fogblend : 
"Trigger: Fog Blend
Acts as a smoothly blending portal between two zones of different fog. Sets the fog for any client passing through it, blending their global fog settings between start and end values proportional to their position within the trigger.

- will 'stuffcmd' 2 dozen times per frame so try not to make these huge
- a bug in most quake engine ports will reset the eye position smoothing that happens when climbing stairs or riding a plat on every frame that a 'stuffcmd' is sent, so fog transitions during upwards motion will cause noticeable stuttering." 
[
	distance(integer) : "Length of blend distance (defaults to size of trigger)"
	angle(integer) : "Axis of motion of blend (points toward end values)"
]
*/
void() trigger_fogblend =
{
	//if (!SUB_ShouldSpawn()) return;
	if (self.angles == '0 0 0')		// InitTrigger assumes angle 0 means no angle
		self.angles = '0 360 0';

	InitTrigger ();
	self.touch = fog_blendTouch;
	self.distance = zeroconvertdefault(self.distance, BoundsAngleSize(self.movedir, self.size));
}



// ================================

float FOGBLEND_ONEWAY = 1;
float FOGBLEND_REVERSE = 2;
float FOGBLEND_ALLCLIENTS = 4;
float FOGBLEND_BLENDTO = 8;


/*
================
target_fogblend_use
================
*/
void() target_fogblend_use = {
	float dTo, dFrom;
	vector cTo, cFrom;
	self.enemy = activator;
	if (self.enemy.classname != "player") return;

	if (!(self.spawnflags & FOGBLEND_ONEWAY))
		self.state = 1 - self.state;
	
	if (self.state)
		self.pain_finished = time + self.delay + self.speed;
	else
		self.pain_finished = time + self.delay + self.speed2;


	if (self.spawnflags & FOGBLEND_ALLCLIENTS) {
		entity pl;
		pl = nextent(world);
		while (pl.flags & FL_CLIENT) {
			fog_save_to_previous(pl);

			pl.fogblend_entity = self;

			pl = nextent(pl);
		}
	}
	else {
		fog_save_to_previous(self.enemy);

		self.enemy.fogblend_entity = self;
	}

	self.nextthink = time + self.delay;
};

void(entity cl, vector cTo, float dTo, float f) fog_blendSetFraction = {
	float d;
	//float s;
	vector c;

	d = lerpHermite(cl.fog_density2, dTo, f);
	//s = lerpHermite(cl.skyfog_density2, cl.skyfog_density, f);
	c = lerpVectorHermite(cl.fog_color2, cTo, f);

	eprint(cl);
	dprint("density: ");dprint(ftos(d));dprint("\n");
	dprint("color: ");dprint(vtos(c));dprint("\n");
	dprint("fraction: ");dprint(ftos(f));dprint("\n");

	fog_set(cl, d, c);
};

/*
================
fog_blendTimeThink
================
*/

vector(entity fblend) fog_blendGetColorByState = {
	if (fblend.state)
		return fblend.fog_color2;
	else
		return fblend.fog_color;
};

float(entity fblend) fog_blendGetDensityByState = {
	if (fblend.state)
		return fblend.fog_density2;
	else
		return fblend.fog_density;
};

void() fog_blendTimeThink = {
	float f;
	float dTo;
	vector cTo;
	
	if (time >= self.pain_finished)	{
		f = 1;
	}
	else {
		self.nextthink = time + FOG_INTERVAL;
		if (self.state && self.speed)
			f = 1 - (self.pain_finished - time) / self.speed;
		else if (self.speed2)
			f = 1 - (self.pain_finished - time) / self.speed2;
		else
			f = 1;
	}

	dTo = fog_blendGetDensityByState(self);
	cTo = fog_blendGetColorByState(self);

	if (self.spawnflags & FOGBLEND_ALLCLIENTS) {
		entity pl;
		pl = nextent(world);
		while (pl.flags & FL_CLIENT) {
			if (pl.fogblend_entity == self) {
				if (!(pl.fog_density2 == dTo && pl.fog_color2 == cTo))
					fog_blendSetFraction(pl, cTo, dTo, f);

				if (time >= self.pain_finished) 
					pl.fogblend_entity = world;
			}

			pl = nextent(pl);
		}
	}
	else {
		if (self.enemy.fogblend_entity == self) {
			if (!(self.enemy.fog_density2 == dTo && self.enemy.fog_color2 == cTo))
				fog_blendSetFraction(self.enemy, cTo, dTo, f);

			if (time >= self.pain_finished) 
				self.enemy.fogblend_entity = 0;
		}
		
	}

};

/*QUAKED target_fogblend (.5 .5 .2) (-8 -8 -8) (8 8 8) ONE_WAY REVERSE GLOBAL BLENDTO
Blends the fog for a client.  activator's fog will be blended from "fog_color" and "fog_density"
to "fog_color2" and "fog_density2".  Triggering again will blend it back, unless ONE_WAY is set.
Set REVERSE if you're tired of swapping the values by hand.
Set GLOBAL to affect all clients in multiplayer, not just the activator.

"delay" - pause before beginning to blend
"speed" - time to spend blending, -1 for an instant change to fog2.
"speed2" - time to spend blending back, if different than "speed". -1 for instant.

CAVEATS:
- will 'stuffcmd' 2 dozen times per frame so try not to make this take too long
- a bug in most quake engine ports will reset the eye position smoothing that happens when climbing stairs or riding a plat on every frame that a 'stuffcmd' is sent, so fog transitions during upwards motion will cause noticeable stuttering.
*/
/*FGD
@PointClass base(Appearflags, Targetname, Target, FogShift) color(128 128 50) = target_fogblend : 
"Target: Fog Blend
Activator's fog will be blended over time from start to end values.

- will 'stuffcmd' 2 dozen times per frame so try not to make this take too long
- a bug in most quake engine ports will reset the eye position smoothing that happens when climbing stairs or riding a plat on every frame that a 'stuffcmd' is sent, so fog transitions during upwards motion will cause noticeable stuttering." 
[
	spawnflags(flags) = [
		1 : "One-Way Only" : 0
		2 : "Reverse Start/End" : 0
		4 : "All clients" : 0
	]
	delay(string) : "Pause before starting blend"
	speed(string) : "Time to blend (-1 for instant)"
	speed2(string) : "Time to blend back, if different (-1 for instant)"
]
*/
void() target_fogblend =
{
	//if (!SUB_ShouldSpawn()) return;
	self.use = target_fogblend_use;
	self.think = fog_blendTimeThink;

	if (self.spawnflags & FOGBLEND_REVERSE)
		self.state = 1;
	else
		self.state = 0;

	if (self.spawnflags & FOGBLEND_ONEWAY)
		self.state = 1 - self.state;
	
	if (!self.speed) self.speed = 1;
	if (!self.speed2) self.speed2 = self.speed;
	
	if (self.speed == -1) self.speed = 0;
	if (self.speed2 == -1) self.speed2 = 0;
}
