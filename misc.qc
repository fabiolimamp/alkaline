

/*QUAKED misc_fireball (0 .5 .8) (-8 -8 -8) (8 8 8)
Lava Balls
*/

void() fire_fly;
void() fire_touch;
void() misc_fireball =
{
	
	precache_model ("progs/lavaball.mdl");
	self.classname = "fireball";
	self.nextthink = time + (random() * 5);
	self.think = fire_fly;
	if (!self.speed)
		self.speed = 1000;
};

void() fire_fly =
{
	local entity	fireball;

	fireball = spawn();
	fireball.solid = SOLID_TRIGGER;
	fireball.movetype = MOVETYPE_TOSS;
	fireball.velocity = '0 0 1000';
	fireball.velocity_x = (random() * 100) - 50;
	fireball.velocity_y = (random() * 100) - 50;
	fireball.velocity_z = self.speed + (random() * 200);
	fireball.classname = "fireball";
	setmodel (fireball, "progs/lavaball.mdl");
	setsize (fireball, '0 0 0', '0 0 0');
	setorigin (fireball, self.origin);
	fireball.nextthink = time + 5;
	fireball.think = SUB_Remove;
	fireball.touch = fire_touch;
	
	self.nextthink = time + (random() * 5) + 3;
	self.think = fire_fly;
};


void() fire_touch =
{
	if (other.health) T_Damage (other, self, self, 20);
	remove(self);
};

//============================================================================


void() barrel_explode =
{
	self.takedamage = DAMAGE_NO;
	self.classname = "explo_box";
	// did say self.owner
	T_RadiusDamage (self, self, 160, world);
	sound (self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);
	particle (self.origin, '0 0 0', 75, 255);

	self.origin_z = self.origin_z + 32;
	BecomeExplosion ();
};



/*QUAKED misc_explobox (0 .5 .8) (0 0 0) (32 32 64)
TESTING THING
*/

void() misc_explobox =
{
	local float	oldz;
	
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	precache_model ("maps/b_explob.bsp");
	setmodel (self, "maps/b_explob.bsp");
	precache_sound ("weapons/r_exp3.wav");
	self.health = 20;
	self.th_die = barrel_explode;
	self.takedamage = DAMAGE_AIM;

	self.origin_z = self.origin_z + 2;
	oldz = self.origin_z;
	droptofloor();
	if (oldz - self.origin_z > 250)
	{
		dprint ("item fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
	}
};




/*QUAKED misc_explobox2 (0 .5 .8) (0 0 0) (32 32 64)
Smaller exploding box, REGISTERED ONLY
*/

void() misc_explobox2 =
{
	local float	oldz;
	
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	precache_model2 ("maps/b_exbox2.bsp");
	setmodel (self, "maps/b_exbox2.bsp");
	precache_sound ("weapons/r_exp3.wav");
	self.health = 20;
	self.th_die = barrel_explode;
	self.takedamage = DAMAGE_AIM;

	self.origin_z = self.origin_z + 2;
	oldz = self.origin_z;
	droptofloor();
	if (oldz - self.origin_z > 250)
	{
		dprint ("item fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
	}
};

//============================================================================

float SPAWNFLAG_SUPERSPIKE	= 1;
float SPAWNFLAG_LASER = 2;

void(vector org, vector vec) LaunchLaser;

void() spikeshooter_use =
{
	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		sound (self, CHAN_VOICE, "enforcer/enfire.wav", 1, ATTN_NORM);
		LaunchLaser (self.origin, self.movedir);
	}
	else
	{
		sound (self, CHAN_VOICE, "weapons/spike2.wav", 1, ATTN_NORM);
		launch_spike (self.origin, self.movedir);
		newmis.velocity = self.movedir * 500;
		if (self.spawnflags & SPAWNFLAG_SUPERSPIKE)
			newmis.touch = superspike_touch;
	}
};

void() shooter_think =
{
	spikeshooter_use ();
	self.nextthink = time + self.wait;
	newmis.velocity = self.movedir * 500;
};


/*QUAKED trap_spikeshooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
When triggered, fires a spike in the direction set in QuakeEd.
Laser is only for REGISTERED.
*/

void() trap_spikeshooter =
{
	SetMovedir ();
	self.use = spikeshooter_use;
	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		precache_model2 ("progs/laser.mdl");
		
		precache_sound2 ("enforcer/enfire.wav");
		precache_sound2 ("enforcer/enfstop.wav");
	}
	else
		precache_sound ("weapons/spike2.wav");
};


