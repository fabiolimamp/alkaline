

/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

void(float resetState) W_SetCurrentAmmo =
{
	if (resetState) {
		if (self.weapon != WEAPON_NO_WEAPON && !(self.weapon == WEAPON_SUPER_NAILGUN && self.cnt == 1)) {
			player_run ();		// get out of any weapon firing states
			self.weaponframe = 0;
		}
	}

	self.items = self.items - ( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );

	if (self.weapon == WEAPON_NO_WEAPON)  //johnfitz
	{
		self.currentammo = 0;
		self.weaponmodel = "";
	}	
	else if (self.weapon == WEAPON_AXE)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_alkaxe20fps.mdl";
	}
	else if (self.weapon == WEAPON_CHAINSAW)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_saw.mdl";
		sound (self, 6, "weapons/sawidle.wav", 1, ATTN_NORM);
	}
	else if (self.weapon == WEAPON_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot40fps.mdl";
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == WEAPON_SUPER_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot2_40fps.mdl";
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == WEAPON_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail_alk40fps.mdl";
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == WEAPON_SUPER_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail3.mdl";
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == WEAPON_LASER_CANNON)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_laserg40fps.mdl";
		self.items = self.items | IT_CELLS;
	}
	else if (self.weapon == WEAPON_PLASMA)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_plasma.mdl";
		self.items = self.items | IT_CELLS;
	}
	else if (self.weapon == WEAPON_GRENADE_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock_40fps.mdl";
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == WEAPON_PROXIMITY_GUN)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_mine_40fps.mdl";
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == WEAPON_ROCKET_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock2_40fps.mdl";
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == WEAPON_LIGHTNING)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_light.mdl";
		self.items = self.items | IT_CELLS;
	}
	else
	{
		self.currentammo = 0;
		self.weaponmodel = "";
	}
};

float(float weapons, float shells, float nails, float cells, float waterlevel) W_BestWeaponParms =
{
	if(waterlevel <= 1 && cells >= 1 && weapons & WEAPON_PLASMA)
		return WEAPON_PLASMA;
	if(waterlevel <= 1 && cells >= 1 && (weapons & WEAPON_LIGHTNING) )
		return WEAPON_LIGHTNING;
	if(cells >= 1 && (weapons & WEAPON_LASER_CANNON) )
		return WEAPON_LASER_CANNON;
	if(nails >= 2 && (weapons & WEAPON_SUPER_NAILGUN) )
		return WEAPON_SUPER_NAILGUN;
	if(shells >= 2 && (weapons & WEAPON_SUPER_SHOTGUN) )
		return WEAPON_SUPER_SHOTGUN;
	if(nails >= 1 && (weapons & WEAPON_NAILGUN) )
		return WEAPON_NAILGUN;
	if(shells >= 1 && (weapons & WEAPON_SHOTGUN) )
		return WEAPON_SHOTGUN;
	if(weapons & WEAPON_CHAINSAW)
		return WEAPON_CHAINSAW;
	if(weapons & WEAPON_AXE)
		return WEAPON_AXE;
	return WEAPON_NO_WEAPON; //johnfitz
};

float() W_BestWeapon = {
	return W_BestWeaponParms(self.weapons, self.ammo_shells, self.ammo_nails, self.ammo_cells, self.waterlevel);
};

float(float currentweapon, float shells, float nails, float rockets, float cells) W_CheckAmmoParms = {
	if (
		(currentweapon == WEAPON_NO_WEAPON) ||
		(currentweapon == WEAPON_AXE) ||
		(currentweapon == WEAPON_CHAINSAW) ||
		(currentweapon == WEAPON_SHOTGUN && shells >= 1) ||
		(currentweapon == WEAPON_SUPER_SHOTGUN && shells >= 2) ||
		(currentweapon == WEAPON_NAILGUN && nails >= 1) ||
		(currentweapon == WEAPON_SUPER_NAILGUN && nails >= 2) ||
		(currentweapon == WEAPON_GRENADE_LAUNCHER && rockets >= 1) ||
		(currentweapon == WEAPON_PROXIMITY_GUN && rockets >= 1) ||
		(currentweapon == WEAPON_ROCKET_LAUNCHER && rockets >= 1) ||
		(currentweapon == WEAPON_LIGHTNING && cells >= 1) ||
		(currentweapon == WEAPON_LASER_CANNON && cells >= 1) ||
		(currentweapon == WEAPON_PLASMA && cells >= 1)
	) return TRUE;
	else return FALSE;
};

