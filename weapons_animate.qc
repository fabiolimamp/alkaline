void() weaponanim_none = {};

void() weaponanim_axe = {};


//=================================================================================================
// Chainsaw
//=================================================================================================

void() weaponanim_chainsaw = {
	// handled via animation loop
	if (self.attackhold) {
		return;
	}

	if (self.attack_finished > time)
		return;

	//sound (self, CHAN_WEAPON2, "weapons/sawatck.wav", 1, ATTN_NORM);
	W_FireSaw();
	
	SUB_CallAsSelf(player_chainsaw1, self.animcontroller);

	self.attack_finished = time + 0.2;

	self.weaponframe = 5;
	self.think = weaponanim_chainsaw_loop;
	self.nextthink = time + 0.1;
}

void() weaponanim_chainsaw_loop = {

	if (!self.attackhold){
		self.weaponframe = 0;
		SUB_CallAsSelf(player_stand1, self.animcontroller);
		weaponanim_chainsaw_idle();
		return;
	}

	if (self.weaponframe >= 10) {
		self.weaponframe = 5;
	}
	else {
		self.weaponframe++;
	}

	if (self.weaponframe % 2 == 1)
		W_FireSaw();
	

	self.think = weaponanim_chainsaw_loop;
	self.nextthink = time + 0.1;

}


void() weaponanim_chainsaw_idle = {
	if (self.weaponframe >= 4) {
		self.weaponframe = 0;
	}
	else {
		self.weaponframe++;
	}

	self.think = weaponanim_chainsaw_idle;
	self.nextthink = time + 0.1;
}


//=================================================================================================
// Shotgun
//=================================================================================================

void() weaponanim_shotgun = {};


void() weaponanim_supershotgun = {};

void() weaponanim_nailgun = {};

//=================================================================================================
// Super Nailgun
//=================================================================================================


void() weaponanim_supernailgun = {
	// handled via animation loop
	if (self.attackhold) {
		return;
	}

	if (self.attack_finished > time)
		return;

	W_FireSaw();
	
	player_axe();

	self.attack_finished = time + 0.2;

	self.weaponframe = 1;
	self.think = weaponanim_supernailgun_loop;
	self.nextthink = time + 0.1;
}

void() weaponanim_supernailgun_loop = {

	if (!self.attackhold){
		weaponanim_supernailgun_end();
		return;
	}

	if (self.weaponframe >= 10) {
		self.weaponframe = 5;
	}
	else {
		self.weaponframe++;
	}

	if (self.weaponframe % 2 == 0)
		W_FireSaw();
	

	self.think = weaponanim_supernailgun_loop;
	self.nextthink = time + 0.1;

}

void() weaponanim_supernailgun_end = {

	if (self.weaponframe >= 40) {
		self.weaponframe = 0;
		return;
	}
	else {
		self.weaponframe++;
	}

	self.think = weaponanim_supernailgun_end;
	self.nextthink = time + 0.05;

}


//=================================================================================================
// Grenade Launcher
//=================================================================================================


void() weaponanim_grenade = {};

void() weaponanim_proximity = {};

void() weaponanim_rocket = {};

void() weaponanim_lg = {};

void() weaponanim_laser = {};

void() weaponanim_plasma = {};