/*QUAKED trap_shooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
Continuously fires spikes.
"wait" time between spike (1.0 default)
"nextthink" delay before firing first spike, so multiple shooters can be stagered.
*/
void() trap_shooter =
{
	trap_spikeshooter ();
	
	if (self.wait == 0)
		self.wait = 1;
	self.nextthink = self.nextthink + self.wait + self.ltime;
	self.think = shooter_think;
};



/*
===============================================================================


===============================================================================
*/


/*
air_bubbles moved to fx.qc
*/

/*~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>
~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~*/

/*QUAKED viewthing (0 .5 .8) (-16 -16 -24) (16 16 40)

Just for the debugging level.  Don't use
*/

void() viewthing =

{
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_BBOX;
	setsize (self, '-16 -16 -24', '16 16 40');
	precache_model ("progs/dread.mdl");
	setmodel (self, "progs/dread.mdl");
};


//============================================================================

void() target_autosave_use =
{
	if (self.enemy)
	{
		activator = self.enemy;
		self.enemy = world;
	}
	if (activator.classname != "player") return;
	if (time < 2)	// make sure an autosave fired from a player start doesn't happen too early
	{
		//if (serverflags & SVFL_RESPAWNING)
		//{
		//	dprint("RESPAWNING flag set, skipping autosave\n");
		//	return;
		//}
		self.enemy = activator;
		self.think = target_autosave_use;
		self.nextthink = 2;
		return;
	}
	sound(activator, CHAN_VOICE, "misc/sav.wav", 1.0, ATTN_NORM);
	autosave(activator, self.message);
}

/*QUAKED target_autosave (1 .0 .5) (-8 -8 -8) (8 8 8)
Saves the game when triggered by a player. Never appears in multiplayer. the bprint tends to stomp any other prints on screen in most quake clients, so use a delayed trigger_relay if you fire this from an important pickup/trigger_counter/something else that puts text on screen more important than the autosave blurb.

Keys:
"message" change save file name, defaults to 'auto'
*/
/*FGD
@Pointclass base(Target, Targetname, Appearflags) color(255 0 128) size(32 32 32) = target_autosave : 
"Saves the game when triggered by a player. Never appears in multiplayer. 
the bprint tends to stomp any other prints on screen in most quake clients, so use a delayed trigger_relay if you fire this from an important pickup/trigger_counter/something else that puts text on screen more important than the autosave blurb." 
[
	message(string) : "Change save filename" : "auto"
]
*/
void() target_autosave =
{
	if (deathmatch || coop)
	{
		remove(self);
		return;
	}
	

	if (self.message == string_null)
		self.message = "auto";
	precache_sound2("misc/sav.wav");
	self.use = target_autosave_use;
}


/***********************************************

target_infight

***********************************************/


float INFIGHT_MUTUAL = 1;

void(entity t1, entity t2) make_angry_at =
{
	if (t2.health > 0 && t1.health > 0) { // checks if targets are alive
		if (t1.enemy.classname == "player")
			t1.oldenemy = t1.enemy;
		t1.enemy = t2;

		entity oself = self;
		self = t1; // FoundTarget() only acts on self
		FoundTarget();
		self = oself;
	}
};

void() target_infight_use = 
{
	local entity	t1, t2;

	t1 = find(world, targetname, self.target);
	t2 = find(world, targetname, self.target2);
	
	if (!t1)
	{
		dprint("[target_infight] Cannot find target\n");
		return;
	}
	if (!t2)
	{
		dprint("[target_infight] Cannot find target2\n");
		return;
	}
	
	make_angry_at(t1, t2);
	
	if (self.spawnflags & INFIGHT_MUTUAL)
		make_angry_at(t2, t1);
};

