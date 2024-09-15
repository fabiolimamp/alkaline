/*
==============================================================================

PLAYER

==============================================================================
*/


//
// running
//
$frame axrun1 axrun2 axrun3 axrun4 axrun5 axrun6

$frame rockrun1 rockrun2 rockrun3 rockrun4 rockrun5 rockrun6

$frame sawrun1 sawrun2 sawrun3 sawrun4 sawrun5 sawrun6

//
// standing
//
$frame stand1 stand2 stand3 stand4 stand5

$frame swstnd1 swstnd2 swstnd3 swstnd4 swstnd5

$frame axstnd1 axstnd2 axstnd3 axstnd4 axstnd5 axstnd6
$frame axstnd7 axstnd8 axstnd9 axstnd10 axstnd11 axstnd12


//
// pain
//
$frame axpain1 axpain2 axpain3 axpain4 axpain5 axpain6

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame swpain1 swpain2 swpain3 swpain4 swpain5 swpain6

//
// death
//

$frame axdeth1 axdeth2 axdeth3 axdeth4 axdeth5 axdeth6
$frame axdeth7 axdeth8 axdeth9

$frame swdeth1 swdeth2 swdeth3 swdeth4 swdeth5 swdeth6
$frame swdeth7 swdeth8 swdeth9

$frame deatha1 deatha2 deatha3 deatha4 deatha5 deatha6 deatha7 deatha8
$frame deatha9 deatha10 deatha11

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9

$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8
$frame deathc9 deathc10 deathc11 deathc12 deathc13 deathc14 deathc15

$frame deathd1 deathd2 deathd3 deathd4 deathd5 deathd6 deathd7
$frame deathd8 deathd9

$frame deathe1 deathe2 deathe3 deathe4 deathe5 deathe6 deathe7
$frame deathe8 deathe9

//
// attacks
//
$frame nailatt1 nailatt2

$frame sawatt1 sawatt2

$frame light1 light2

$frame rockatt1 rockatt2 rockatt3 rockatt4 rockatt5 rockatt6

$frame shotatt1 shotatt2 shotatt3 shotatt4 shotatt5 shotatt6

$frame axatt1 axatt2 axatt3 axatt4 axatt5 axatt6

$frame axattb1 axattb2 axattb3 axattb4 axattb5 axattb6

$frame axattc1 axattc2 axattc3 axattc4 axattc5 axattc6

$frame axattd1 axattd2 axattd3 axattd4 axattd5 axattd6


/*
===================================================================================================
PLAYER

All frame functions run with self as player.animcontroller, in order to keep them separate from
viewmodels animations.

===================================================================================================
*/



void() player_stand1 =[	$axstnd1,	player_stand1	] {
	self.owner.frame = self.frame;

	if (self.owner.velocity_x || self.owner.velocity_y) {
		self.owner.walkframe = 0;
		player_run();
		return;
	}
	

	if (self.owner.weapon == WEAPON_AXE) {
		if (self.owner.walkframe >= 12)
			self.owner.walkframe = 0;
		self.owner.frame = $axstnd1 + self.owner.walkframe;
	}
	else {
		if (self.owner.walkframe >= 5)
			self.owner.walkframe = 0;
		self.owner.frame = $stand1 + self.owner.walkframe;
	}
	self.owner.walkframe = self.owner.walkframe + 1;	
};



void()	player_run =[	$rockrun1,	player_run	] {
	self.owner.frame = self.frame;

	if (!self.owner.velocity_x && !self.owner.velocity_y)
	{
		self.owner.walkframe = 0;
		player_stand1();
		return;
	}


	if (self.owner.weapon == WEAPON_AXE) {
		if (self.owner.walkframe == 6)
			self.owner.walkframe = 0;
		self.owner.frame = $axrun1 + self.owner.walkframe;
	}
	else {
		if (self.owner.walkframe == 6)
			self.owner.walkframe = 0;
		self.owner.frame = self.owner.frame + self.owner.walkframe;
	}

	self.owner.walkframe = self.owner.walkframe + 1;

	if ((self.owner.walkframe == 1 || self.owner.walkframe == 4) && self.owner.flags & FL_ONGROUND && !intermission_running) {
		// Need to be moving before feet sounds
		float spd;
		spd = vlen([self.owner.velocity_x, self.owner.velocity_y, 0]);
		if (spd > 50) {
			play_footstep(self.owner, FALSE, clamp(spd, 0, 320)/320);
		}
	}
};





