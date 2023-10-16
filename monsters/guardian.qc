
$frame mfstand1
//$frame mfup01 mfup02 mfup03 mfup04 mfup05 mfup06
//$frame mfup07 mfup08 mfup09 mfup10 mfup11 mfup12

$frame start01 start02 start03 start04 start05 start06
$frame start07 start08 start09 start10 start11 start12
$frame start13 start14 start15 start16 start17 start18
$frame start19 start20 start21 start22 start23 start24
$frame start25 start26 start27 start28 start29 start30 start31

$frame mfrun01 mfrun02 mfrun03 mfrun04 mfrun05 mfrun06
$frame mfrun07 mfrun08 mfrun09 mfrun10 mfrun11

$frame mfwlk01 mfwlk02 mfwlk03 mfwlk04 mfwlk05 mfwlk06 mfwlk07 mfwlk08
$frame mfwlk09 mfwlk10 mfwlk11 mfwlk12 mfwlk13

$frame mfata01 mfata02 mfata03 mfata04 mfata05
$frame mfata06 mfata07 mfata08 mfata09

$frame mfatb01 mfatb02 mfatb03 mfatb04 mfatb05 mfatb06
$frame mfatb07 mfatb08 mfatb09 mfatb10 mfatb11

$frame mfatc01 mfatc02 mfatc03 mfatc04 mfatc05 mfatc06
$frame mfatc07 mfatc08 mfatc09 mfatc10 mfatc11 mfatc12
$frame mfatc13 mfatc14 mfatc15 mfatc16

$frame mfknck01 mfknck02 mfknck03 mfknck04 mfknck05 mfknck06
$frame mfknck07 mfknck08 mfknck09 mfknck10 mfknck11 mfknck12

$frame mfpain01 mfpain02 mfpain03 mfpain04 mfpain05
$frame mfpain06 mfpain07 mfpain08 mfpain09 mfpain10

$frame mfpbin01 mfpbin02 mfpbin03 mfpbin04 mfpbin05
$frame mfpbin06 mfpbin07

$frame mfdth01 mfdth02 mfdth03 mfdth04 mfdth05
$frame mfdth06 mfdth07 mfdth08 mfdth09 mfdth10
$frame mfdth11 mfdth12 mfdth13 mfdth14 mfdth15
$frame mfdth16 mfdth17 mfdth18 mfdth19 mfdth20
$frame mfdth21 

$frame mfchrg01 mfchrg02 mfchrg03 mfchrg04 mfchrg05
$frame mfchrg06 mfchrg07 mfchrg08 mfchrg09

.float	childrenSpawned;

float BOSS2_BALL_VEL = 600;

// ========================
// standing
// ========================
void() guardian_stand1 = [ $mfstand1, guardian_stand1 ] { ai_stand(); };

// ========================
// movement
// ========================
void() guardian_walk1  = [ $mfwlk01, guardian_walk2  ] {ai_walk(8);};
void() guardian_walk2  = [ $mfwlk02, guardian_walk3  ] {ai_walk(4);};
void() guardian_walk3  = [ $mfwlk03, guardian_walk4  ] {ai_walk(6);};
void() guardian_walk4  = [ $mfwlk04, guardian_walk5  ] {ai_walk(7);};
void() guardian_walk5  = [ $mfwlk05, guardian_walk6  ] {ai_walk(12);};
void() guardian_walk6  = [ $mfwlk06, guardian_walk7  ] {ai_walk(9);};
void() guardian_walk7  = [ $mfwlk07, guardian_walk8  ] {ai_walk(6);};
void() guardian_walk8  = [ $mfwlk08, guardian_walk9  ] {ai_walk(7);};
void() guardian_walk9  = [ $mfwlk09, guardian_walk10 ] {ai_walk(4);};
void() guardian_walk10 = [ $mfwlk10, guardian_walk11 ] {ai_walk(5);};
void() guardian_walk11 = [ $mfwlk11, guardian_walk12 ] {ai_walk(12);};
void() guardian_walk12 = [ $mfwlk12, guardian_walk13 ] {ai_walk(11);};
void() guardian_walk13 = [ $mfwlk13, guardian_walk1  ] {ai_walk(7);};
 /*
void() guardian_run1 = [ $mfrun01, guardian_run2 ] { ai_run(7);};
void() guardian_run2 = [ $mfrun02, guardian_run3 ] { ai_run(18);};
void() guardian_run3 = [ $mfrun03, guardian_run4 ] { ai_run(16);};
void() guardian_run4 = [ $mfrun04, guardian_run5 ] { ai_run(21);};
void() guardian_run5 = [ $mfrun05, guardian_run6 ] { ai_run(11);};
void() guardian_run6 = [ $mfrun06, guardian_run7 ] { ai_run(9);};
void() guardian_run7 = [ $mfrun07, guardian_run8 ] { ai_run(8);};
void() guardian_run8 = [ $mfrun08, guardian_run9 ] { ai_run(10);};
void() guardian_run9 = [ $mfrun09, guardian_run10 ] {ai_run(16);};
void() guardian_run10 =[ $mfrun10, guardian_run11 ] {ai_run(18);};
void() guardian_run11 =[ $mfrun11, guardian_run1 ] { ai_run(12);};
*/

