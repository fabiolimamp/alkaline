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
==============================================================================
PLAYER
==============================================================================
*/

void() player_stand1 =[	$axstnd1,	player_stand1	] {
	self.owner.frame = $axstnd1;

	if (self.owner.velocity_x || self.owner.velocity_y) {
		self.owner.walkframe = 0;
		player_run();
		return;
	}
	
	/*if (self.weapon == WEAPON_CHAINSAW) {
		self.weaponframe = self.weaponframe + 1;
		if(self.weaponframe >= 5)
		{
			self.weaponframe = 0;
			if (self.view_ofs != '0 0 0')
				sound (self, CHAN_AUTO, "weapons/sawridle.wav", 1, ATTN_NORM);
		}
		if (self.walkframe >= 5)
			self.walkframe = 0;
		self.frame = $swstnd1 + self.walkframe;
		self.walkframe = self.walkframe + 1;	
		
		return;
	}
	*/


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
	self.owner.frame = $rockrun1;
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

void()	player_shot1 =	[$shotatt1, player_shot2	] {self.owner.frame = self.frame;};
void()	player_shot2 =	[$shotatt2, player_shot3	] {self.owner.frame = self.frame;};
void()	player_shot3 =	[$shotatt3, player_shot4	] {self.owner.frame = self.frame;};
void()	player_shot4 =	[$shotatt4, player_shot5	] {self.owner.frame = self.frame;};
void()	player_shot5 =	[$shotatt5, player_shot6	] {self.owner.frame = self.frame;};
void()	player_shot6 =	[$shotatt6, player_run		] {self.owner.frame = self.frame;};




void()	player_sshot1 =	[$shotatt1, player_sshot2	] {self.weaponframe=1; self.effects = self.effects | EF_MUZZLEFLASH; nxth(0.025);};
void()	player_sshot2 =	[$shotatt1, player_sshot3	] {self.weaponframe=2; nxth(0.025);};
void()	player_sshot3 =	[$shotatt1, player_sshot4	] {self.weaponframe=3; nxth(0.025);};
void()	player_sshot4 =	[$shotatt2, player_sshot5	] {self.weaponframe=4; nxth(0.025);};
void()	player_sshot5 =	[$shotatt2, player_sshot6	] {self.weaponframe=5; nxth(0.025);};
void()	player_sshot6 =	[$shotatt2, player_sshot7	] {self.weaponframe=6; nxth(0.025);};
void()	player_sshot7 =	[$shotatt2, player_sshot8	] {self.weaponframe=7; nxth(0.025);};
void()	player_sshot8 =	[$shotatt3, player_sshot9	] {self.weaponframe=8; nxth(0.025);};
void()	player_sshot9 =	[$shotatt3, player_sshot10	] {self.weaponframe=9; nxth(0.025);};
void()	player_sshot10 =	[$shotatt3, player_sshot11	] {self.weaponframe=10; nxth(0.025);};
void()	player_sshot11 =	[$shotatt4, player_sshot12	] {self.weaponframe=11; nxth(0.025);};
void()	player_sshot12 =	[$shotatt4, player_sshot13	] {self.weaponframe=12; nxth(0.025);};
void()	player_sshot13 =	[$shotatt4, player_sshot14	] {self.weaponframe=13; nxth(0.025);};
void()	player_sshot14 =	[$shotatt5, player_sshot15	] {self.weaponframe=14; nxth(0.025);};
void()	player_sshot15 =	[$shotatt5, player_sshot16	] {self.weaponframe=15; nxth(0.025);};
void()	player_sshot16 =	[$shotatt5, player_sshot17	] {self.weaponframe=16; nxth(0.025);};
void()	player_sshot17 =	[$shotatt5, player_sshot18	] {self.weaponframe=17; nxth(0.025);};
void()	player_sshot18 =	[$shotatt6, player_sshot19	] {self.weaponframe=18; nxth(0.025);};
void()	player_sshot19 =	[$shotatt6, player_sshot20	] {self.weaponframe=19; nxth(0.025);};
void()	player_sshot20 =	[$shotatt6, player_sshot21	] {self.weaponframe=20; nxth(0.025);};
void()	player_sshot21 =	[$shotatt6, player_run		] {self.weaponframe=21; nxth(0.025);};



void() player_axe = {
	if (!self.owner.weaponframe) {
		self.weaponframe = floor(random()*4.99)*10 + 2;

		if (self.weaponframe == 2) self.frame = $axattc1;
		if (self.weaponframe == 12) self.frame = $axattc1;
		if (self.weaponframe == 22) self.frame = $axattb1;
		if (self.weaponframe == 32) self.frame = $axattd1;
		if (self.weaponframe == 42) self.frame = $axatt1;
	}
	else if (self.weaponframe % 10 == 1) {
		player_run();
		return;
	}
	else {
		self.weaponframe++;
	}

	if (self.weaponframe % 10 == 5) W_FireAxe();

	if (
		self.weaponframe % 10 == 5 ||
		self.weaponframe % 10 == 8 ||
		self.weaponframe % 10 == 0
	) self.frame++;



	self.think = player_axe;
	self.nextthink = time + 0.05;
}


//============================================================================

void() player_chainsaw1   =[$sawatt1, player_chainsaw2 ] {self.owner.frame = self.frame;};
void() player_chainsaw2   =[$sawatt2, player_chainsaw1 ] {self.owner.frame = self.frame;};


//============================================================================


void() player_nail = {
	if (!self.button0 || self.weapon != WEAPON_NAILGUN) {
		player_run();
		return;
	}
		
		
	if (self.weaponframe >= 8)
		self.weaponframe = 1;
	else
		self.weaponframe++;
		
	float offs;
	if (self.weaponframe == 1 || self.weaponframe == 5) {
		self.effects |= EF_MUZZLEFLASH;
		
		if (self.frame != $nailatt1)
			self.frame = $nailatt1;
		else 
			self.frame += 1;

		if (self.frame == $nailatt1) offs = -3;
		else offs = 3;
		SuperDamageSound();
		W_FireSpikes(offs);

		self.attack_finished = time + 0.2;
	}

	self.think = player_nail;
	self.nextthink = time + 0.025;
}

void() player_super_nail = {

	self.weaponframe = self.weaponframe + 1;	
	
	if (self.weaponframe >= 9)
		self.weaponframe = 1;

	self.cnt = 0; //using this to keep track of if we're spinning down or not;

	if (!self.button0)	{	
		player_run();
		self.cnt = 1;
		super_nail_spindown();
		return;
	}


	if ((self.weaponframe == 1 || self.weaponframe == 5) && self.ammo_nails >= 1) {

		self.punchangle_x = -2;

		self.effects |= EF_MUZZLEFLASH;

		if (self.frame != $nailatt1)
			self.frame = $nailatt1;
		else 
			self.frame += 1;
		SuperDamageSound();
		W_FireSpikes(0);
	}
	
	self.think = player_super_nail;
	self.nextthink = time + 0.025;
}

// same as player_run but while spinning down
void() player_super_nail_spindown = {

	// thinks run at 4x the usual speed while spinning down,
	// so only update every 4 weaponframes
	if (self.weaponframe % 4 == 0) {
		if (self.walkframe >= 6)
			self.walkframe = 0;
		self.frame = $axrun1 + self.walkframe;
		
		self.walkframe = self.walkframe + 1;

		if ((self.walkframe == 1 || self.walkframe == 4) && self.flags & FL_ONGROUND && !intermission_running) {
			// Need to be moving before feet sounds
			float spd;
			spd = vlen([self.velocity_x, self.velocity_y, 0]);
			if (spd > 50) {
				play_footstep(self.owner, FALSE, clamp(spd, 0, 320)/320);
			}
		}
	}
}

void() super_nail_spindown = {

	self.weaponframe += 1;
	player_run();
	
	if (self.weaponframe == 25) sound (self, 7, "weapons/spindn_click.wav", 0.15, ATTN_NORM);
	if (self.weaponframe == 48) sound (self, 7, "weapons/spindn_click.wav", 0.3, ATTN_NORM);

	if (self.weaponframe < 51) {
		self.think = super_nail_spindown;
		self.nextthink = time + 0.025;
	}	
	else {
		self.cnt = 0;
	}
}




void() player_light1 = [$light1, player_light2  ] {
	self.effects = self.effects | EF_MUZZLEFLASH;
	
	if (!self.button0) {
		player_run();
		return;
	}

	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 5)
		self.weaponframe = 1;
	SuperDamageSound();
	W_FireLightning();
	self.attack_finished = time + 0.2;
};
void() player_light2   =[$light2, player_light1  ] {
	self.effects = self.effects | EF_MUZZLEFLASH;

	if (!self.button0)
		{player_run ();return;}
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 5)
		self.weaponframe = 1;
	SuperDamageSound();
	W_FireLightning();
	self.attack_finished = time + 0.2;
};