void(entity ctrl, float seq) player_axe_start = {
	switch (seq) {
		case 0: ctrl.owner.frame = $axattc1;
		case 1: ctrl.owner.frame = $axattc1;
		case 2: ctrl.owner.frame = $axattb1;
		case 3: ctrl.owner.frame = $axattd1;
		case 4: ctrl.owner.frame = $axatt1;
	}

	ctrl.think = player_axe;
	ctrl.nextthink = time + 0.1;
}


void() player_axe = {
	/*
	if (self.owner.weaponframe == 2) self.owner.frame = $axattc1;
	if (self.owner.weaponframe == 12) self.owner.frame = $axattc1;
	if (self.owner.weaponframe == 22) self.owner.frame = $axattb1;
	if (self.owner.weaponframe == 32) self.owner.frame = $axattd1;
	if (self.owner.weaponframe == 42) self.owner.frame = $axatt1;
	*/
	if ((self.owner.frame - $axatt1 + 1) % 6 == 0) {
		player_run();
		return;
	}

	self.owner.frame++;

	self.think = player_axe;
	self.nextthink = time + 0.1;
}


void() player_chainsaw1   =[$sawatt1, player_chainsaw2 ] {self.owner.frame = self.frame;};
void() player_chainsaw2   =[$sawatt2, player_chainsaw1 ] {self.owner.frame = self.frame;};


void()	player_shot1 =	[$shotatt1, player_shot2	] {self.owner.frame = self.frame;};
void()	player_shot2 =	[$shotatt2, player_shot3	] {self.owner.frame = self.frame;};
void()	player_shot3 =	[$shotatt3, player_shot4	] {self.owner.frame = self.frame;};
void()	player_shot4 =	[$shotatt4, player_shot5	] {self.owner.frame = self.frame;};
void()	player_shot5 =	[$shotatt5, player_shot6	] {self.owner.frame = self.frame;};
void()	player_shot6 =	[$shotatt6, player_run		] {self.owner.frame = self.frame;};


void() player_nail1   =[$nailatt1, player_nail2 ] {self.owner.frame = self.frame;};
void() player_nail2   =[$nailatt2, player_nail1 ] {self.owner.frame = self.frame;};


void() player_rockatt1	=[$rockatt1, player_rockatt2 ] {self.owner.frame = self.frame;};
void() player_rockatt2	=[$rockatt2, player_rockatt3 ] {self.owner.frame = self.frame;};
void() player_rockatt3	=[$rockatt3, player_rockatt4 ] {self.owner.frame = self.frame;};
void() player_rockatt4	=[$rockatt4, player_rockatt5 ] {self.owner.frame = self.frame;};
void() player_rockatt5	=[$rockatt5, player_rockatt6 ] {self.owner.frame = self.frame;};
void() player_rockatt6	=[$rockatt6, player_run ] {self.owner.frame = self.frame;};


void() player_light1 = [$light1, player_light2  ] {self.owner.frame = self.frame;}
void() player_light2 = [$light2, player_light1  ] {self.owner.frame = self.frame;}