void() guardian_run1 = [ $mfrun01, guardian_run2 ] { ai_run(14);}; //32
void() guardian_run2 = [ $mfrun02, guardian_run3 ] { ai_run(10);}; //33
void() guardian_run3 = [ $mfrun03, guardian_run4 ] { ai_run(26);}; //34
void() guardian_run4 = [ $mfrun04, guardian_run5 ] { ai_run(22);}; //35
void() guardian_run5 = [ $mfrun05, guardian_run6 ] { ai_run(26);}; //36
void() guardian_run6 = [ $mfrun06, guardian_run7 ] { ai_run(8);}; //37
void() guardian_run7 = [ $mfrun07, guardian_run8 ] { ai_run(4);}; //38
void() guardian_run8 = [ $mfrun08, guardian_run9 ] { ai_run(10);}; //39
void() guardian_run9 = [ $mfrun09, guardian_run10 ] {ai_run(14);}; //40
void() guardian_run10 =[ $mfrun10, guardian_run11 ] {ai_run(22);}; //41
void() guardian_run11 =[ $mfrun11, guardian_run1 ] { ai_run(24);}; //42
// ========================
// new attack code
// ========================
void() guardian_stab2 =
{
	local float		dist;
	local float		attackDamage;
	local vector	org, dir;
	
	if (!self.enemy)
		return;
	if (!CanDamage (self.enemy, self.origin))
		return;

	ai_face();

	dir = self.enemy.origin - self.origin;
	dist = vlen ( dir );
	dir = normalize ( dir );
	makevectors (self.angles);

	if ( dist <= 90 )
	{
		sound (self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_STATIC);
	    attackDamage = (random() * 10) + 20;
		T_Damage (self.enemy, self, self, attackDamage, DMGTYPE_MELEE);
		SpawnBlood ( self.enemy.origin, v_forward * 150, 14);
	}
	else
	{
		self.effects = self.effects | EF_MUZZLEFLASH;
		org = self.origin + v_forward * 107 + v_right * 0 + '0 0 30';
		LaunchLaser(org, dir * 600);
		if ( dist )
		{
			LaunchLaser(org, (dir + v_right * 0.04) * 600);
			LaunchLaser(org, (dir - v_right * 0.04) * 600);
		}
		else
		{
			LaunchLaser(org, (dir + v_right * 0.10) * 600);
			LaunchLaser(org, (dir - v_right * 0.10) * 600);	
		}
	}
	makevectors (self.angles);
	self.enemy.velocity = v_forward * 200 + '0 0 200';
	self.enemy.flags =  not(self.enemy.flags, FL_ONGROUND);
};

// ========================
// hand to hand attack
// ========================

