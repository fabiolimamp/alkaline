void() torm_checkprojectiles;
void() torm_block1;
float torm_ahead_divider;

void() torm_stand1	=[	0,	torm_stand2	] {ai_stand();

	if (time < self.air_finished)
		return;

	float rnd;
	if (!(self.spawnflags & MONSTER_NOIDLESOUND)) {
		rnd = random();
		if (rnd < 0.1) {
			sound (self, CHAN_VOICE, "tormentor/idle1.wav", 1, ATTN_IDLE);
			self.air_finished = time + 4;
		}
		else if (rnd < 0.2) {
			sound (self, CHAN_VOICE, "tormentor/idle2.wav", 1, ATTN_IDLE);
			self.air_finished = time + 4;
		}
	}
};
void() torm_stand2	=[	1,	torm_stand3	] {ai_stand();};
void() torm_stand3	=[	2,	torm_stand4	] {ai_stand();};
void() torm_stand4	=[	3,	torm_stand5	] {ai_stand();};
void() torm_stand5	=[	4,	torm_stand6	] {ai_stand();};
void() torm_stand6	=[	5,	torm_stand7	] {ai_stand();};
void() torm_stand7	=[	6,	torm_stand8	] {ai_stand();};
void() torm_stand8	=[	7,	torm_stand9	] {ai_stand();};
void() torm_stand9	=[	8,	torm_stand10] {ai_stand();};
void() torm_stand10	=[	9,	torm_stand11] {ai_stand();};
void() torm_stand11	=[	10,	torm_stand12] {ai_stand();};
void() torm_stand12	=[	11,	torm_stand13] {ai_stand();};
void() torm_stand13	=[	12,	torm_stand1] {ai_stand();};



//============================================================================

void() torm_walk1	=[   13,        torm_walk2 ] {
	ai_walk(18);

	if (time < self.air_finished)
		return;

	float rnd;
	rnd = random();
	if (rnd < 0.15) {
		sound (self, CHAN_VOICE, "tormentor/idle1.wav", 1, ATTN_IDLE);
		self.air_finished = time + 4;
	}
	else if (rnd < 0.3) {
		sound (self, CHAN_VOICE, "tormentor/idle2.wav", 1, ATTN_IDLE);
		self.air_finished = time + 4;
	}
};
void() torm_walk2       =[      14,        torm_walk3 ] {ai_walk(12);};
void() torm_walk3       =[      15,        torm_walk4 ] {ai_walk(14);};
void() torm_walk4       =[      16,        torm_walk5 ] {ai_walk(16);};
void() torm_walk5       =[      17,        torm_walk6 ] {ai_walk(16);};
void() torm_walk6       =[      18,        torm_walk7 ] {ai_walk(18);  sound(self, CHAN_AUTO, "tormentor/step1.wav", 1, ATTN_IDLE);};
void() torm_walk7       =[      19,        torm_walk8 ] {ai_walk(28);};
void() torm_walk8       =[      20,        torm_walk9 ] {ai_walk(12);};
void() torm_walk9       =[      21,        torm_walk10] {ai_walk(10);};
void() torm_walk10      =[      22,        torm_walk11] {ai_walk(14);};
void() torm_walk11      =[      23,        torm_walk12] {ai_walk(14);};
void() torm_walk12      =[      24,        torm_walk1 ] {ai_walk(16);  sound(self, CHAN_AUTO, "tormentor/step1.wav", 1, ATTN_IDLE);};



//============================================================================

void() torm_run1	   =[      13,        torm_run2 ] {
	self.state = 0; self.yaw_speed = 20; 
	ai_run(18);

	if(time < self.air_finished) return;

	float rnd;
	rnd = random();
	if (rnd < 0.2) {
		sound (self, CHAN_VOICE, "tormentor/angry1.wav", 1, ATTN_NORM);
		self.air_finished = time + 2.5;
	}
	else if (rnd < 0.4) {
		sound (self, CHAN_VOICE, "tormentor/angry2.wav", 1, ATTN_NORM);
		self.air_finished = time + 2.5;
	}
	
};
void() torm_run2       =[      14,        torm_run3 ] {ai_run(12); torm_checkprojectiles();};
void() torm_run3       =[      15,        torm_run4 ] {ai_run(14); torm_checkprojectiles();};
void() torm_run4       =[      16,        torm_run5 ] {ai_run(16); torm_checkprojectiles();};
void() torm_run5       =[      17,        torm_run6 ] {ai_run(16); torm_checkprojectiles();};
void() torm_run6       =[      18,        torm_run7 ] {ai_run(18); sound(self, CHAN_AUTO, "tormentor/step1.wav", 1, ATTN_NORM); torm_checkprojectiles();};
void() torm_run7       =[      19,        torm_run8 ] {ai_run(28); torm_checkprojectiles();};
void() torm_run8       =[      20,        torm_run9 ] {ai_run(12); torm_checkprojectiles();};
void() torm_run9       =[      21,        torm_run10] {ai_run(10); torm_checkprojectiles();};
void() torm_run10      =[      22,        torm_run11] {ai_run(14); torm_checkprojectiles();};
void() torm_run11      =[      23,        torm_run12] {ai_run(14); torm_checkprojectiles();};
void() torm_run12      =[      24,        torm_run1 ] {ai_run(16); sound(self, CHAN_AUTO, "tormentor/step1.wav", 1, ATTN_NORM); torm_checkprojectiles();};


