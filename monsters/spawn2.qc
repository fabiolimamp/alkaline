/*
==============================================================================

SPAWN 2

==============================================================================


if enemy closer than 192
- jump

if on floor or ceiling (surface angles dot product vs '0 0 1' < 0.5):
- if random < 10%
  - traceline up. If <= 256 jump to ceiling
- else
  - if random < 5% start moving to a side
  - else move horizontally towards enemy
- adjust height to be on surface

if on wall (surface angles_x between -30 and 30)
- if moving vertically
  - move vertically until it hits a floor or ceiling
- if not moving vertically, move horizontally towards enemy while sticking to the wall surface
  - if linear distance didn't reduce for 5 consecutive frames:
    - trace up and down towards the first horizontal surface
    - whichever is close, initiate move towards it

*/

void(float dist) spwn2_run = {
	makevectors_angles(self.angles);
	traceline(self.origin + v_up, self.origin - v_up*16, FALSE, self);

	if (trace_fraction == 1 || trace_ent.solid != SOLID_BSP)
		return;
	
	vector surfnormal = trace_plane_normal;
	vector surfangle = vectoangles(surfnormal);
	vector surfpos = trace_endpos;

	if (surfnormal * '0 0 1' >= 0.5) {
		
		if (random() < 0.1) {
			traceline(self.origin, self.origin + '0 0 250', FALSE, self);
			if (trace_fraction < 1 && trace_ent.solid == SOLID_BSP) {
				self.velocity_z = 200;
				self.touch = spwn2_vertjump_touch;
				return;
			}
		}



	}
}


void() spwn2_vertjump_touch = {

}

$frame walk1 walk2 walk3 walk4  walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12 walk13 walk14 walk15 walk16 walk17 walk18 walk19
$frame walk20 walk21 walk22 walk23 walk24 walk25

$frame run1 run2 run3 run4 run5 run6  run7 run8 run9 run10 run11 run12 run13
$frame run14 run15 run16 run17 run18 run19 run20 run21 run22 run23
$frame run24 run25

$frame jump1 jump2 jump3 jump4 jump5 jump6

$frame fly1 fly2 fly3 fly4

$frame exp

void()	spwn2_stand1	=[	$walk1,		spwn2_stand1	] {ai_stand();};

void()	spwn2_hang1		=[	$walk1,		spwn2_hang1	] {ai_stand();};

void()	spwn2_walk1	=[	$walk1,		spwn2_walk2	] {ai_turn();};
void()	spwn2_walk2	=[	$walk2,		spwn2_walk3	] {ai_turn();};
void()	spwn2_walk3	=[	$walk3,		spwn2_walk4	] {ai_turn();};
void()	spwn2_walk4	=[	$walk4,		spwn2_walk5	] {ai_turn();};
void()	spwn2_walk5	=[	$walk5,		spwn2_walk6	] {ai_turn();};
void()	spwn2_walk6	=[	$walk6,		spwn2_walk7	] {ai_turn();};
void()	spwn2_walk7	=[	$walk7,		spwn2_walk8	] {ai_turn();};
void()	spwn2_walk8	=[	$walk8,		spwn2_walk9	] {ai_turn();};
void()	spwn2_walk9	=[	$walk9,		spwn2_walk10	] {ai_turn();};
void()	spwn2_walk10	=[	$walk10,		spwn2_walk11	] {ai_turn();};
void()	spwn2_walk11	=[	$walk11,		spwn2_walk12	] {ai_walk(2);};
void()	spwn2_walk12	=[	$walk12,		spwn2_walk13	] {ai_walk(2);};
void()	spwn2_walk13	=[	$walk13,		spwn2_walk14	] {ai_walk(2);};
void()	spwn2_walk14	=[	$walk14,		spwn2_walk15	] {ai_walk(2);};
void()	spwn2_walk15	=[	$walk15,		spwn2_walk16	] {ai_walk(2);};
void()	spwn2_walk16	=[	$walk16,		spwn2_walk17	] {ai_walk(2);};
void()	spwn2_walk17	=[	$walk17,		spwn2_walk18	] {ai_walk(2);};
void()	spwn2_walk18	=[	$walk18,		spwn2_walk19	] {ai_walk(2);};
void()	spwn2_walk19	=[	$walk19,		spwn2_walk20	] {ai_walk(2);};
void()	spwn2_walk20	=[	$walk20,		spwn2_walk21	] {ai_walk(2);};
void()	spwn2_walk21	=[	$walk21,		spwn2_walk22	] {ai_walk(2);};
void()	spwn2_walk22	=[	$walk22,		spwn2_walk23	] {ai_walk(2);};
void()	spwn2_walk23	=[	$walk23,		spwn2_walk24	] {ai_walk(2);};
void()	spwn2_walk24	=[	$walk24,		spwn2_walk25	] {ai_walk(2);};
void()	spwn2_walk25	=[	$walk25,		spwn2_walk1	] {ai_walk(2);};