//============================================================================

void() player_laser1   =[$nailatt1, player_laser2  ] {self.attack_finished = time + 0.1; self.weaponframe=1; nxth(0.025); HIP_FireLaser(0);};
void() player_laser2   =[$nailatt1, player_laser3  ] {self.weaponframe=2; nxth(0.025);};
void() player_laser3   =[$nailatt1, player_laser4  ] {self.weaponframe=3; nxth(0.025);};
void() player_laser4   =[$nailatt1, player_laser5  ] {self.weaponframe=4; nxth(0.025);};
void() player_laser5   =[$nailatt2, player_laser6  ] {self.attack_finished = time + 0.1; self.weaponframe=5; nxth(0.025); HIP_FireLaser(1);};
void() player_laser6   =[$nailatt2, player_laser7  ] {self.weaponframe=6; nxth(0.025);};
void() player_laser7   =[$nailatt2, player_laser8  ] {self.weaponframe=7; nxth(0.025);};
void() player_laser8   =[$nailatt2, player_run  ] {self.weaponframe=8; nxth(0.025);};

//============================================================================

void()	player_plasma1 =	[$shotatt1, player_plasma2	] {self.weaponframe=1; nxth(0.05); self.effects = self.effects | EF_MUZZLEFLASH;};
void()	player_plasma2 =	[$shotatt1, player_plasma3	] {self.weaponframe=2; nxth(0.05);};
void()	player_plasma3 =	[$shotatt3, player_run		] {self.weaponframe=1; nxth(0.1);};