//============================================================================

void(float dist) torm_sting_hit = {
	vector vec1;


	makevectors(self.angles);
	vec1 = normalize(self.enemy.origin - self.origin);
	if (vlen(v_forward - vec1) < 0.2) {
		if (!CanDamage(self.enemy, self.origin))
			return;

		if (vlen(self.enemy.origin - self.origin) < dist) {
			T_Damage(self.enemy, self, self, 8, DMGTYPE_MELEE);
		}
	}
};

void() torm_sting1     =[      49,       torm_sting2    ] {self.nextthink = time + 0.05;ai_face();};
void() torm_sting2     =[      50,       torm_sting3    ] {self.nextthink = time + 0.05;ai_face();
	sound (self, CHAN_WEAPON, "tormentor/sting2.wav", 1, ATTN_NORM);};
void() torm_sting3     =[      51,       torm_sting4    ] {self.nextthink = time + 0.05;ai_face();};
void() torm_sting4     =[      52,       torm_sting5    ] {self.nextthink = time + 0.05;ai_face();};
void() torm_sting5     =[      53,       torm_sting6    ] {self.nextthink = time + 0.05;ai_face();torm_sting_hit(128);};
void() torm_sting6     =[      54,       torm_sting7    ] {self.nextthink = time + 0.05;ai_face();torm_sting_hit(170);};
void() torm_sting7     =[      55,       torm_sting8    ] {self.nextthink = time + 0.05;torm_sting_hit(212);};
void() torm_sting8     =[      56,       torm_sting9    ] {self.nextthink = time + 0.05;torm_sting_hit(256);};
void() torm_sting9     =[      57,       torm_sting10   ] {self.nextthink = time + 0.05;torm_sting_hit(212);};
void() torm_sting10    =[      58,       torm_sting11   ] {self.nextthink = time + 0.05;torm_sting_hit(170);};
void() torm_sting11    =[      59,       torm_sting12   ] {self.nextthink = time + 0.05;torm_sting_hit(128);};
void() torm_sting12    =[      60,       torm_sting13	] {self.nextthink = time + 0.05;};
void() torm_sting13    =[      61,       torm_run1	    ] {self.nextthink = time + 0.05;};


//============================================================================

void() torm_slap_hit = {
	if (infront(self.enemy)) {
		if (vlen(self.enemy.origin - self.origin) < 128 && CanDamage(self.enemy, self.origin)) {
			sound(self, CHAN_WEAPON, "tormentor/punch_hit.wav", 1, ATTN_NORM);
			T_Damage(self.enemy, self, self, 40, DMGTYPE_MELEE);
			makevectors(self.angles);

			if (!(self.enemy.flags & FL_ONGROUND))
				self.enemy.velocity = (v_forward * 200) + '0 0 235';
			else	
				self.enemy.velocity = '0 0 235';

			self.enemy.punchangle_x = -10;
		}
	}
}

