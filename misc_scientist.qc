void() scientist_work;
void() scientist_work_sounds;
void() scientist_scared_sounds;
void() scientist_die_sounds;

$frame a1 a2 a3 a4 a5 a6 a7 a8 a9 a10
$frame a11 a12 a13 a14 a15 a16

$frame b1 b2 b3 b4 b5 b6 b7 b8 b9 b10

$frame d1 d2 d3 d4 d5 d6 d7 d8 d9 d10
$frame d11 d12 d13 d14 d15 d16 d17 d18 d19 d20
$frame d21 d22 d23 d24 d25 d26 d27 d28 d29 d30
$frame d31 d32 d33 d34 d35 d36 d37 d38 d39 d40
$frame d41 d42 d43 d44 d45 d46

$frame death1 death2 death3 death4 death5 death6
$frame death7 death8 death9 death10 death11 death12

$frame walk1 walk2 walk3 walk4 walk5 walk6
$frame walk7 walk8 walk9 walk10 walk11 walk12

$frame walka1 walka2 walka3 walka4 walka5 walka6
$frame walka7 walka8 walka9 walka10 walka11 walka12

$frame duck1 duck2 duck3 duck4 duck5 duck6
$frame cower1 cower2

void()	scientist_work_a_01		=[	$a1,	scientist_work_a_02	] {ai_stand();scientist_work_sounds();};
void()	scientist_work_a_02		=[	$a2,	scientist_work_a_03	] {ai_stand();};
void()	scientist_work_a_03		=[	$a3,	scientist_work_a_04	] {ai_stand();};
void()	scientist_work_a_04		=[	$a4,	scientist_work_a_05	] {ai_stand();};
void()	scientist_work_a_05		=[	$a5,	scientist_work_a_06	] {ai_stand();};
void()	scientist_work_a_06		=[	$a6,	scientist_work_a_07	] {ai_stand();};
void()	scientist_work_a_07		=[	$a7,	scientist_work_a_08	] {ai_stand();};
void()	scientist_work_a_08		=[	$a8,	scientist_work_a_09	] {ai_stand();};
void()	scientist_work_a_09		=[	$a9,	scientist_work_a_10	] {ai_stand();};
void()	scientist_work_a_10		=[	$a10,	scientist_work_a_11	] {ai_stand();};
void()	scientist_work_a_11		=[	$a11,	scientist_work_a_12	] {ai_stand();};
void()	scientist_work_a_12		=[	$a12,	scientist_work_a_13	] {ai_stand();};
void()	scientist_work_a_13		=[	$a13,	scientist_work_a_14	] {ai_stand();};
void()	scientist_work_a_14		=[	$a14,	scientist_work_a_15	] {ai_stand();};
void()	scientist_work_a_15		=[	$a15,	scientist_work_a_16	] {ai_stand();};
void()	scientist_work_a_16		=[	$a16,	scientist_work_a_01	] {ai_stand();scientist_work();};

void()	scientist_work_b_01		=[	$b1,	scientist_work_b_02	] {ai_stand();scientist_work_sounds();};
void()	scientist_work_b_02		=[	$b2,	scientist_work_b_03	] {ai_stand();};
void()	scientist_work_b_03		=[	$b3,	scientist_work_b_04	] {ai_stand();};
void()	scientist_work_b_04		=[	$b4,	scientist_work_b_05	] {ai_stand();};
void()	scientist_work_b_05		=[	$b5,	scientist_work_b_06	] {ai_stand();};
void()	scientist_work_b_06		=[	$b6,	scientist_work_b_07	] {ai_stand();};
void()	scientist_work_b_07		=[	$b7,	scientist_work_b_08	] {ai_stand();};
void()	scientist_work_b_08		=[	$b8,	scientist_work_b_09	] {ai_stand();};
void()	scientist_work_b_09		=[	$b9,	scientist_work_b_10	] {ai_stand();};
void()	scientist_work_b_10		=[	$b10,	scientist_work_b_01	] {ai_stand();scientist_work();};