void()	spwn2_run1	=[	$run1,		spwn2_run2	] {ai_face();};
void()	spwn2_run2	=[	$run2,		spwn2_run3	] {ai_face();};
void()	spwn2_run3	=[	$run3,		spwn2_run4	] {ai_face();};
void()	spwn2_run4	=[	$run4,		spwn2_run5	] {ai_face();};
void()	spwn2_run5	=[	$run5,		spwn2_run6	] {ai_face();};
void()	spwn2_run6	=[	$run6,		spwn2_run7	] {ai_face();};
void()	spwn2_run7	=[	$run7,		spwn2_run8	] {ai_face();};
void()	spwn2_run8	=[	$run8,		spwn2_run9	] {ai_face();};
void()	spwn2_run9	=[	$run9,		spwn2_run10	] {ai_face();};
void()	spwn2_run10	=[	$run10,		spwn2_run11	] {ai_face();};
void()	spwn2_run11	=[	$run11,		spwn2_run12	] {ai_run(2);};
void()	spwn2_run12	=[	$run12,		spwn2_run13	] {ai_run(2);};
void()	spwn2_run13	=[	$run13,		spwn2_run14	] {ai_run(2);};
void()	spwn2_run14	=[	$run14,		spwn2_run15	] {ai_run(2);};
void()	spwn2_run15	=[	$run15,		spwn2_run16	] {ai_run(2);};
void()	spwn2_run16	=[	$run16,		spwn2_run17	] {ai_run(2);};
void()	spwn2_run17	=[	$run17,		spwn2_run18	] {ai_run(2);};
void()	spwn2_run18	=[	$run18,		spwn2_run19	] {ai_run(2);};
void()	spwn2_run19	=[	$run19,		spwn2_run20	] {ai_run(2);};
void()	spwn2_run20	=[	$run20,		spwn2_run21	] {ai_run(2);};
void()	spwn2_run21	=[	$run21,		spwn2_run22	] {ai_run(2);};
void()	spwn2_run22	=[	$run22,		spwn2_run23	] {ai_run(2);};
void()	spwn2_run23	=[	$run23,		spwn2_run24	] {ai_run(2);};
void()	spwn2_run24	=[	$run24,		spwn2_run25	] {ai_run(2);};
void()	spwn2_run25	=[	$run25,		spwn2_run1	] {ai_run(2);};


//============================================================================



void()	spwn2_JumpTouch =
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
	self.think = spwn2_run1;
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
	self.think = spwn2_jump1;
	self.nextthink = time + 0.1;
};

void()	spwn2_jump5;

void()	spwn2_fly1		=[	$fly1,	spwn2_fly2	] {};
void()	spwn2_fly2		=[	$fly2,	spwn2_fly3	] {};
void()	spwn2_fly3		=[	$fly3,	spwn2_fly4	] {};
void()	spwn2_fly4		=[	$fly4,	spwn2_fly1	] {
self.cnt = self.cnt + 1;
if (self.cnt == 4)
{
//dprint ("spawn hop\n");
spwn2_jump5 ();
}
};

void()	spwn2_jump1		=[	$jump1,	spwn2_jump2		] {ai_face();};
void()	spwn2_jump2		=[	$jump2,	spwn2_jump3		] {ai_face();};
void()	spwn2_jump3		=[	$jump3,	spwn2_jump4		] {ai_face();};
void()	spwn2_jump4		=[	$jump4,	spwn2_jump5		] {ai_face();};
void()	spwn2_jump5		=[	$jump5,	spwn2_jump6		]
{	
	self.movetype = MOVETYPE_BOUNCE;
	self.touch = spwn2_JumpTouch;
	makevectors (self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = v_forward * 600 + '0 0 200';
	self.velocity_z = self.velocity_z + random()*150;
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
	self.cnt = 0;
};
void()	spwn2_jump6	=[	$jump6,spwn2_fly1	] {};



//=============================================================================

void()	spwn2_die1	=[	$exp,		spwn2_die2	] {
self.takedamage = DAMAGE_NO;
};
void()	spwn2_die2	=[	$exp,		spwn2_run1	] 
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

void() spwn2_sight = {
	sound (self, CHAN_VOICE, "blob/sight1.wav", 1, ATTN_NORM);
};

//=============================================================================


/*QUAKED monster_spawn (1 0 0) (-16 -16 -24) (16 16 24) Ambush
*/
void(entity e) monster_spawn2_start =
{
	local entity oself;

	oself = self;
	self = e;
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_FLY;

	setmodel (self, "progs/tarbaby.mdl");

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	self.health = 80;
	if (self.obituary == "") self.obituary = "was slimed by a Spawn";

	self.th_stand = spwn2_stand1;
	self.th_walk = spwn2_walk1;
	self.th_run = spwn2_run1;
	self.th_missile = spwn2_jump1;
	self.th_melee = spwn2_jump1;
	self.th_die = spwn2_die1;
	self.th_sight = spwn2_sight;
	
	walkmonster_start ();

	self = oself;
};

void() monster_spawn2_spawner = {
	monster_spawner(monster_spawn_start);
};


void() monster_spawn2 =
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
		self.use = monster_spawn2_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_spawn2_start(self);
	}
};