void(float dmgtype) PainSound = {
	local float		rs;

	if (self.health <= 0)
		return;

	if (damage_attacker.classname == "teledeath") {
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

	// HURT HURT HURT
	if (dmgtype == DMGTYPE_LAVA || dmgtype == DMGTYPE_SLIME || dmgtype == DMGTYPE_BURN) {
		if (random() > 0.5)
			sound (self, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);
		return;
	}

	// damage while underwater always makes drown sound, regardless of damage type
	if (dmgtype == DMGTYPE_DROWN || self.waterlevel >= 3) {
		DeathBubbles(1);
		if (random() > 0.5)
			sound (self, CHAN_VOICE, "player/drown1.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "player/drown2.wav", 1, ATTN_NORM);
		return;
	}


	// don't make multiple pain sounds right after each other
	if (self.pain_finished > time) {
		self.axhitme = 0;
		return;
	}

	self.pain_finished = time + 0.5;


	// ax pain sound
	if (self.axhitme == 1) {
		self.axhitme = 0;
		sound (self, CHAN_VOICE, "player/axhit1.wav", 1, ATTN_NORM);
		return;
	}
	

	rs = rint((random() * 5) + 1);

	string snd = "";
	if (rs == 1)
		snd = "player/pain1.wav";
	else if (rs == 2)
		snd = "player/pain2.wav";
	else if (rs == 3)
		snd = "player/pain3.wav";
	else if (rs == 4)
		snd = "player/pain4.wav";
	else if (rs == 5)
		snd = "player/pain5.wav";
	else
		snd = "player/pain6.wav";

	sound (self, CHAN_VOICE, snd, 1, ATTN_NORM);
};

void()	player_pain1 =	[	$pain1,	player_pain2	] {self.owner.frame = self.frame;};
void()	player_pain2 =	[	$pain2,	player_pain3	] {self.owner.frame = self.frame;};
void()	player_pain3 =	[	$pain3,	player_pain4	] {self.owner.frame = self.frame;};
void()	player_pain4 =	[	$pain4,	player_pain5	] {self.owner.frame = self.frame;};
void()	player_pain5 =	[	$pain5,	player_pain6	] {self.owner.frame = self.frame;};
void()	player_pain6 =	[	$pain6,	player_run	] {self.owner.frame = self.frame;};

void()	player_swpain1 =	[	$swpain1,	player_pain2	] {self.owner.frame = self.frame;};
void()	player_swpain2 =	[	$swpain2,	player_pain3	] {self.owner.frame = self.frame;};
void()	player_swpain3 =	[	$swpain3,	player_pain4	] {self.owner.frame = self.frame;};
void()	player_swpain4 =	[	$swpain4,	player_pain5	] {self.owner.frame = self.frame;};
void()	player_swpain5 =	[	$swpain5,	player_pain6	] {self.owner.frame = self.frame;};
void()	player_swpain6 =	[	$swpain6,	player_run		] {self.owner.frame = self.frame;};

void()	player_axpain1 =	[	$axpain1,	player_axpain2	] {self.owner.frame = self.frame;};
void()	player_axpain2 =	[	$axpain2,	player_axpain3	] {self.owner.frame = self.frame;};
void()	player_axpain3 =	[	$axpain3,	player_axpain4	] {self.owner.frame = self.frame;};
void()	player_axpain4 =	[	$axpain4,	player_axpain5	] {self.owner.frame = self.frame;};
void()	player_axpain5 =	[	$axpain5,	player_axpain6	] {self.owner.frame = self.frame;};
void()	player_axpain6 =	[	$axpain6,	player_run	] {self.owner.frame = self.frame;};


//=================================================================================================


inline void(entity attacker, float damage) player_pain_generic = {
	player_pain(attacker, damage, DMGTYPE_GENERIC);
};

void(entity attacker, float damage, float dmgtype) player_pain = {
	if (self.weaponframe)
		return;

	if (self.invisible_finished > time)
		return;		// eyes don't have pain frames

	PainSound(dmgtype);
	//self.weaponframe = 0;

	if (self.weapon == WEAPON_AXE)
		SUB_CallAsSelf(player_axpain1, self.animcontroller);
	else if (self.weapon == WEAPON_CHAINSAW)
		SUB_CallAsSelf(player_swpain1, self.animcontroller);
	else
		SUB_CallAsSelf(player_pain1, self.animcontroller);
};


void() DeathBubblesSpawn = {
	entity bubble;

	if (self.owner.waterlevel < 3)
		return;

	bubble = bubble_spawn(self.owner.origin + '0 0 24');
	
	self.nextthink = time + 0.1;
	self.think = DeathBubblesSpawn;
	self.air_finished = self.air_finished + 1;
	if (self.air_finished >= self.bubble_count)
		remove(self);
};

void(float num_bubbles) DeathBubbles = {
	entity bubble_spawner;
	
	bubble_spawner = spawn();
	setorigin (bubble_spawner, self.origin);
	bubble_spawner.movetype = MOVETYPE_NONE;
	bubble_spawner.solid = SOLID_NOT;
	bubble_spawner.nextthink = time + 0.1;
	bubble_spawner.think = DeathBubblesSpawn;
	bubble_spawner.air_finished = 0;
	bubble_spawner.owner = self;
	bubble_spawner.bubble_count = num_bubbles;
};


void() DeathSound = {
	float rs;

	// water death sounds
	if (self.waterlevel >= 3) {
		DeathBubbles(20);
		sound (self, CHAN_VOICE, "player/h2odeath.wav", 1, ATTN_NONE);
		return;
	}
	
	rs = rint ((random() * 4) + 1);
	if (rs == 1)
		self.noise = "player/death1.wav";
	if (rs == 2)
		self.noise = "player/death2.wav";
	if (rs == 3)
		self.noise = "player/death3.wav";
	if (rs == 4)
		self.noise = "player/death4.wav";
	if (rs == 5)
		self.noise = "player/death5.wav";

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NONE);
	return;
};



vector(float dm) VelocityForDamage = {
	vector v;

	v_x = 100 * crandom();
	v_y = 100 * crandom();
	v_z = 200 + 100 * random();

	if (dm > -50)
	{
//		dprint ("level 1\n");
		v = v * 0.7;
	}
	else if (dm > -200)
	{
//		dprint ("level 3\n");
		v = v * 2;
	}
	else
		v = v * 10;

	return v;
};

void() GibPlayer = {
	ThrowHead("progs/h_player.mdl", self.health);
	ThrowGib("progs/gib1.mdl", self.health);
	ThrowGib("progs/gib2.mdl", self.health);
	ThrowGib("progs/gib3.mdl", self.health);

	self.deadflag = DEAD_DEAD;

	if (damage_attacker.classname == "teledeath")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

	if (damage_attacker.classname == "teledeath2")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}
		
	if (random() < 0.5)
		sound (self, CHAN_VOICE, "player/gib.wav", 1, ATTN_NONE);
	else
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NONE);
};

