

float BOB_COLLISION = 2;		// Collision for misc_bob
float BOB_NONSOLID = 4;			// Non solid for func_bob

/*QUAKED func_bob (0 .5 .8) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
A SOLID bmodel that gently moves back and forth
-------- KEYS --------
targetname : trigger entity (works with entity state system)
angle    : direction movement, use "360" for angle 0
height   : direction intensity (def=8)
count    : direction cycle timer (def=2s, minimum=1s)
waitmin  : Speed up scale (def=1) 1+=non linear
waitmin2 : Slow down scale (def=0.75)
delay    : Starting time delay (def=0, -1=random)
style    : If set to 1, starts off and waits for trigger
_dirt       : -1 = will be excluded from dirtmapping
_minlight   : Minimum light level for any surface of the brush model
_mincolor   : Minimum light color for any surface (def='1 1 1' RGB)
_shadow     : Will cast shadows on other models and itself
_shadowself : Will cast shadows on itself
-------- SPAWNFLAGS --------
STARTOFF : Starts off and waits for trigger - DISABLED, Ripped out ESTATE System (RennyC)
-------- NOTES --------
A SOLID bmodel that gently moves back and forth
*/

//----------------------------------------------------------------------
void() func_bob_timer =
{
	// Keep ticking in background, use local timer (faster)
	float localtime = getLocalTime();
	self.think = func_bob_timer;


	self.nextthink = localtime + 0.1;

	// Has the cycle completed?
	if (self.attack_timer < localtime)
	{
		// Setup bob cycle and half way point for slowdown
		self.attack_timer = localtime + self.count;
		self.distance = localtime + (self.count * 0.5);
		// Flip direction of bmodel bob
		self.lefty = 1 - self.lefty;
		if (self.lefty < 1)
			self.t_length = self.height;
		else
			self.t_length = -self.height;

		// Always reset velocity and flags
		self.velocity = '0 0 0';
		self.flags = 0;
	}

	// Is the direction set?
	// This is a block condition to prevent the bmodel moving
	if (self.lefty != -1)
	{
		// Slow down velocity (gradually)
		if (self.distance < localtime)
			self.velocity = self.velocity * self.waitmin2;
		else
		{
			// Speed up velocity (linear/exponentially)
			self.t_length = self.t_length * self.waitmin;
			self.velocity = self.velocity + (self.movedir * self.t_length);
		}
	}
};

//----------------------------------------------------------------------
void() func_bob_on =
{
	// This may have been called as a "use" function, so don't allow it
	// to be called repeatedly -- iw
	self.use = SUB_Null;

	if (self.bsporigin)
	{
		self.movetype = MOVETYPE_PUSH;
		self.solid = SOLID_BSP;
	}
	else
	{
		self.movetype = MOVETYPE_FLY;
		self.solid = SOLID_BBOX;
		self.flags = 0;	// Reset any onground flags
	}

	if (self.spawnflags & BOB_NONSOLID)
		self.solid = SOLID_NOT;

	setmodel (self, self.mdl);
	setsize (self, self.mins , self.maxs);

	self.think = func_bob_timer;
	self.nextthink = getLocalTime() + 0.3 + self.delay;
};

//----------------------------------------------------------------------
void() func_bob_off =
{
	if (self.bsporigin)
	{
		self.movetype = MOVETYPE_PUSH;
		self.solid = SOLID_BSP;
	}
	else
	{
		self.movetype = MOVETYPE_FLY;
		self.solid = SOLID_BBOX;
	}

	if (self.spawnflags & BOB_NONSOLID)
		self.solid = SOLID_NOT;

	setmodel (self, self.mdl);
	setsize (self, self.mins , self.maxs);
	self.velocity = '0 0 0';

	if (self.style & 1)
		self.use = func_bob_on;
};

//----------------------------------------------------------------------
void() func_bob_orig =
{
	if (!SUB_InitEntity()) return;
	
	self.spawnflags = self.spawnflags | BOB_COLLISION;
	if (self.spawnflags & BOB_NONSOLID)
		self.spawnflags = self.spawnflags - (self.spawnflags & BOB_COLLISION);

	// Using a custom model?
	if (self.mdl == "")
	{
		self.bsporigin = TRUE;
		self.mdl = self.model;
	}
	else
	{
		self.bsporigin = FALSE;
		self.modelindex = 0;
		self.model = "";
	}

	SetMovedir ();
	self.movedir = normalize(self.movedir);

	if (self.height <= 0)
		self.height = 8;			// Direction intensity
	if (self.count < 1)
		self.count = 2;				// Direction switch timer
	if (self.waitmin <= 0)
		self.waitmin = 1;			// Speed up
	if (self.waitmin2 <= 0)
		self.waitmin2 = 0.75;		// Slow down
	if (self.delay < 0)
		self.delay = random() + random() + random();

	// Setup Entity State functionality - Nope! (RennyC)
	// if (self.targetname != "")
	// 	self.use = func_bob_on;

	if (!self.style)  //added style key 1 for start off -- dumptruck_ds
		func_bob_on();
	else
		func_bob_off();
};