void() torm_slap1     =[      62,       torm_slap2    ] {
	sound(self, CHAN_WEAPON, "tormentor/punch_swoosh.wav", 1, ATTN_NORM);
	ai_face(); ai_forward(8);
};
void() torm_slap2     =[      63,       torm_slap3    ] {ai_face(); ai_forward(8);};
void() torm_slap3     =[      64,       torm_slap4    ] {ai_face(); ai_forward(8); torm_slap_hit();};
void() torm_slap4     =[      65,       torm_slap5    ] {ai_face(); ai_forward(8);};
void() torm_slap5     =[      66,       torm_slap6    ] {ai_face(); ai_forward(8);};
void() torm_slap6     =[      67,       torm_slap7    ] {ai_face(); ai_forward(8); sound(self, CHAN_WEAPON, "tormentor/punch_swoosh.wav", 1, ATTN_NORM);};
void() torm_slap7     =[      68,       torm_slap8    ] {ai_face(); ai_forward(8);};
void() torm_slap8     =[      69,       torm_slap9    ] {ai_face(); ai_forward(8); torm_slap_hit();};
void() torm_slap9     =[      70,       torm_slap10   ] {ai_face(); ai_forward(8);};
void() torm_slap10    =[      71,       torm_slap11   ] {ai_face(); ai_forward(8);};
void() torm_slap11    =[      72,       torm_slap12   ] {ai_face(); ai_forward(8);};
void() torm_slap12    =[      73,       torm_run1	  ] {ai_face(); ai_forward(8);};



//============================================================================

void() torm_shot_face = {
	vector ang;
	ang = vectoangles(self.enemy.origin + self.enemy.velocity/torm_ahead_divider - self.origin);
	self.ideal_yaw = ang_y;
	ChangeYaw();
};


//============================================================================

void() torm_largeshot_touch = {
	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY) {
		remove(self);
		return;
	}
	if (other.health) {
		T_Damage(other, self, self.owner, 60, DMGTYPE_EXPLOSION);
		if (other.classname == "player") {
			other.velocity = ((other.velocity + (self.velocity * 0.2)) + '0 0 120');
			other.flags = (other.flags - (other.flags & FL_ONGROUND));
		}
	}
	self.velocity = '0 0 0';
	T_RadiusDamage (self, self.owner, 60, 1, other, DMGTYPE_EXPLOSION);

	BecomeExplosion();
};

void(vector org, vector dir) torm_launch_largeshot = {
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	newmis.classname = "torm_largeshot";
	newmis.angles = vectoangles(dir);
	newmis.velocity = dir * 700;
	newmis.touch = torm_largeshot_touch;
	newmis.nextthink = time + 5;
	newmis.think = SUB_Remove;
	newmis.flags = newmis.flags | FL_PROJECTILE;
	newmis.effects = EF_DIMLIGHT;

	setmodel(newmis, "progs/torm_largeshot.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, org);
};

void() torm_shot1_fire = {
	vector dir, shotorigin, shotdest;

	makevectors(self.angles);

	shotorigin = self.origin + '0 0 80' + v_forward*80 + v_right * 16;
	shotdest = self.enemy.origin + self.enemy.velocity/(torm_ahead_divider - 1);
	dir = normalize(shotdest - shotorigin);

	torm_launch_largeshot(shotorigin, dir);
	
	self.attack_finished = time + 3;
	
	sound (self, CHAN_WEAPON, "tormentor/fire2.wav", 1, ATTN_NORM);

	self.effects = self.effects | EF_MUZZLEFLASH;
};

void() torm_shot1_1     =[      74,       torm_shot1_2    ] {ai_face();};
void() torm_shot1_2     =[      75,       torm_shot1_3    ] {ai_face();};
void() torm_shot1_3     =[      76,       torm_shot1_4    ] {ai_face();};
void() torm_shot1_4     =[      77,       torm_shot1_5    ] {ai_face();
	float rnd;
	rnd = random();
	if (startskill == SKILL_EASY)
		self.count = 1 + floor(rnd * 1.99);
	else if (startskill == SKILL_NORMAL)
		self.count = 2 + floor(rnd * 1.99);
	else
		self.count = 3 + floor(rnd * 2.99);
};
void() torm_shot1_5     =[      78,       torm_shot1_6    ] {torm_shot_face(); torm_shot1_fire();};
void() torm_shot1_6     =[      79,       torm_shot1_7    ] {};
void() torm_shot1_7     =[      80,       torm_shot1_8    ] {};
void() torm_shot1_8     =[      81,       torm_shot1_9    ] {torm_checkprojectiles();};
void() torm_shot1_9     =[      82,       torm_shot1_10   ] {torm_shot_face();torm_checkprojectiles();};
void() torm_shot1_10    =[      83,       torm_shot1_11   ] {torm_shot_face();torm_checkprojectiles();
	if (self.count > 0) {
		self.count--;
		torm_shot1_5();
		return;
	}
};
void() torm_shot1_11    =[      84,       torm_shot1_12   ] {ai_face();torm_checkprojectiles();};
void() torm_shot1_12    =[      85,       torm_run1	      ] {ai_face();torm_checkprojectiles();};


//============================================================================

void() torm_smallshot_touch = {

	local vector org;
	
	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY) {
		remove(self);
		return;
	}
	
	sound (self, CHAN_VOICE, "hunter/hit.wav", 1, ATTN_NORM);
	
	org = self.origin - 8*normalize(self.velocity);

	if (other.health)
		T_Damage(other, self, self.owner, 15, DMGTYPE_BALLISTIC);

	self.velocity = '0 0 0';
	T_RadiusDamage (self, self, 15, 1, other, DMGTYPE_EXPLOSION);		//Additional radial damage 
	
	become_big_bullet_explosion();	//ball explosion effect
};