float() W_CheckNoAmmo =
{
	if (self.currentammo > 0)
		return TRUE;

	if (self.weapon == WEAPON_AXE)
		return TRUE;
	
	if (self.weapon == WEAPON_CHAINSAW)
		return TRUE;
	
	float current = self.weapon;
	self.weapon = W_BestWeapon ();

	if (current != self.weapon)
		W_SetCurrentAmmo(TRUE);
	else
		W_SetCurrentAmmo(FALSE);
	
// drop the weapon down
	return FALSE;
};



/*
============
W_Attack

Called on each frame while the player
is pressing the attack button, except if
self.attack_finished timer hasn't passed.
Fired from W_WeaponFrame (impulses.qc)
============
*/


void() W_Attack =
{

	if (!W_CheckNoAmmo ())
		return;

	makevectors	(self.v_angle);			// calculate forward angle for velocity
	self.show_hostile = time + 1;	// wake monsters up

	if (self.weapon == WEAPON_AXE)
	{
		self.show_hostile = 0; // will only be set if the axe hits something
		sound (self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
		player_axe();
		//W_FireBall();

		self.attack_finished = time + 0.5;
	}
	else if (self.weapon == WEAPON_SHOTGUN)
	{
		player_shot1 ();
		W_FireShotgun ();
		self.attack_finished = time + 0.5;
	}
	else if (self.weapon == WEAPON_SUPER_SHOTGUN)
	{
		player_sshot1 ();
		W_FireSuperShotgun ();
		self.attack_finished = time + 0.7;
	}
	else if (self.weapon == WEAPON_NAILGUN)
	{
		player_nail ();
		// projectile firing is done through the animation function
	}
	else if (self.weapon == WEAPON_SUPER_NAILGUN)
	{
		player_super_nail ();
		// projectile firing is done through the animation function
	}
	else if (self.weapon == WEAPON_GRENADE_LAUNCHER)
	{
		player_grenade1();
		W_FireGrenade();
		self.attack_finished = time + 0.6;
	}
	else if (self.weapon == WEAPON_PROXIMITY_GUN)
	{
		player_proxgrenade1();
		W_FireProximityGrenade();
		self.attack_finished = time + 0.6;
	}
	else if (self.weapon == WEAPON_ROCKET_LAUNCHER)
	{
		player_rocket1();
		W_FireRocket();
		self.attack_finished = time + 0.8;
	}
	else if (self.weapon == WEAPON_LIGHTNING)
	{
		player_light1();
		self.attack_finished = time + 0.1;
		sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
	}
	else if (self.weapon == WEAPON_LASER_CANNON)
	{
		player_laser1();
		// projectile firing is done through the animation function
	}
	else if (self.weapon == WEAPON_PLASMA)
	{
		player_plasma1();
		W_FirePlasma();
		self.attack_finished = time + 0.05;
	}
	else if (self.weapon == WEAPON_CHAINSAW)
	{
		player_chainsaw1();
		self.attack_finished = time + 0.55;
		sound (self, CHAN_AUTO, "weapons/sawatck.wav", 1, ATTN_NORM);
	}
	else return;

	SuperDamageSound ();
	
};

/*
========
SuperDamageSound

Plays sound if needed
========
*/
void() SuperDamageSound =
{
	if ((self.super_damage_finished > time) || (self.trif_finished > time))
	{
		if (self.super_sound < time)
		{
			
			if(self.trif_finished > time) {
				sound(self, CHAN_BODY, "items/trifecta3.wav", 1, ATTN_NORM);
				self.super_sound = time + 0.7;
			}
			else{
				sound (self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
				self.super_sound = time + 1;
			}
			
		}
	}
	return;
};


/*
============
W_ChangeWeapon

============
*/
void() W_ChangeWeapon =
{
	local float noammo;
	local float new, current;
	local float item;
	
	noammo = 0;

	if (self.impulse == 1) {
		if (!(self.weapons & WEAPON_AXE) && (self.weapons & WEAPON_CHAINSAW)) { // has the saw but not the axe
			new = WEAPON_CHAINSAW;
		}
		else if (self.weapon == WEAPON_AXE) {
			if (self.weapons & WEAPON_CHAINSAW) {
				new = WEAPON_CHAINSAW;
			}
			else 
				new = WEAPON_AXE;
		}
		else
			new = WEAPON_AXE; 
	}
	else if (self.impulse == 2)	{
		new = WEAPON_SHOTGUN;
		if (self.ammo_shells < 1)
			noammo = 1;
	}
	else if (self.impulse == 3)	{
		new = WEAPON_SUPER_SHOTGUN;
		if (self.ammo_shells < 2)
			noammo = 1;
	}		
	else if (self.impulse == 4)	{
		new = WEAPON_NAILGUN;
		if (self.ammo_nails < 1)
			noammo = 1;
	}
	else if (self.impulse == 5)	{
		new = WEAPON_SUPER_NAILGUN;
		if (self.ammo_nails < 2)
			noammo = 1;
	}
	else if (self.impulse == 6)	{
		new = WEAPON_GRENADE_LAUNCHER;
		if(self.weapon == WEAPON_GRENADE_LAUNCHER){
			new = WEAPON_PROXIMITY_GUN;
		}
		else {
			if (self.weapons & WEAPON_GRENADE_LAUNCHER){
				new = WEAPON_GRENADE_LAUNCHER;
			}
			else if (self.weapons & WEAPON_PROXIMITY_GUN){
				new = WEAPON_PROXIMITY_GUN;
			}
		}
		
		if (self.ammo_rockets < 1) 
			noammo = 1;
	}
	else if (self.impulse == 7)	{
		new = WEAPON_ROCKET_LAUNCHER;
		if (self.ammo_rockets < 1)
			noammo = 1;
	}
	else if (self.impulse == 8)	{
		if (self.weapon == WEAPON_LIGHTNING) {
			if(self.weapons & WEAPON_LASER_CANNON)
				new = WEAPON_LASER_CANNON;
			else {
				new = WEAPON_PLASMA;
			}
		}
		else if (self.weapon == WEAPON_LASER_CANNON) {
			if (self.weapons & WEAPON_PLASMA) {
				new = WEAPON_PLASMA;
			}
			else 
				new = item = WEAPON_LIGHTNING;
		}
		else if(self.weapon == WEAPON_PLASMA) {
			if(self.weapons & WEAPON_LIGHTNING)
				new = WEAPON_LIGHTNING;
			else
				new = WEAPON_LASER_CANNON;
		}
		else if(self.weapons & WEAPON_LIGHTNING)
			new = WEAPON_LIGHTNING;
		else if(self.weapons & WEAPON_LASER_CANNON)
			new = WEAPON_LASER_CANNON;
		else {
			new = WEAPON_PLASMA;
		}

		if (self.ammo_cells < 1)
			noammo = 1;
	}
	else if (self.impulse == 225) {
		new = WEAPON_LASER_CANNON;
		if (self.ammo_cells < 1)
			noammo = 1;
	}
	else if (self.impulse == 226) {
		new = WEAPON_CHAINSAW;
	}
	else if (self.impulse == 227) {
		new = WEAPON_PLASMA;
		if (self.ammo_cells < 1)
			noammo = 1;
	} 
	else if (self.impulse == 228) {
		new = WEAPON_LIGHTNING;
		if (self.ammo_cells < 1)
			noammo = 1;
	}
	else if (self.impulse == 229) {
		new = WEAPON_PROXIMITY_GUN;
		if (self.ammo_rockets < 1)
			noammo = 1;
	}
	else if (self.impulse == 230) {
		new = WEAPON_GRENADE_LAUNCHER;
		if (self.ammo_rockets < 1)
			noammo = 1;
	}
	else if (self.impulse == 231) {
		new = WEAPON_AXE;
	}
	else 
		new = WEAPON_NO_WEAPON; // doesn't work right but does no harm either
	
	self.impulse = 0;
	
	if (new) {
		if (!(self.weapons & new)) {	// don't have the weapon or the ammo
			sprint (self, "no weapon.\n");
			return;
		}
	}

	
	if (noammo) {	// don't have the ammo
		sprint (self, "not enough ammo.\n");
		return;
	}
	
//
// set weapon, set ammo
//
	current = self.weapon;
	self.weapon = new;

	if (current != new) W_SetCurrentAmmo (TRUE);
	else W_SetCurrentAmmo (FALSE);
	
};

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void() CycleWeaponCommand =
{
	float	weaps, current, noammo, loop;
	
	weaps = self.weapons;
	
	self.impulse = 0;
	self.weaponframe = 0;
	
	if (!(weaps & ALL_WEAPONS))
	{
		self.weapon = WEAPON_NO_WEAPON;
		W_SetCurrentAmmo (TRUE);
		return;
	}

	current = self.weapon;
	
	while (1)
	{
		noammo = FALSE;
		
		if (self.weapon == WEAPON_AXE)
		{
			self.weapon = WEAPON_CHAINSAW;			
		}
		else if (self.weapon == WEAPON_CHAINSAW)
		{
			self.weapon = WEAPON_SHOTGUN;
			if (self.ammo_shells < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_SHOTGUN)
		{
			self.weapon = WEAPON_SUPER_SHOTGUN;
			if (self.ammo_shells < 2)
				noammo = TRUE;
		}		
		else if (self.weapon == WEAPON_SUPER_SHOTGUN)
		{
			self.weapon = WEAPON_NAILGUN;
			if (self.ammo_nails < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_NAILGUN)
		{
			self.weapon = WEAPON_SUPER_NAILGUN;
			if (self.ammo_nails < 2)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_SUPER_NAILGUN)
		{
			self.weapon = WEAPON_GRENADE_LAUNCHER;
			if (self.ammo_rockets < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_GRENADE_LAUNCHER)
		{
			self.weapon = WEAPON_PROXIMITY_GUN;
			if (self.ammo_rockets < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_PROXIMITY_GUN)
		{
			self.weapon = WEAPON_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_ROCKET_LAUNCHER)
		{
			self.weapon = WEAPON_LIGHTNING;
			if (self.ammo_cells < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_LIGHTNING)
		{
			self.weapon = WEAPON_LASER_CANNON;
			if (self.ammo_cells < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_LASER_CANNON)
		{
			self.weapon = WEAPON_PLASMA;
			if (self.ammo_cells < 1)
				noammo = TRUE;			
		}
		else if (self.weapon == WEAPON_PLASMA)
		{
			self.weapon = WEAPON_AXE;
		}
		
		if ((weaps & self.weapon && !noammo) || loop > 12)
		{
			if (loop > 12) self.weapon = WEAPON_NO_WEAPON;
			
			if (current != self.weapon)
				W_SetCurrentAmmo(TRUE);
			else
				W_SetCurrentAmmo(FALSE);
			
			return;
		}

		loop++;

	}
};

/*
============
CycleWeaponReverseCommand

Go to the prev weapon with ammo
============
*/
void() CycleWeaponReverseCommand =
{
	float	weaps, current, noammo, loop;
	
	weaps = self.weapons;

	self.impulse = 0;
	self.weaponframe = 0;

	if (!(weaps & ALL_WEAPONS))
	{
		self.weapon = WEAPON_NO_WEAPON;
		W_SetCurrentAmmo (TRUE);
		return;
	}

	current = self.weapon;

	while (1)
	{
		noammo = FALSE;
		
		if (self.weapon == WEAPON_PLASMA)
		{
			self.weapon = WEAPON_LASER_CANNON;
			if (self.ammo_cells < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_LASER_CANNON)
		{
			self.weapon = WEAPON_LIGHTNING;
			if (self.ammo_cells < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_LIGHTNING)
		{
			self.weapon = WEAPON_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_ROCKET_LAUNCHER)
		{
			self.weapon = WEAPON_PROXIMITY_GUN;
			if (self.ammo_rockets < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_PROXIMITY_GUN)
		{
			self.weapon = WEAPON_GRENADE_LAUNCHER;
			if (self.ammo_rockets < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_GRENADE_LAUNCHER)
		{
			self.weapon = WEAPON_SUPER_NAILGUN;
			if (self.ammo_nails < 2)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_SUPER_NAILGUN)
		{
			self.weapon = WEAPON_NAILGUN;
			if (self.ammo_nails < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_NAILGUN)
		{
			self.weapon = WEAPON_SUPER_SHOTGUN;
			if (self.ammo_shells < 2)
				noammo = TRUE;
		}		
		else if (self.weapon == WEAPON_SUPER_SHOTGUN)
		{
			self.weapon = WEAPON_SHOTGUN;
			if (self.ammo_shells < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_SHOTGUN)
		{
			self.weapon = WEAPON_CHAINSAW;
		}
		else if (self.weapon == WEAPON_CHAINSAW)
		{
			self.weapon = WEAPON_AXE;
		}
		else if (self.weapon == WEAPON_AXE || self.weapon == WEAPON_NO_WEAPON)
		{	
			self.weapon = WEAPON_PLASMA;
			if (self.ammo_cells < 1)
				noammo = TRUE;
		}
		
		if ((weaps & self.weapon && !noammo) || loop > 12)
		{
			if (loop > 12) self.weapon = WEAPON_NO_WEAPON;

			if (current != self.weapon)
				W_SetCurrentAmmo(TRUE);
			else
				W_SetCurrentAmmo(FALSE);
			
			return;
		}
		loop++;
	}

};