void()	scientist_work_d_01		=[	$d1,	scientist_work_d_02	] {ai_stand();scientist_work_sounds();};
void()	scientist_work_d_02		=[	$d2,	scientist_work_d_03	] {ai_stand();};
void()	scientist_work_d_03		=[	$d3,	scientist_work_d_04	] {ai_stand();};
void()	scientist_work_d_04		=[	$d4,	scientist_work_d_05	] {ai_stand();};
void()	scientist_work_d_05		=[	$d5,	scientist_work_d_06	] {ai_stand();};
void()	scientist_work_d_06		=[	$d6,	scientist_work_d_07	] {ai_stand();};
void()	scientist_work_d_07		=[	$d7,	scientist_work_d_08	] {ai_stand();};
void()	scientist_work_d_08		=[	$d8,	scientist_work_d_09	] {ai_stand();};
void()	scientist_work_d_09		=[	$d9,	scientist_work_d_10	] {ai_stand();};
void()	scientist_work_d_10		=[	$d10,	scientist_work_d_11	] {ai_stand();};
void()	scientist_work_d_11		=[	$d11,	scientist_work_d_12	] {ai_stand();};
void()	scientist_work_d_12		=[	$d12,	scientist_work_d_13	] {ai_stand();};
void()	scientist_work_d_13		=[	$d13,	scientist_work_d_14	] {ai_stand();};
void()	scientist_work_d_14		=[	$d14,	scientist_work_d_15	] {ai_stand();};
void()	scientist_work_d_15		=[	$d15,	scientist_work_d_16	] {ai_stand();};
void()	scientist_work_d_16		=[	$d16,	scientist_work_d_17	] {ai_stand();};
void()	scientist_work_d_17		=[	$d17,	scientist_work_d_18	] {ai_stand();};
void()	scientist_work_d_18		=[	$d18,	scientist_work_d_19	] {ai_stand();};
void()	scientist_work_d_19		=[	$d19,	scientist_work_d_20	] {ai_stand();};
void()	scientist_work_d_20		=[	$d20,	scientist_work_d_21	] {ai_stand();};
void()	scientist_work_d_21		=[	$d21,	scientist_work_d_22	] {ai_stand();};
void()	scientist_work_d_22		=[	$d22,	scientist_work_d_23	] {ai_stand();};
void()	scientist_work_d_23		=[	$d23,	scientist_work_d_24	] {ai_stand();};
void()	scientist_work_d_24		=[	$d24,	scientist_work_d_25	] {ai_stand();};
void()	scientist_work_d_25		=[	$d25,	scientist_work_d_26	] {ai_stand();};
void()	scientist_work_d_26		=[	$d26,	scientist_work_d_27	] {ai_stand();};
void()	scientist_work_d_27		=[	$d27,	scientist_work_d_28	] {ai_stand();};
void()	scientist_work_d_28		=[	$d28,	scientist_work_d_29	] {ai_stand();};
void()	scientist_work_d_29		=[	$d29,	scientist_work_d_30	] {ai_stand();};
void()	scientist_work_d_30		=[	$d30,	scientist_work_d_31	] {ai_stand();};
void()	scientist_work_d_31		=[	$d31,	scientist_work_d_32	] {ai_stand();};
void()	scientist_work_d_32		=[	$d32,	scientist_work_d_33	] {ai_stand();};
void()	scientist_work_d_33		=[	$d33,	scientist_work_d_34	] {ai_stand();};
void()	scientist_work_d_34		=[	$d34,	scientist_work_d_35	] {ai_stand();};
void()	scientist_work_d_35		=[	$d35,	scientist_work_d_36	] {ai_stand();};
void()	scientist_work_d_36		=[	$d36,	scientist_work_d_37	] {ai_stand();};
void()	scientist_work_d_37		=[	$d37,	scientist_work_d_38	] {ai_stand();};
void()	scientist_work_d_38		=[	$d38,	scientist_work_d_39	] {ai_stand();};
void()	scientist_work_d_39		=[	$d39,	scientist_work_d_40	] {ai_stand();};
void()	scientist_work_d_40		=[	$d40,	scientist_work_d_41	] {ai_stand();};
void()	scientist_work_d_41		=[	$d41,	scientist_work_d_42	] {ai_stand();};
void()	scientist_work_d_42		=[	$d42,	scientist_work_d_43	] {ai_stand();};
void()	scientist_work_d_43		=[	$d43,	scientist_work_d_44	] {ai_stand();};
void()	scientist_work_d_44		=[	$d44,	scientist_work_d_45	] {ai_stand();};
void()	scientist_work_d_45		=[	$d45,	scientist_work_d_46	] {ai_stand();};
void()	scientist_work_d_46		=[	$d46,	scientist_work_d_01	] {ai_stand();scientist_work();};