void() guardian_attack01 = [ $mfatb01, guardian_attack02 ] {ai_face();};
void() guardian_attack02 = [ $mfatb02, guardian_attack03 ] {ai_face();};
void() guardian_attack03 = [ $mfatb03, guardian_attack04 ] {ai_face();};
void() guardian_attack04 = [ $mfatb04, guardian_attack05 ] {ai_face();};
void() guardian_attack05 = [ $mfatb05, guardian_attack06 ] {ai_face();};
void() guardian_attack06 = [ $mfatb06, guardian_attack07 ] {ai_face();};
void() guardian_attack07 = [ $mfatb07, guardian_attack08 ] {guardian_stab2();};
void() guardian_attack08 = [ $mfatb08, guardian_attack09 ] {ai_face();};
void() guardian_attack09 = [ $mfatb09, guardian_attack10 ] {ai_face();};
void() guardian_attack10 = [ $mfatb10, guardian_attack11 ] {ai_face();};
void() guardian_attack11 = [ $mfatb11, guardian_attack12 ] {ai_face();};
void() guardian_attack12 = [ $mfatb01, guardian_run1     ] {ai_face();};

void() guardian_bigattack01 = [ $mfatc01, guardian_bigattack02 ] { ai_face(); };
void() guardian_bigattack02 = [ $mfatc02, guardian_bigattack03 ] { ai_face(); };
void() guardian_bigattack03 = [ $mfatc03, guardian_bigattack04 ] { ai_face(); };
void() guardian_bigattack04 = [ $mfatc04, guardian_bigattack05 ] { ai_face(); };
void() guardian_bigattack05 = [ $mfatc05, guardian_bigattack06 ] { ai_face(); };
void() guardian_bigattack06 = [ $mfatc06, guardian_bigattack07 ] { ai_face(); };
void() guardian_bigattack07 = [ $mfatc07, guardian_bigattack08 ] { ai_face(); };
void() guardian_bigattack08 = [ $mfatc08, guardian_bigattack09 ] { ai_face(); };
void() guardian_bigattack09 = [ $mfatc09, guardian_bigattack10 ] { ai_face(); };
void() guardian_bigattack10 = [ $mfatc10, guardian_bigattack11 ] { guardian_stab2();};
void() guardian_bigattack11 = [ $mfatc11, guardian_bigattack12 ] { ai_face(); };
void() guardian_bigattack12 = [ $mfatc12, guardian_bigattack13 ] { ai_face(); };
void() guardian_bigattack13 = [ $mfatc13, guardian_bigattack14 ] { ai_face(); };
void() guardian_bigattack14 = [ $mfatc14, guardian_bigattack15 ] { ai_face(); };
void() guardian_bigattack15 = [ $mfatc15, guardian_bigattack16 ] { ai_face(); };
void() guardian_bigattack16 = [ $mfatc16, guardian_bigattack17 ] { ai_face(); };
void() guardian_bigattack17 = [ $mfatc01, guardian_run1        ] { ai_face(); };

void() guardian_smack = 
{
    local vector    delta;
    local float     ldmg;

	if (!self.enemy)
		return;
	if (!CanDamage (self.enemy, self.origin))
		return;

	ai_face();

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 128)
		return;
		
    ldmg = (random() * 10) + 10;
	T_Damage (self.enemy, self, self, ldmg, DMGTYPE_MELEE);
	
	makevectors (self.angles);
	self.enemy.velocity = v_forward * 400 + '0 0 400';
	self.enemy.flags =  not(self.enemy.flags, FL_ONGROUND);
};

void() guardian_knockback01 = [ $mfknck01, guardian_knockback02 ] { ai_face(); };
void() guardian_knockback02 = [ $mfknck02, guardian_knockback03 ] { ai_face(); };
void() guardian_knockback03 = [ $mfknck03, guardian_knockback04 ] { ai_face(); };
void() guardian_knockback04 = [ $mfknck04, guardian_knockback05 ] { guardian_smack();};
void() guardian_knockback05 = [ $mfknck05, guardian_knockback06 ] { ai_face(); };
void() guardian_knockback06 = [ $mfknck06, guardian_knockback07 ] { ai_face(); };
void() guardian_knockback07 = [ $mfknck07, guardian_knockback08 ] { ai_face(); };
void() guardian_knockback08 = [ $mfknck08, guardian_knockback09 ] { ai_face(); };
void() guardian_knockback09 = [ $mfknck09, guardian_knockback10 ] { ai_face(); };
void() guardian_knockback10 = [ $mfknck10, guardian_knockback11 ] { ai_face(); };
void() guardian_knockback11 = [ $mfknck11, guardian_knockback12 ] { ai_face(); };
void() guardian_knockback12 = [ $mfknck12, guardian_run1        ] { ai_face(); };