void()	player_proxgrenade1 =	[$rockatt1, player_proxgrenade2	] {self.weaponframe=1; self.effects = self.effects | EF_MUZZLEFLASH; nxth(0.025);};
void()	player_proxgrenade2 =	[$rockatt1, player_proxgrenade3	] {self.weaponframe=2; nxth(0.025);};
void()	player_proxgrenade3 =	[$rockatt1, player_proxgrenade4	] {self.weaponframe=3; nxth(0.025);};
void()	player_proxgrenade4 =	[$rockatt1, player_proxgrenade5	] {self.weaponframe=4; nxth(0.025);};
void()	player_proxgrenade5 =	[$rockatt2, player_proxgrenade6	] {self.weaponframe=5; nxth(0.025);};
void()	player_proxgrenade6 =	[$rockatt2, player_proxgrenade7	] {self.weaponframe=6; nxth(0.025);};
void()	player_proxgrenade7 =	[$rockatt2, player_proxgrenade8	] {self.weaponframe=7; nxth(0.025);};
void()	player_proxgrenade8 =	[$rockatt2, player_proxgrenade9	] {self.weaponframe=8; nxth(0.025);};
void()	player_proxgrenade9 =	[$rockatt3, player_proxgrenade10	] {self.weaponframe=9; nxth(0.025);};
void()	player_proxgrenade10 =	[$rockatt3, player_proxgrenade11	] {self.weaponframe=10; nxth(0.025);};
void()	player_proxgrenade11 =	[$rockatt3, player_proxgrenade12	] {self.weaponframe=11; nxth(0.025);};
void()	player_proxgrenade12 =	[$rockatt3, player_proxgrenade13	] {self.weaponframe=12; nxth(0.025);};
void()	player_proxgrenade13 =	[$rockatt4, player_proxgrenade14	] {self.weaponframe=13; nxth(0.025);};
void()	player_proxgrenade14 =	[$rockatt4, player_proxgrenade15	] {self.weaponframe=14; nxth(0.025);};
void()	player_proxgrenade15 =	[$rockatt4, player_proxgrenade16	] {self.weaponframe=15; nxth(0.025);};
void()	player_proxgrenade16 =	[$rockatt4, player_proxgrenade17	] {self.weaponframe=16; nxth(0.025);};
void()	player_proxgrenade17 =	[$rockatt5, player_proxgrenade18	] {self.weaponframe=17; nxth(0.025);};
void()	player_proxgrenade18 =	[$rockatt5, player_proxgrenade19	] {self.weaponframe=18; nxth(0.025);};
void()	player_proxgrenade19 =	[$rockatt5, player_proxgrenade20	] {self.weaponframe=19; nxth(0.025);};
void()	player_proxgrenade20 =	[$rockatt5, player_proxgrenade21	] {self.weaponframe=20; nxth(0.025);};
void()	player_proxgrenade21 =	[$rockatt6, player_proxgrenade22	] {self.weaponframe=21; nxth(0.025);};
void()	player_proxgrenade22 =	[$rockatt6, player_proxgrenade23	] {self.weaponframe=22; nxth(0.025);};
void()	player_proxgrenade23 =	[$rockatt6, player_proxgrenade24	] {self.weaponframe=23; nxth(0.025);};
void()	player_proxgrenade24 =	[$rockatt6, player_run		] {self.weaponframe=24; nxth(0.025);};


