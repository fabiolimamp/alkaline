

/*QUAKED misc_fireball (0 .5 .8) (-8 -8 -8) (8 8 8)
Lava Balls
*/

void() misc_fireball = {
	if (!SUB_InitEntity()) return;
	
	precache_model ("progs/lavaball.mdl");
	self.classname = "fireball";
	self.nextthink = time + (random() * 5);
	self.think = fire_fly;
	if (!self.obituary) self.obituary = "ate a lavaball";
	if (!self.speed)
		self.speed = 1000;
};

void() fire_fly = {
	self.nextthink = time + (random() * 5) + 3;
	self.think = fire_fly;

	if (self.estate != STATE_ACTIVE)
		return;

	entity fireball;

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
	

};


void() fire_touch = {
	if (other.health) T_Damage(other, self, self, 20, DMGTYPE_BURN);
	remove(self);
};



//============================================================================

void() misc_drip = {
	if (!SUB_InitEntity()) return;
	

	if (self.mdl == "") self.mdl = "progs/drip.spr";
	precache_model(self.mdl);

	// mute
	if (!(self.spawnflags & 2)) {
		precache_sound("misc/singledrip1.wav");
		precache_sound("misc/singledrip2.wav");
		precache_sound("misc/singledrip3.wav");
		precache_sound("misc/singledrip4.wav");
	}

	self.think = misc_drip_think;
	self.use = misc_drip_use;

	self.waitmin = defaultFl(self.waitmin, 2);
	self.waitmax = defaultFl(self.waitmax, 3);
	float tmin = min(self.waitmin, self.waitmax);
	float tmax = max(self.waitmin, self.waitmax);
	self.waitmin = tmin;
	self.waitmax = tmax;
	// start off
	if (self.spawnflags & 1)
		self.estate = STATE_INACTIVE;

	self.nextthink = time + self.waitmin + random()*(self.waitmax - self.waitmin);
}

void() misc_drip_use = {
	if (self.estate != STATE_ACTIVE)
		self.estate = STATE_ACTIVE;
	else
		self.estate = STATE_INACTIVE;
}

void() misc_drip_think = {
	self.nextthink = time + self.waitmin + random()*(self.waitmax - self.waitmin);
	if (self.estate != STATE_ACTIVE)
		return;

	misc_drip_spawn();
}

void() misc_drip_spawn = {
	entity e = spawn();

	e.movetype = MOVETYPE_TOSS;
	e.solid = SOLID_BBOX;
	setorigin(e, self.origin);
	setmodel(e, self.mdl);
	setsize(e, '0 0 0', '0 0 0');
	e.owner = self;
	e.touch = misc_drip_touch;
	e.think = SUB_Remove;
	e.nextthink = time + 5;
}

void() misc_drip_touch = {
	self.solid = SOLID_NOT;

	// mute
	if (!(self.spawnflags & 2)) {
		float r = random();
		string dripsnd;

		if (r < 0.25) dripsnd = "misc/singledrip1.wav";
		else if (r < 0.5) dripsnd = "misc/singledrip2.wav";
		else if (r < 0.75) dripsnd = "misc/singledrip3.wav";
		else dripsnd = "misc/singledrip4.wav";

		sound(self, CHAN_VOICE, dripsnd, 0.1, ATTN_STATIC);
	}
	
	// if no bounce is off
	if (!(self.spawnflags & 4)) {
		vector v_drip, angle_normal;

		traceline(self.origin + '0 0 2', self.origin - '0 0 2', FALSE, self);
		angle_normal = vectoangles(trace_plane_normal);
		
		entity e;
		for (float i = 0; i < 3; i++) {

			e = spawn();
			e.movetype = MOVETYPE_BOUNCE;
			e.solid = SOLID_TRIGGER;
			setorigin(e, self.origin);
			setmodel(e, self.model);
			setsize(e, '0 0 0', '0 0 0');
			e.touch = misc_drip_bouncetouch;
			e.think = SUB_Remove;
			e.nextthink = time + 1;

			// create the initial drip vector
			makevectors([-50 - random()*15, 360/3*i + crandom()*30, 0]);

			// rotate the vector 90deg so it's facing front
			v_drip = [v_forward_z, v_forward_y, -v_forward_x];

			// negate X axis to account for makevectors
			makevectors([-angle_normal_x, angle_normal_y, angle_normal_z]);

			// reorient the drip vector around the surface normal
			e.velocity = (v_forward*v_drip_x - v_right*v_drip_y + v_up*v_drip_z) * (130 + random()*40);//vlen(self.velocity)/4;
		}
	}
	remove(self);

}

void() misc_drip_bouncetouch = {
	if (other.solid == SOLID_TRIGGER)
		return;
	remove(self);
}
//============================================================================


void() barrel_explode =
{
	self.takedamage = DAMAGE_NO;
	self.classname = "explo_box";

	particle (self.origin, '0 0 0', 75, 255);

	self.origin_z = self.origin_z + 32;
	
	sound (self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);

	T_RadiusDamage (self, self, self.dmg, 1, world, DMGTYPE_EXPLOSION);

	activator = self.enemy;
	SUB_UseTargets();

	BecomeExplosion();
};

void() barrel_die = {
	// already fired, so disable all subsequent triggers
	self.th_die = SUB_Null;
	self.use = SUB_Null;

	// exploded by damage, not by triggering, so the attacker becomes the activator
	if (self.health <= 0) self.enemy = damage_attacker;
	else self.enemy = activator;

	self.think = barrel_explode;
	self.nextthink = time + 0.05 + random()*0.05;
}

