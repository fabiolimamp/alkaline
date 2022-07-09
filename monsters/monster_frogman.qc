void() harpoon;
void() frogmen_outcontrol;


void(vector where) make_bub = {
	local entity bubble;
	bubble = spawn();
	setmodel(bubble, "progs/s_bubble.spr");
	setorigin(bubble, where);
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity_z = 10 + random() * 10;
	bubble.touch = bubble_remove;
	bubble.classname = "bubble";
	setsize(bubble, '-8 -8 -8', '8 8 8');
	bubble.nextthink = time;
	bubble.think = bubble_bob;
};

void() frogmen_fire1 = [20, frogmen_fire2]{self.yaw_speed = 20; ai_face();};
void() frogmen_fire2 = [21, frogmen_fire3]{ai_face();};
void() frogmen_fire3 = [22, frogmen_fire4]{ai_face();};
void() frogmen_fire4 = [23, frogmen_fire5]{ai_face();};
void() frogmen_fire5 = [24, frogmen_fire6]{ai_face();};
void() frogmen_fire6 = [19, frogmen_fire7]{ai_face();};
void() frogmen_fire7 = [18, frogmen_fire8]{ai_face();};
void() frogmen_fire8 = [17, frogmen_fire9]{harpoon();};
void() frogmen_fire9 = [16, frogmen_fire10]{ai_face();};
void() frogmen_fire10 = [15, frogmen_fire11]{ai_face();};
void() frogmen_fire11 = [16, frogmen_fire12]{ai_face();sound(self, CHAN_VOICE, "frogman/shot3.wav", 1, ATTN_NORM);};
void() frogmen_fire12 = [17, frogmen_fire13]{ai_face();};
void() frogmen_fire13 = [18, frogmen_fire14]{ai_face();};
void() frogmen_fire14 = [19, frogman_down1]{ai_face();};
//void() frogmen_fire10 = [18, frogman_down1]{ai_face();self.yaw_speed = 10;};

void() frogman_down1 = [34, frogman_down2]{};
void() frogman_down2 = [35, frogman_down3]{};
void() frogman_down3 = [36, frogman_down4]{};
void() frogman_down4 = [37, frogman_down5]{};
void() frogman_down5 = [38, frogmen_run1]{};

void() frogmen_fire = {
	if (random() < 0.8)	frogmen_fire1();
	else frogmen_run1();
};

void() frogmen_stand1 = [19, frogmen_stand2]
{
	ai_stand();
	if (random() < 0.2 && !(self.spawnflags & MONSTER_NOIDLESOUND && !self.enemy))
	{
		sound(self, CHAN_VOICE, "frogman/idle.wav", 1, ATTN_IDLE);
	}
};
void() frogmen_stand2 = [20, frogmen_stand3]{ai_stand();};
void() frogmen_stand3 = [21, frogmen_stand4]{ai_stand();};
void() frogmen_stand4 = [22, frogmen_stand5]{ai_stand();};
void() frogmen_stand5 = [23, frogmen_stand6]{ai_stand();};
void() frogmen_stand6 = [24, frogmen_stand7]{ai_stand();};
void() frogmen_stand7 = [25, frogmen_stand8]{ai_stand();};
void() frogmen_stand8 = [26, frogmen_stand9]{ai_stand();};
void() frogmen_stand9 = [27, frogmen_stand1]{ai_stand();};

void() frogmen_walk1 = [0, frogmen_walk2]
{
	ai_walk(8);
	if (random() < 0.2)
	{
		sound(self, CHAN_VOICE, "frogman/idle.wav", 1, ATTN_IDLE);
	}
};
void() frogmen_walk2 = [1, frogmen_walk3]{ai_walk(8);};
void() frogmen_walk3 = [2, frogmen_walk4]{ai_walk(8);};
void() frogmen_walk4 = [3, frogmen_walk5]{ai_walk(8);};
void() frogmen_walk5 = [4, frogmen_walk6]{ai_walk(8);};
void() frogmen_walk6 = [5, frogmen_walk7]{ai_walk(8);};
void() frogmen_walk7 = [6, frogmen_walk8]{ai_walk(8);};
void() frogmen_walk8 = [7, frogmen_walk1]{ai_walk(8);};