void(vector org, vector dir) torm_launch_smallshot = {
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	newmis.classname = "torm_smallshot";
	newmis.angles = vectoangles(dir);
	newmis.velocity = dir * 800;
	newmis.touch = torm_smallshot_touch;
	newmis.nextthink = time + 5;
	newmis.think = SUB_Remove;
	newmis.flags = newmis.flags | FL_PROJECTILE;

	setmodel(newmis, "progs/big_bullet.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, org);
};


void() torm_shot2_9;
void() torm_shot2_fire = {
	vector dir, shotorigin, shotdest;
	float delta;
	
	makevectors(self.angles);
	shotorigin = self.origin + '0 0 80' + v_forward*48;
	shotdest = self.enemy.origin + self.enemy.velocity/torm_ahead_divider;
	dir = normalize(shotdest - shotorigin);

	sound (self, CHAN_WEAPON, "hunter/fire.wav", 1, ATTN_NORM);
	torm_launch_smallshot(shotorigin + (v_right * 12), dir);
	torm_launch_smallshot(shotorigin - (v_right * 12), dir);

	self.effects = self.effects | EF_MUZZLEFLASH;

	self.attack_finished = time + 3;

	enemy_yaw = vectoyaw(self.enemy.origin - self.origin);
	delta = enemy_yaw - self.angles_y;
	if (fabs(delta) > 45) {
		self.count = 0;
	}
};

void() torm_shot2_1     =[      86,       torm_shot2_2    ] {ai_face();};
void() torm_shot2_2     =[      87,       torm_shot2_3    ] {ai_face();};
void() torm_shot2_3     =[      88,       torm_shot2_4    ] {ai_face();};
void() torm_shot2_4     =[      89,       torm_shot2_5    ] {ai_face();};
void() torm_shot2_5     =[      90,       torm_shot2_6    ] {
	float rnd;
	rnd = random();
	if (startskill == SKILL_EASY)
		self.count = 4 + floor(rnd * 3.99);
	else if (startskill == SKILL_NORMAL)
		self.count = 6 + floor(rnd * 4.99);
	else
		self.count = 8 + floor(rnd * 4.99);
};
void() torm_shot2_6     =[      91,       torm_shot2_7    ] {self.yaw_speed = 12; torm_shot2_fire();};
void() torm_shot2_7     =[      92,       torm_shot2_8    ] {torm_checkprojectiles();};
void() torm_shot2_8     =[      93,       torm_shot2_9    ] {
	torm_shot_face();
	torm_checkprojectiles();
	if (self.count > 0) {
		self.count--;
		torm_shot2_6();
		return;
	}

};
void() torm_shot2_9     =[      94,       torm_shot2_10   ] {self.yaw_speed = 20; torm_checkprojectiles();};
void() torm_shot2_10    =[      95,       torm_shot2_11   ] {torm_checkprojectiles();};
void() torm_shot2_11    =[      96,       torm_shot2_12   ] {torm_checkprojectiles();};
void() torm_shot2_12    =[      97,       torm_run1	      ] {torm_checkprojectiles();};


//============================================================================

void() torm_melee = {
	local float chance, dist;
	dist = vlen(self.origin - self.enemy.origin);
	
	chance = random();
	if (chance < 0.8 && dist < 120)
		torm_slap1();
	else
		torm_sting1();
};

void() torm_fire = {
	local float chance, dist;
	dist = vlen(self.origin - self.enemy.origin);

	chance = random();
	if ((chance > 0.5 && dist <= 600 && dist > 300) || dist > 600)
		torm_shot2_1(); // small shot
	else
		torm_shot1_1(); // large shot
};


//============================================================================

void() torm_checkprojectiles = {
	entity e;
	vector missiledir;

	e = findradius(self.origin, 512);

	while (e) {
		if (e.flags & FL_PROJECTILE) {
			if ((e.classname == "missile" || e.classname == "grenade" || e.classname == "proximity_grenade") && e.owner == self.enemy) {
				missiledir = normalize(e.velocity);

				traceline(e.origin, e.origin + missiledir*1000, FALSE, e);

				if (trace_fraction < 1) {
					if (trace_ent == self) {
						torm_block1();
						return;
					}
				}
			}
		}
		e = e.chain;
	}
};

void() torm_block1       =[      37, torm_block2      ] {self.yaw_speed = 20; ai_face();};
void() torm_block2       =[      38, torm_block3      ] {self.state = 1;};
void() torm_block3       =[      39, torm_block4      ] {};
void() torm_block4       =[      40, torm_block5      ] {}; 
void() torm_block5       =[      41, torm_block6      ] {}; 
void() torm_block6       =[      42, torm_block7      ] {}; 
void() torm_block7       =[      43, torm_block8      ] {}; //move back to frame 40 after this for looping
void() torm_block8       =[      44, torm_block9      ] {};
void() torm_block9       =[      45, torm_block10     ] {};
void() torm_block10      =[      46, torm_block11     ] {self.state = 0;};
void() torm_block11      =[      47, torm_block12     ] {};
void() torm_block12      =[      48, torm_run1        ] {};

//============================================================================


void() torm_pain1       =[      25, torm_pain2      ] {self.state = 0; self.yaw_speed = 20; };
void() torm_pain2       =[      26, torm_pain3      ] {};
void() torm_pain3       =[      27, torm_pain4      ] {};
void() torm_pain4       =[      28, torm_pain5      ] {};
void() torm_pain5       =[      29, torm_pain6      ] {};
void() torm_pain6       =[      30, torm_pain7      ] {};
void() torm_pain7       =[      31, torm_pain8      ] {};
void() torm_pain8       =[      32, torm_pain9      ] {};
void() torm_pain9       =[      33, torm_pain10     ] {};
void() torm_pain10      =[      34, torm_pain11     ] {};
void() torm_pain11      =[      35, torm_pain12     ] {};
void() torm_pain12      =[      36, torm_run1       ] {};

void(entity attacker, float damage)	torm_pain =
{
	//dprint3 ("Damage: ", ftos(damage), ";\n");
	if (self.health <= 0)
		return;		// already dying, don't go into pain frame

	// single spikes/superspikes and single-barrel shotgun fire will never pain him
	// only rockets/grenades, quad-damage shots in general, and direct SSG blasts (small chance)
	if (40 + random()*200 > damage)
		return;	

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 2;
	
	sound (self, CHAN_VOICE, "tormentor/pain1.wav", 1, ATTN_NORM);
	torm_pain1();
};


//============================================================================

float() torm_CheckAttack = {
	local entity	targ;
	local float		chance;
	local float 	dist;

	targ = self.enemy;
	
	dist = vlen(self.origin - targ.origin);

	if (dist <= 192) {	// melee attack
		if (CanDamage(targ, self.origin)
			&& (dist < 120 || random() < 0.4))
		{
			//self.th_melee ();
			self.attack_state = AS_MELEE;
			return TRUE;
		}
	}

	if (!canshoot(targ))
		return FALSE;
		
	if (time < self.attack_finished)
		return FALSE;

	// missile attack
	if (dist < 500) 
		chance = 0.4;
	else if (dist < 1000)	
		chance = 0.1;
	else
		return FALSE;

	if (random () < chance)	{
		//self.th_missile ();
		self.attack_state = AS_MISSILE;
		SUB_AttackFinished (2*random());
		return TRUE;
	}

	return FALSE;
};

// only takes 1/5 of the damage while blocking
float(entity inflictor, entity attacker, float damage, float orig_damage, float dmgtype) torm_customdamage = {
	if (self.state == 1) {
		return damage * 0.2;
	}
	else {
		return damage;
	}
};

//============================================================================

void() torm_death = [ 98, torm_death ] {

	if (self.walkframe == 0)
		sound (self, CHAN_VOICE, "tormentor/death.wav", 1, ATTN_NORM);

	self.walkframe = (self.walkframe + 1);

	if (self.walkframe == 3) {
		self.solid = SOLID_TRIGGER;
		setorigin(self, self.origin);
		SUB_ClearBumpers();
	}
	else if (self.walkframe == 30) {
		SpawnExplosion(self.origin + '0 0 16', 0, self, 0);
	}
	else if (self.walkframe == 34) {
		SpawnExplosion(self.origin + '16 0 16', 0, self, 0);
	}
	else if (self.walkframe == 36) {
		SpawnExplosion(self.origin + '0 16 32', 0, self, 0);
	}
	else if (self.walkframe == 40) {
		SpawnExplosion(self.origin, 80, self, 0);

		self.nextthink = -1;
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_torm.mdl", -20);
		ThrowGib ("progs/gib1.mdl", -25);
		ThrowGib ("progs/gib1.mdl", -25);
		ThrowGib ("progs/gib2.mdl", -20);
		ThrowGib ("progs/gib3.mdl", -20);
		ThrowGib ("progs/gib3.mdl", -15);
		ThrowGib ("progs/gib3.mdl", -20);
		ThrowGib ("progs/fgib1.mdl", -23);
		ThrowGib ("progs/fgib1.mdl", -23);
		ThrowGib ("progs/fgib1.mdl", -23);
		self.deadflag = DEAD_GIBBED;
		return;
	}

	self.frame = (self.frame + self.walkframe);
};

//============================================================================

void() torm_sight = {
	sound (self, CHAN_VOICE, "tormentor/sight.wav", 1, ATTN_NORM);
	self.air_finished = time + 3;
};

//============================================================================


void(entity e) monster_tormentor_start = {
	local entity oself;

	oself = self;
	self = e;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	setmodel (self, "progs/tormentor.mdl");

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);

	if (!self.health) self.health = 2000;
	if (self.obituary == "") self.obituary = "was obliterated by Tormentor";

	if (startskill == SKILL_EASY)
		torm_ahead_divider = 8;
	else if (startskill == SKILL_NORMAL)
		torm_ahead_divider = 4;
	else
		torm_ahead_divider = 3;

	SUB_AddBumper('-32 -32 120', TRUE);
	SUB_AddBumper('-32 32 120', TRUE);
	SUB_AddBumper('32 -32 120', TRUE);
	SUB_AddBumper('32 32 120', TRUE);
	SUB_AddBumper('32 0 120', TRUE);
	SUB_AddBumper('-32 0 120', TRUE);
	SUB_AddBumper('0 32 120', TRUE);
	SUB_AddBumper('0 -32 120', TRUE);


	SUB_AddBumper('-32 -32 104', TRUE);
	SUB_AddBumper('-32 32 104', TRUE);
	SUB_AddBumper('32 -32 104', TRUE);
	SUB_AddBumper('32 32 104', TRUE);
	SUB_AddBumper('32 0 104', TRUE);
	SUB_AddBumper('-32 0 104', TRUE);
	SUB_AddBumper('0 32 104', TRUE);
	SUB_AddBumper('0 -32 104', TRUE);

	self.th_stand = torm_stand1;
	self.th_walk = torm_walk1;
	self.th_run = torm_run1;
	self.th_die = torm_death;
	self.th_melee = torm_melee;
	self.th_missile = torm_fire;
	self.th_pain = torm_pain;
	self.th_sight = torm_sight;
	self.th_checkattack = torm_CheckAttack;
	self.th_damage = torm_customdamage;
	
	walkmonster_start();

	self = oself;
};

