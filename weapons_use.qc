

/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

void() W_SetCurrentAmmo =
{
	if (self.weapon != WEAPON_NO_WEAPON && !(self.weapon == WEAPON_SUPER_NAILGUN && self.cnt == 1)) player_run ();		// get out of any weapon firing states

	self.items = self.items - ( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );
	
	if (self.weapon == WEAPON_NO_WEAPON)  //johnfitz
	{
		self.currentammo = 0;
		self.weaponmodel = "";
		self.weaponframe = 0;
	}	
	else if (self.weapon == WEAPON_AXE)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_alkaxe20fps.mdl";
		self.weaponframe = 0;
	}
	else if (self.weapon == WEAPON_CHAINSAW)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_saw.mdl";
		self.weaponframe = 0;
		sound (self, 6, "weapons/sawidle.wav", 1, ATTN_NORM);
	}
	else if (self.weapon == WEAPON_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == WEAPON_SUPER_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == WEAPON_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail_alk40fps.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == WEAPON_SUPER_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail3.mdl";
		if (self.cnt != 1) self.weaponframe = 0;
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == WEAPON_LASER_CANNON)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_laserg.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_CELLS;
	}
	else if (self.weapon == WEAPON_PLASMA)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_plasma.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_CELLS;
	}
	else if (self.weapon == WEAPON_GRENADE_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == WEAPON_PROXIMITY_GUN)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_mine.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == WEAPON_ROCKET_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == WEAPON_LIGHTNING)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_light.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_CELLS;
	}
	else
	{
		self.currentammo = 0;
		self.weaponmodel = "";
		self.weaponframe = 0;
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

float() W_BestWeapon =
{
	local	float	weaps;
	
	weaps = self.weapons;

	return W_BestWeaponParms(weaps, self.ammo_shells, self.ammo_nails, self.ammo_cells, self.waterlevel);
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
	
	self.weapon = W_BestWeapon ();

	W_SetCurrentAmmo ();
	
// drop the weapon down
	return FALSE;
};



/*
============
W_Attack

Called when player presses the attack button.
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
		player_shot1 ();
		W_FireSuperShotgun ();
		self.attack_finished = time + 0.7;
	}
	else if (self.weapon == WEAPON_NAILGUN)
	{
		player_nail ();
	}
	else if (self.weapon == WEAPON_SUPER_NAILGUN)
	{
		player_super_nail ();
	}
	else if (self.weapon == WEAPON_GRENADE_LAUNCHER)
	{
		player_rocket1();
		W_FireGrenade();
		self.attack_finished = time + 0.6;
	}
	else if (self.weapon == WEAPON_PROXIMITY_GUN)
	{
		player_rocket1();
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
};

/*
============
W_ChangeWeapon

============
*/
void() W_ChangeWeapon =
{
	local float noammo;
	local float weap;
	local float item;
	
	noammo = 0;
	self.weaponframe = 0;

	if (self.impulse == 1) {
		if (!(self.weapons & WEAPON_AXE) && (self.weapons & WEAPON_CHAINSAW)) { // has the saw but not the axe
			weap = WEAPON_CHAINSAW;
		}
		else if (self.weapon == WEAPON_AXE) {
			if (self.weapons & WEAPON_CHAINSAW) {
				weap = WEAPON_CHAINSAW;
			}
			else 
				weap = WEAPON_AXE;
		}
		else
			weap = WEAPON_AXE; 
	}
	else if (self.impulse == 2)	{
		weap = WEAPON_SHOTGUN;
		if (self.ammo_shells < 1)
			noammo = 1;
	}
	else if (self.impulse == 3)	{
		weap = WEAPON_SUPER_SHOTGUN;
		if (self.ammo_shells < 2)
			noammo = 1;
	}		
	else if (self.impulse == 4)	{
		weap = WEAPON_NAILGUN;
		if (self.ammo_nails < 1)
			noammo = 1;
	}
	else if (self.impulse == 5)	{
		weap = WEAPON_SUPER_NAILGUN;
		if (self.ammo_nails < 2)
			noammo = 1;
	}
	else if (self.impulse == 6)	{
		weap = WEAPON_GRENADE_LAUNCHER;
		if(self.weapon == WEAPON_GRENADE_LAUNCHER){
			weap = WEAPON_PROXIMITY_GUN;
		}
		else {
			if(self.weapons & WEAPON_GRENADE_LAUNCHER){
				weap = WEAPON_GRENADE_LAUNCHER;
			}
			else if(self.weapons & WEAPON_PROXIMITY_GUN){
				weap = WEAPON_PROXIMITY_GUN;
			}
		}
		
		if (self.ammo_rockets < 1) 
			noammo = 1;
	}
	else if (self.impulse == 7)	{
		weap = WEAPON_ROCKET_LAUNCHER;
		if (self.ammo_rockets < 1)
			noammo = 1;
	}
	else if (self.impulse == 8)	{
		if (self.weapon == WEAPON_LIGHTNING) {
			if(self.weapons & WEAPON_LASER_CANNON)
				weap = WEAPON_LASER_CANNON;
			else {
				weap = WEAPON_PLASMA;
			}
		}
		else if (self.weapon == WEAPON_LASER_CANNON) {
			if (self.weapons & WEAPON_PLASMA) {
				weap = WEAPON_PLASMA;
			}
			else 
				weap = item = WEAPON_LIGHTNING;
		}
		else if(self.weapon == WEAPON_PLASMA) {
			if(self.weapons & WEAPON_LIGHTNING)
				weap = WEAPON_LIGHTNING;
			else
				weap = WEAPON_LASER_CANNON;
		}
		else if(self.weapons & WEAPON_LIGHTNING)
			weap = WEAPON_LIGHTNING;
		else if(self.weapons & WEAPON_LASER_CANNON)
			weap = WEAPON_LASER_CANNON;
		else {
			weap = WEAPON_PLASMA;
		}

		if (self.ammo_cells < 1)
			noammo = 1;
	}
	else if (self.impulse == 225) {
		weap = WEAPON_LASER_CANNON;
		if (self.ammo_cells < 1)
			noammo = 1;
	}
	else if (self.impulse == 226) {
		weap = WEAPON_CHAINSAW;
	}
	else if (self.impulse == 227) {
		weap = WEAPON_PLASMA;
		if (self.ammo_cells < 1)
			noammo = 1;
	} 
	else if (self.impulse == 228) {
		weap = WEAPON_LIGHTNING;
		if (self.ammo_cells < 1)
			noammo = 1;
	}
	else if (self.impulse == 229) {
		weap = WEAPON_PROXIMITY_GUN;
		if (self.ammo_rockets < 1)
			noammo = 1;
	}
	else if (self.impulse == 230) {
		weap = WEAPON_GRENADE_LAUNCHER;
		if (self.ammo_rockets < 1)
			noammo = 1;
	}
	else if (self.impulse == 231) {
		weap = WEAPON_AXE;
	}
	else 
		weap = WEAPON_NO_WEAPON; // doesn't work right but does no harm either
	
	self.impulse = 0;
	

	if(weap) {
		if (!(self.weapons & weap)) {	// don't have the weapon or the ammo
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
	self.weapon = weap;

	W_SetCurrentAmmo ();
};

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void() CycleWeaponCommand =
{
	local	float	weaps, noammo, loop;
	
	weaps = self.weapons;
	
	self.impulse = 0;
	self.weaponframe = 0;
	
	if (!(weaps & ALL_WEAPONS))
	{
		self.weapon = WEAPON_NO_WEAPON;
		W_SetCurrentAmmo ();
		return;
	}

	
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
			W_SetCurrentAmmo ();
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
	local	float	weaps, noammo, loop;
	
	weaps = self.weapons;

	self.impulse = 0;
	self.weaponframe = 0;

	if (!(weaps & ALL_WEAPONS))
	{
		self.weapon = WEAPON_NO_WEAPON;
		W_SetCurrentAmmo ();
		return;
	}

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
			W_SetCurrentAmmo ();
			return;
		}
		loop++;
	}

};