void() frogmen_run1 = [0, frogmen_run2]
{
	ai_forward(20);
	ai_face();
	if (random() < 0.5)
	{
		sound(self, CHAN_VOICE, "frogman/swim.wav", 1, ATTN_IDLE);
	}
};
void() frogmen_run2 = [1, frogmen_run3]{ai_forward(20);sound(self, CHAN_VOICE, "frogman/swim.wav", 1, ATTN_IDLE);};
void() frogmen_run3 = [2, frogmen_run4]{ai_forward(20);};
void() frogmen_run4 = [3, frogmen_run5]{ai_forward(18);};
void() frogmen_run5 = [4, frogmen_run6]{ai_run(22);};
void() frogmen_run6 = [5, frogmen_run7]{ai_run(19);};
void() frogmen_run7 = [6, frogmen_run8]{ai_run(20);};
void() frogmen_run8 = [7, frogmen_run1]{ai_run(19);};

void() frogmen_death1 = [39, frogmen_death2]{sound(self, CHAN_VOICE, "frogman/death.wav", 1, ATTN_NORM);};
void() frogmen_death2 = [40, frogmen_death3]{self.solid = SOLID_TRIGGER; setorigin(self, self.origin);};
void() frogmen_death3 = [41, frogmen_death4]{};
void() frogmen_death4 = [42, frogmen_death5]{};
void() frogmen_death5 = [43, frogmen_death6]{};
void() frogmen_death6 = [44, frogmen_death7]{};
void() frogmen_death7 = [45, frogmen_death8]{};
void() frogmen_death8 = [46, frogmen_death9]{};
void() frogmen_death9 = [47, frogmen_death10]{};
void() frogmen_death10 = [48, frogmen_death11]{};
void() frogmen_death11 = [49, frogmen_death11]{self.think = SUB_MakeNotSolid; self.nextthink = time + 5;};

void() frogmen_pain1 = [28, frogmen_pain2]{};
void() frogmen_pain2 = [29, frogmen_pain3]{ai_pain(1);};
void() frogmen_pain3 = [30, frogmen_pain4]{ai_pain(1);};
void() frogmen_pain4 = [31, frogmen_pain5]{};
void() frogmen_pain5 = [32, frogmen_run1]{};

void(entity attacker, float damage) frogmen_pain = 
{

	if (self.health < self.max_health * 0.4)	self.skin = 2;
	else if (self.health < self.max_health * 0.8)	self.skin = 1;

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 3;
	
	if (random() < 0.5)
		sound(self, CHAN_VOICE, "frogman/pain1.wav", 1, ATTN_NORM);
	else
		sound(self, CHAN_VOICE, "frogman/pain2.wav", 1, ATTN_NORM);

	frogmen_pain1();
};

void() poon_bang = 
{
	if (other == self.owner)
		return;

	self.velocity = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	if (pointcontents(self.origin) == CONTENT_SKY) {
		remove(self);
		return;
	}
	sound(self, CHAN_WEAPON, "frogman/impact.wav", 1, ATTN_NORM);
	if (other.health)
	{
		T_Damage(other, self, self.owner, 30, DMGTYPE_BALLISTIC);
		remove(self);
	}
};