void() VoidKillPlayer = {
	ThrowHeadVoid();
	self.deadflag = DEAD_DEAD;
	DeathSound();

};

void(float deathbyvoid) PlayerDieGo = {
	float i;
	
	StopBurning(self); //johnfitz
	
	self.items = self.items - (self.items & IT_INVISIBILITY);
	self.invisible_finished = 0;	// don't die as eyes
	self.invincible_finished = 0;
	self.trif_finished = 0;	
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.modelindex = modelindex_player;	// don't use eyes

	if (deathmatch || coop)
		DropBackpack();
	
	self.weaponmodel="";
	self.view_ofs = '0 0 -8';
	self.deadflag = DEAD_DYING;
	self.solid = SOLID_NOT;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.movetype = MOVETYPE_TOSS;
	
	if (deathbyvoid) {
		VoidKillPlayer();
		return;
	}

	if (self.velocity_z < 10)
		self.velocity_z = self.velocity_z + random()*300;

	if (self.health < -40) {
		GibPlayer ();
		return;
	}

	DeathSound();
	
	self.angles_x = 0;
	self.angles_z = 0;
	
	if (self.weapon == WEAPON_AXE) {
		SUB_CallAsSelf(player_die_ax1, self.animcontroller);
		return;
	}
	
	if (self.weapon == WEAPON_CHAINSAW) {
		SUB_CallAsSelf(player_die_sw1, self.animcontroller);
		return;
	}
	
	i = 1 + floor(random()*6);
	
	if (i == 1)
		SUB_CallAsSelf(player_diea1, self.animcontroller);
	else if (i == 2)
		SUB_CallAsSelf(player_dieb1, self.animcontroller);
	else if (i == 3)
		SUB_CallAsSelf(player_diec1, self.animcontroller);
	else if (i == 4)
		SUB_CallAsSelf(player_died1, self.animcontroller);
	else
		SUB_CallAsSelf(player_diee1, self.animcontroller);

}

void() PlayerDie = {
	PlayerDieGo(FALSE);
};