void() monster_tormentor_spawner = {
	monster_spawner(monster_tormentor_start);
};


void() monster_tormentor = {
	if (!SUB_InitEntity()) return;
	
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/tormentor.mdl");
	precache_model ("progs/h_torm.mdl");
	precache_model ("progs/torm_largeshot.mdl");
	precache_model ("progs/big_bullet.mdl");
	precache_model ("progs/big_bullet_blast.mdl");
	precache_model ("progs/fgib1.mdl");
	
	precache_sound ("tormentor/step1.wav");
	precache_sound ("tormentor/sight.wav");
	precache_sound ("tormentor/fire2.wav");
	precache_sound ("tormentor/sting2.wav");
	precache_sound ("tormentor/death.wav");
	precache_sound ("tormentor/pain1.wav");
	precache_sound ("tormentor/idle1.wav");
	precache_sound ("tormentor/idle2.wav");
	precache_sound ("tormentor/angry1.wav");
	precache_sound ("tormentor/angry2.wav");
	precache_sound ("tormentor/punch_swoosh.wav");
	precache_sound ("tormentor/punch_hit.wav");

	precache_sound("hunter/hit.wav");
	precache_sound("hunter/fire.wav");

	self.cmins = '-32 -32 -24';
	self.cmaxs = '32 32 120';

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_tormentor_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_tormentor_start(self);
	}
};