//----------------------------------------------------------------------

/*QUAKED misc_bob (0 0.5 0.8) (-8 -8 -8) (8 8 8) X BOB_COLLISION BOB_NONSOLID X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
{
	model ({"path" : mdl, "skin" : skin, "frame": frame});
}
Same as func_bob but uses a custom model instead of a brush. Use the mdl key to set the path of the model.
*/
void() misc_bob = {func_bob();};

void() func_bob = {
	if (!SUB_InitEntity()) return;

	if (self.height <= 0)
		self.height = 8;			// Direction intensity
	if (self.count < 1)
		self.count = 2;				// Direction switch timer
	if (self.delay < 0)
		self.delay = random();

	self.wait = self.count * 2;
	self.distance = 32 * pow(2, self.count-1) * (self.height / 8);
	if (self.style) self.spawnflags |= 1;
	if (self.spawnflags & 4) {
		self.solid = -1;
		self.spawnflags &~= 4;
	}

	
	func_bobbing();
}



/*
	FUNC_BOBBING

a lot has been done here to never ever rely on values that are repeatedly summed
over time, as floating point error will cause gradual drift.

usually, movers use self.ltime so that time doesn't advance for them while they're
blocked, preventing SUB_CalcMove from being shifted off the end of its motion and
screwing up doors. we don't do that here, because accumulated time error in .ltime  
will cause bobbings to slowly slide out of phase with each other and not keep good 
time. if the mapper sets an oscillation period of 5.0 seconds, the mover damn sure
better oscillate once every exactly 5 seconds, not '5-ish'.

engine structure requires that mover thinks be scheduled using .ltime because that's
what it compares a MOVETYPE_PUSH's nextthink against, but we can use global time for
actual positioning/velocity. it requires some particular gymnastics in the .blocked()
function, but the result is precise and seamless.

.wait: wavelength in seconds
.delay: current phase offset (0-1)
.search_time: origin point in time of the cosine wave. whenever we save it, we shift
	it backwards by the current .delay * .wait
.length: think rate, usually 0.1 but can be lower on hyperactive bobbers
*/

const float SFLAG_BOB_CRUSHER = 2;
const float SFLAG_BOB_NONSOLID = 4;
const float SFLAG_BOB_STOPLOW = 8;
const float SFLAG_BOB_STOPMID = 16;
const float SFLAG_BOB_STOPHI = 32;
const float SFLAG_BOB_STOP = 8+16+32;


void() func_bobbing_blocked = 
{
	T_Damage(other, self, self, self.dmg, DMGTYPE_CRUSH);
	
	if (self.spawnflags & SFLAG_BOB_CRUSHER)	// don't reverse
		return;
	
	// reversing direction entails reversing the phase
	self.delay = (self.delay * -1) + 1 + (self.length / self.wait);
	// put it one think in the future too
	
	// set new starting conditions to reanchor the reverse movement at
	// the moment of contact
	self.search_time = time - self.delay * self.wait - self.length;
	// subtracting .length puts the reversed wave one more think in the past.
	// if we don't we'll get a frame of 0 movement
	
	// start new movement now or we'll be a CRUSHER anyway
	func_bobbing_think();
}

void() func_bobbing_use = 
{
	self.think = func_bobbing_think;
	
	if (self.state == 2)	// a future stop was requested but we never reached it
		self.state = 1;		// go back to being plain old 'on'
	else
		self.state = !self.state;
	
	if (self.state)	// start immediately
	{
		self.search_time = time - self.delay * self.wait;
		//sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);	// move
		self.think();
		return;
	}
	
	if (self.spawnflags & SFLAG_BOB_STOP)	// stop at an apex, not immediately
	{
		self.state = 2;
		return;
	}
	
	// stop immediately
	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);	// cut off move sound with stop sound
	self.nextthink = 0;
}

vector(float phase) func_bobbing_pos =
{
	vector pos;
	float cosD;
	
	cosD = (1 - cos(360 * phase)) / 2;	// flip -1/1 and scale to 0-1
	pos = self.pos1 + (cosD * (self.pos2 - self.pos1));
	return pos;
}

void() func_bobbing_think =
{
	if (!self.state)
	{
		self.velocity = VEC_ORIGIN;
		return;
	}

	vector dst;
	float phase;
	float atLow, atHigh, stop;
	
	// always derive current phase from a fixed starting time rather than
	// summing an offset every think, or we'll accumulate error and drift
	phase = ((time - self.search_time) / self.wait) % 1;
	if (phase < self.delay)
		phase += 1;	// don't wrap yet
	
	atLow = (self.delay < 0.5 && phase >= 0.5);
	atHigh = (self.delay < 1 && phase >= 1);
	
	if (self.state == 2) // stop at our earliest convenience
	{
		if (atLow && (self.spawnflags & SFLAG_BOB_STOPLOW))
		{
			phase = 0.5;
			stop = TRUE;
		}
		else if (atHigh && (self.spawnflags & SFLAG_BOB_STOPHI))
		{
			phase = 0;
			stop = TRUE;
		}
		else if (self.spawnflags & SFLAG_BOB_STOPMID)
		{
			if (self.delay < 0.25 && phase >= 0.25)
			{
				phase = 0.25;
				stop = TRUE;
			}
			else if (self.delay < 0.75 && phase >= 0.75)
			{
				phase = 0.75;
				stop = TRUE;
			}		
		}
	}	
	else if ( atLow || atHigh )
	{
		// when we pass either apex, repeat the noises
		//sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);	// move
		//sound (self, CHAN_BODY, self.noise, 1, ATTN_NORM);	// stop
	}
	
	if (stop)
	{
		self.state = 0;
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);	// cut off move sound with stop sound
	}
	
	self.delay = phase;
	if (self.delay > 1)	// now we can wrap
		self.delay -= 1;
	
	// whither are we going
	dst = func_bobbing_pos(phase);
	
	self.velocity = (dst - self.origin) / self.length;
	self.nextthink = self.ltime + self.length;
}