void()	player_grenade1 =	[$rockatt1, player_grenade2	] {self.weaponframe=1; self.effects = self.effects | EF_MUZZLEFLASH; nxth(0.025);};
void()	player_grenade2 =	[$rockatt1, player_grenade3	] {self.weaponframe=2; nxth(0.025);};
void()	player_grenade3 =	[$rockatt1, player_grenade4	] {self.weaponframe=3; nxth(0.025);};
void()	player_grenade4 =	[$rockatt1, player_grenade5	] {self.weaponframe=4; nxth(0.025);};
void()	player_grenade5 =	[$rockatt2, player_grenade6	] {self.weaponframe=5; nxth(0.025);};
void()	player_grenade6 =	[$rockatt2, player_grenade7	] {self.weaponframe=6; nxth(0.025);};
void()	player_grenade7 =	[$rockatt2, player_grenade8	] {self.weaponframe=7; nxth(0.025);};
void()	player_grenade8 =	[$rockatt2, player_grenade9	] {self.weaponframe=8; nxth(0.025);};
void()	player_grenade9 =	[$rockatt3, player_grenade10	] {self.weaponframe=9; nxth(0.025);};
void()	player_grenade10 =	[$rockatt3, player_grenade11	] {self.weaponframe=10; nxth(0.025);};
void()	player_grenade11 =	[$rockatt3, player_grenade12	] {self.weaponframe=11; nxth(0.025);};
void()	player_grenade12 =	[$rockatt3, player_grenade13	] {self.weaponframe=12; nxth(0.025);};
void()	player_grenade13 =	[$rockatt4, player_grenade14	] {self.weaponframe=13; nxth(0.025);};
void()	player_grenade14 =	[$rockatt4, player_grenade15	] {self.weaponframe=14; nxth(0.025);};
void()	player_grenade15 =	[$rockatt4, player_grenade16	] {self.weaponframe=15; nxth(0.025);};
void()	player_grenade16 =	[$rockatt4, player_grenade17	] {self.weaponframe=16; nxth(0.025);};
void()	player_grenade17 =	[$rockatt5, player_grenade18	] {self.weaponframe=17; nxth(0.025);};
void()	player_grenade18 =	[$rockatt5, player_grenade19	] {self.weaponframe=18; nxth(0.025);};
void()	player_grenade19 =	[$rockatt5, player_grenade20	] {self.weaponframe=19; nxth(0.025);};
void()	player_grenade20 =	[$rockatt5, player_grenade21	] {self.weaponframe=20; nxth(0.025);};
void()	player_grenade21 =	[$rockatt6, player_grenade22	] {self.weaponframe=21; nxth(0.025);};
void()	player_grenade22 =	[$rockatt6, player_grenade23	] {self.weaponframe=22; nxth(0.025);};
void()	player_grenade23 =	[$rockatt6, player_grenade24	] {self.weaponframe=23; nxth(0.025);};
void()	player_grenade24 =	[$rockatt6, player_run		] {self.weaponframe=24; nxth(0.025);};