void() set_suicide_frame = {
	// used by klill command and diconnect command
	if (self.model != "progs/player.mdl")
		return;	// allready gibbed
	self.frame = $deatha11;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_TOSS;
	self.deadflag = DEAD_DEAD;
	self.nextthink = -1;
};


void(entity cl) PlayerDead = {
	cl.nextthink = -1;
// allow respawn after a certain time
	cl.deadflag = DEAD_DEAD;
};

void()	player_diea1	=	[	$deatha1,	player_diea2	] {self.owner.frame = self.frame;};
void()	player_diea2	=	[	$deatha2,	player_diea3	] {self.owner.frame = self.frame;};
void()	player_diea3	=	[	$deatha3,	player_diea4	] {self.owner.frame = self.frame;};
void()	player_diea4	=	[	$deatha4,	player_diea5	] {self.owner.frame = self.frame;};
void()	player_diea5	=	[	$deatha5,	player_diea6	] {self.owner.frame = self.frame;};
void()	player_diea6	=	[	$deatha6,	player_diea7	] {self.owner.frame = self.frame;};
void()	player_diea7	=	[	$deatha7,	player_diea8	] {self.owner.frame = self.frame;};
void()	player_diea8	=	[	$deatha8,	player_diea9	] {self.owner.frame = self.frame;};
void()	player_diea9	=	[	$deatha9,	player_diea10	] {self.owner.frame = self.frame;};
void()	player_diea10	=	[	$deatha10,	player_diea11	] {self.owner.frame = self.frame;};
void()	player_diea11	=	[	$deatha11,	SUB_Null ] {PlayerDead(self.owner);};

void()	player_dieb1	=	[	$deathb1,	player_dieb2	] {self.owner.frame = self.frame;};
void()	player_dieb2	=	[	$deathb2,	player_dieb3	] {self.owner.frame = self.frame;};
void()	player_dieb3	=	[	$deathb3,	player_dieb4	] {self.owner.frame = self.frame;};
void()	player_dieb4	=	[	$deathb4,	player_dieb5	] {self.owner.frame = self.frame;};
void()	player_dieb5	=	[	$deathb5,	player_dieb6	] {self.owner.frame = self.frame;};
void()	player_dieb6	=	[	$deathb6,	player_dieb7	] {self.owner.frame = self.frame;};
void()	player_dieb7	=	[	$deathb7,	player_dieb8	] {self.owner.frame = self.frame;};
void()	player_dieb8	=	[	$deathb8,	player_dieb9	] {self.owner.frame = self.frame;};
void()	player_dieb9	=	[	$deathb9,	SUB_Null	] {PlayerDead(self.owner);};

void()	player_diec1	=	[	$deathc1,	player_diec2	] {self.owner.frame = self.frame;};
void()	player_diec2	=	[	$deathc2,	player_diec3	] {self.owner.frame = self.frame;};
void()	player_diec3	=	[	$deathc3,	player_diec4	] {self.owner.frame = self.frame;};
void()	player_diec4	=	[	$deathc4,	player_diec5	] {self.owner.frame = self.frame;};
void()	player_diec5	=	[	$deathc5,	player_diec6	] {self.owner.frame = self.frame;};
void()	player_diec6	=	[	$deathc6,	player_diec7	] {self.owner.frame = self.frame;};
void()	player_diec7	=	[	$deathc7,	player_diec8	] {self.owner.frame = self.frame;};
void()	player_diec8	=	[	$deathc8,	player_diec9	] {self.owner.frame = self.frame;};
void()	player_diec9	=	[	$deathc9,	player_diec10	] {self.owner.frame = self.frame;};
void()	player_diec10	=	[	$deathc10,	player_diec11	] {self.owner.frame = self.frame;};
void()	player_diec11	=	[	$deathc11,	player_diec12	] {self.owner.frame = self.frame;};
void()	player_diec12	=	[	$deathc12,	player_diec13	] {self.owner.frame = self.frame;};
void()	player_diec13	=	[	$deathc13,	player_diec14	] {self.owner.frame = self.frame;};
void()	player_diec14	=	[	$deathc14,	player_diec15	] {self.owner.frame = self.frame;};
void()	player_diec15	=	[	$deathc15,	SUB_Null ] {PlayerDead(self.owner);};

