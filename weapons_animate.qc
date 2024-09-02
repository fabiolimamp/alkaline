//=================================================================================================
// Axe
//=================================================================================================

void() weaponanim_axe = {
	if (self.attack_finished > time)
		return;

	self.attack_finished = time + 0.5;
	
	self.weaponframe = floor(random()*4.99)*10 + 2;

	player_axe_start(self.animcontroller, (self.weaponframe - 2)/10);

	self.think = weaponanim_axe1;
	self.nextthink = time + 0.05;
}

void() weaponanim_axe1 = {
	if (self.weaponframe % 10 == 5)
		W_FireAxe();

	if (self.weaponframe % 10 == 1) {
		self.weaponframe = 0;
		return;
	}
	else {
		self.weaponframe++;
	}

	self.think = weaponanim_axe1;
	self.nextthink = time + 0.05;

}


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

	sound (self, CHAN_WEAPON, "weapons/sawatck.wav", 1, ATTN_NORM);
	W_FireSaw();
	
	SUB_CallAsSelf(player_chainsaw1, self.animcontroller);

	self.attack_finished = time + 0.55;

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

	if (self.weaponframe == 5) sound(self, CHAN_WEAPON, "weapons/sawatck.wav", 1, ATTN_NORM);

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

	if (self.view_ofs != '0 0 0' && self.weaponframe == 0)
		sound (self, CHAN_WEAPON, "weapons/sawridle.wav", 1, ATTN_IDLE);

	self.think = weaponanim_chainsaw_idle;
	self.nextthink = time + 0.1;
}



//=================================================================================================
// Shotgun
//=================================================================================================

void() weaponanim_shotgun = {
	if (self.attack_finished > time)
		return;

	if (W_CheckWeapon(WEAPON_SHOTGUN, self) != WEAPONSTAT_AVAILABLE){
		W_ChangeWeapon(W_BestWeapon());
		return;
	}

	self.currentammo = self.ammo_shells = self.ammo_shells - 1;

	self.attack_finished = time + 0.5;
	
	SUB_CallAsSelf(player_shot1, self.animcontroller);
	
	self.effects = self.effects | EF_MUZZLEFLASH;

	W_FireShotgun();

	self.weaponframe = 1;
	self.think = weaponanim_shotgun1;
	self.nextthink = time + 0.025;
}

void() weaponanim_shotgun1 = {

	if (self.weaponframe >= 24) {
		self.weaponframe = 0;
		return;
	}
	else {
		self.weaponframe++;
	}

	self.think = weaponanim_shotgun1;
	self.nextthink = time + 0.025;

}



//=================================================================================================
// Super Shotgun
//=================================================================================================

void() weaponanim_supershotgun = {
	if (self.attack_finished > time)
		return;

	if (W_CheckWeapon(WEAPON_SUPER_SHOTGUN, self) != WEAPONSTAT_AVAILABLE){
		//dprint("Not available!\n");
		W_ChangeWeapon(W_BestWeapon());
		return;
	}

	self.currentammo = self.ammo_shells = self.ammo_shells - 2;

	self.attack_finished = time + 0.7;
	
	SUB_CallAsSelf(player_shot1, self.animcontroller);
	
	self.effects = self.effects | EF_MUZZLEFLASH;

	W_FireSuperShotgun();

	self.weaponframe = 1;
	self.think = weaponanim_supershotgun1;
	self.nextthink = time + 0.025;
}

void() weaponanim_supershotgun1 = {

	if (self.weaponframe >= 21) {
		self.weaponframe = 0;
		return;
	}
	else {
		self.weaponframe++;
	}

	self.think = weaponanim_supershotgun1;
	self.nextthink = time + 0.025;

}




//=================================================================================================
// Nailgun
//=================================================================================================

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