/*QUAKED target_infight (1 .0 .5) (-8 -8 -8) (8 8 8) MUTUAL
Makes 'target' monster angry at 'target2'.

By default, the infighting doesn't start mutually, that is, 'target2' monster will only get mad back at 'target' after it's been attacked.

If you want to make them angry at each other instantly, you can set the spawnflag 'Mutual hate'.
*/
void() target_infight = 
{
	self.use = target_infight_use;
};




/*
==============================================================================

SIMPLE BMODELS

==============================================================================
*/

void() func_wall_use =
{	// change to alternate textures
	self.frame = 1 - self.frame;
};

/*QUAKED func_wall (0 .5 .8) ?
This is just a solid wall if not inhibitted
*/
void() func_wall =
{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};


/*QUAKED func_togglewall (0 .5 .8) ? START_OFF X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY

Creates a invisible wall that can be toggled on and off.

START_OFF wall doesn't block until triggered.

"noise" is the sound to play when wall is turned off.
"noise1" is the sound to play when wall is blocking.
"dmg" is the amount of damage to cause when touched.
*/

void () blocker_touch =
	{
    if ( !self.dmg )
      return;

	if (time < self.attack_finished)
		return;
	self.attack_finished = time + 0.5;
	T_Damage (other, self, self, self.dmg);
	sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
   };

