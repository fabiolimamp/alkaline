/*
===================================================================================================
===================================================================================================
									weapons_animate.qc
===================================================================================================
===================================================================================================

Code responsible for managing the whole firing cycle and animations for the player's weapons.
Ammo usage and checking should be managed here too.
*/


//=================================================================================================
// Axe
//=================================================================================================

float() weaponanim_axe = {
	if (self.attack_finished > time)
		return FALSE;

	sound (self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
	
	self.attack_finished = time + 0.5;
	
	self.weaponframe = floor(random()*4.99)*10 + 2;

	player_axe_start(self.animcontroller, (self.weaponframe - 2)/10);

	self.think = weaponanim_axe_loop;
	self.nextthink = time + 0.05;

	return FALSE; // axe swing will never count as fired until it hits something
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

float() weaponanim_chainsaw = {
	// handled via animation loop
	if (self.attackhold) {
		return FALSE;
	}

	if (self.attack_finished > time)
		return FALSE;

	
	SUB_CallAsSelf(player_chainsaw1, self.animcontroller);

	self.attack_finished = time + 0.55;

	self.weaponframe = 4;
	weaponanim_chainsaw_loop();
	
	return TRUE;
}

void() weaponanim_chainsaw_loop = {

	if (!self.attackhold && !self.attackpressed){
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

	if (self.weaponframe == 5) sound(self, CHAN_AUTO, "weapons/sawatck.wav", 1, ATTN_NORM);

	if (self.weaponframe % 2 == 1)
		W_FireSaw();
	

	self.think = weaponanim_chainsaw_loop;
	self.nextthink = time + 0.1;

}


void() weaponanim_chainsaw_idle = {

	if (self.view_ofs != '0 0 0' && self.weaponframe == 0)
		sound (self, CHAN_AUTO, "weapons/sawridle.wav", 1, ATTN_IDLE);

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

float() weaponanim_shotgun = {
	if (self.attack_finished > time)
		return FALSE;

	if (W_CheckWeapon(self.weapon, self) != WEAPONSTAT_AVAILABLE){
		W_ChangeWeapon(W_BestWeapon());
		return FALSE;
	}

	self.currentammo = self.ammo_shells = self.ammo_shells - 1;

	self.attack_finished = time + 0.5;
	
	SUB_CallAsSelf(player_shot1, self.animcontroller);
	
	self.effects = self.effects | EF_MUZZLEFLASH;

	SuperDamageSound();
	W_FireShotgun();

	self.weaponframe = 1;
	self.think = weaponanim_shotgun_loop;
	self.nextthink = time + 0.025;
	
	return TRUE;
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

float() weaponanim_supershotgun = {
	if (self.attack_finished > time)
		return FALSE;

	float stat = W_CheckWeapon(self.weapon, self);

	if (stat != WEAPONSTAT_AVAILABLE){
		//dprint("Not available!\n");
		W_ChangeWeapon(W_BestWeapon());
		return FALSE;
	}

	self.attack_finished = time + 0.7;
	
	SUB_CallAsSelf(player_shot1, self.animcontroller);
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	
	SuperDamageSound();

	if (self.ammo_shells == 1) {
		W_FireShotgun();
		self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	}
	else {
		W_FireSuperShotgun();
		self.currentammo = self.ammo_shells = self.ammo_shells - 2;
	}

	self.weaponframe = 1;
	self.think = weaponanim_supershotgun_loop;
	self.nextthink = time + 0.025;
	
	return TRUE;
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

float() weaponanim_nailgun = {
	// handled via animation loop4
	if (self.attackhold && self.attack_finished > time) {
		return FALSE;
	}

	if (self.attack_finished > time)
		return FALSE;

	SUB_CallAsSelf(player_nail1, self.animcontroller);

	self.weaponframe = 0;
	self.nextthink1 = time + 0.1;
	
	weaponanim_nailgun_loop();
	
	return TRUE;
	
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

	// frame correction so the firing rate isn't so dependent on the server framerate
	if (time > self.nextthink1) {
		if (self.weaponframe > 5) self.weaponframe = 1;
		else if (self.weaponframe > 1) self.weaponframe = 5;
	}

	float offs;
	
	if (self.weaponframe == 1 || self.weaponframe == 5) {

		// fire rate timer. Don't set if on the first firing serverframe, since this will already be set by the startup animation function
		if (self.attackhold) self.nextthink1 += 0.1;
		
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


float() weaponanim_supernailgun = {
	// handled via animation loop4
	if (self.attackhold && self.attack_finished > time) {
		return FALSE;
	}
	
	if (self.attack_finished > time)
		return FALSE;

	SUB_CallAsSelf(player_nail1, self.animcontroller);

	if (self.weaponframe > 8 && self.weaponframe <= 16) self.weaponframe -= 8;
	else self.weaponframe = 0;

	self.nextthink1 = time + 0.1;

	weaponanim_supernailgun_loop();
	
	return TRUE;
	
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
	
	// frame correction so the firing rate isn't so dependent on the server frametime
	if (time > self.nextthink1) {
		if (self.weaponframe > 5) self.weaponframe = 1;
		else if (self.weaponframe > 1) self.weaponframe = 5;
	}

	if (self.weaponframe == 1 || self.weaponframe == 5) {
		// fire rate timer. Don't set if on the first firing serverframe, since this will already be set by the startup animation function
		if (self.attackhold) self.nextthink1 += 0.1;
		
		self.attack_finished = time + 0.2;

		self.punchangle_x = -2;

		self.effects |= EF_MUZZLEFLASH;

		SuperDamageSound();

		if (self.ammo_nails < 2) {
			W_FireSpikes(0);
			self.currentammo = self.ammo_nails = self.ammo_nails - 1;
		}
		else {
			W_FireSuperSpikes();
			self.currentammo = self.ammo_nails = self.ammo_nails - 2;
		}
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

float() weaponanim_grenade = {
	if (self.attack_finished > time)
		return FALSE;

	if (W_CheckWeapon(self.weapon, self) != WEAPONSTAT_AVAILABLE){
		W_ChangeWeapon(W_BestWeapon());
		return FALSE;
	}

	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;

	self.attack_finished = time + 0.6;
	
	SUB_CallAsSelf(player_rockatt1, self.animcontroller);
	
	self.effects = self.effects | EF_MUZZLEFLASH;

	W_FireGrenade();

	self.weaponframe = 1;
	self.think = weaponanim_grenade_loop;
	self.nextthink = time + 0.025;
	
	return TRUE;
}

void() weaponanim_grenade_loop = {

	if (self.weaponframe >= 24) {
		self.weaponframe = 0;
		return;
	}
	else {
		self.weaponframe++;
	}

	self.think = weaponanim_grenade_loop;
	self.nextthink = time + 0.025;

}



//=================================================================================================
// Proximity Launcher
//=================================================================================================

float() weaponanim_proximity = {
	if (self.attack_finished > time)
		return FALSE;

	if (W_CheckWeapon(self.weapon, self) != WEAPONSTAT_AVAILABLE){
		W_ChangeWeapon(W_BestWeapon());
		return FALSE;
	}

	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;

	self.attack_finished = time + 0.6;
	
	SUB_CallAsSelf(player_rockatt1, self.animcontroller);
	
	self.effects = self.effects | EF_MUZZLEFLASH;

	W_FireProximityGrenade();

	self.weaponframe = 1;
	self.think = weaponanim_proximity_loop;
	self.nextthink = time + 0.025;
	
	return TRUE;
}

void() weaponanim_proximity_loop = {

	if (self.weaponframe >= 24) {
		self.weaponframe = 0;
		return;
	}
	else {
		self.weaponframe++;
	}

	self.think = weaponanim_proximity_loop;
	self.nextthink = time + 0.025;

}



//=================================================================================================
// Rocket Launcher
//=================================================================================================

float() weaponanim_rocket = {
	if (self.attack_finished > time)
		return FALSE;

	if (W_CheckWeapon(self.weapon, self) != WEAPONSTAT_AVAILABLE){
		W_ChangeWeapon(W_BestWeapon());
		return FALSE;
	}

	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;

	self.attack_finished = time + 0.8;
	
	SUB_CallAsSelf(player_rockatt1, self.animcontroller);
	
	self.effects = self.effects | EF_MUZZLEFLASH;

	W_FireRocket();

	self.weaponframe = 1;
	self.think = weaponanim_rocket_loop;
	self.nextthink = time + 0.025;
	
	return TRUE;
}

void() weaponanim_rocket_loop = {

	if (self.weaponframe >= 32) {
		self.weaponframe = 0;
		return;
	}
	else {
		self.weaponframe++;
	}

	self.think = weaponanim_rocket_loop;
	self.nextthink = time + 0.025;

}



//=================================================================================================
// Lightning Gun
//=================================================================================================

float() weaponanim_lg = {	// handled via animation loop4
	if (self.attackhold && self.attack_finished > time) {
		return FALSE;
	}

	if (self.attack_finished > time)
		return FALSE;

	SUB_CallAsSelf(player_light1, self.animcontroller);

	self.weaponframe = 0;
	
	weaponanim_lg_loop();
	
	return TRUE;
	
}

void() weaponanim_lg_loop = {
	if (!self.attackhold && !self.attackpressed){
		self.weaponframe = 0;
		SUB_CallAsSelf(player_run, self.animcontroller);
		return;
	}


	if (W_CheckWeapon(self.weapon, self) != WEAPONSTAT_AVAILABLE){
		W_ChangeWeapon(W_BestWeapon());
		return;
	}

	if (self.weaponframe >= 4) {
		self.weaponframe = 1;
	}
	else {
		self.weaponframe++;
	}
	
	self.attack_finished = time + 0.2;

	self.currentammo = self.ammo_cells = self.ammo_cells - 1;

	self.punchangle_x = -2;

	self.effects |= EF_MUZZLEFLASH;

	SuperDamageSound();
	W_FireLightning();

	

	self.think = weaponanim_lg_loop;
	self.nextthink = time + 0.1;
}




//=================================================================================================
// Laser Cannon
//=================================================================================================

float() weaponanim_laser = {
	// handled via animation loop4
	if (self.attackhold && self.attack_finished > time) {
		return FALSE;
	}

	if (self.attack_finished > time)
		return FALSE;

	SUB_CallAsSelf(player_nail1, self.animcontroller);

	self.weaponframe = 0;
	self.nextthink1 = time + 0.1;
	weaponanim_laser_loop();
	
	
	return TRUE;
}

void() weaponanim_laser_loop = {
	if (!self.attackhold && !self.attackpressed){
		self.weaponframe = 0;
		SUB_CallAsSelf(player_run, self.animcontroller);
		return FALSE;
	}

	if (W_CheckWeapon(self.weapon, self) != WEAPONSTAT_AVAILABLE){
		W_ChangeWeapon(W_BestWeapon());
		return FALSE;
	}

	if (self.weaponframe >= 8) {
		self.weaponframe = 1;
	}
	else {
		self.weaponframe++;
	}
	
	// frame correction so the firing rate isn't so dependent on the server frametime
	if (time > self.nextthink1) {
		if (self.weaponframe > 5) self.weaponframe = 1;
		else if (self.weaponframe > 1) self.weaponframe = 5;
	}

	if (self.weaponframe == 1 || self.weaponframe == 5) {
		// fire rate timer. Don't set if on the first firing serverframe, since this will already be set by the startup animation function
		if (self.attackhold) self.nextthink1 += 0.1;

		self.attack_finished = time + 0.1;

		self.currentammo = self.ammo_cells = self.ammo_cells - 1;

		self.effects |= EF_MUZZLEFLASH;

		SuperDamageSound();

		if (self.weaponframe == 1)
			HIP_FireLaser(0);
		else
			HIP_FireLaser(1);

	}
	

	self.think = weaponanim_laser_loop;
	self.nextthink = time + 0.025;
}



//=================================================================================================
// Plasma Gun
//=================================================================================================

float() weaponanim_plasma = {
	if (self.attack_finished > time)
		return FALSE;

	if (W_CheckWeapon(self.weapon, self) != WEAPONSTAT_AVAILABLE){
		W_ChangeWeapon(W_BestWeapon());
		return FALSE;
	}

	self.currentammo = self.ammo_cells = self.ammo_cells - 1;

	self.attack_finished = time + 0.05;
	
	SUB_CallAsSelf(player_shot1, self.animcontroller);
	
	self.effects = self.effects | EF_MUZZLEFLASH;

	SuperDamageSound();
	W_FirePlasma();

	self.weaponframe = 1;
	self.think = weaponanim_plasma1;
	self.nextthink = time + 0.05;
	
	return TRUE;
}

void() weaponanim_plasma1 = {
	self.weaponframe = 2;
	self.think = weaponanim_plasma2;
	self.nextthink = time + 0.05;
}

void() weaponanim_plasma2 = {
	self.weaponframe = 1;
	self.think = weaponanim_plasma3;
	self.nextthink = time + 0.1;
}

void() weaponanim_plasma3 = {
	self.weaponframe = 0;
}