void()	player_rocket1 =	[$rockatt1, player_rocket2	] {self.weaponframe=1; nxth(0.025);};
void()	player_rocket2 =	[$rockatt1, player_rocket3	] {self.weaponframe=2; self.effects = self.effects | EF_MUZZLEFLASH; nxth(0.025);};
void()	player_rocket3 =	[$rockatt1, player_rocket4	] {self.weaponframe=3; nxth(0.025);};
void()	player_rocket4 =	[$rockatt1, player_rocket5	] {self.weaponframe=4; nxth(0.025);};
void()	player_rocket5 =	[$rockatt2, player_rocket6	] {self.weaponframe=5; nxth(0.025);};
void()	player_rocket6 =	[$rockatt2, player_rocket7	] {self.weaponframe=6; nxth(0.025);};
void()	player_rocket7 =	[$rockatt2, player_rocket8	] {self.weaponframe=7; nxth(0.025);};
void()	player_rocket8 =	[$rockatt2, player_rocket9	] {self.weaponframe=8; nxth(0.025);};
void()	player_rocket9 =	[$rockatt3, player_rocket10	] {self.weaponframe=9; nxth(0.025);};
void()	player_rocket10 =	[$rockatt3, player_rocket11	] {self.weaponframe=10; nxth(0.025);};
void()	player_rocket11 =	[$rockatt3, player_rocket12	] {self.weaponframe=11; nxth(0.025);};
void()	player_rocket12 =	[$rockatt3, player_rocket13	] {self.weaponframe=12; nxth(0.025);};
void()	player_rocket13 =	[$rockatt4, player_rocket14	] {self.weaponframe=13; nxth(0.025);};
void()	player_rocket14 =	[$rockatt4, player_rocket15	] {self.weaponframe=14; nxth(0.025);};
void()	player_rocket15 =	[$rockatt4, player_rocket16	] {self.weaponframe=15; nxth(0.025);};
void()	player_rocket16 =	[$rockatt4, player_rocket17	] {self.weaponframe=16; nxth(0.025);};
void()	player_rocket17 =	[$rockatt4, player_rocket18	] {self.weaponframe=17; nxth(0.025);};
void()	player_rocket18 =	[$rockatt4, player_rocket19	] {self.weaponframe=18; nxth(0.025);};
void()	player_rocket19 =	[$rockatt5, player_rocket20	] {self.weaponframe=19; nxth(0.025);};
void()	player_rocket20 =	[$rockatt5, player_rocket21	] {self.weaponframe=20; nxth(0.025);};
void()	player_rocket21 =	[$rockatt5, player_rocket22	] {self.weaponframe=21; nxth(0.025);};
void()	player_rocket22 =	[$rockatt5, player_rocket23	] {self.weaponframe=22; nxth(0.025);};
void()	player_rocket23 =	[$rockatt5, player_rocket24	] {self.weaponframe=23; nxth(0.025);};
void()	player_rocket24 =	[$rockatt5, player_rocket25	] {self.weaponframe=24; nxth(0.025);};
void()	player_rocket25 =	[$rockatt6, player_rocket26	] {self.weaponframe=25; nxth(0.025);};
void()	player_rocket26 =	[$rockatt6, player_rocket27	] {self.weaponframe=26; nxth(0.025);};
void()	player_rocket27 =	[$rockatt6, player_rocket28	] {self.weaponframe=27; nxth(0.025);};
void()	player_rocket28 =	[$rockatt6, player_rocket29	] {self.weaponframe=28; nxth(0.025);};
void()	player_rocket29 =	[$rockatt6, player_rocket30	] {self.weaponframe=29; nxth(0.025);};
void()	player_rocket30 =	[$rockatt6, player_rocket31	] {self.weaponframe=30; nxth(0.025);};
void()	player_rocket31 =	[$rockatt6, player_rocket32	] {self.weaponframe=31; nxth(0.025);};
void()	player_rocket32 =	[$rockatt6, player_run	] {self.weaponframe=32; nxth(0.025);};


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

