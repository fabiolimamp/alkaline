void() harpoon;
void() OutControl;


void(vector where) make_bub = 
{
	local entity bubble;
	bubble = spawn();
	setmodel(bubble, "progs/s_bubble.spr");
	setorigin(bubble, where);
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity_z = SVC_SETVIEWANGLES + random() * SVC_SETVIEWANGLES;
	bubble.touch = bubble_remove;
	bubble.classname = "bubble";
	setsize(bubble, '-8 -8 -8', '8 8 8');
	bubble.nextthink = time;
	bubble.think = bubble_bob;
};

void() frogmen_fire1 = [20, frogmen_fire2]{ai_face();};
void() frogmen_fire2 = [21, frogmen_fire3]{ai_face();};
void() frogmen_fire3 = [22, frogmen_fire4]{ai_face();};
void() frogmen_fire4 = [23, frogmen_fire5]{ai_face();};
void() frogmen_fire5 = [24, frogmen_fire6]{ai_face();};
void() frogmen_fire6 = [19, frogmen_fire7]{ai_face();};
void() frogmen_fire7 = [18, frogmen_fire8]{ai_face();};
void() frogmen_fire8 = [17, frogmen_fire9]{harpoon();};
void() frogmen_fire9 = [16, frogmen_fire10]{ai_face();};
void() frogmen_fire10 = [15, frogmen_fire11]{ai_face();};
void() frogmen_fire11 = [16, frogmen_fire12]{ai_face();sound(self, CHAN_VOICE, "frogman/shot3.wav", SPAWNFLAG_SUPERSPIKE, ATTN_NORM);};
void() frogmen_fire12 = [17, frogmen_fire13]{ai_face();};
void() frogmen_fire13 = [18, frogmen_fire14]{ai_face();};
void() frogmen_fire14 = [19, frogman_down1]{ai_face();};
//void() frogmen_fire10 = [18, frogman_down1]{ai_face();};

void() frogman_down1 = [34, frogman_down2]{};
void() frogman_down2 = [35, frogman_down3]{};
void() frogman_down3 = [36, frogman_down4]{};
void() frogman_down4 = [37, frogman_down5]{};
void() frogman_down5 = [38, frogmen_run1]{};

void() frogmen_fire = 
{
	if (random() < 0.4)
	{
		frogmen_fire1();
	}
	else
	{
		frogmen_run1();
	}
};