/*QUAKED misc_explobox (0 .5 .8) (0 0 0) (32 32 64)
TESTING THING
*/
void() misc_explobox = {
	if (!SUB_InitEntity()) return;
	
	float oldz;
	
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	precache_model("maps/b_explob.bsp");
	setmodel(self, "maps/b_explob.bsp");
	precache_sound("weapons/r_exp3.wav");
	if (!self.health) self.health = 20;
	if (!self.dmg) self.dmg = 160;
	if (!self.obituary) self.obituary = "blew up";
	self.th_die = barrel_die;
	self.use = barrel_die;
	if (!(self.spawnflags & 1)) self.takedamage = DAMAGE_AIM;

	self.bloodtype = zeroconvertdefault(self.bloodtype, SPAWN_YELLOWSPARK);
	self.origin_z = self.origin_z + 2;
	oldz = self.origin_z;
	droptofloor();
	if (oldz - self.origin_z > 250) {
		dprint ("Explobox fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
	}
};




/*QUAKED misc_explobox2 (0 .5 .8) (0 0 0) (32 32 64)
Smaller exploding box, REGISTERED ONLY
*/

void() misc_explobox2 = {
	if (!SUB_InitEntity()) return;
	
	float oldz;
	
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	precache_model2 ("maps/b_exbox2.bsp");
	setmodel (self, "maps/b_exbox2.bsp");
	precache_sound ("weapons/r_exp3.wav");
	if (!self.health) self.health = 20;
	if (!self.dmg) self.dmg = 160;
	if (!self.obituary) self.obituary = "blew up";
	self.th_die = barrel_explode;
	self.use = barrel_explode;
	
	if(!(self.spawnflags & 1)) self.takedamage = DAMAGE_AIM;

	self.bloodtype = zeroconvertdefault(self.bloodtype, SPAWN_YELLOWSPARK);
	self.origin_z = self.origin_z + 2;
	oldz = self.origin_z;
	droptofloor();
	if (oldz - self.origin_z > 250)
	{
		dprint ("Explobox fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
	}
};

//============================================================================

float TRAP_SUPERSPIKE = 1;
float TRAP_LASER = 2;
float TRAP_ROCKET = 4;
float TRAP_VOREBALL = 8;
float TRAP_GRENADE = 16;

float TRAP_STARTOFF = 128;
float TRAP_TARGETPLAYER = 65536;

void() ShalMisTouchEnt = {

	if (other.solid == SOLID_BSP) {
		//dprint("touched bsp, returning...\n");
		return;
	}
	
	if (other.classname == "shalmissiletf" || other.classname == "shalmissile") {
		//dprint("touched other missile, returning...\n");
		return;
	}

	if (other.flags & FL_PROJECTILE)
		return;

	//dprint3("T.field touched entity: ", other.classname, "\n");
	
	self.touch = SUB_Null;
	self.owner.touch = SUB_Null;

	if (other.classname == "monster_zombie")
		T_Damage(other, self.owner, self.owner, 110, DMGTYPE_EXPLOSION);

	self.owner.dmg = zeroconvertdefault(self.owner.dmg, 40);

	T_RadiusDamage (self.owner, self.owner.owner, self.owner.dmg, 1, self, DMGTYPE_EXPLOSION);

	sound (self.owner, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	SUB_CallAsSelf(BecomeExplosion, self.owner);

	remove(self);
};

void() ShalMisTouchWorld = {
	if (other.solid != SOLID_BSP)
		return;

	//dprint3("Projectile touched entity: ", other.classname, "\n");
	
	self.touch = SUB_Null;
	self.trigger_field.touch = SUB_Null;

	self.dmg = zeroconvertdefault(self.dmg, 40);

	T_RadiusDamage(self, self.owner, self.dmg, 1, self.trigger_field, DMGTYPE_EXPLOSION);
	
	remove(self.trigger_field);

	sound(self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	BecomeExplosion();
}

void() ShalMisTfThink = {
	if (self.owner.trigger_field != self) {
		remove(self);
		return;
	}
	self.nextthink = time + 0.05;
	setorigin(self, self.owner.origin);
}

void() ShalMisTfDie = {
	other = self.owner.enemy;
	ShalMisTouchEnt();
}

void() spikeshooter_use = {
	float spd, damage;
	vector launchdir;

	if (self.estate != STATE_ACTIVE) return;


	launchdir = self.movedir;
	
	if (self.spawnflags & TRAP_TARGETPLAYER) {
		entity pl = findClosest(self.origin, classname, "player", 0);
		launchdir = normalize(pl.origin - self.origin);
	}
	else if (self.target != "") {
		entity tgt = find(world, targetname, self.target);
		if (tgt) launchdir = normalize(tgt.origin - self.origin);
	}


	if (self.spawnflags & TRAP_LASER) {
		sound (self, CHAN_VOICE, "enforcer/enfire.wav", 1, ATTN_NORM);
		LaunchLaser (self.origin, launchdir);
		spd = 600;
		damage = 15;
	}
	else if (self.spawnflags & TRAP_ROCKET) {
		sound (self, CHAN_VOICE, "weapons/sgun1.wav", 1, ATTN_NORM);
		launch_rocket (self.origin, launchdir);
		spd = 500;
		damage = 60;
	}
	else if (self.spawnflags & TRAP_VOREBALL) {
		self.originalmonsters = 1;
		ShalMissile();
		damage = 20;
		spd = 200;

		if (activator.flags & FL_CLIENT && activator.health > 0)
			newmis.enemy = activator;
		else
			newmis.enemy = findClosest(self.origin, classname, "player", 0);

		newmis.attack_finished = time + 10;
		newmis.movetype = MOVETYPE_FLY;
		setmodel(newmis, "progs/v_spike_green.mdl");
		setorigin(newmis, self.origin);
		setsize(newmis, '0 0 0', '0 0 0');	
		newmis.touch = ShalMisTouchWorld;
		newmis.nextthink = time + 0.2;
		

		entity e;
		e = spawn();
		e.think = ShalMisTfThink;
		e.nextthink = time + 0.05;
		e.touch = ShalMisTouchEnt;
		
		e.health = zeroconvertdefault(self.health, 30);
		if (e.health) {
			e.takedamage = DAMAGE_AIM;
			e.th_die = ShalMisTfDie;
			e.solid = SOLID_BBOX;
		}
		else {
			e.solid = SOLID_TRIGGER;
		}
		e.movetype = MOVETYPE_FLY;
		e.owner = newmis;
		newmis.trigger_field = e;
		setorigin(e, newmis.origin);
		setsize(e, '-16 -16 -16', '16 16 16');
		
		e.classname = "shalmissiletf";
		//sound (self, CHAN_WEAPON, "shalrath/attack2.wav", 1, ATTN_NORM);
	}
	else if (self.spawnflags & TRAP_GRENADE) {
		sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

		newmis = spawn();
		newmis.classname = "grenade";
		newmis.owner = self;
		newmis.movetype = MOVETYPE_BOUNCE;
		newmis.solid = SOLID_BBOX;
		newmis.flags |= FL_PROJECTILE;

		// set missile speed
		newmis.velocity = launchdir * 500;
		newmis.velocity_z += 200;
		newmis.avelocity = '300 300 300';
		newmis.angles = vectoangles(newmis.velocity);
		newmis.touch = OgreGrenadeTouch;

		// set missile duration
		newmis.nextthink = time + 2.5;
		newmis.think = OgreGrenadeExplode;

		setmodel (newmis, "progs/grenade.mdl");
		setsize (newmis, '0 0 0', '0 0 0');
		setorigin (newmis, self.origin);
		spd = 500;
		damage = 40;
	}
	else
	{
		sound(self, CHAN_VOICE, "weapons/spike2.wav", 1, ATTN_NORM);
		launch_spike (self.origin, launchdir);
		spd = 500;
		if (self.spawnflags & TRAP_SUPERSPIKE) {
			newmis.touch = superspike_touch;
			damage = 18;
		}
		else damage = 9;
	}
	
	if (self.dmg) damage = zeroconvert(self.dmg);
	newmis.dmg = damage;
	
	if (self.speed) spd = self.speed;
	newmis.velocity = normalize(newmis.velocity) * spd;
};

void() shooter_think =
{
	if (!SUB_InitEntity()) return;
	
	spikeshooter_use();
	self.nextthink = time + self.wait + self.rand*random();
};


/*QUAKED trap_spikeshooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
When triggered, fires a spike in the direction set in QuakeEd.
Laser is only for REGISTERED.
*/

void() trap_spikeshooter =
{
	if (!SUB_InitEntity()) return;
	
	SetMovedir();

	if (self.target != "") {
		entity tgt = find(world, targetname, self.target);
		if (tgt) self.movedir = normalize(tgt.origin - self.origin);
	}

	self.use = spikeshooter_use;

	if (!self.obituary) {
		if (self.spawnflags & TRAP_LASER) self.obituary = "was zapped by a frickin' laser beam";
		else if (self.spawnflags & TRAP_ROCKET) self.obituary = "rode a rocket";
		else if (self.spawnflags & TRAP_VOREBALL) self.obituary = "played catch with a homing ball";
		else self.obituary = "was spiked";
	}

	if (self.spawnflags & TRAP_LASER)
	{
		precache_model("progs/laser.mdl");
		
		precache_sound("enforcer/enfire.wav");
		precache_sound("enforcer/enfstop.wav");
	}
	else if (self.spawnflags & TRAP_VOREBALL) {
		//precache_model("progs/v_spike_red.mdl");
		precache_model("progs/v_spike_green.mdl");
		precache_model("progs/v_spike.mdl");
		
		precache_sound("shalrath/attack2.wav");
	}
	// spike and rocket sounds precached in weapons.qc
	// models in world.qc
};


/*QUAKED trap_shooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
Continuously fires spikes.
"wait" time between spike (1.0 default)
"nextthink" delay before firing first spike, so multiple shooters can be stagered.
*/
void() trap_shooter = {
	if (!SUB_InitEntity()) return;
	
	trap_spikeshooter ();
	self.use = trap_shooter_toggle;

	if (self.wait == 0)
		self.wait = 1;

	if (self.spawnflags & TRAP_STARTOFF)
		self.estate = STATE_INACTIVE;

	if (!self.delay)
		self.delay = self.nextthink; // backwards compatibility with id1

	self.nextthink = time + self.delay + self.rand*random();
	self.think = shooter_think;
	
};

void() trap_shooter_toggle = {
	if (self.estate != STATE_ACTIVE){
		self.estate = STATE_ACTIVE;
		self.nextthink = time + self.delay + self.rand*random();
	}
	else {
		self.estate = STATE_INACTIVE;
	}
};

/*QUAKED viewthing (0 .5 .8) (-16 -16 -24) (16 16 40)

Just for the debugging level.  Don't use
*/

void() viewthing = {
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_BBOX;
	setsize (self, '-16 -16 -24', '16 16 40');
	precache_model ("progs/dread.mdl");
	setmodel (self, "progs/dread.mdl");
};


/***********************************************

target_autosave
from Copper

***********************************************/

void() target_autosave_use = {
	if (noautosaves) return;
	
	if (self.enemy)	{
		activator = self.enemy;
		self.enemy = world;
	}

	if (activator.classname != "player") return;

	if (time < 2) {	// make sure an autosave fired from a player start doesn't happen too early
		self.enemy = activator;
		self.think = target_autosave_use;
		self.nextthink = 2;
		return;
	}
	sound(activator, CHAN_VOICE, "misc/sav.wav", 0.3, ATTN_NORM);
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
void() target_autosave = {
	if (!SUB_InitEntity()) return;
	
	if (deathmatch || coop) {
		remove(self);
		return;
	}
	
	if (self.message == string_null)
		self.message = "auto";

	precache_sound2("misc/sav.wav");
	self.use = target_autosave_use;
}


/***********************************************

target_move

***********************************************/


void() target_move_use = {
	entity t;
	vector neworigin;

	// move activator
	if (self.spawnflags & 8)
		t = activator;
	else {
		t = find(world, targetname, self.target);

		if (!t) //targetname not found, search for targetname2
			t = find(world, targetname2, self.target);
	}

	if (t) {
		if(t.movetype == MOVETYPE_STEP) //monsters need to move off the ground, otherwise they'll lerp 
			neworigin = self.origin + '0 0 1';
		else
			neworigin = self.origin;

		// spawn teleport effect
		if (self.spawnflags & 4) {
			spawn_tfog(t.origin);
		}

		setorigin(t, neworigin);
		//t.origin = self.origin;
		// keep original angle
		if (!(self.spawnflags & 1)) t.angles = self.mangle;
		// keep original velocity
		if (!(self.spawnflags & 2)) t.velocity = '0 0 0';
		t.flags = t.flags - t.flags & FL_ONGROUND;

		if (self.spawnflags & 4) {
			vector tfog_org;
			if (t.flags & FL_CLIENT) {
				makevectors(t.v_angle);
				tfog_org = t.origin + v_forward * 32;
			}
			else
				tfog_org = t.origin;
			spawn_tfog(tfog_org);
		}
	}

};

/*QUAKED target_move (1 .0 .5) (-8 -8 -8) (8 8 8) KEEP_ANGLE KEEP_VELOCITY
Moves target entity to this spot and angle when triggered.
Use spawnflag 1 to not change the entity's original angle.
Spawnflag 2 keeps the entity's original velocity.
*/
void() target_move = {
	if (!SUB_InitEntity()) return;
	
	if (!self.target && !(self.spawnflags & 8))
		objerror("No target set");

	if (!self.targetname)
		objerror("No targetname set");

	self.use = target_move_use;
	
	if (!self.mangle) self.mangle = self.angles;
};


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

void() target_infight_use = {
	entity t1, prev_t1, t2;
	
	t2 = find(world, targetname, self.target2);

	if (!t2) {
		t2 = find(world, targetname2, self.target2);
	}

	if (!t2) {
		dprint("[target_infight] Cannot find target2\n");
		return;
	}

	t1 = find(world, targetname, self.target);
	while (t1) {
		if (t1.flags & FL_MONSTER){
			make_angry_at(t1, t2);
			prev_t1 = t1;
		}
		t1 = find(t1, targetname, self.target);
	}
	
	t1 = find(world, targetname2, self.target);
	while (t1) {
		if (t1.flags & FL_MONSTER){
			make_angry_at(t1, t2);
			prev_t1 = t1;
		}
		t1 = find(t1, targetname2, self.target);
	}
	
	if (self.spawnflags & INFIGHT_MUTUAL && prev_t1)
		make_angry_at(t2, prev_t1);
};

/*QUAKED target_infight (1 .0 .5) (-8 -8 -8) (8 8 8) MUTUAL
Makes 'target' monster angry at 'target2'.

By default, the infighting doesn't start mutually, that is, 'target2' monster will only get mad back at 'target' after it's been attacked.

If you want to make them angry at each other instantly, you can set the spawnflag 'Mutual hate'.
*/
void() target_infight = {
	if (!SUB_InitEntity()) return;
	
	self.use = target_infight_use;
};




/*
==============================================================================

SIMPLE BMODELS

==============================================================================
*/

void() func_wall_use = {
	// change to alternate textures
	float onframe = (self.spawnflags & 4) ? 1 : 0;

	if (self.estate == STATE_ACTIVE) {
		// when the flicker flag is on, frame is managed via think function
		if (!(self.spawnflags & 8)) self.frame = 1 - onframe;
		self.estate = STATE_INACTIVE;
	}
	else {
		if (!(self.spawnflags & 8)) self.frame = onframe;
		self.estate = STATE_ACTIVE;
	}
};

void(float newstate, float stateflags) func_wall_setstate = {
	float onframe = (self.spawnflags & 4) ? 1 : 0;

	if (newstate == STATE_ACTIVE) {
		self.frame = onframe;
	}
	else {
		self.frame = 1 - onframe;
	}
	self.estate = newstate;
}

/*QUAKED func_wall (0 .5 .8) ?
This is just a solid wall if not inhibitted
*/
void() func_wall = {
	if (!SUB_InitEntity()) return;
	
	self.angles = '0 0 0';

	if (self.spawnflags & 2) {
		self.movetype = MOVETYPE_NONE;
		self.solid = SOLID_NOT;
	}
	else {
		self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
		self.solid = SOLID_BSP;
	}
	self.use = func_wall_use;
	self.th_setstate = func_wall_setstate;

	setmodel (self, self.model);
	
	float onframe = (self.spawnflags & 4) ? 1 : 0;
	
	//self.frame = onframe;

	if (self.spawnflags & 16) { // start off
		self.estate = STATE_INACTIVE;
		self.frame = 1 - onframe;
	}

	if (self.spawnflags & 8) { // sync with fluoro flicker
		self.think = func_wall_think;
		self.nextthink = getLocalTime() + 0.1;
	}
	
	if (self.switchshadstyle) lightstyle(self.switchshadstyle, "a");
};


void() func_wall_think = {
	self.nextthink = getLocalTime() + 0.01;

	float onframe = (self.spawnflags & 4) ? 0 : 1;

	if (self.estate != STATE_ACTIVE) {
		self.frame = 1 - onframe;
		return;
	}

	float ltframe = ceil((time % 2.5) * 10);
	//dprint3("Frame time: ", ftos((time % 2.5) * 10), "\n");
	//dprint3("Frame number: ", ftos(ltframe), "\n");

	/*
mmamammmmammamamaaamammma
	*/
	if (ltframe == 3 || ltframe == 5 || ltframe == 10 || ltframe == 13 || ltframe == 15 ||
		ltframe == 17 || ltframe == 18 || ltframe == 19 || ltframe == 21 || ltframe == 25
	)
		self.frame = 1 - onframe;
	
	else
		self.frame = onframe;


}


//=============================================================================

/*QUAKED func_togglewall (0 .5 .8) ? START_OFF X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY

Creates a invisible wall that can be toggled on and off.

START_OFF wall doesn't block until triggered.

"noise" is the sound to play when wall is turned off.
"noise1" is the sound to play when wall is blocking.
"dmg" is the amount of damage to cause when touched.
*/

void () blocker_touch =	{
	if (!self.dmg )
	  return;

	if (time < self.attack_finished)
		return;
	self.attack_finished = time + 0.5;
	T_Damage(other, self, self, self.dmg, DMGTYPE_CRUSH);
	sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
};

void () blocker_use = {
	if (self.estate != STATE_ACTIVE) {
		self.estate = STATE_ACTIVE;

		if (!(self.spawnflags & 2)) { //not solid
			self.solid = SOLID_BSP;
			self.movetype = MOVETYPE_PUSH;
		}

		setmodel(self, self.mdl);
		self.model = "";
		// sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	}
	else {
		self.estate = STATE_INACTIVE;
		self.solid = SOLID_NOT;
		self.movetype = MOVETYPE_NONE;
		setmodel(self, "");
		sound(self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	}
};

void() func_togglewall = {
	if (!SUB_InitEntity()) return;
	

	self.classname = "togglewall";
	
	self.mdl = self.model;
	setmodel (self, self.model);

	self.touch = blocker_touch;
	self.use = blocker_use;

	if ( !self.noise )
		self.noise = ("misc/null.wav");

	if ( !self.noise1 )
		self.noise1 = ("misc/null.wav");

	precache_sound( self.noise );
	precache_sound( self.noise1 );
	
	if ( self.spawnflags & START_OFF ) self.estate = STATE_ACTIVE;
	else self.estate = STATE_INACTIVE;
	  
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

void() func_togglevisiblewall_use = {
	if (self.estate != STATE_ACTIVE) {
		func_togglevisiblewall_setstate(STATE_ACTIVE, 0);
	} else {
		func_togglevisiblewall_setstate(STATE_INACTIVE, 0);
	}
};

void(float newstate, float stateflags) func_togglevisiblewall_setstate = {
	if (newstate == STATE_ACTIVE) {
		if (!(self.spawnflags & TOGGLEVISWALL_NOTSOLID)) {
			self.solid = SOLID_BSP;
			self.movetype = MOVETYPE_PUSH;
		}
		setmodel(self, self.origmodel);
		if (self.switchshadstyle) lightstyle(self.switchshadstyle, "a");
	}
	else {
		self.solid = SOLID_NOT;
		self.movetype = MOVETYPE_NONE;
		setmodel(self, "");
		if (self.switchshadstyle) lightstyle(self.switchshadstyle, "m");
	}
	self.estate = newstate;
}

/*QUAKED func_togglevisiblewall (0 .5 .8) ? TOGGLEVISWALL_STARTOFF TOGGLEVISWALL_NOTSOLID X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY

A bmodel which you can toggle its visibility. Behaves much like a traditional func_wall in any other way,
but you can target it to toggle visible/invisible.
If the entity has a switchable shadow it also toggles.

TOGGLEVISWALL_STARTOFF spawns in disabled state.

TOGGLEVISWALL_NOTSOLID sets it to be non-solid.

*/
void() func_togglevisiblewall =
{
	if (!SUB_InitEntity()) return;
	

	self.angles = '0 0 0';
	self.use = func_togglevisiblewall_use;
	self.th_setstate = func_togglevisiblewall_setstate;

	self.origmodel = self.model;

	if (self.spawnflags & TOGGLEVISWALL_STARTOFF) self.estate = STATE_ACTIVE;
	else self.estate = STATE_INACTIVE;

	if (self.spawnflags & TOGGLEVISWALL_NOTSOLID) {
		self.solid = SOLID_NOT;
		self.movetype = MOVETYPE_NONE;
	}

	func_togglevisiblewall_use();

};

/*****************
func_shadow

An invisible bmodel that can be used to only cast shadows.

******************/
void() func_shadow_use =
{

	if (!self.switchshadstyle)
		return;

	entity shadow = self.shadowcontroller;
	entity oldself = self;
	self = shadow;

	
	if (oldself.estate == 1) {
		misc_shadowcontroller_setsteps(self.speed);
		shadow_fade_in();
		shadow.shadowoff = 0;
		oldself.estate = 0;
	} else {
		misc_shadowcontroller_setsteps(self.speed2);
		shadow_fade_out();
		shadow.shadowoff = 1;
		oldself.estate = 1;
	}
	
	self = oldself;
	
};

void(float newstate, float stateflags) func_shadow_setstate = {
	entity shadow = self.shadowcontroller;
	entity oldself = self;
	self = shadow;
	
	if (newstate == STATE_ACTIVE) {
		misc_shadowcontroller_setsteps(self.speed);
		shadow_fade_in();
		shadow.shadowoff = 1;
		oldself.estate = newstate;
	} else {
		misc_shadowcontroller_setsteps(self.speed2);
		shadow_fade_out();
		shadow.shadowoff = 0;
		oldself.estate = newstate;
	}

	self = oldself;
}

void() func_shadow = {
	if (!SUB_InitEntity()) return;
	

	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;

	self.modelindex = 0;
	self.model = "";

	
	self.use = func_shadow_use;
	self.th_setstate = func_shadow_setstate;

	if (self.switchshadstyle) {
		
		entity shadow = spawn();
		
		self.shadowcontroller = shadow;
		
		shadow.classname = "misc_shadowcontroller";
		shadow.switchshadstyle = self.switchshadstyle;
		shadow.speed = self.speed;
		shadow.speed2 = self.speed2;
		
		if (self.spawnflags & 1) {
			self.estate = 1;
			shadow.spawnflags = 1;
		}
		
		
		entity oldself = self;
		
		self = shadow;
		misc_shadowcontroller();
		
		self = oldself;
	}

}
/*QUAKED func_illusionary (0 .5 .8) ?
A simple entity that looks solid but lets you walk through it.
*/
void() func_illusionary =

{
	if (!SUB_InitEntity()) return;
	
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
	if (!SUB_InitEntity()) return;
	
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
	if (!SUB_InitEntity()) return;
	
	if ( (serverflags & 15) == 15)
		return;		// all episodes completed
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};

//============================================================================



void() FireAmbient =
{
	precache_sound ("ambience/fire1.wav");
// attenuate fast
	ambientsound (self.origin, "ambience/fire1.wav", 0.5, ATTN_STATIC);
};

void(string sound, float default_vol) ambient_entity = {
	local float attn;
	precache_sound (sound);

	attn = ATTN_STATIC; // all ambients use ATTN_STATIC by default, no need to pass that as parameter
	if (self.speed) attn = self.speed;
	if (self.volume) default_vol = self.volume;

	ambientsound (self.origin, sound, default_vol, attn);
	remove(self);
}

/*QUAKED ambient_general (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
Plays any looped sound

Keys:

"noise" is the wav file to play

"volume" default 0.5

"speed" attenuation, default 3
*/
void() ambient_general = 		{ ambient_entity(self.noise, 				0.5	); };

/*QUAKED ambient_suck_wind (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)*/
void() ambient_suck_wind = 		{ ambient_entity("ambience/suck1.wav", 		1	); };
/*QUAKED ambient_drone (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)*/
void() ambient_drone = 			{ ambient_entity("ambience/drone6.wav",		0.5	); };
/*QUAKED ambient_flouro_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)*/
void() ambient_flouro_buzz = 	{ ambient_entity("ambience/buzz1.wav",		1	); };
/*QUAKED ambient_drip (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)*/
void() ambient_drip =			{ ambient_entity("ambience/drip1.wav",		0.5	); };
/*QUAKED ambient_comp_hum (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)*/
void() ambient_comp_hum = 		{ ambient_entity("ambience/comp1.wav", 		1	); };
/*QUAKED ambient_thunder (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)*/
void() ambient_thunder =		{ ambient_entity("ambience/thunder1.wav", 	0.5	); };
/*QUAKED ambient_light_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)*/
void() ambient_light_buzz =		{ ambient_entity("ambience/fl_hum1.wav", 	0.5	); };
/*QUAKED ambient_swamp1 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)*/
void() ambient_swamp1 = 		{ ambient_entity("ambience/swamp1.wav", 	0.5	); };
/*QUAKED ambient_swamp2 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)*/
void() ambient_swamp2 = 		{ ambient_entity("ambience/swamp2.wav", 	0.5	); };
/*QUAKED ambient_fire (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)*/
void() ambient_fire = 			{ ambient_entity("ambience/fire1.wav", 		0.5	); };
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
void() play_sound_triggered = {

	if (!SUB_InitEntity()) return;
	
	if (!self.noise) {
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
		self.speed = ATTN_NONE;

	if (self.spawnflags & 1){
		if (self.impulse == 0)
			self.impulse = 7;
	}

	self.use = play_sound_triggered_use;
};

void() play_sound_triggered_use = {
	entity src;

	if (self.spawnflags & 4) { // play on activator
		src = activator;
	}
	else if (self.spawnflags & 8) { // play on player
		if (!(activator.flags & FL_CLIENT)) {
			entity closest = findClosest(self.origin, classname, "player", 1);
			if (!closest) closest = findClosest(self.origin, classname, "player", 0);

			if (closest) src = closest;
			else src = self;
		} 
		else
			src = activator;
	}
	else if (self.spawnflags & 16) { // play on all players
		src = find(world, classname, "player");
	}

	else src = self;

	if (self.spawnflags & 1) { // toggle
		if (self.state == 0) {
			self.state = 1;

			if (self.spawnflags & 16) { // play on all players
				while (src) { // first player was already searched for, if there's none then it'll bail out immediately
					sound (src, self.impulse, self.noise, self.volume, self.speed);
					src = find(src, classname, "player");
				}
			}
			else
				sound (src, self.impulse, self.noise, self.volume, self.speed);
		}
		else {
			self.state = 0;

			if (self.spawnflags & 16) { // play on all players
				while (src) { // first player was already searched for, if there's none then it'll bail out immediately
					sound (src, self.impulse, "misc/null.wav", self.volume, self.speed);
					src = find(src, classname, "player");
				}
			}
			else
				sound (src, self.impulse, "misc/null.wav", self.volume, self.speed);
		}
	}
	else {
		if (self.spawnflags & 16) { // play on all players
			while (src) { // first player was already searched for, if there's none then it'll bail out immediately
				sound (src, self.impulse, self.noise, self.volume, self.speed);
				src = find(src, classname, "player");
			}
		}
		else
			sound (src, self.impulse, self.noise, self.volume, self.speed);
	}
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

void() play_sound = {play_sound_repeat();}

void() play_sound_repeat = {

	if (!SUB_InitEntity()) return;
	
	if (!self.noise) {
		objerror ("no soundfile set in noise!\n");
		remove(self);
		return;
	}

	play_sound_triggered();

	if (self.wait == 0)
		self.wait = 20;

	if (self.delay == 0)
		self.delay = 2;
	
	self.think = play_sound_think;
	self.use = play_sound_use;

	if (self.spawnflags & 1) {
		self.estate = STATE_INACTIVE;
	}
	else {
		self.nextthink = time + self.delay + self.wait * random();
	}
};

void() play_sound_think = {
	if (self.estate != STATE_ACTIVE)
		return;

	self.nextthink = time + self.delay + self.wait * random();

	sound(self, self.impulse, self.noise, self.volume, self.speed);
};

void() play_sound_use = {
	if (self.estate != STATE_ACTIVE) {
		self.estate = STATE_ACTIVE;
		self.nextthink = time + self.delay + self.wait * random();
	}
	else {
		self.estate = STATE_INACTIVE;
	}
};

/*
=============================================================

misc_changemusic
Adapted from progs_dump's trigger_changemusic/trigger_cdtrack

Also, changing worldspawn fields through pointers? WHAT IS THIS WITCHERY
--bmFbr

=============================================================
*/

void(float newtrack) changemusic = {
  *world_sounds = newtrack;  //changing the field via a pointer
  //world.sounds has now been changed via our pointer, newly connecting players (like those connecting after the game is loaded) will get sent the new cd track's number.

  //let everyone currently on the server know.
  WriteByte(MSG_ALL, SVC_CDTRACK);
  WriteByte(MSG_ALL, newtrack);  //initial track
  WriteByte(MSG_ALL, newtrack);  //looped track... should generally be set the same as the initial track as most engines ignore it entirely so it might as well be sane for those that care.
};

void() misc_changemusic_use = {
	changemusic(self.sounds);
}

void() misc_changemusic = {
	if (!SUB_InitEntity()) return;
	
	if (!self.sounds) {
		objerror("ERROR: misc_changemusic needs valid track number in sounds field");
		return;
	}

	self.use = misc_changemusic_use;
}




/*
=============================================================

trigger_textstory

=============================================================
*/
float TEXTSTORY_SILENT = 1;
float TEXTSTORY_NOFADE = 2;

void(entity controller) textstory_hide = {
	if (!self.enemy || !(self.enemy.flags & FL_CLIENT)) return;

	self.enemy.suppressCenterPrint = FALSE;
	centerprint(self.enemy, "");

	if (controller.noise2 != "") 
		sound(self.enemy, CHAN_BODY, controller.noise2, 1, ATTN_NORM);
	
	if (!(controller.spawnflags & TEXTSTORY_NOFADE))
		csf_fade_clear(self.enemy, 0.5, 110);
};

void(entity controller) textstory_show = {
	if (!self.enemy || !(self.enemy.flags & FL_CLIENT)) return;

	self.enemy.suppressCenterPrint = TRUE;
	string msg;

	if (controller.mapvar && read_mapvar(controller.mapvar)){
		msg = controller.message2;
	}
	else {
		msg = controller.message;
	}

	centerprint_builtin(self.enemy, msg);

	if (!self.state) {
		if (controller.noise1 != "")
			sound(self.enemy, CHAN_BODY, controller.noise1, 1, ATTN_NORM);

		if (!(controller.spawnflags & TEXTSTORY_NOFADE))
			csf_fade(self.enemy, 160, '0 0 0', 1, 110);
	}


	self.state = 1;
};

//----------------------------------------

void() trigger_textstory_hide = {
	textstory_hide(self);

	self.pain_finished = 0;
	self.enemy = world;
	self.state = 0;
};

void() trigger_textstory_show = {
	textstory_show(self);	

	if (time > self.pain_finished)
		self.think = trigger_textstory_hide;
	else
		self.think = trigger_textstory_show;
	self.nextthink = time + 0.2;

};

void() trigger_textstory_touch = {
	
	if (!(other.flags & FL_CLIENT)) return;
	if (self.estate != STATE_ACTIVE) return;

	// don't show message if another player is already triggering it
	if (other != self.enemy && self.state == 1) return;

	if (self.mangle && !isInAngle(other.v_angle, self.mangle, self.view_ofs))
		return;

	if (!self.pain_finished) {
		self.pain_finished = time + self.wait;
	}

	if (self.attack_finished < time) {

		self.attack_finished = time + 0.1;
		self.enemy = other;

		trigger_textstory_show();
	}
};

void() trigger_textstory = {
	if (!SUB_InitEntity()) return;
	
	InitTrigger();
	self.touch = trigger_textstory_touch;

	if (self.view_ofs == '0 0 0')
		self.view_ofs = '90 90 0';

	if (self.noise1 == "")
		self.noise1 = "misc/talk.wav";

	if (self.noise2 == "")
		self.noise2 = "misc/null.wav";

	if (self.spawnflags & TEXTSTORY_SILENT) {
		self.noise1 = string_null;
		self.noise2 = string_null;
	}


	if (self.noise1 != "")
		precache_sound (self.noise1);
	if (self.noise2 != "")
		precache_sound (self.noise2);

	SUB_CheckWaiting();
};


//-----------------------------


void() target_textstory_helper_hide = {

	textstory_hide(self.owner);
	remove(self);
};

void() target_textstory_helper_show = {
	if (!self.enemy || !(self.enemy.flags & FL_CLIENT)) {
		remove(self);
		return;
	}

	textstory_show(self.owner);

	if (self.attack_finished < time) self.think = target_textstory_helper_hide;
	
	self.nextthink = time + 0.1;
};

void(entity tgt) target_textstory_spawn_helper = {
	entity e;

	e = spawn();
	e.classname = "target_textstory_helper";
	e.owner = self;
	e.think = target_textstory_helper_show;
	e.nextthink = time + 0.1;
	e.attack_finished = time + self.wait;
	e.enemy = tgt;
};

void() target_textstory_use = {

	if (!(activator.flags & FL_CLIENT)) return;
	if (self.estate != STATE_ACTIVE) return;
	
	entity t;

	if (self.spawnflags & TRIGGER_CENTERPRINTALL) {
		t = find(world, classname, "player");
		while (t) {
			target_textstory_spawn_helper(t);
			t = find(t, classname, "player");
		}
	}
	else
		target_textstory_spawn_helper(activator);
};

void() target_textstory = {
	if (!SUB_InitEntity()) return;
	
	if (self.noise1 == "")
		self.noise1 = "misc/talk.wav";
	
	if (self.noise2 == "")
		self.noise2 = "misc/null.wav";

	if (self.spawnflags & TEXTSTORY_SILENT) {
		self.noise1 = "";
		self.noise2 = "";
	}

	if (self.spawnflags & TEXTSTORY_NOFADE)
		self.spawnflags = self.spawnflags - TEXTSTORY_NOFADE;
	else
		self.spawnflags = self.spawnflags | TEXTSTORY_NOFADE;

	if (self.noise1 != "")
		precache_sound (self.noise1);
	if (self.noise2 != "")
		precache_sound (self.noise2);

	if (!self.wait)
		self.wait = 5;

	self.use = target_textstory_use;
};


/*
=============================================================

func_fade

=============================================================
*/

float FUNC_FADE_REVERSE = 1;
float FUNC_FADE_START_ON = 2;

void() func_fade = {
	if (!SUB_InitEntity()) return;
	

	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NOCLIP; 

	setmodel(self, self.model);

	self.alpha1 = defaultFl(self.alpha, 1);
	self.alpha2 += 0.000001;
	self.alpha = self.alpha2;

	self.waitmin = defaultFl(self.waitmin, 192);
	self.waitmax = defaultFl(self.waitmax, 384);

	// invert the distances if min > max
	if (self.waitmin > self.waitmax) {
		float tmpwait = self.waitmax;
		self.waitmax = self.waitmin;
		self.waitmin = tmpwait;
	}

	if (self.switchshadstyle) {
		lightstyle(self.switchshadstyle, lightstyle_fade_lookup(12));
	}

	self.think = func_fade_start;
	self.nextthink = time + 0.025;

	self.use = func_fade_use;
	self.th_setstate = func_fade_setstate;
	self.speed = zeroconvertdefault(self.speed, 1);
	
	// increment per think frame @ 40fps
	if (!self.speed) self.delay = 1;
	else self.delay = clamp(1/(self.speed / 0.025), 0, 1);

};

void() func_fade_start = {
	// default origin point for distance calculation
	self.dest = (self.absmin + self.absmax)/2;

	entity e;

	// custom origin point
	if (self.target != "") {
		e = find(world, targetname, self.target);

		if (e)
			self.dest = e.origin;
	}

	// light to fade in/out together
	if (self.target2 != "") {
		e = find(world, targetname, self.target2);

		if (e && e.style)
			self.style = e.style;
	}


	if (self.spawnflags & FUNC_FADE_START_ON) {
		func_fade_setfade(1);
		self.state = 1;
	}
	else
		func_fade_setfade(0);


	if (self.targetname == "") {
		self.think = func_fade_think_distance;
		self.nextthink = time + 0.05;
	}
	
};

void(float newstate, float stateflags) func_fade_setstate = {
	self.estate = newstate;
	if (self.targetname == "")
		func_fade_think_setstate();
}

void() func_fade_think_setstate = {
	float closest, perc, playerperc, dist;

	closest = 1000000000;

	entity pl = find(world, classname, "player");
	
	while (pl) {
		dist = vlen(pl.origin - self.dest);
		if (dist < closest) closest = dist;
		pl = find(pl, classname, "player");
	}

	playerperc = clamp(1 - (closest - self.waitmin)/(self.waitmax - self.waitmin), 0, 1);

	if (!self.estate) // going to on
		perc = self.light_lev + self.delay;
	else
		perc = self.light_lev - self.delay;

	func_fade_setfade(perc);

	if (perc <= 0 || perc >= 1 ||
		(perc >= playerperc && !self.estate)
		//|| (perc <= playerperc && self.estate)
	) {
		self.think = func_fade_think_distance;
		self.nextthink = time + 0.05;
	}
	else {
		self.think = func_fade_think_setstate;
		self.nextthink = time + 0.025;
	}

}

void() func_fade_think_distance = {

	if (self.estate != STATE_ACTIVE)
		return;

	self.nextthink = time + 0.05;

	float closest, dist, perc;
	
	closest = 1000000000;

	entity pl = find(world, classname, "player");
	
	while (pl) {
		dist = vlen(pl.origin - self.dest);
		if (dist < closest) closest = dist;
		pl = find(pl, classname, "player");
	}

	//dprint3("Distance: ", ftos(closest), "\n");
	if (closest < self.waitmax + 128) {
		perc = clamp(1 - (closest - self.waitmin)/(self.waitmax - self.waitmin), 0, 1);
		func_fade_setfade(perc);

		self.attack_finished = time + 0.2;
	}
	else if (time < self.attack_finished) {
		func_fade_setfade(0);
	}
	else self.nextthink = time + 0.2;

};


void() func_fade_use = {
	self.state = !self.state;
	//dprint3("State: ", ftos(self.state), "\n");
	func_fade_think_timed();
};

void() func_fade_think_timed = {
	float perc;

	if (self.state) // going to on
		perc = self.light_lev + self.delay;
	else
		perc = self.light_lev - self.delay;

	perc = clamp(perc, 0, 1);

	func_fade_setfade(perc);

	if (perc != 0 && perc != 1) {
		self.think = func_fade_think_timed;
		self.nextthink = time + 0.025;
	}
}

void(float perc) func_fade_setfade = {
	//dprint3("Percent: ", ftos(perc), "\n");
	self.light_lev = perc;

	if (self.spawnflags & FUNC_FADE_REVERSE) perc = 1 - perc;

	self.alpha = (self.alpha1 - self.alpha2) * perc + self.alpha2;

	if (self.style) {
		float step1 = rint(perc * 12);
		lightstyle(self.style, lightstyle_fade_lookup(step1));
	}

	if (self.switchshadstyle) {
		float step2 = rint((1 - perc) * 12);
		lightstyle(self.switchshadstyle, lightstyle_fade_lookup(step2));
	}
};



/*
=============================================================

target_skybox

=============================================================
*/

void(entity cl) skybox_apply = {
	dprint3("Applying skybox '", cl.sky, "' to client\n");
	stuffcmd(cl, "sky ");
	stuffcmd(cl, cl.sky);
	stuffcmd(cl, "\n");
};

void() target_skybox_use = {
	string skyname;
	if (!(activator.flags & FL_CLIENT) && !(self.spawnflags & 1))
		return;

	if (self.sky != "") skyname = self.sky;
	else skyname = world.sky;
	
	if (self.spawnflags & 1) {
		entity pl;
		pl = find(world, classname, "player");
		
		while (pl) {
			pl.sky = skyname;
			skybox_apply(pl);
			pl = find(pl, classname, "player");
		}
		return;
	}

	activator.sky = skyname;
	skybox_apply(activator);
};

void() target_skybox = {
	if (!SUB_InitEntity()) return;
	
	self.use = target_skybox_use;
};