void()	player_pain1 =	[	$pain1,	player_pain2	] {};
void()	player_pain2 =	[	$pain2,	player_pain3	] {};
void()	player_pain3 =	[	$pain3,	player_pain4	] {};
void()	player_pain4 =	[	$pain4,	player_pain5	] {};
void()	player_pain5 =	[	$pain5,	player_pain6	] {};
void()	player_pain6 =	[	$pain6,	player_run	] {};

void()	player_swpain1 =	[	$swpain1,	player_pain2	] {};
void()	player_swpain2 =	[	$swpain2,	player_pain3	] {};
void()	player_swpain3 =	[	$swpain3,	player_pain4	] {};
void()	player_swpain4 =	[	$swpain4,	player_pain5	] {};
void()	player_swpain5 =	[	$swpain5,	player_pain6	] {};
void()	player_swpain6 =	[	$swpain6,	player_run		] {};

void()	player_axpain1 =	[	$axpain1,	player_axpain2	] {};
void()	player_axpain2 =	[	$axpain2,	player_axpain3	] {};
void()	player_axpain3 =	[	$axpain3,	player_axpain4	] {};
void()	player_axpain4 =	[	$axpain4,	player_axpain5	] {};
void()	player_axpain5 =	[	$axpain5,	player_axpain6	] {};
void()	player_axpain6 =	[	$axpain6,	player_run	] {};

inline void(entity attacker, float damage) player_pain_generic = {
	player_pain(attacker, damage, DMGTYPE_GENERIC);
};