void() frogmen_stand1 = [19, frogmen_stand2]
{
	ai_stand();
	if (random() < 0.2)
	{
		sound(self, CHAN_VOICE, "frogman/idle.wav", SPAWNFLAG_SUPERSPIKE, ATTN_IDLE);
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
	ai_walk(SECRET_NO_SHOOT);
	if (random() < 0.2)
	{
		sound(self, CHAN_VOICE, "frogman/idle.wav", SPAWNFLAG_SUPERSPIKE, ATTN_IDLE);
	}
};
void() frogmen_walk2 = [1, frogmen_walk3]{ai_walk(SECRET_NO_SHOOT);};
void() frogmen_walk3 = [2, frogmen_walk4]{ai_walk(SECRET_NO_SHOOT);};
void() frogmen_walk4 = [3, frogmen_walk5]{ai_walk(SECRET_NO_SHOOT);};
void() frogmen_walk5 = [4, frogmen_walk6]{ai_walk(SECRET_NO_SHOOT);};
void() frogmen_walk6 = [5, frogmen_walk7]{ai_walk(SECRET_NO_SHOOT);};
void() frogmen_walk7 = [6, frogmen_walk8]{ai_walk(SECRET_NO_SHOOT);};
void() frogmen_walk8 = [7, frogmen_walk1]{ai_walk(SECRET_NO_SHOOT);};

void() frogmen_run1 = [0, frogmen_run2]
{
	ai_forward(20);
	ai_face();
	if (random() < 0.5)
	{
		sound(self, CHAN_VOICE, "frogman/swim.wav", SPAWNFLAG_SUPERSPIKE, ATTN_IDLE);
	}
};
void() frogmen_run2 = [1, frogmen_run3]{ai_forward(20);sound(self, CHAN_VOICE, "frogman/swim.wav", SPAWNFLAG_SUPERSPIKE, ATTN_IDLE);};
void() frogmen_run3 = [2, frogmen_run4]{ai_forward(20);};
void() frogmen_run4 = [3, frogmen_run5]{ai_forward(18);};
void() frogmen_run5 = [4, frogmen_run6]{ai_run(22);};
void() frogmen_run6 = [5, frogmen_run7]{ai_run(19);};
void() frogmen_run7 = [6, frogmen_run8]{ai_run(20);};
void() frogmen_run8 = [7, frogmen_run1]{ai_run(19);};

void() frogmen_death1 = [39, frogmen_death2]{sound(self, CHAN_VOICE, "frogman/death.wav", SPAWNFLAG_SUPERSPIKE, ATTN_NORM);};
void() frogmen_death2 = [40, frogmen_death3]{self.solid = SOLID_NOT;};
void() frogmen_death3 = [41, frogmen_death4]{};
void() frogmen_death4 = [42, frogmen_death5]{};
void() frogmen_death5 = [43, frogmen_death6]{};
void() frogmen_death6 = [44, frogmen_death7]{};
void() frogmen_death7 = [45, frogmen_death8]{};
void() frogmen_death8 = [46, frogmen_death9]{};
void() frogmen_death9 = [47, frogmen_death10]{};
void() frogmen_death10 = [48, frogmen_death11]{};
void() frogmen_death11 = [49, frogmen_death11]{};

void() frogmen_pain1 = [28, frogmen_pain2]{};
void() frogmen_pain2 = [29, frogmen_pain3]{ai_pain(SPAWNFLAG_SUPERSPIKE);};
void() frogmen_pain3 = [30, frogmen_pain4]{ai_pain(SPAWNFLAG_SUPERSPIKE);};
void() frogmen_pain4 = [31, frogmen_pain5]{};
void() frogmen_pain5 = [32, frogmen_run1]{};

void(entity attacker, float damage) frogmen_pain = 
{
	if (self.pain_finished > time)
	{
		return;
	}
	self.pain_finished = time + AS_MELEE;
	if (random() < 0.5)
	{
		sound(self, CHAN_VOICE, "frogman/pain1.wav", SPAWNFLAG_SUPERSPIKE, ATTN_NORM);
	}
	else
	{
		sound(self, CHAN_VOICE, "frogman/pain2.wav", SPAWNFLAG_SUPERSPIKE, ATTN_NORM);
	}
	frogmen_pain1();
};

void() poon_bang = 
{
	if (other == self.owner)
	{
		return;
	}
	self.velocity = VEC_ORIGIN;
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	sound(self, CHAN_WEAPON, "frogman/impact.wav", SPAWNFLAG_SUPERSPIKE, ATTN_NORM);
	if (other.health)
	{
		T_Damage(other, self, self.owner, SVC_INTERMISSION);
		remove(self);
	}
};

void() harpoon = 
{
	local vector trace1;
	local entity harp;
	harp = spawn();
	harp.movetype = MOVETYPE_FLYMISSILE;
	harp.owner = self;
	harp.solid = SOLID_BBOX;
	trace1 = normalize(self.origin - self.enemy.origin);
	harp.velocity = trace1 * -1000;
	harp.angles = vectoangles(trace1 * CONTENT_EMPTY);
	harp.touch = poon_bang;
	harp.nextthink = time + SVC_SETVIEWPORT;
	harp.think = SUB_Remove;
	setmodel(harp, "progs/harpoon.mdl");
	harp.skin = SPAWNFLAG_SUPERSPIKE;
	setsize(harp, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(harp, self.origin + + v_right * -8 + v_forward * 14 + '0 0 14');
};

void() spinup1 = [56, spinup2]
{
	self.velocity_z = 400;
	self.touch = OutControl;
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
	self.touch = OutControl;
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

void() EndAll = 
{
	if (other == world)
	{
		self.movetype = MOVETYPE_NONE;
		self.think = SUB_Null;
	}
};

void() OutControl = 
{
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_BOUNCE;
	self.touch = EndAll;
	frogmen_death1();
};

void() frogmen_die = 
{
	local float r;
	if (self.health < -50)
	{
		sound(self, CHAN_VOICE, "player/udeath.wav", SPAWNFLAG_SUPERSPIKE, ATTN_NORM);
		ThrowHead("progs/gib3.mdl", self.health);
		ThrowGib("progs/gib1.mdl", self.health);
		ThrowGib("progs/gib2.mdl", self.health);
		ThrowGib("progs/gib3.mdl", self.health);
		return;
	}
	if (self.health > -30)
	{
		frogmen_death1();
	}
	else
	{
		r = random();
		if (r < 0.5)
		{
			spinup1();
		}
		else
		{
			self.angles_y = (0.5 - random()) * 360;
			self.angles_x = MSG_BROADCAST;
			self.angles_z = MSG_BROADCAST;
			makevectors(self.angles);
			self.old_angles = v_forward * 400 + v_forward * random() * 200;
			spinover1();
		}
	}
};

void() monster_frogman = 
{
	if (!deathmatch)
	{
		precache_model("progs/frogman.mdl");
		precache_model("progs/harpoon.mdl");
		precache_sound("frogman/sight.wav");
		precache_sound("frogman/pain1.wav");
		precache_sound("frogman/pain2.wav");
		precache_sound("frogman/swim.wav");
		precache_sound("frogman/idle.wav");
		precache_sound("frogman/shot3.wav");
		precache_sound("frogman/death.wav");
		precache_sound("frogman/impact.wav");
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_STEP;
		setmodel(self, "progs/frogman.mdl");
		setsize(self, VEC_HULL_MIN, '16 16 40');
		self.health = 100;
		//dealwithskill(); // unkown Malice stuff, changes monster health depending on skill?
		self.th_stand = frogmen_stand1;
		self.th_walk = frogmen_walk1;
		self.th_run = frogmen_run1;
		self.th_die = frogmen_die;
		self.th_pain = frogmen_pain;
		self.th_missile = frogmen_fire;
		self.th_melee = frogmen_fire1;
		swimmonster_start();
	}
	else
	{
		remove(self);
	}
};