void() scientist_work =
{
	local float rng;
	
	rng = random();
	
	if (rng < 0.3)
	{
		scientist_work_d_01();
	}
	else if(rng < 0.6)
	{
		scientist_work_b_01();
	}
	else
	{
		scientist_work_a_01();
	}
}

void()	scientist_death_01		=[	$death1,	scientist_death_02	] {self.solid = SOLID_NOT;};
void()	scientist_death_02		=[	$death2,	scientist_death_03	] {scientist_die_sounds();};
void()	scientist_death_03		=[	$death3,	scientist_death_04	] {};
void()	scientist_death_04		=[	$death4,	scientist_death_05	] {};
void()	scientist_death_05		=[	$death5,	scientist_death_06	] {};
void()	scientist_death_06		=[	$death6,	scientist_death_07	] {};
void()	scientist_death_07		=[	$death7,	scientist_death_08	] {};
void()	scientist_death_08		=[	$death8,	scientist_death_09	] {};
void()	scientist_death_09		=[	$death9,	scientist_death_10	] {};
void()	scientist_death_10		=[	$death10,	scientist_death_11	] {};
void()	scientist_death_11		=[	$death11,	scientist_death_12	] {};
void()	scientist_death_12		=[	$death12,	scientist_death_12	] {};

void()	scientist_walk_01		=[	$walk1,		scientist_walk_02	] {ai_walk(4);};
void()	scientist_walk_02		=[	$walk2,		scientist_walk_03	] {ai_walk(3);};
void()	scientist_walk_03		=[	$walk3,		scientist_walk_04	] {ai_walk(3);};
void()	scientist_walk_04		=[	$walk4,		scientist_walk_05	] {ai_walk(3);};
void()	scientist_walk_05		=[	$walk5,		scientist_walk_06	] {ai_walk(4);};
void()	scientist_walk_06		=[	$walk6,		scientist_walk_07	] {ai_walk(4);};
void()	scientist_walk_07		=[	$walk7,		scientist_walk_08	] {ai_walk(5);};
void()	scientist_walk_08		=[	$walk8,		scientist_walk_09	] {ai_walk(4);};
void()	scientist_walk_09		=[	$walk9,		scientist_walk_10	] {ai_walk(3);};
void()	scientist_walk_10		=[	$walk10,	scientist_walk_11	] {ai_walk(2);};
void()	scientist_walk_11		=[	$walk11,	scientist_walk_12	] {ai_walk(3);};
void()	scientist_walk_12		=[	$walk12,	scientist_walk_01	] {ai_walk(3);};

void()	scientist_run_away_01	=[	$walka1,	scientist_run_away_02	] {ai_run_away(30);scientist_scared_sounds();};
void()	scientist_run_away_02	=[	$walka3,	scientist_run_away_03	] {ai_run_away(30);};
void()	scientist_run_away_03	=[	$walka11,	scientist_run_away_04	] {ai_run_away(30);};
void()	scientist_run_away_04	=[	$walka9,	scientist_run_away_01	] {ai_run_away(30);};