void() guardian_attack =
{
	local float 	attackChoice;
	
	attackChoice = random();
	
	if (attackChoice < 0.50)
		guardian_bigattack01();
	else if (attackChoice < 0.75)
		guardian_attack01();
	else
		guardian_knockback01();
};

void(vector org, vector dir) guardian_missile =
{
	entity 	missile;
	//vector	dir;

	self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "shalrath/attack2.wav", 1, ATTN_NORM);
	makevectors(self.angles);
	
	//dir = (enemy_vispos() + '0 0 10') - self.origin + enemy_aim_vertical();
	//dir = normalize(dir);
	
	// if player has strafed around behind, don't lob the missile out of our ass
	if (angledif(self.ideal_yaw, self.angles_y) > 80)
	{
		dir_x = v_forward_x;
		dir_y = v_forward_y;
		dir = normalize(dir);
	}
	
	missile = launch_projectile(org, dir * BOSS2_BALL_VEL, "voreball");

	SUB_ChangeModel (missile, "progs/v_spike.mdl");

	missile.avelocity = '300 300 300';
	missile.nextthink = time + 0.1;
	missile.think = ShalHome;
	missile.enemy = self.enemy;
	missile.touch = ShalMissileTouch;
	missile.lifetime_finished = time + 30;	 // blow up after a while
}

// ========================
// ranged attack
// ========================
void() guardian_fire =
{
	local vector org, dir;

	ai_face();
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	
	makevectors (self.angles);
	org = self.origin + v_forward * 69 + v_right * 20 + '0 0 39';
	dir = normalize ( self.enemy.origin - org);
	
	guardian_missile(org,dir);
	
	if ( vlen (self.enemy.origin - self.origin) > 400 )
	{
		LaunchLaser(org, (dir + v_right * 0.04) * 600);
		LaunchLaser(org, (dir - v_right * 0.04) * 600);
	}
	else
	{
		LaunchLaser(org, (dir + v_right * 0.10) * 600);
		LaunchLaser(org, (dir - v_right * 0.10) * 600);	
	}

};

// ============================
// Charging - monster spawning
// ============================

void() prepare_for_charging=
{
	self.pain_finished = time + 2;
	self.count = self.count + 1;
	self.takedamage = DAMAGE_NO;
	self.think = guardian_charging_on01;
	self.nextthink = time + 0.1;
}

float() check_monster_spawning = 
{
	if(self.health < 5800 && self.count == 0)
	{
		prepare_for_charging();
		return TRUE;
	}
	else if(self.health < 4600 && self.count == 1)
	{
		prepare_for_charging();
		return TRUE;
	}
	else if(self.health < 3400 && self.count == 2)
	{
		prepare_for_charging();
		return TRUE;
	}
	else if(self.health < 2200 && self.count == 3)
	{
		prepare_for_charging();
		return TRUE;
	}
	return FALSE;
}

void() guardian_emit_lightning =
{
	if(self.lip < 10)
	{
		//LightningBeam (self.origin, self.origin + '0 0 2000', self, 0);
		fx_beam(self.origin + '0 0 32', self.origin + '0 0 2000', self);
		self.think = guardian_emit_lightning;
		self.lip++;
	}
	else
	{
		remove(self);
	}
	self.nextthink = time + 0.2;
}