void(entity attacker, float damage, float dmgtype) player_pain = {
	if (self.weaponframe)
		return;

	if (self.invisible_finished > time)
		return;		// eyes don't have pain frames

	PainSound(dmgtype);
	self.weaponframe = 0;

	if (self.weapon == WEAPON_AXE)
		player_axpain1 ();
	else if (self.weapon == WEAPON_CHAINSAW)
		player_swpain1 ();
	else
		player_pain1 ();
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


void() PlayerDead = {
	self.nextthink = -1;
// allow respawn after a certain time
	self.deadflag = DEAD_DEAD;
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
		player_die_ax1 ();
		return;
	}
	
	if (self.weapon == WEAPON_CHAINSAW) {
		player_die_sw1 ();
		return;
	}
	
	i = 1 + floor(random()*6);
	
	if (i == 1)
		player_diea1();
	else if (i == 2)
		player_dieb1();
	else if (i == 3)
		player_diec1();
	else if (i == 4)
		player_died1();
	else
		player_diee1();

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


void()	player_diea1	=	[	$deatha1,	player_diea2	] {};
void()	player_diea2	=	[	$deatha2,	player_diea3	] {};
void()	player_diea3	=	[	$deatha3,	player_diea4	] {};
void()	player_diea4	=	[	$deatha4,	player_diea5	] {};
void()	player_diea5	=	[	$deatha5,	player_diea6	] {};
void()	player_diea6	=	[	$deatha6,	player_diea7	] {};
void()	player_diea7	=	[	$deatha7,	player_diea8	] {};
void()	player_diea8	=	[	$deatha8,	player_diea9	] {};
void()	player_diea9	=	[	$deatha9,	player_diea10	] {};
void()	player_diea10	=	[	$deatha10,	player_diea11	] {};
void()	player_diea11	=	[	$deatha11,	player_diea11 ] {PlayerDead();};

void()	player_dieb1	=	[	$deathb1,	player_dieb2	] {};
void()	player_dieb2	=	[	$deathb2,	player_dieb3	] {};
void()	player_dieb3	=	[	$deathb3,	player_dieb4	] {};
void()	player_dieb4	=	[	$deathb4,	player_dieb5	] {};
void()	player_dieb5	=	[	$deathb5,	player_dieb6	] {};
void()	player_dieb6	=	[	$deathb6,	player_dieb7	] {};
void()	player_dieb7	=	[	$deathb7,	player_dieb8	] {};
void()	player_dieb8	=	[	$deathb8,	player_dieb9	] {};
void()	player_dieb9	=	[	$deathb9,	player_dieb9	] {PlayerDead();};

void()	player_diec1	=	[	$deathc1,	player_diec2	] {};
void()	player_diec2	=	[	$deathc2,	player_diec3	] {};
void()	player_diec3	=	[	$deathc3,	player_diec4	] {};
void()	player_diec4	=	[	$deathc4,	player_diec5	] {};
void()	player_diec5	=	[	$deathc5,	player_diec6	] {};
void()	player_diec6	=	[	$deathc6,	player_diec7	] {};
void()	player_diec7	=	[	$deathc7,	player_diec8	] {};
void()	player_diec8	=	[	$deathc8,	player_diec9	] {};
void()	player_diec9	=	[	$deathc9,	player_diec10	] {};
void()	player_diec10	=	[	$deathc10,	player_diec11	] {};
void()	player_diec11	=	[	$deathc11,	player_diec12	] {};
void()	player_diec12	=	[	$deathc12,	player_diec13	] {};
void()	player_diec13	=	[	$deathc13,	player_diec14	] {};
void()	player_diec14	=	[	$deathc14,	player_diec15	] {};
void()	player_diec15	=	[	$deathc15,	player_diec15 ] {PlayerDead();};

void()	player_died1	=	[	$deathd1,	player_died2	] {};
void()	player_died2	=	[	$deathd2,	player_died3	] {};
void()	player_died3	=	[	$deathd3,	player_died4	] {};
void()	player_died4	=	[	$deathd4,	player_died5	] {};
void()	player_died5	=	[	$deathd5,	player_died6	] {};
void()	player_died6	=	[	$deathd6,	player_died7	] {};
void()	player_died7	=	[	$deathd7,	player_died8	] {};
void()	player_died8	=	[	$deathd8,	player_died9	] {};
void()	player_died9	=	[	$deathd9,	player_died9	] {PlayerDead();};

void()	player_diee1	=	[	$deathe1,	player_diee2	] {};
void()	player_diee2	=	[	$deathe2,	player_diee3	] {};
void()	player_diee3	=	[	$deathe3,	player_diee4	] {};
void()	player_diee4	=	[	$deathe4,	player_diee5	] {};
void()	player_diee5	=	[	$deathe5,	player_diee6	] {};
void()	player_diee6	=	[	$deathe6,	player_diee7	] {};
void()	player_diee7	=	[	$deathe7,	player_diee8	] {};
void()	player_diee8	=	[	$deathe8,	player_diee9	] {};
void()	player_diee9	=	[	$deathe9,	player_diee9	] {PlayerDead();};

void()	player_die_ax1	=	[	$axdeth1,	player_die_ax2	] {};
void()	player_die_ax2	=	[	$axdeth2,	player_die_ax3	] {};
void()	player_die_ax3	=	[	$axdeth3,	player_die_ax4	] {};
void()	player_die_ax4	=	[	$axdeth4,	player_die_ax5	] {};
void()	player_die_ax5	=	[	$axdeth5,	player_die_ax6	] {};
void()	player_die_ax6	=	[	$axdeth6,	player_die_ax7	] {};
void()	player_die_ax7	=	[	$axdeth7,	player_die_ax8	] {};
void()	player_die_ax8	=	[	$axdeth8,	player_die_ax9	] {};
void()	player_die_ax9	=	[	$axdeth9,	player_die_ax9	] {PlayerDead();};

void()	player_die_sw1	=	[	$swdeth1,	player_die_sw2	] {};
void()	player_die_sw2	=	[	$swdeth2,	player_die_sw3	] {};
void()	player_die_sw3	=	[	$swdeth3,	player_die_sw4	] {};
void()	player_die_sw4	=	[	$swdeth4,	player_die_sw5	] {};
void()	player_die_sw5	=	[	$swdeth5,	player_die_sw6	] {};
void()	player_die_sw6	=	[	$swdeth6,	player_die_sw7	] {};
void()	player_die_sw7	=	[	$swdeth7,	player_die_sw8	] {};
void()	player_die_sw8	=	[	$swdeth8,	player_die_sw9	] {};
void()	player_die_sw9	=	[	$swdeth9,	player_die_sw9	] {PlayerDead();};