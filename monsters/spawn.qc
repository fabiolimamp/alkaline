/*
==============================================================================

BLOB

==============================================================================
*/

$frame walk1 walk2 walk3 walk4  walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12 walk13 walk14 walk15 walk16 walk17 walk18 walk19
$frame walk20 walk21 walk22 walk23 walk24 walk25

$frame run1 run2 run3 run4 run5 run6  run7 run8 run9 run10 run11 run12 run13
$frame run14 run15 run16 run17 run18 run19 run20 run21 run22 run23
$frame run24 run25

$frame jump1 jump2 jump3 jump4 jump5 jump6

$frame fly1 fly2 fly3 fly4

$frame exp

void()	spwn_stand1	=[	$walk1,		spwn_stand1	] {ai_stand();};

void()	spwn_hang1		=[	$walk1,		spwn_hang1	] {ai_stand();};

void()	spwn_walk1	=[	$walk1,		spwn_walk2	] {ai_turn();};
void()	spwn_walk2	=[	$walk2,		spwn_walk3	] {ai_turn();};
void()	spwn_walk3	=[	$walk3,		spwn_walk4	] {ai_turn();};
void()	spwn_walk4	=[	$walk4,		spwn_walk5	] {ai_turn();};
void()	spwn_walk5	=[	$walk5,		spwn_walk6	] {ai_turn();};
void()	spwn_walk6	=[	$walk6,		spwn_walk7	] {ai_turn();};
void()	spwn_walk7	=[	$walk7,		spwn_walk8	] {ai_turn();};
void()	spwn_walk8	=[	$walk8,		spwn_walk9	] {ai_turn();};
void()	spwn_walk9	=[	$walk9,		spwn_walk10	] {ai_turn();};
void()	spwn_walk10	=[	$walk10,		spwn_walk11	] {ai_turn();};
void()	spwn_walk11	=[	$walk11,		spwn_walk12	] {ai_walk(2);};
void()	spwn_walk12	=[	$walk12,		spwn_walk13	] {ai_walk(2);};
void()	spwn_walk13	=[	$walk13,		spwn_walk14	] {ai_walk(2);};
void()	spwn_walk14	=[	$walk14,		spwn_walk15	] {ai_walk(2);};
void()	spwn_walk15	=[	$walk15,		spwn_walk16	] {ai_walk(2);};
void()	spwn_walk16	=[	$walk16,		spwn_walk17	] {ai_walk(2);};
void()	spwn_walk17	=[	$walk17,		spwn_walk18	] {ai_walk(2);};
void()	spwn_walk18	=[	$walk18,		spwn_walk19	] {ai_walk(2);};
void()	spwn_walk19	=[	$walk19,		spwn_walk20	] {ai_walk(2);};
void()	spwn_walk20	=[	$walk20,		spwn_walk21	] {ai_walk(2);};
void()	spwn_walk21	=[	$walk21,		spwn_walk22	] {ai_walk(2);};
void()	spwn_walk22	=[	$walk22,		spwn_walk23	] {ai_walk(2);};
void()	spwn_walk23	=[	$walk23,		spwn_walk24	] {ai_walk(2);};
void()	spwn_walk24	=[	$walk24,		spwn_walk25	] {ai_walk(2);};
void()	spwn_walk25	=[	$walk25,		spwn_walk1	] {ai_walk(2);};

void()	spwn_run1	=[	$run1,		spwn_run2	] {ai_face();};
void()	spwn_run2	=[	$run2,		spwn_run3	] {ai_face();};
void()	spwn_run3	=[	$run3,		spwn_run4	] {ai_face();};
void()	spwn_run4	=[	$run4,		spwn_run5	] {ai_face();};
void()	spwn_run5	=[	$run5,		spwn_run6	] {ai_face();};
void()	spwn_run6	=[	$run6,		spwn_run7	] {ai_face();};
void()	spwn_run7	=[	$run7,		spwn_run8	] {ai_face();};
void()	spwn_run8	=[	$run8,		spwn_run9	] {ai_face();};
void()	spwn_run9	=[	$run9,		spwn_run10	] {ai_face();};
void()	spwn_run10	=[	$run10,		spwn_run11	] {ai_face();};
void()	spwn_run11	=[	$run11,		spwn_run12	] {ai_run(2);};
void()	spwn_run12	=[	$run12,		spwn_run13	] {ai_run(2);};
void()	spwn_run13	=[	$run13,		spwn_run14	] {ai_run(2);};
void()	spwn_run14	=[	$run14,		spwn_run15	] {ai_run(2);};
void()	spwn_run15	=[	$run15,		spwn_run16	] {ai_run(2);};
void()	spwn_run16	=[	$run16,		spwn_run17	] {ai_run(2);};
void()	spwn_run17	=[	$run17,		spwn_run18	] {ai_run(2);};
void()	spwn_run18	=[	$run18,		spwn_run19	] {ai_run(2);};
void()	spwn_run19	=[	$run19,		spwn_run20	] {ai_run(2);};
void()	spwn_run20	=[	$run20,		spwn_run21	] {ai_run(2);};
void()	spwn_run21	=[	$run21,		spwn_run22	] {ai_run(2);};
void()	spwn_run22	=[	$run22,		spwn_run23	] {ai_run(2);};
void()	spwn_run23	=[	$run23,		spwn_run24	] {ai_run(2);};
void()	spwn_run24	=[	$run24,		spwn_run25	] {ai_run(2);};
void()	spwn_run25	=[	$run25,		spwn_run1	] {ai_run(2);};