void()	scientist_duck_01		=[	$duck1,		scientist_duck_02	] {};
void()	scientist_duck_02		=[	$duck2,		scientist_duck_03	] {};
void()	scientist_duck_03		=[	$duck3,		scientist_duck_04	] {};
void()	scientist_duck_04		=[	$duck4,		scientist_duck_05	] {};
void()	scientist_duck_05		=[	$duck5,		scientist_duck_06	] {};
void()	scientist_duck_06		=[	$duck6,		scientist_cower_01	] {};

void()	scientist_cower_01		=[	$cower1,	scientist_cower_02	] {};
void()	scientist_cower_02		=[	$cower2,	scientist_cower_01	] {};

void() scientist_work_sounds =
{
	local float rng;
	
	if(time < self.aflag)
		return;
	
	rng = random();
	if(rng >= 0.3)
		return;
	
	rng = random();
	if (rng < 0.125)
	{
		sound (self, CHAN_VOICE, "scientist/allnominal.wav", 1, ATTN_NORM);
	}
	else if(rng < 0.25)
	{
		sound (self, CHAN_VOICE, "scientist/alright.wav", 1, ATTN_NORM);
	}
	else if(rng < 0.375)
	{
		sound (self, CHAN_VOICE, "scientist/asexpected.wav", 1, ATTN_NORM);
	}
	else if(rng < 0.5)
	{
		sound (self, CHAN_VOICE, "scientist/c1a0_sci_crit2a.wav", 1, ATTN_NORM);
	}
	else if(rng < 0.625)
	{
		sound (self, CHAN_VOICE, "scientist/cough.wav", 1, ATTN_NORM);
	}
	else if(rng < 0.75)
	{
		sound (self, CHAN_VOICE, "scientist/cantbeserious.wav", 1, ATTN_NORM);
	}
	else
	{
		sound (self, CHAN_VOICE, "scientist/c1a0_sci_stall.wav", 1, ATTN_NORM);
	}
	self.aflag = time + 3;
};

void() scientist_scared_sounds =
{
	local float rng;
	
	if(time < self.aflag)
		return;
	
	rng = random();
	if (rng < 1/18)
	{
		sound (self, CHAN_VOICE, "scientist/sci_fear6.wav", 1, ATTN_NORM);
	}
	else if (rng < 2/18)
	{
		sound (self, CHAN_VOICE, "scientist/sci_fear7.wav", 1, ATTN_NORM);
	}
	else if (rng < 3/18)
	{
		sound (self, CHAN_VOICE, "scientist/sci_fear8.wav", 1, ATTN_NORM);
	}
	else if (rng < 4/18)
	{
		sound (self, CHAN_VOICE, "scientist/sci_fear13.wav", 1, ATTN_NORM);
	}
	else if (rng < 5/18)
	{
		sound (self, CHAN_VOICE, "scientist/sci_fear15.wav", 1, ATTN_NORM);
	}
	else if (rng < 6/18)
	{
		sound (self, CHAN_VOICE, "scientist/scream01.wav", 1, ATTN_NORM);
	}
	else if (rng < 7/18)
	{
		sound (self, CHAN_VOICE, "scientist/scream06.wav", 1, ATTN_NORM);
	}
	else if (rng < 8/18)
	{
		sound (self, CHAN_VOICE, "scientist/scream09.wav", 1, ATTN_NORM);
	}
	else if (rng < 9/18)
	{
		sound (self, CHAN_VOICE, "scientist/scream10.wav", 1, ATTN_NORM);
	}
	else if (rng < 10/18)
	{
		sound (self, CHAN_VOICE, "scientist/scream14.wav", 1, ATTN_NORM);
	}
	else if (rng < 11/18)
	{
		sound (self, CHAN_VOICE, "scientist/scream15.wav", 1, ATTN_NORM);
	}
	else if (rng < 12/18)
	{
		sound (self, CHAN_VOICE, "scientist/scream16.wav", 1, ATTN_NORM);
	}
	else if (rng < 13/18)
	{
		sound (self, CHAN_VOICE, "scientist/scream17.wav", 1, ATTN_NORM);
	}else if (rng < 14/18)
	{
		sound (self, CHAN_VOICE, "scientist/scream18.wav", 1, ATTN_NORM);
	}
	else if (rng < 15/18)
	{
		sound (self, CHAN_VOICE, "scientist/scream19.wav", 1, ATTN_NORM);
	}
	else if (rng < 16/18)
	{
		sound (self, CHAN_VOICE, "scientist/scream20.wav", 1, ATTN_NORM);
	}
	else if (rng < 17/18)
	{
		sound (self, CHAN_VOICE, "scientist/scream22.wav", 1, ATTN_NORM);
	}
	else
	{
		sound (self, CHAN_VOICE, "scientist/scream25.wav", 1, ATTN_NORM);
	}
	
	self.aflag = time + 3;
};
void() scientist_die_sounds =
{
	local float rng;
	
	rng = random();
	if (rng < 1/5)
	{
		sound (self, CHAN_VOICE, "scientist/sci_die1.wav", 1, ATTN_NORM);
	}
	else if (rng < 2/5)
	{
		sound (self, CHAN_VOICE, "scientist/scream08.wav", 1, ATTN_NORM);
		
	}
	else if (rng < 3/5)
	{
		sound (self, CHAN_VOICE, "scientist/scream23.wav", 1, ATTN_NORM);
	}
	else if (rng < 4/5)
	{
		sound (self, CHAN_VOICE, "scientist/scream24.wav", 1, ATTN_NORM);
	}
	else
	{
		sound (self, CHAN_VOICE, "scientist/sci_dragoff.wav", 1, ATTN_NORM);
	}
};

