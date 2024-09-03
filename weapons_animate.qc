//=================================================================================================
// Axe
//=================================================================================================

void() weaponanim_axe = {
	if (self.attack_finished > time)
		return;

	self.attack_finished = time + 0.5;
	
	self.weaponframe = floor(random()*4.99)*10 + 2;

	player_axe_start(self.animcontroller, (self.weaponframe - 2)/10);

	self.think = weaponanim_axe_loop;
	self.nextthink = time + 0.05;
}

void() weaponanim_axe_loop = {
	if (self.weaponframe % 10 == 5)
		W_FireAxe();

	if (self.weaponframe % 10 == 1) {
		self.weaponframe = 0;
		return;
	}
	else {
		self.weaponframe++;
	}

	self.think = weaponanim_axe_loop;
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
	self.think = weaponanim_shotgun_loop;
	self.nextthink = time + 0.025;
}

void() weaponanim_shotgun_loop = {

	if (self.weaponframe >= 24) {
		self.weaponframe = 0;
		return;
	}
	else {
		self.weaponframe++;
	}

	self.think = weaponanim_shotgun_loop;
	self.nextthink = time + 0.025;

}



//=================================================================================================
// Super Shotgun
//=================================================================================================

void() weaponanim_supershotgun = {
	if (self.attack_finished > time)
		return;

	if (W_CheckWeapon(self.weapon, self) != WEAPONSTAT_AVAILABLE){
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
	self.think = weaponanim_supershotgun_loop;
	self.nextthink = time + 0.025;
}

void() weaponanim_supershotgun_loop = {

	if (self.weaponframe >= 21) {
		self.weaponframe = 0;
		return;
	}
	else {
		self.weaponframe++;
	}

	self.think = weaponanim_supershotgun_loop;
	self.nextthink = time + 0.025;

}




//=================================================================================================
// Nailgun
//=================================================================================================

void() weaponanim_nailgun = {
	// handled via animation loop4
	if (self.attackhold && self.attack_finished > time) {
		return;
	}

	if (self.attack_finished > time)
		return;

	SUB_CallAsSelf(player_nail1, self.animcontroller);

	if (self.weaponframe > 8 && self.weaponframe <= 16) self.weaponframe -= 8;
	else self.weaponframe = 0;
	
	weaponanim_nailgun_loop();
	
}

void() weaponanim_nailgun_loop = {
	if (!self.attackhold && !self.attackpressed){
		self.weaponframe = 0;
		SUB_CallAsSelf(player_run, self.animcontroller);
		return;
	}

	if (W_CheckWeapon(self.weapon, self) != WEAPONSTAT_AVAILABLE){
		W_ChangeWeapon(W_BestWeapon());
		return;
	}

	if (self.weaponframe >= 8) {
		self.weaponframe = 1;
	}
	else {
		self.weaponframe++;
	}
	
	float offs;
	
	if (self.weaponframe == 1 || self.weaponframe == 5) {
		self.attack_finished = time + 0.2;

		self.currentammo = self.ammo_nails = self.ammo_nails - 1;

		self.punchangle_x = -2;

		self.effects |= EF_MUZZLEFLASH;

		if (self.weaponframe == 1) offs = -3;
		else offs = 3;

		SuperDamageSound();
		W_FireSpikes(offs);
	}
	

	self.think = weaponanim_nailgun_loop;
	self.nextthink = time + 0.025;
}


//=================================================================================================
// Super Nailgun
//=================================================================================================


void() weaponanim_supernailgun = {
	// handled via animation loop4
	if (self.attackhold && self.attack_finished > time) {
		return;
	}

	if (self.attack_finished > time)
		return;

	SUB_CallAsSelf(player_nail1, self.animcontroller);

	if (self.weaponframe > 8 && self.weaponframe <= 16) self.weaponframe -= 8;
	else self.weaponframe = 0;
	
	weaponanim_supernailgun_loop();
	
}

void() weaponanim_supernailgun_loop = {

	if (!self.attackhold && !self.attackpressed){
		self.weaponframe += 8;
		weaponanim_supernailgun_end();
		SUB_CallAsSelf(player_run, self.animcontroller);
		return;
	}

	if (W_CheckWeapon(self.weapon, self) != WEAPONSTAT_AVAILABLE){
		W_ChangeWeapon(W_BestWeapon());
		return;
	}

	if (self.weaponframe >= 8) {
		self.weaponframe = 1;
	}
	else {
		self.weaponframe++;
	}

	if (self.weaponframe == 1 || self.weaponframe == 5) {
		self.attack_finished = time + 0.2;

		self.currentammo = self.ammo_nails = self.ammo_nails - 2;

		self.punchangle_x = -2;

		self.effects |= EF_MUZZLEFLASH;

		SuperDamageSound();
		W_FireSuperSpikes();
	}
	

	self.think = weaponanim_supernailgun_loop;
	self.nextthink = time + 0.025;
}


void() weaponanim_supernailgun_end = {

	if (self.weaponframe >= 59) {
		self.weaponframe = 0;
		return;
	}
	else {
		self.weaponframe++;
	}

	if (self.weaponframe == 33) sound (self, 7, "weapons/spindn_click.wav", 0.15, ATTN_NORM);
	if (self.weaponframe == 56) sound (self, 7, "weapons/spindn_click.wav", 0.3, ATTN_NORM);

	self.think = weaponanim_supernailgun_end;
	self.nextthink = time + 0.025;

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