/*QUAKED func_bobbing (0 .5 .8) ? START_OFF CRUSHER STOP_LOW STOP_MID STOP_HIGH - - START_INVIS
Bobbing platform. Moves in a smooth sine wave. Build at the center of motion, specify 'wait' for the wavelength in seconds and 'distance' for the amplitude (distance from end to end) in units.
Trigger to freeze/reactivate.

"angle" set bob axis
"distance" total distance of bob, will move half this far in either direction
"pos1"/"pos2" ignore angle/distance and set apex offsets directly
"wait" wavelength of bob in seconds
"delay" phase offset to start at (0 = pos1, 0.5 = pos2, 1.0 = back at pos1 again)
"sounds"
0) none, or, set your own with 'noise' (stop sound) and 'noise1' (move sound)
1) ratchet metal
2) base plat

Spawnflags
START_OFF	start off
CRUSHER		don't reverse when blocked
STOP_*		when triggered off, keep oscillating until reaching the low/high/midpoint and stop there. checking more than one adds eligible stopping places, and the bobber will stop at the first one reached.
*/
/*FGD
@baseclass base(Appearflags, Targetname, TrainSounds, Angle, Func, FuncInvis) = Bob
[
	spawnflags(flags) = [
		1 : "Start off" : 0
		2 : "Crusher (no reverse)" : 0
		4 : "Don't stop until low pos" : 0
		8 : "Don't stop until mid pos" : 0
		16 : "Don't stop until high pos" : 0
	]
	wait(string) : "Period (Wavelength)" : "4"
	distance(integer) : "Length (Amplitude)" : 64
	delay(string) : "Starting offset (0-1) (Phase)" : "0.0"
	dmg(integer) : "Damage when blocked" : 2
	noise(string) : "Override stop sound"
	noise1(string) : "Override move sound"
	pos1(string) : "Override peak position (relative)"
	pos2(string) : "Override trough position (relative)"
]
@SolidClass base(Bob) = func_bobbing : "Bobbing platform.
Moves in a smooth sine wave. Build at the center of motion, specify 'wait' for the wavelength in seconds and 'distance' for the amplitude (distance from end to end) in units. Use 'delay' to set a phase offset (0-1).
Trigger to freeze in place or reactivate. If any 'don't stop until' spawnflags are checked, the bobber will keep oscillating until it reaches one of the designated positions and stop there.

Set both 'pos1' & 'pos2' to override the two apex positions (ends of the bob) to build and light your plat wherever."  []
*/
void() func_bobbing =
{
	if (!SUB_InitEntity()) return;
	
	if (self.mdl != "")
		precache_model(self.mdl);
	//train_sounds();

	SetMovedir();
	if (!self.distance)
		self.distance = 64;
	if (self.wait <= 0)
		self.wait = 4;
	
	self.dmg = zeroconvertdefault(self.dmg, 2);
	
	if (!self.pos1 && !self.pos2)
	{
		//self.pos1 = self.origin + self.distance * 0.5 * self.movedir;
		//self.pos2 = self.origin - self.distance * 0.5 * self.movedir;
		self.pos1 = self.origin;
		self.pos2 = self.origin - self.distance * self.movedir;
	}
	self.length = min(0.1, self.wait / 6);

	if (self.spawnflags & 128)
		self.use = func_bobbing_spawn;
	else
		func_bobbing_spawn();
}

void() func_bobbing_spawn =
{
	if (!(self.spawnflags & START_OFF))
	{
		self.think = func_bobbing_use;
		self.nextthink = 0.3;	// wait for items and monsters to rest on it
	}
	
	self.use = func_bobbing_use;
	self.blocked = func_bobbing_blocked;
	
	if (!(self.spawnflags & SFLAG_BOB_NONSOLID) && self.mdl == "")
		self.solid = SOLID_BSP;

	if (!self.solid)
		self.movetype = MOVETYPE_NOCLIP;
	else
		self.movetype = MOVETYPE_PUSH;

	if (self.mdl != "")
		setmodel (self, self.mdl);
	else
		setmodel (self, self.model);

	setsize (self, self.mins, self.maxs);
	setorigin (self, func_bobbing_pos(self.delay));
}

void() misc_bobbing = {func_bobbing();}