//============================================================================


void()	spwn_jump1;

void()	Tar_JumpTouch =
{
	local	float	ldmg;

	if (other.takedamage && other.classname != self.classname)
	{
		if ( vlen(self.velocity) > 400 )
		{
			ldmg = 10 + 10*random();
			T_Damage(other, self, self, ldmg, DMGTYPE_MELEE);	
			sound (self, CHAN_WEAPON, "blob/hit1.wav", 1, ATTN_NORM);
		}
	}
	else
		sound (self, CHAN_WEAPON, "blob/land1.wav", 1, ATTN_NORM);


	if (!checkbottom(self))
	{
		if (self.flags & FL_ONGROUND)
		{	// jump randomly to not get hung up
//dprint ("popjump\n");
	self.touch = SUB_Null;
	self.think = spwn_run1;
	self.movetype = MOVETYPE_STEP;
	self.nextthink = time + 0.1;

//			self.velocity_x = (random() - 0.5) * 600;
//			self.velocity_y = (random() - 0.5) * 600;
//			self.velocity_z = 200;
//			self.flags = self.flags - FL_ONGROUND;
		}
		return;	// not on ground yet
	}

	self.touch = SUB_Null;
	self.think = spwn_jump1;
	self.nextthink = time + 0.1;
};

void()	spwn_jump5;

void()	spwn_fly1		=[	$fly1,	spwn_fly2	] {};
void()	spwn_fly2		=[	$fly2,	spwn_fly3	] {};
void()	spwn_fly3		=[	$fly3,	spwn_fly4	] {};
void()	spwn_fly4		=[	$fly4,	spwn_fly1	] {
self.cnt = self.cnt + 1;
if (self.cnt == 4)
{
//dprint ("spawn hop\n");
spwn_jump5 ();
}
};

void()	spwn_jump1		=[	$jump1,	spwn_jump2		] {ai_face();};
void()	spwn_jump2		=[	$jump2,	spwn_jump3		] {ai_face();};
void()	spwn_jump3		=[	$jump3,	spwn_jump4		] {ai_face();};
void()	spwn_jump4		=[	$jump4,	spwn_jump5		] {ai_face();};
void()	spwn_jump5		=[	$jump5,	spwn_jump6		]
{	
	self.movetype = MOVETYPE_BOUNCE;
	self.touch = Tar_JumpTouch;
	makevectors (self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = v_forward * 600 + '0 0 200';
	self.velocity_z = self.velocity_z + random()*150;
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
	self.cnt = 0;
};
void()	spwn_jump6	=[	$jump6,spwn_fly1	] {};



//=============================================================================

void()	spwn_die1	=[	$exp,		spwn_die2	] {
self.takedamage = DAMAGE_NO;
};
void()	spwn_die2	=[	$exp,		spwn_run1	] 
{
	T_RadiusDamage (self, self, 120, 1, world, DMGTYPE_EXPLOSION);

	sound (self, CHAN_VOICE, "blob/death1.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_TAREXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	
	TriggerExplosion();
	SUB_Hide();
	self.deadflag = DEAD_GIBBED;
};

void() spwn_sight = {
	sound (self, CHAN_VOICE, "blob/sight1.wav", 1, ATTN_NORM);
};

//=============================================================================


/*QUAKED monster_spawn (1 0 0) (-16 -16 -24) (16 16 24) Ambush
*/
void(entity e) monster_spawn_start =
{
	local entity oself;

	oself = self;
	self = e;
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/tarbaby.mdl");

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	self.health = 80;
	if (self.obituary == "") self.obituary = "was slimed by a Spawn";

	self.th_stand = spwn_stand1;
	self.th_walk = spwn_walk1;
	self.th_run = spwn_run1;
	self.th_missile = spwn_jump1;
	self.th_melee = spwn_jump1;
	self.th_die = spwn_die1;
	self.th_sight = spwn_sight;
	
	walkmonster_start ();

	self = oself;
};

void() monster_spawn_spawner = {
	monster_spawner(monster_spawn_start);
};


void() monster_spawn =
{
	if (!SUB_InitEntity()) return;
	
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model2 ("progs/tarbaby.mdl");

	precache_sound2 ("blob/death1.wav");
	precache_sound2 ("blob/hit1.wav");
	precache_sound2 ("blob/land1.wav");
	precache_sound2 ("blob/sight1.wav");

	self.cmins = '-16 -16 -24';
	self.cmaxs = '16 16 40';

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_spawn_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_spawn_start(self);
	}
};

void() monster_tarbaby = {
	monster_spawn();
}