void()	player_died1	=	[	$deathd1,	player_died2	] {self.owner.frame = self.frame;};
void()	player_died2	=	[	$deathd2,	player_died3	] {self.owner.frame = self.frame;};
void()	player_died3	=	[	$deathd3,	player_died4	] {self.owner.frame = self.frame;};
void()	player_died4	=	[	$deathd4,	player_died5	] {self.owner.frame = self.frame;};
void()	player_died5	=	[	$deathd5,	player_died6	] {self.owner.frame = self.frame;};
void()	player_died6	=	[	$deathd6,	player_died7	] {self.owner.frame = self.frame;};
void()	player_died7	=	[	$deathd7,	player_died8	] {self.owner.frame = self.frame;};
void()	player_died8	=	[	$deathd8,	player_died9	] {self.owner.frame = self.frame;};
void()	player_died9	=	[	$deathd9,	SUB_Null	] {PlayerDead(self.owner);};

void()	player_diee1	=	[	$deathe1,	player_diee2	] {self.owner.frame = self.frame;};
void()	player_diee2	=	[	$deathe2,	player_diee3	] {self.owner.frame = self.frame;};
void()	player_diee3	=	[	$deathe3,	player_diee4	] {self.owner.frame = self.frame;};
void()	player_diee4	=	[	$deathe4,	player_diee5	] {self.owner.frame = self.frame;};
void()	player_diee5	=	[	$deathe5,	player_diee6	] {self.owner.frame = self.frame;};
void()	player_diee6	=	[	$deathe6,	player_diee7	] {self.owner.frame = self.frame;};
void()	player_diee7	=	[	$deathe7,	player_diee8	] {self.owner.frame = self.frame;};
void()	player_diee8	=	[	$deathe8,	player_diee9	] {self.owner.frame = self.frame;};
void()	player_diee9	=	[	$deathe9,	SUB_Null	] {PlayerDead(self.owner);};

void()	player_die_ax1	=	[	$axdeth1,	player_die_ax2	] {self.owner.frame = self.frame;};
void()	player_die_ax2	=	[	$axdeth2,	player_die_ax3	] {self.owner.frame = self.frame;};
void()	player_die_ax3	=	[	$axdeth3,	player_die_ax4	] {self.owner.frame = self.frame;};
void()	player_die_ax4	=	[	$axdeth4,	player_die_ax5	] {self.owner.frame = self.frame;};
void()	player_die_ax5	=	[	$axdeth5,	player_die_ax6	] {self.owner.frame = self.frame;};
void()	player_die_ax6	=	[	$axdeth6,	player_die_ax7	] {self.owner.frame = self.frame;};
void()	player_die_ax7	=	[	$axdeth7,	player_die_ax8	] {self.owner.frame = self.frame;};
void()	player_die_ax8	=	[	$axdeth8,	player_die_ax9	] {self.owner.frame = self.frame;};
void()	player_die_ax9	=	[	$axdeth9,	SUB_Null	] {PlayerDead(self.owner);};

void()	player_die_sw1	=	[	$swdeth1,	player_die_sw2	] {self.owner.frame = self.frame;};
void()	player_die_sw2	=	[	$swdeth2,	player_die_sw3	] {self.owner.frame = self.frame;};
void()	player_die_sw3	=	[	$swdeth3,	player_die_sw4	] {self.owner.frame = self.frame;};
void()	player_die_sw4	=	[	$swdeth4,	player_die_sw5	] {self.owner.frame = self.frame;};
void()	player_die_sw5	=	[	$swdeth5,	player_die_sw6	] {self.owner.frame = self.frame;};
void()	player_die_sw6	=	[	$swdeth6,	player_die_sw7	] {self.owner.frame = self.frame;};
void()	player_die_sw7	=	[	$swdeth7,	player_die_sw8	] {self.owner.frame = self.frame;};
void()	player_die_sw8	=	[	$swdeth8,	player_die_sw9	] {self.owner.frame = self.frame;};
void()	player_die_sw9	=	[	$swdeth9,	SUB_Null	] {PlayerDead(self.owner);};