void () blocker_use = {
	if ( !self.state ) {
		self.state = 1;
		self.solid = SOLID_BSP;
		self.movetype = MOVETYPE_PUSH;
		setmodel(self, self.mdl);
		self.model = "";
		// sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	}
	else {
		self.state = 0;
		self.solid = SOLID_NOT;
		self.movetype = MOVETYPE_NONE;
		setmodel(self, "");
		sound(self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	}
};

void() func_togglewall = {

	self.classname = "togglewall";
	
	self.mdl = self.model;
	setmodel (self, self.model);
	//setsize (self, self.mins, self.maxs);
	//setorigin (self, self.origin);

	self.touch = blocker_touch;
	self.use = blocker_use;

	if ( !self.noise )
      self.noise = ("misc/null.wav");

   	if ( !self.noise1 )
      self.noise1 = ("misc/null.wav");

	precache_sound( self.noise );
	precache_sound( self.noise1 );

	//self.model = string_null;

	
	if ( self.spawnflags & START_OFF ) self.state = 1;
	else self.state = 0;
      
    blocker_use();
};

/*****************
func_togglevisiblewall

A bmodel which you can toggle its visibility. Behaves much like a traditional func_wall in any other way,
but you can target it to toggle visible/invisible.
If the entity has a switchable shadow it also toggles.

spawnflag 1: starts invisible
spawnflag 2: set brush as non-solid

******************/

float TOGGLEVISWALL_STARTOFF = 1;
float TOGGLEVISWALL_NOTSOLID = 2;

void() func_togglevisiblewall_use =
{
	if(!self.state) {
		if(!(self.spawnflags & TOGGLEVISWALL_NOTSOLID)) {
			self.solid = SOLID_BSP;
			self.movetype = MOVETYPE_PUSH;
		}
		setmodel (self, self.origmodel);
		if(self.switchshadstyle) lightstyle(self.switchshadstyle, "a");
		self.state = 1;
	} else {

		self.solid = SOLID_NOT;
		self.movetype = MOVETYPE_NONE;
		setmodel (self, "");
		if(self.switchshadstyle) lightstyle(self.switchshadstyle, "m");
		self.state = 0;
	}

};

/*QUAKED func_togglevisiblewall (0 .5 .8) ? TOGGLEVISWALL_STARTOFF TOGGLEVISWALL_NOTSOLID X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY

A bmodel which you can toggle its visibility. Behaves much like a traditional func_wall in any other way,
but you can target it to toggle visible/invisible.
If the entity has a switchable shadow it also toggles.

TOGGLEVISWALL_STARTOFF spawns in disabled state.

TOGGLEVISWALL_NOTSOLID sets it to be non-solid.

*/
void() func_togglevisiblewall =
{

	self.angles = '0 0 0';
	self.use = func_togglevisiblewall_use;

	self.origmodel = self.model;

	if(self.spawnflags & TOGGLEVISWALL_STARTOFF) self.state = 1;
	else self.state = 0;

	if(self.spawnflags & TOGGLEVISWALL_NOTSOLID) {
		self.solid = SOLID_NOT;
		self.movetype = MOVETYPE_NONE;
	}

	func_togglevisiblewall_use();

};

/*QUAKED func_illusionary (0 .5 .8) ?
A simple entity that looks solid but lets you walk through it.
*/
void() func_illusionary =

{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel (self, self.model);
	makestatic (self);
};

/*QUAKED func_episodegate (0 .5 .8) ? E1 E2 E3 E4
This bmodel will appear if the episode has allready been completed, so players can't reenter it.
*/
void() func_episodegate =

{
	if (!(serverflags & self.spawnflags))
		return;			// can still enter episode

	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};

/*QUAKED func_bossgate (0 .5 .8) ?
This bmodel appears unless players have all of the episode sigils.
*/
void() func_bossgate =

{
	if ( (serverflags & 15) == 15)
		return;		// all episodes completed
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};

//============================================================================

 //johnfitz -- ambient_general
/*QUAKED ambient_general (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
Plays any looped sound

Keys:

"noise" is the wav file to play

"volume" default 0.5

"speed" attenuation, default 3
*/
void () ambient_general =
{
	precache_sound (self.noise);
	if (!self.speed)
	{
		self.speed = ATTN_STATIC;
	}
	if (!self.volume)
	{
		self.volume = 0.5;
	}
	ambientsound (self.origin, self.noise, self.volume, self.speed);
	remove(self);
};
//johnfitz

/*QUAKED ambient_suck_wind (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/

void() FireAmbient =
{
	precache_sound ("ambience/fire1.wav");
// attenuate fast
	ambientsound (self.origin, "ambience/fire1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED ambient_fire (0.3 0.1 0.6) (-10 -10 -8) (10 10 8) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
ambinet fire sound effects added for consistency
same as FireAmbient
*/

void() ambient_fire =
{
	FireAmbient();
};

void() ambient_suck_wind =
{
	precache_sound ("ambience/suck1.wav");
	ambientsound (self.origin, "ambience/suck1.wav", 1, ATTN_STATIC);
	remove(self); //johnfitz -- reduce edict usage
};

/*QUAKED ambient_drone (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_drone =
{
	precache_sound ("ambience/drone6.wav");
	ambientsound (self.origin, "ambience/drone6.wav", 0.5, ATTN_STATIC);
	remove(self); //johnfitz -- reduce edict usage
};

/*QUAKED ambient_flouro_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_flouro_buzz =
{
	precache_sound ("ambience/buzz1.wav");
	ambientsound (self.origin, "ambience/buzz1.wav", 1, ATTN_STATIC);
	remove(self); //johnfitz -- reduce edict usage
};
/*QUAKED ambient_drip (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_drip =
{
	precache_sound ("ambience/drip1.wav");
	ambientsound (self.origin, "ambience/drip1.wav", 0.5, ATTN_STATIC);
	remove(self); //johnfitz -- reduce edict usage
};
/*QUAKED ambient_comp_hum (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_comp_hum =
{
	precache_sound ("ambience/comp1.wav");
	ambientsound (self.origin, "ambience/comp1.wav", 1, ATTN_STATIC);
	remove(self); //johnfitz -- reduce edict usage
};
/*QUAKED ambient_thunder (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_thunder =
{
	precache_sound ("ambience/thunder1.wav");
	ambientsound (self.origin, "ambience/thunder1.wav", 0.5, ATTN_STATIC);
	remove(self); //johnfitz -- reduce edict usage
};
/*QUAKED ambient_light_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_light_buzz =
{
	precache_sound ("ambience/fl_hum1.wav");
	ambientsound (self.origin, "ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
	remove(self); //johnfitz -- reduce edict usage
};
/*QUAKED ambient_swamp1 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_swamp1 =
{
	precache_sound ("ambience/swamp1.wav");
	ambientsound (self.origin, "ambience/swamp1.wav", 0.5, ATTN_STATIC);
	remove(self); //johnfitz -- reduce edict usage
};
/*QUAKED ambient_swamp2 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_swamp2 =
{
	precache_sound ("ambience/swamp2.wav");
	ambientsound (self.origin, "ambience/swamp2.wav", 0.5, ATTN_STATIC);
	remove(self); //johnfitz -- reduce edict usage
};

//============================================================================

void() noise_think =
{
	self.nextthink = time + 0.5;
	sound (self, 1, "enforcer/enfire.wav", 1, ATTN_NORM);
	sound (self, 2, "enforcer/enfstop.wav", 1, ATTN_NORM);
	sound (self, 3, "enforcer/sight1.wav", 1, ATTN_NORM);
	sound (self, 4, "enforcer/sight2.wav", 1, ATTN_NORM);
	sound (self, 5, "enforcer/sight3.wav", 1, ATTN_NORM);
	sound (self, 6, "enforcer/sight4.wav", 1, ATTN_NORM);
	sound (self, 7, "enforcer/pain1.wav", 1, ATTN_NORM);
};

/*QUAKED misc_noisemaker (1 0.5 0) (-10 -10 -10) (10 10 10)

For optimzation testing, starts a lot of sounds.
*/

void() misc_noisemaker =

{
	precache_sound2 ("enforcer/enfire.wav");
	precache_sound2 ("enforcer/enfstop.wav");
	precache_sound2 ("enforcer/sight1.wav");
	precache_sound2 ("enforcer/sight2.wav");
	precache_sound2 ("enforcer/sight3.wav");
	precache_sound2 ("enforcer/sight4.wav");
	precache_sound2 ("enforcer/pain1.wav");
	precache_sound2 ("enforcer/pain2.wav");
	precache_sound2 ("enforcer/death1.wav");
	precache_sound2 ("enforcer/idle1.wav");

	self.nextthink = time + 0.1 + random();
	self.think = noise_think;
};



//a collection of various pieces of mods and some new code -- by dumptruck_ds

void() play_sound_use =
   {
   if (self.spawnflags & 1)
      {
      if (self.state == 0)
         {
         self.state = 1;
         sound (self, self.impulse, self.noise, self.volume, self.speed);
         }
      else
         {
         self.state = 0;
         sound (self, self.impulse, "misc/null.wav", self.volume, self.speed);
         }
      }
   else
      {
      sound (self, self.impulse, self.noise, self.volume, self.speed);
      }
   };

void() PlaySoundThink =
   {
   local float t;
   t = self.wait * random();
   if (t < self.delay)
      t = self.delay;
   self.nextthink = time + t;
   play_sound_use();
   };

/*QUAKED play_sound_triggered (0.3 0.1 0.6) (-8 -8 -8) (8 8 8) toggle
play a sound when it is used
"toggle" determines whether sound should be stopped when triggered again
"volume" how loud (1 default full volume)
"noise" sound to play
"impulse" channel on which to play sound (0-7) (0 automatic is default)
"speed" attenuation factor
   -1 - no attenuation
    1 - normal
    2 - idle
    3 - static
*/
void() play_sound_triggered =
   {
   
   if (!self.noise) //dumptruck_ds
   {
       objerror ("no soundfile set in noise!\n");
       remove(self);
       return;
   }

   precache_sound (self.noise);
   precache_sound ("misc/null.wav");
   if (self.volume == 0)
      self.volume = 1;
   if (self.speed == 0)
      self.speed = 1;
   if (self.speed == -1)
      // self.speed = 0;
      self.speed = ATTN_NONE;
   if (self.spawnflags & 1)
      if (self.impulse == 0)
         self.impulse = 7;
   self.use = play_sound_use;
   };

/*QUAKED play_sound (0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
play a sound on a periodic basis
"volume" how loud (1 default full volume)
"noise" sound to play
"wait" random time between sounds (default 20)
"delay" minimum delay between sounds (default 2)
"impulse" channel on which to play sound (0-7) (0 automatic is default)
"speed" attenuation factor
   -1 - no attenuation
    1 - normal
    2 - idle
    3 - static
*/
void() play_sound =
   {


   local float t;

   if (!self.noise) //dumptruck_ds
   {
      objerror ("no soundfile set in noise!\n");
      remove(self);
      return;
   }


   play_sound_triggered();
   if (self.wait == 0)
      self.wait = 20;
   if (self.delay == 0)
      self.delay = 2;
   self.think = PlaySoundThink;
   t = self.wait * random();
   if (t < self.delay)
      t = self.delay;
   self.nextthink = time + t;
   };