void() guardian_lightning_emitter =
{
	entity lightning_ent;
	lightning_ent = spawn();
	lightning_ent.owner = self;
	lightning_ent.classname = "guardian_lightning_emitter";
	lightning_ent.solid = SOLID_NOT;
	setsize (lightning_ent, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (lightning_ent, self.origin + '0 0 176');
	
	lightning_ent.think = guardian_emit_lightning;
	lightning_ent.nextthink = time + 0.2;
}

void() guardian_charge =
{
	guardian_lightning_emitter();
	self.think = spawn_wave;
	self.nextthink = time + 3;
}

void() spawn_wave = 
{
	if(self.count == 1)
	{
		SUB_UseTargets();
	}
	else if(self.count == 2)
	{
		SUB_UseTargets();
	}
	else if(self.count == 3)
	{
		SUB_UseTargets();
	}
	else if(self.count == 4)
	{
		SUB_UseTargets();
	}
	
	guardian_charging_off01();
}

void() guardian_fire1 = [ $mfata01, guardian_fire2 ] {ai_face();};
void() guardian_fire2 = [ $mfata02, guardian_fire3 ] {ai_face();};
void() guardian_fire3 = [ $mfata03, guardian_fire4 ] {ai_face();};
void() guardian_fire4 = [ $mfata04, guardian_fire5 ] {guardian_fire();};
void() guardian_fire5 = [ $mfata05, guardian_fire6 ] {ai_face();};
void() guardian_fire6 = [ $mfata06, guardian_fire7 ] {ai_face();};
void() guardian_fire7 = [ $mfata07, guardian_fire8 ] {ai_face();};
void() guardian_fire8 = [ $mfata08, guardian_fire9] {ai_face();};
void() guardian_fire9 = [ $mfata09, guardian_run1 ] {ai_face();};

void() guardian_charging_on01 = [ $mfchrg01, guardian_charging_on02 ] {};
void() guardian_charging_on02 = [ $mfchrg02, guardian_charging_on03 ] {};
void() guardian_charging_on03 = [ $mfchrg03, guardian_charging_on04 ] {};
void() guardian_charging_on04 = [ $mfchrg04, guardian_charging_on05 ] {};
void() guardian_charging_on05 = [ $mfchrg05, guardian_charging_on06 ] {};
void() guardian_charging_on06 = [ $mfchrg06, guardian_charging_on07 ] {};
void() guardian_charging_on07 = [ $mfchrg07, guardian_charging_on08 ] {};
void() guardian_charging_on08 = [ $mfchrg08, guardian_charging_on09 ] {};
void() guardian_charging_on09 = [ $mfchrg09, guardian_charging_on09 ] {guardian_charge();};

void() guardian_charging_off01 = [ $mfchrg09, guardian_charging_off02 ] {};
void() guardian_charging_off02 = [ $mfchrg08, guardian_charging_off03 ] {};
void() guardian_charging_off03 = [ $mfchrg07, guardian_charging_off04 ] {};
void() guardian_charging_off04 = [ $mfchrg06, guardian_charging_off05 ] {};
void() guardian_charging_off05 = [ $mfchrg05, guardian_charging_off06 ] {};
void() guardian_charging_off06 = [ $mfchrg04, guardian_charging_off07 ] {};
void() guardian_charging_off07 = [ $mfchrg03, guardian_charging_off08 ] {};
void() guardian_charging_off08 = [ $mfchrg02, guardian_charging_off09 ] {};
void() guardian_charging_off09 = [ $mfchrg01, guardian_run1 ] {self.takedamage = DAMAGE_AIM;};

// ========================
// pain
// ========================
void() guardian_painA1 = [ $mfpain01, guardian_painA2 ] {};
void() guardian_painA2 = [ $mfpain02, guardian_painA3 ] {};
void() guardian_painA3 = [ $mfpain03, guardian_painA4 ] {};
void() guardian_painA4 = [ $mfpain04, guardian_painA5 ] {};
void() guardian_painA5 = [ $mfpain05, guardian_painA6 ] {};
void() guardian_painA6 = [ $mfpain06, guardian_painA7 ] {};
void() guardian_painA7 = [ $mfpain07, guardian_painA8 ] {};
void() guardian_painA8 = [ $mfpain08, guardian_painA9 ] {};
void() guardian_painA9 = [ $mfpain09, guardian_painA10 ] {};
void() guardian_painA10 = [ $mfpain10, guardian_run1 ] {check_monster_spawning();};

void() guardian_painB1 = [ $mfpbin01, guardian_painB2 ] {};
void() guardian_painB2 = [ $mfpbin02, guardian_painB3 ] {};
void() guardian_painB3 = [ $mfpbin03, guardian_painB4 ] {};
void() guardian_painB4 = [ $mfpbin04, guardian_painB5 ] {};
void() guardian_painB5 = [ $mfpbin05, guardian_painB6 ] {};
void() guardian_painB6 = [ $mfpbin06, guardian_painB7 ] {};
void() guardian_painB7 = [ $mfpbin07, guardian_run1 ] {check_monster_spawning();};

void(entity attacker, float damage) guardian_pain =
{
	if (self.pain_finished > time)
		return;
	
	if(check_monster_spawning())
		return;
	
	if (random() > 0.10)
		return;
	
	self.pain_finished = time + 2;

	sound (self, CHAN_VOICE, "guard/pain1.wav", 1, ATTN_NORM );

	if (random() > 0.6)
		self.think = guardian_painB1;
	else
		self.think = guardian_painA1;
	
	self.nextthink = time + 0.1;
};

// ========================
// die
// ========================
void() guardian_die1 = [ $mfdth01, guardian_die2 ] {};
void() guardian_die2 = [ $mfdth02, guardian_die3 ] {};
void() guardian_die3 = [ $mfdth03, guardian_die4 ] {};
void() guardian_die4 = [ $mfdth04, guardian_die5 ] {};
void() guardian_die5 = [ $mfdth05, guardian_die6 ] {self.skin = 1;};
void() guardian_die6 = [ $mfdth06, guardian_die7 ] {};
void() guardian_die7 = [ $mfdth07, guardian_die8 ] {};
void() guardian_die8 = [ $mfdth08, guardian_die9 ] {};
void() guardian_die9 = [ $mfdth09, guardian_die10 ] {};
void() guardian_die10 = [ $mfdth10, guardian_die11 ] {self.skin = 2;};
void() guardian_die11 = [ $mfdth11, guardian_die12 ] {};
void() guardian_die12 = [ $mfdth12, guardian_die13 ] {};
void() guardian_die13 = [ $mfdth13, guardian_die14 ] {};
void() guardian_die14 = [ $mfdth14, guardian_die15 ] {};
void() guardian_die15 = [ $mfdth15, guardian_die16 ] {self.skin = 3;};
void() guardian_die16 = [ $mfdth16, guardian_die17 ] {};
void() guardian_die17 = [ $mfdth17, guardian_die18 ] {};
void() guardian_die18 = [ $mfdth18, guardian_die19 ] {};
void() guardian_die19 = [ $mfdth19, guardian_die20 ] {};
void() guardian_die20 = [ $mfdth20, guardian_die21 ] {};
void() guardian_die21 = [ $mfdth21, guardian_die21 ] 
{
	remove(self);
};

void() guardian_die =
{
 	sound ( self, CHAN_VOICE, "guard/death.wav", 1, ATTN_NORM);
    self.solid = SOLID_NOT;
    self.think = guardian_die1;
    self.nextthink = time + 0.1;
};


// ========================
// hide in floor
// ========================
void() guardian_wake1 = [ $start01, guardian_wake2 ] 
{
	sound ( self, CHAN_VOICE, "guard/see1.wav", 1, ATTN_NORM );
};
void() guardian_wake2 = [ $start02, guardian_wake3 ] {};
void() guardian_wake3 = [ $start03, guardian_wake4 ] {};
void() guardian_wake4 = [ $start04, guardian_wake5 ] {};
void() guardian_wake5 = [ $start05, guardian_wake6 ] {};
void() guardian_wake6 = [ $start06, guardian_wake7 ] {};
void() guardian_wake7 = [ $start07, guardian_wake8 ] {};
void() guardian_wake8 = [ $start08, guardian_wake9 ] {};
void() guardian_wake9 = [ $start09, guardian_wake10 ] {self.skin = 2;};
void() guardian_wake10 = [ $start10, guardian_wake11 ] {};
void() guardian_wake11 = [ $start11, guardian_wake12 ] {};
void() guardian_wake12 = [ $start12, guardian_wake13 ] {};
void() guardian_wake13 = [ $start13, guardian_wake14 ] {};
void() guardian_wake14 = [ $start14, guardian_wake15 ] {};
void() guardian_wake15 = [ $start15, guardian_wake16 ] {};
void() guardian_wake16 = [ $start16, guardian_wake17 ] {};
void() guardian_wake17 = [ $start17, guardian_wake18 ] {self.skin = 1;};
void() guardian_wake18 = [ $start18, guardian_wake19 ] {};
void() guardian_wake19 = [ $start19, guardian_wake20 ] {};
void() guardian_wake20 = [ $start20, guardian_wake21 ] {};
void() guardian_wake21 = [ $start21, guardian_wake22 ] {};
void() guardian_wake22 = [ $start22, guardian_wake23 ] {};
void() guardian_wake23 = [ $start23, guardian_wake24 ] {};
void() guardian_wake24 = [ $start24, guardian_wake25 ] {};
void() guardian_wake25 = [ $start25, guardian_wake26 ] {self.skin = 0;};
void() guardian_wake26 = [ $start26, guardian_wake27 ] {};
void() guardian_wake27 = [ $start27, guardian_wake28 ] {};
void() guardian_wake28 = [ $start28, guardian_wake29 ] {};
void() guardian_wake29 = [ $start29, guardian_wake30 ] {};
void() guardian_wake30 = [ $start30, guardian_wake31 ] {};
void() guardian_wake31 = [ $start31, guardian_stand1 ] 
{
	self.solid = SOLID_SLIDEBOX;
	self.takedamage = DAMAGE_AIM;
	
	self.th_stand = guardian_stand1;
	self.th_walk = guardian_walk1;
	self.th_run = guardian_run1;
	
	///	Hack to stop copper from killing Guardian on touch, 
	///	when spawning...
	self.mins = self.mins + '4 4 0';
	self.maxs = self.maxs - '4 4 0';
	
	walkmonster_start();
	
	setsize (self, self.cmins, self.cmaxs);
};

void() guardian_try_to_wake =
{
	self.solid = SOLID_SLIDEBOX;
	if (!walkmove (0, 0))
	{
		self.solid = SOLID_NOT;
		self.think = guardian_try_to_wake;
		self.nextthink = time + 1;
	}
	else
	{
		self.effects = self.effects | EF_DIMLIGHT;
		guardian_wake1();
	}
}

void(entity e) monster_guardian_start =
{
	local entity oself;

	oself = self;
	self = e;
	
	self.classname = "monster_guardian";

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/guardian.mdl");

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -48', '0 0 -48');
	else setsize (self, self.cmins, self.cmaxs);
	
	self.th_stand = guardian_wake1;
	self.th_walk = guardian_wake1;
	self.th_run = guardian_wake1;
	self.th_missile = guardian_fire1;
	self.th_melee = guardian_attack;
	self.th_pain = guardian_pain;
	self.th_die = guardian_die;
	self.th_checkattack = CheckAttack;
	
	if (self.obituary == "") self.obituary = "was crushed by the Guardian";
	
	self.takedamage = DAMAGE_NO;
	self.flags = self.flags | FL_MONSTER;
	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 20;
	self.view_ofs = '0 0 25';
	self.frame = $start01;

	if (!self.health) self.health = 7000;

	self.skin = 3;
	self.lip = 0;
	
	guardian_try_to_wake();

	self = oself;
};


void() monster_guardian_spawner = {
	monster_spawner(monster_guardian_start);
}


/*QUAKED monster_guardian (1 0 0) (-32 -32 -24) (32 32 64)
The morphing monster.

If the monster has a targetname (triggered by something) he will rise up out of the floor when triggered.
*/
void() monster_guardian =
{
	if (!SUB_InitEntity()) return;
	
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/guardian.mdl");
	//precache_model ("progs/morph_eg.mdl");
	
	precache_model2 ("progs/v_spike.mdl");
	precache_model2 ("progs/laser.mdl");
	precache_sound2 ("enforcer/enfire.wav");
	precache_sound2 ("enforcer/enfstop.wav");
	precache_sound2 ("guard/death.wav");
	precache_sound2 ("guard/pain1.wav");
	precache_sound2 ("guard/see1.wav");
	precache_sound2 ("shalrath/attack2.wav");
	
	self.cmins = '-32 -32 -48';
	self.cmaxs = '32 32 88';
	
	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -48', '0 0 -48');
	else setsize (self, self.cmins, self.cmaxs);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_guardian_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_guardian_start(self);
	}
};