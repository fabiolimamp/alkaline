void() probe_pulsetouch;
void() probe_stand_attack;

void(float ofs, float turn) Probe_laser_fire = {
	local vector src;
	local vector vec;
	local vector targ;
	local vector ang;
	local entity missile;
	local float dist;

	ang = self.angles;
	ang_y = ang_y + self.fixangle;
	
	if (turn == 1)
		ang_y = ang_y + 165;
	else if (turn == 2)
		ang_y = ang_y - 165;

	makevectors(ang);
	src = self.origin + '0 0 -10' + v_right * ofs + v_forward;
	targ = self.enemy.origin + self.enemy.view_ofs;
	
	if (startskill != 0)	{
		dist = vlen(targ - src);
		targ = targ + self.enemy.velocity * (dist / 1000);
	}

	vec = targ - src;
	vec = normalize(vec);
	dist = vec * v_forward;

	if (dist < self.worldtype) {
		vec = v_forward;
	}

	self.effects = self.effects | EF_MUZZLEFLASH;
	sound(self, CHAN_WEAPON, "probe/shoot.wav", 1, ATTN_NORM);
	self.punchangle_x = -2;

	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";
	missile.velocity = vec * 800;
	missile.angles = vectoangles(vec);
	missile.touch = probe_pulsetouch;
	missile.nextthink = time + 5;
	missile.think = SUB_Remove;
	missile.flags = missile.flags | FL_PROJECTILE;
	setmodel(missile, "progs/laser.mdl");
	setsize(missile, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(missile, src);
};


// derived from OgreFireGrenade
// needs some functions from ogre.qc

void(float ofs, float elevation) ProbeFireGrenade =
{
	local entity missile;
	local vector ang;

	local vector src;
	local vector vec;
	local vector targ;
	local float dist;
	//local float ofs;
	entity enem;

	enem = SUB_entEnemyTarget();

	ang = self.angles;
	ang_y = ang_y + self.fixangle;
	

	/*if (self.lip) {
		ofs = 30;
		self.lip = 0;
	}
	else {
		ofs = -30;
		self.lip = 1;
	}*/
	/*if (turn == 1)
		ang_y = ang_y + 165;
	else if (turn == 2)
		ang_y = ang_y - 165;
		*/
	ang_x = -elevation - 10;
	makevectors(ang);
	src = self.origin + '0 0 -10' + v_right * ofs + v_forward;
	targ = enem.origin + enem.view_ofs;
	
	if (startskill != 0)	{
		dist = vlen(targ - src);
		targ = targ + enem.velocity * (dist / 800);
	}

	vec = targ - src;
	vec = normalize(vec);
	dist = vec * v_forward;

	if (dist < self.worldtype) {
		vec = v_forward;
	}



	self.effects = self.effects | EF_MUZZLEFLASH;

	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.classname = "grenade";
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.flags = missile.flags | FL_PROJECTILE;
	missile.dmg = 30;

	// set missile speed
	/*ang = self.angles;
	ang_x = -elevation;
	makevectors (ang);
*/
	missile.velocity = vec * OGRE_G_VEL;

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);

	missile.touch = OgreGrenadeTouch;

	// set missile duration
	missile.nextthink = time + 2.5;
	missile.think = OgreGrenadeExplode;

	setmodel (missile, "progs/grenade_probe.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, src);
};


void() probe_pulsetouch = 
{
	local vector org;
	if (other == self.owner)
	{
		return;
	}
	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	org = self.origin - 8 * normalize(self.velocity);
	if (other.health)
	{
		ImpactSpawn(org, self.velocity * 0.2, 15, other.bloodtype);
		T_Damage(other, self, self.owner, 12);
	}
	else
	{
		sound(self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_NORM);
		self.origin = self.origin - 8 * normalize(self.velocity);
		WriteByte(0, SVC_TEMPENTITY);
		WriteByte(0, TE_GUNSHOT);
		WriteCoord(0, self.origin_x);
		WriteCoord(0, self.origin_y);
		WriteCoord(0, self.origin_z);
	}
	remove(self);
};

void(float angdelta, float delta) probe_turn = 
{
	if (fabs(angdelta) < 10)
		self.fixangle = delta;
	else if (angdelta > 5)
		self.fixangle = self.fixangle + 9;
	else if (angdelta < -5)
		self.fixangle = self.fixangle - 9;
	else
		self.fixangle = delta;
};

/************************
 Sound functions
 ************************/

void() probe_sound = {sound(self, 6, "probe/footfall.wav", 1, ATTN_NORM);};
void() probe_servo = {sound(self, 7, "probe/servo.wav", 0.5, ATTN_NORM);};

void() probe_idle_sound = {
	if (!(self.spawnflags & MONSTER_NOIDLESOUND)) return;

	local float r;
	r = random();
	if (r < 0.5)		sound(self, CHAN_VOICE, "probe/idle1.wav", 1, ATTN_IDLE);			
	else				sound(self, CHAN_VOICE, "probe/idle2.wav", 1, ATTN_IDLE);
	
}

void() probe_walk_sound = {
	if (self.bubble_count == 0) probe_servo();
	self.bubble_count++;
	if (self.bubble_count > 18) self.bubble_count = 0;
};

void() probe_angry_sound = {
	
	//if (self.bubble_count == 1) probe_sound();
	//else if (self.bubble_count == 3) probe_servo();
	if (self.bubble_count == 18) {
		if (random() < 0.5)
			sound(self, CHAN_VOICE, "probe/idle3.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_VOICE, "probe/idle4.wav", 1, ATTN_NORM);
	}

	self.bubble_count++;
	if (self.bubble_count > 18) self.bubble_count = 0;
};

/************************
 Think functions
 ************************/


void() probe_think = {
	local float delta;
	local float angdelta;
	entity enem;
	enem = SUB_entEnemyTarget();

	setorigin(self.trigger_field, self.origin);
	self.trigger_field.angles = self.angles;
	self.trigger_field.frame = self.frame;
	if(self.frame > 22) self.frame = 0;
	if(enem)
		self.trigger_field.angles_y = self.trigger_field.angles_y + self.fixangle;

	enemy_yaw = vectoyaw(enem.origin - self.origin);
	self.ideal_yaw = enemy_yaw;
	delta = self.ideal_yaw - self.angles_y;
	self.cnt = 0;

	if (delta > 180)
		delta = delta - 360;
	if (delta < -180)
		delta = delta + 360;
	if (fabs(delta) > 90) {
		delta = 0;
		self.cnt = 1;
	}

	angdelta = delta - self.fixangle;
	probe_turn(angdelta, delta);

	if (self.health < 0)
		return;

	if (time > self.super_time && !enem)	{
		self.super_time = time + 3;
		if (random() < 0.5 && !enem)
			probe_idle_sound();
	}
};

void() probe_walkthink = {
	local float delta;
	local float angdelta;
	entity enem;
	enem = SUB_entEnemyTarget();

	probe_walk_sound();

	setorigin(self.trigger_field, self.origin);
	self.trigger_field.angles = self.angles;
	self.trigger_field.frame = self.frame;
	if(self.frame > 22) self.frame = 0;
	if(enem)
		self.trigger_field.angles_y = self.trigger_field.angles_y + self.fixangle;

	delta = 0;
	angdelta = delta - self.fixangle;
	probe_turn(angdelta, delta);
	self.cnt = 0;

	if (self.health < 0)
		return;

	if (time > self.super_time)	{
		self.super_time = time + 3;
		if (random() < 0.5 && !enem) 
			probe_idle_sound();	
	}

};

/************************
 Animation
 ************************/

void() probe_stand1 = 	[0, probe_stand2] 	{ai_stand(); probe_think(); };
void() probe_stand2 = 	[1, probe_stand3] 	{ai_stand(); probe_think(); };
void() probe_stand3 = 	[2, probe_stand4] 	{ai_stand(); probe_think(); };
void() probe_stand4 = 	[3, probe_stand5] 	{ai_stand(); probe_think(); };
void() probe_stand5 = 	[4, probe_stand6] 	{ai_stand(); probe_think(); };
void() probe_stand6 = 	[5, probe_stand7] 	{ai_stand(); probe_think(); };
void() probe_stand7 = 	[6, probe_stand8] 	{ai_stand(); probe_think(); };
void() probe_stand8 = 	[7, probe_stand9] 	{ai_stand(); probe_think(); };
void() probe_stand9 = 	[8, probe_stand10] 	{ai_stand(); probe_think(); };
void() probe_stand10 =	[9, probe_stand11] 	{ai_stand(); probe_think(); };
void() probe_stand11 = 	[10, probe_stand12] {ai_stand(); probe_think(); };
void() probe_stand12 = 	[11, probe_stand13] {ai_stand(); probe_think(); };
void() probe_stand13 = 	[12, probe_stand1] 	{ai_stand(); probe_think(); };




void() probe_walk1 = 	[0, probe_walk2]	{
	self.yaw_speed = 12;
	ai_walk(10);
	probe_walkthink();
};
void() probe_walk2 =	[1, probe_walk3]	{ai_walk(10); probe_walkthink(); };
void() probe_walk3 =	[2, probe_walk4]	{ai_walk(10); probe_walkthink(); };
void() probe_walk4 =	[3, probe_walk5]	{ai_walk(10); probe_walkthink(); };
void() probe_walk5 =	[4, probe_walk6]	{ai_walk(10); probe_walkthink(); };
void() probe_walk6 =	[5, probe_walk7]	{ai_walk(10); probe_walkthink(); };
void() probe_walk7 =	[6, probe_walk8]	{ai_walk(10); probe_walkthink(); };
void() probe_walk8 =	[7, probe_walk9]	{ai_walk(10); probe_walkthink(); };
void() probe_walk9 =	[8, probe_walk10]	{ai_walk(10); probe_walkthink(); };
void() probe_walk10 =	[9, probe_walk11]	{ai_walk(10); probe_walkthink(); };
void() probe_walk11 =	[10, probe_walk12]	{ai_walk(10); probe_walkthink(); };
void() probe_walk12 =	[11, probe_walk13]	{ai_walk(10); probe_walkthink(); };
void() probe_walk13 =	[12, probe_walk1]	{ai_walk(10); probe_walkthink(); };



void() probe_run_frame = {
	probe_angry_sound();
	ChangeYaw();
	
	ai_run(10);
	probe_think();
};

void() probe_run1 = 	[0, probe_run2] 	{self.yaw_speed = 8; probe_run_frame();};
void() probe_run2 =		[1, probe_run3] 	{probe_run_frame();};
void() probe_run3 = 	[2, probe_run4] 	{probe_run_frame();};
void() probe_run4 = 	[3, probe_run5] 	{probe_run_frame();};
void() probe_run5 = 	[4, probe_run6] 	{probe_run_frame();};
void() probe_run6 = 	[5, probe_run7]		{probe_run_frame();};
void() probe_run7 = 	[6, probe_run8] 	{probe_run_frame();};
void() probe_run8 = 	[7, probe_run9] 	{probe_run_frame();};
void() probe_run9 = 	[8, probe_run10] 	{probe_run_frame();};
void() probe_run10 = 	[9, probe_run11] 	{probe_run_frame();};
void() probe_run11 = 	[10, probe_run12] 	{probe_run_frame();};
void() probe_run12 = 	[11, probe_run13] 	{probe_run_frame();};
void() probe_run13 = 	[12, probe_run1] 	{probe_run_frame();

	local float delta;
	
	if (self.cnt == 1 && time > self.attack_finished)
	{
		delta = self.ideal_yaw - self.angles_y;
		if (delta > 180)
		{
			delta = delta - 360;
		}
		if (delta < -180)
		{
			delta = delta + 360;
		}
		return;
	}
	if (self.lefty == 1)
	{
		self.lefty = 0;
		self.think = self.th_missile;
	}
};




void() probe_watk_frame = {
	ChangeYaw();
	walkmove(self.angles_y, 14);
	probe_think();
}

void() probe_watk1 = 	[13, probe_watk2] 	{probe_watk_frame(); probe_servo();};
void() probe_watk2 = 	[14, probe_watk3] 	{probe_watk_frame(); Probe_laser_fire(-30, 0);};
void() probe_watk3 = 	[15, probe_watk4] 	{probe_watk_frame(); };
void() probe_watk4 = 	[16, probe_watk5] 	{probe_watk_frame();};
void() probe_watk5 = 	[17, probe_watk6] 	{probe_watk_frame(); Probe_laser_fire(30, 0); };
void() probe_watk6 = 	[18, probe_watk7] 	{probe_watk_frame(); probe_sound();};
void() probe_watk7 = 	[19, probe_watk8] 	{probe_watk_frame();};
void() probe_watk8 = 	[20, probe_watk9] 	{probe_watk_frame();};
void() probe_watk9 = 	[21, probe_watk10] 	{probe_watk_frame();};
void() probe_watk10 = 	[22, probe_run1] 	{probe_watk_frame(); SUB_AttackFinished(1);};


void() probe_gr_watk1 = 	[13, probe_gr_watk2] 	{probe_watk_frame(); probe_servo();
	self.attack_elevation = IterateElevation(30, SUB_entEnemyTarget().origin);
};
void() probe_gr_watk2 = 	[14, probe_gr_watk3] 	{probe_watk_frame(); ProbeFireGrenade(-30, self.attack_elevation);};
void() probe_gr_watk3 = 	[15, probe_gr_watk4] 	{probe_watk_frame();
	self.attack_elevation = IterateElevation(self.attack_elevation, SUB_entEnemyTarget().origin);
};
void() probe_gr_watk4 = 	[16, probe_gr_watk5] 	{probe_watk_frame();
	self.attack_elevation = IterateElevation(self.attack_elevation, SUB_entEnemyTarget().origin);
};
void() probe_gr_watk5 = 	[17, probe_gr_watk6] 	{probe_watk_frame(); ProbeFireGrenade(30, self.attack_elevation);};
void() probe_gr_watk6 = 	[18, probe_gr_watk7] 	{probe_watk_frame(); probe_sound();};
void() probe_gr_watk7 = 	[19, probe_gr_watk8] 	{probe_watk_frame();};
void() probe_gr_watk8 = 	[20, probe_gr_watk9] 	{probe_watk_frame();};
void() probe_gr_watk9 = 	[21, probe_gr_watk10] 	{probe_watk_frame();};
void() probe_gr_watk10 = 	[22, probe_run1] 	{probe_watk_frame(); SUB_AttackFinished(1);};


void() probe_plant1 = [0, probe_plant1] {probe_stand_attack(); probe_think();};



void() probe_stop1 = [20, probe_stop2] {probe_think();};
void() probe_stop2 = [21, probe_stop3] {probe_think();};
void() probe_stop3 = [22, probe_plant1] {probe_sound();	probe_think();};



void() probe_satk1 = [23, probe_satk2] {probe_think(); probe_servo();};
void() probe_satk2 = [24, probe_satk3] {probe_think(); Probe_laser_fire(-18, 0); Probe_laser_fire(18, 0);};
void() probe_satk3 = [25, probe_satk4] {probe_think(); probe_sound();};
void() probe_satk4 = [26, probe_satk5] {probe_think();};
void() probe_satk5 = [27, probe_satk6] {probe_think();};
void() probe_satk6 = [28, probe_plant1] {probe_think(); SUB_AttackFinished(0.3);};



void() probe_gr_satk1 = [23, probe_gr_satk2] {probe_think(); probe_servo();
	self.attack_elevation = IterateElevation(30, SUB_entEnemyTarget().origin);
};
void() probe_gr_satk2 = [24, probe_gr_satk3] {probe_think(); ProbeFireGrenade(30, self.attack_elevation); ProbeFireGrenade(-30, self.attack_elevation);};
void() probe_gr_satk3 = [25, probe_gr_satk4] {probe_think(); probe_sound();};
void() probe_gr_satk4 = [26, probe_gr_satk5] {probe_think();};
void() probe_gr_satk5 = [27, probe_gr_satk6] {probe_think();};
void() probe_gr_satk6 = [28, probe_plant1] {probe_think(); SUB_AttackFinished(0.3);};



void() bodydie = {
	self.health = self.trigger_field.health;
	self.origin = self.origin + '0 0 -32';
	FuelTankExplode();
	if (self.trigger_field.classname == "monster_grenadeprobe") ThrowGib ("progs/progib1_double_cannons.mdl", self.health);
	else ThrowGib ("progs/progib1.mdl", self.health);
	ThrowGib ("progs/progib2.mdl", self.health);
	ThrowGib ("progs/progib3.mdl", self.health);
	SUB_Remove();
};


void() probe_die1 = [13, probe_die2] {
	probe_think();
	ai_run_slide();
	ai_run_slide();
	FuelTankExplode();
	self.trigger_field.flags = self.trigger_field.flags - FL_FLY;
		
};

void() probe_die2 = [14, probe_die3] {
	probe_think();
	sound(self, CHAN_AUTO, "probe/death.wav", 1, ATTN_NORM);
	self.nextthink = time + 0.2;
	ai_run_slide();
};

void() probe_die3 = [15, SUB_Hide] {
	self.trigger_field.trigger_field = self;
	self.trigger_field.think = bodydie;
	self.trigger_field.nextthink = time + 0.1;
	self.trigger_field.frame = self.frame;
	FuelTankExplode();	
};

void(entity attacker, float damage) probe_pain = {
	if (self.health <= 0)
		return;
	if (damage < 25)
		return;
	if (self.pain_finished > time)
		return;
	self.pain_finished = time + 2;
	sound(self, CHAN_AUTO, "probe/pain.wav", 1, ATTN_NORM);
};

void() probe_missile_attack = {
	if (random() < 0.5){
		if (self.classname == "monster_grenadeprobe") probe_gr_watk1();
		else probe_watk1();
	}
	else {
		if (self.classname == "monster_grenadeprobe") probe_gr_satk1();
		else probe_satk1();
	}
};

void() probe_stand_attack = {
	
	local vector spot1, spot2;
	entity enem;
	enem = SUB_entEnemyTarget();

	spot1 = self.origin + self.view_ofs;
	spot2 = enem.origin + enem.view_ofs;
	traceline(spot1, spot2, 0, self);

	if (trace_ent != enem) {
		probe_run1();
		return;
	}
	
	if (trace_inopen && trace_inwater) {
		probe_run1();
		return;
	}

	if (time < self.attack_finished) {
		return;
	}
	self.state = 0;
	if (vlen(spot2 - spot1) > 450)
	{
		probe_run1();
		return;
	}
	
	if (self.classname == "monster_grenadeprobe") probe_gr_satk1();
	else probe_satk1();

	if (self.cnt == 1) {
		probe_run1();
		return;
	}
};

float() ProbeCheckAttack = {
	local vector spot1;
	local vector spot2;
	local entity targ;
	local float ang;
	local float delta;
	local float dist;
	entity enem;
	enem = SUB_entEnemyTarget();
	
	self.lefty = 0;
	targ = enem;
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, 0, self);

	if (trace_inopen && trace_inwater)
		return 0;

	if (time < self.attack_finished)
		return 0;

	ang = self.angles_y + self.fixangle;
	delta = self.ideal_yaw - ang;
	dist = vlen(spot2 - spot1);

	if (fabs(delta) > 10 && dist > 200 || enem.classname != "player")
		return 0;
	
	if (dist < 400)	{
		self.th_melee();
		return 1;
	}

	self.lefty = 1;

	return 0;
};

void() probe_sight = {
	sound (self, CHAN_AUTO, "probe/sight.wav", 1, ATTN_NORM);
}

void(entity e) monster_probe_start = {
	local entity oself;

	local entity body;

	oself = self;
	self = e;

	self.lefty = 0;
	self.solid = SOLID_SLIDEBOX;
	self.fixangle = 0;
	self.movetype = MOVETYPE_STEP;
	setmodel(self, "progs/probedom.mdl");
	setsize(self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	setorigin(self, self.origin);

	body = spawn();
	body.origin = self.origin;// - '0 0 64';
	body.solid = SOLID_NOT;
	body.movetype = MOVETYPE_STEP;
	body.flags = body.flags | FL_FLY;
	
	if (self.classname == "monster_grenadeprobe") setmodel(body, "progs/probebod_double_cannons.mdl");
	else setmodel(body, "progs/probebod.mdl");

	
	setsize(body, VEC_HULL2_MIN, VEC_HULL2_MAX);
	setorigin(body, body.origin);

	self.trigger_field = body;
	body.trigger_field = self;

	if(!self.bloodtype) self.bloodtype = SPAWN_YELLOWSPARK;
	self.yaw_speed = 9;
	self.health = 200;

	if (!self.above && self.classname == "monster_grenadeprobe") self.above = 64;

	if (self.obituary == "") {
		if (self.classname == "monster_grenadeprobe") self.obituary = "was plugged by a Grenade Probe";
		else self.obituary = "was plugged by a Probe";
	}

	self.worldtype = 0.75;
	self.state = 0;
	self.super_time = 0;
	self.ltime = 0;

	self.th_stand = probe_stand1;
	self.th_walk = probe_walk1;
	self.th_run = probe_run1;
	self.th_die = probe_die1;
	self.th_missile = probe_missile_attack;
	self.th_melee = probe_missile_attack;
	self.th_pain = probe_pain;
	self.th_sight = probe_sight;

	flymonster_start();

	self = oself;
};

void() monster_probe_spawner = {
	monster_spawner(monster_probe_start);
};



void() monster_grenadeprobe = {
	//local float sk;
	if (deathmatch)	{
		remove(self);
		return;
	}

	precache_model("progs/progib1_double_cannons.mdl");
	precache_model("progs/progib2.mdl");
	precache_model("progs/progib3.mdl");		
	precache_model("progs/probebod_double_cannons.mdl");
	precache_model("progs/probedom.mdl");
	precache_model("progs/d_explod.spr");
	precache_model("progs/laser.mdl");
	precache_model("progs/grenade_probe.mdl");
	
	precache_sound("probe/shoot.wav");
	precache_sound("probe/footfall.wav");
	precache_sound("probe/servo.wav");
	precache_sound("probe/death.wav");
	precache_sound("probe/pain.wav");
	precache_sound("enforcer/enfstop.wav");
	precache_sound("probe/sight.wav");
	precache_sound("probe/idle1.wav");
	precache_sound("probe/idle2.wav");
	precache_sound("probe/idle3.wav");
	precache_sound("probe/idle4.wav");
	precache_sound("weapons/fuelexp.wav");

	setsize(self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_probe_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_probe_start(self);
	}
};


void() monster_probe = {
	//local float sk;
	if (deathmatch)	{
		remove(self);
		return;
	}

	precache_model("progs/progib1.mdl");
	precache_model("progs/progib2.mdl");
	precache_model("progs/progib3.mdl");		
	precache_model("progs/probebod.mdl");
	precache_model("progs/probedom.mdl");
	precache_model("progs/d_explod.spr");
	precache_model("progs/laser.mdl");
	
	precache_sound("probe/shoot.wav");
	precache_sound("probe/footfall.wav");
	precache_sound("probe/servo.wav");
	precache_sound("probe/death.wav");
	precache_sound("probe/pain.wav");
	precache_sound("enforcer/enfstop.wav");
	precache_sound("probe/sight.wav");
	precache_sound("probe/idle1.wav");
	precache_sound("probe/idle2.wav");
	precache_sound("probe/idle3.wav");
	precache_sound("probe/idle4.wav");
	precache_sound("weapons/fuelexp.wav");

	setsize(self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_probe_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_probe_start(self);
	}
};