void() harpoon = {
	local vector trace1;
	local entity harp;
	harp = spawn();
	harp.movetype = MOVETYPE_FLYMISSILE;
	harp.owner = self;
	harp.solid = SOLID_BBOX;
	trace1 = normalize(self.origin - self.enemy.origin);
	harp.velocity = trace1 * -1000;
	harp.angles = vectoangles(trace1 * -1);
	harp.touch = poon_bang;
	harp.nextthink = time + 5;
	harp.think = SUB_Remove;
	harp.flags = harp.flags | FL_PROJECTILE;
	setmodel(harp, "progs/harpoon.mdl");
	harp.skin = 1;
	setsize(harp, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(harp, self.origin + + v_right * -8 + v_forward * 14 + '0 0 14');
};

void() spinup1 = [56, spinup2]
{
	self.velocity_z = 400;
	self.touch = frogmen_outcontrol;
	make_bub(self.origin);
};

void() spinup2 = [57, spinup3]
{
	self.velocity_z = 400;
	make_bub(self.origin);
};

void() spinup3 = [58, spinup4]
{
	self.velocity_z = 400;
	make_bub(self.origin);
};

void() spinup4 = [59, spinup1]
{
	self.velocity_z = 400;
	make_bub(self.origin);
};

void() spinover1 = [50, spinover2]
{
	self.velocity = self.old_angles;
	self.touch = frogmen_outcontrol;
	make_bub(self.origin);
};

void() spinover2 = [51, spinover3]
{
	self.velocity = self.old_angles;
	make_bub(self.origin);
};

void() spinover3 = [52, spinover4]
{
	self.velocity = self.old_angles;
	make_bub(self.origin);
};

void() spinover4 = [53, spinover5]
{
	self.velocity = self.old_angles;
	make_bub(self.origin);
};

void() spinover5 = [54, spinover6]
{
	self.velocity = self.old_angles;
	make_bub(self.origin);
};

void() spinover6 = [55, spinover1]
{
	self.velocity = self.old_angles;
	make_bub(self.origin);
};

void() frogmen_end_all = {
	if (other == world)
	{
		self.movetype = MOVETYPE_NONE;
		self.think = SUB_Null;
	}
};

void() frogmen_outcontrol = 
{
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_BOUNCE;
	self.touch = frogmen_end_all;
	frogmen_death1();
};

void() frogmen_die = 
{
	local float r;
	if (self.health < -50) {
		self.skin = 0;
		sound(self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead("progs/h_zombie.mdl", self.health);
		ThrowGib("progs/gib1.mdl", self.health);
		ThrowGib("progs/gib1.mdl", self.health);
		ThrowGib("progs/gib2.mdl", self.health);
		ThrowGib("progs/gib3.mdl", self.health);
		ThrowGib("progs/gib3.mdl", self.health);
		return;
	}
	self.skin = 3;

	if (self.health > -30) {
		frogmen_death1();
	}
	else {
		r = random();
		if (r < 0.5) {
			spinup1();
		}
		else {
			self.angles_y = (0.5 - random()) * 360;
			self.angles_x = 0;
			self.angles_z = 0;
			makevectors(self.angles);
			self.old_angles = v_forward * 400 + v_forward * random() * 200;
			spinover1();
		}
	}
};


void() frogmen_sight = {
	sound(self, CHAN_VOICE, "frogman/sight.wav", 1, ATTN_NORM);
};

void(entity e) monster_frogman_start = 
{
	local entity oself;

	oself = self;
	self = e;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel(self, "progs/frogman.mdl");
	
	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);

	self.health = 100;
	if (self.obituary == "") self.obituary = "was harpooned by a Frogman";

	self.th_stand = frogmen_stand1;
	self.th_walk = frogmen_walk1;
	self.th_run = frogmen_run1;
	self.th_die = frogmen_die;
	self.th_pain = frogmen_pain;
	self.th_missile = frogmen_fire;
	self.th_melee = frogmen_fire1;
	self.th_sight = frogmen_sight;

	swimmonster_start();

	self = oself;
};

void() monster_frogman_spawner = {
	monster_spawner(monster_frogman_start);
};

void() monster_frogman = 
{
	if (deathmatch){
		remove(self);
		return;
	}

	precache_model("progs/frogman.mdl");
	precache_model("progs/harpoon.mdl");
	precache_model ("progs/h_zombie.mdl");
	precache_model ("progs/gib1.mdl");
	precache_model ("progs/gib2.mdl");
	precache_model ("progs/gib3.mdl");
	precache_sound("frogman/sight.wav");
	precache_sound("frogman/pain1.wav");
	precache_sound("frogman/pain2.wav");
	precache_sound("frogman/swim.wav");
	precache_sound("frogman/idle.wav");
	precache_sound("frogman/shot3.wav");
	precache_sound("frogman/death.wav");
	precache_sound("frogman/impact.wav");

	self.cmins = '-16 -16 -24';
	self.cmaxs = '16 16 40';

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_frogman_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_frogman_start(self);
	}
};