void() scientist_die =
{
// check for gib
	if (self.health < -15 || random() < 0.2)
	{
		sound (self, CHAN_VOICE, "zombie/z_gib.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_zombie.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		return;
	}

	scientist_death_01();
};

void() misc_scientist =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/misc_scientist.mdl");
	precache_model ("progs/h_zombie.mdl");

	precache_sound ("zombie/z_gib.wav");
	
	//	Idle sounds
	precache_sound ("scientist/allnominal.wav");
	precache_sound ("scientist/alright.wav");
	precache_sound ("scientist/asexpected.wav");
	precache_sound ("scientist/c1a0_sci_crit2a.wav");
	precache_sound ("scientist/cough.wav");
	precache_sound ("scientist/cantbeserious.wav");
	precache_sound ("scientist/c1a0_sci_stall.wav");
	
	//	Death sounds
	precache_sound ("scientist/sci_die1.wav");
	precache_sound ("scientist/scream08.wav");
	precache_sound ("scientist/scream23.wav");
	precache_sound ("scientist/scream24.wav");
	precache_sound ("scientist/sci_dragoff.wav");
	
	//	Scream sounds
	precache_sound ("scientist/sci_fear6.wav");
	precache_sound ("scientist/sci_fear7.wav");
	precache_sound ("scientist/sci_fear8.wav");
	precache_sound ("scientist/sci_fear13.wav");
	precache_sound ("scientist/sci_fear15.wav");
	precache_sound ("scientist/scream01.wav");
	precache_sound ("scientist/scream06.wav");
	precache_sound ("scientist/scream09.wav");
	precache_sound ("scientist/scream10.wav");
	precache_sound ("scientist/scream14.wav");
	precache_sound ("scientist/scream15.wav");
	precache_sound ("scientist/scream16.wav");
	precache_sound ("scientist/scream17.wav");
	precache_sound ("scientist/scream18.wav");
	precache_sound ("scientist/scream19.wav");
	precache_sound ("scientist/scream20.wav");
	precache_sound ("scientist/scream22.wav");
	precache_sound ("scientist/scream25.wav");
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.flags = self.flags | FL_PACIFIST;

	setmodel (self, "progs/misc_scientist.mdl");

	setsize (self, '-16 -16 -24', '16 16 40');
	self.health = 15;

	self.th_stand = scientist_work;
	self.th_walk = scientist_walk_01;
	self.th_run = scientist_run_away_01;
	self.th_melee = SUB_Null;
	self.th_pain = SUB_NullPain;
	self.th_die = scientist_die;
	
	walkpacifist_start ();
};