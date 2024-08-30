typedef struct {
	float id;
	float slot;
	float slotPos;
	string name;
	string model;
	.float ammofield;
	float ammo_item;
	float ammo_usage;
	void() animfunction;
} weaponclass_t;


weaponclass_t wpc_no_weapon = {
	WEAPON_NO_WEAPON,
	0, // slot
	0, // slotPos
	"No weapon", // name
	"", // model
	ammo_shells, // ammofield
	IT_SHELLS,
	0, // ammo_usage
	weaponanim_none // animfunction
};

weaponclass_t wpc_axe = {
	WEAPON_AXE,
	1, // slot
	0, // slotPos
	"Axe", // name
	"progs/v_alkaxe20fps.mdl", // model
	ammo_shells, // ammofield
	IT_SHELLS,
	0, // ammo_usage
	weaponanim_axe // animfunction
};

weaponclass_t wpc_chainsaw = {
	WEAPON_CHAINSAW,
	1, // slot
	1, // slotPos
	"Chainsaw", // name
	"progs/sawidle.mdl", // model
	ammo_shells, // ammofield
	IT_SHELLS,
	0, // ammo_usage
	weaponanim_chainsaw // animfunction
};

weaponclass_t wpc_shotgun = {
	WEAPON_SHOTGUN,
	2, // slot
	0, // slotPos
	"Shotgun", // name
	"progs/v_shot40fps.mdl", // model
	ammo_shells, // ammofield
	IT_SHELLS,
	1, // ammo_usage
	weaponanim_shotgun // animfunction
};

weaponclass_t wpc_supershotgun = {
	WEAPON_SUPER_SHOTGUN,
	3, // slot
	0, // slotPos
	"Super Shotgun", // name
	"progs/v_shot2_40fps.mdl", // model
	ammo_shells, // ammofield
	IT_SHELLS,
	2, // ammo_usage
	weaponanim_supershotgun // animfunction
};

weaponclass_t wpc_nailgun = {
	WEAPON_NAILGUN,
	4, // slot
	0, // slotPos
	"Nailgun", // name
	"progs/v_nail_alk40fps.mdl", // model
	ammo_nails, // ammofield
	IT_NAILS,
	1, // ammo_usage
	weaponanim_nailgun // animfunction
};

weaponclass_t wpc_supernailgun = {
	WEAPON_SUPER_NAILGUN,
	5, // slot
	0, // slotPos
	"Super Nailgun", // name
	"progs/v_nail3.mdl", // model
	ammo_nails, // ammofield
	IT_NAILS,
	2, // ammo_usage
	weaponanim_supernailgun // animfunction
};

weaponclass_t wpc_grenade = {
	WEAPON_GRENADE_LAUNCHER,
	6, // slot
	0, // slotPos
	"Grenade Launcher", // name
	"progs/v_rock_40fps.mdl", // model
	ammo_rockets, // ammofield
	IT_ROCKETS,
	1, // ammo_usage
	weaponanim_grenade // animfunction
};

weaponclass_t wpc_proximity = {
	WEAPON_PROXIMITY_GUN,
	6, // slot
	1, // slotPos
	"Proximity Launcher", // name
	"progs/v_mine_40fps.mdl", // model
	ammo_rockets, // ammofield
	IT_ROCKETS,
	1, // ammo_usage
	weaponanim_proximity // animfunction
};

weaponclass_t wpc_rocket = {
	WEAPON_ROCKET_LAUNCHER,
	7, // slot
	0, // slotPos
	"Rocket Launcher", // name
	"progs/v_rock2_40fps.mdl", // model
	ammo_rockets, // ammofield
	IT_ROCKETS,
	1, // ammo_usage
	weaponanim_rocket // animfunction
};

weaponclass_t wpc_lg = {
	WEAPON_LIGHTNING,
	8, // slot
	0, // slotPos
	"Lightning gun", // name
	"progs/v_light.mdl", // model
	ammo_cells, // ammofield
	IT_CELLS,
	1, // ammo_usage
	weaponanim_lg // animfunction
};

weaponclass_t wpc_laser = {
	WEAPON_LASER_CANNON,
	8, // slot
	1, // slotPos
	"Laser Cannon", // name
	"progs/v_laserg40fps.mdl", // model
	ammo_cells, // ammofield
	IT_CELLS,
	1, // ammo_usage
	weaponanim_laser // animfunction
};

weaponclass_t wpc_plasma = {
	WEAPON_PLASMA,
	8, // slot
	2, // slotPos
	"Plasma Gun", // name
	"progs/v_plasma.mdl", // model
	ammo_cells, // ammofield
	IT_CELLS,
	1, // ammo_usage
	weaponanim_plasma // animfunction
};

weaponclass_t weaponsclass[13] = {
	wpc_no_weapon,
	wpc_axe,
	wpc_chainsaw,
	wpc_shotgun,
	wpc_supershotgun,
	wpc_nailgun,
	wpc_supernailgun,
	wpc_grenade,
	wpc_proximity,
	wpc_rocket,
	wpc_lg,
	wpc_laser,
	wpc_plasma
};

float MAX_WEAPON_NUM = 12;

float(float weap) getWeapon = {
	switch (weap) {
		case WEAPON_AXE:				return 1;
		case WEAPON_CHAINSAW: 			return 2;
		case WEAPON_SHOTGUN:			return 3;
		case WEAPON_SUPER_SHOTGUN:		return 4;
		case WEAPON_NAILGUN:			return 5;
		case WEAPON_SUPER_NAILGUN:		return 6;
		case WEAPON_GRENADE_LAUNCHER:	return 7;
		case WEAPON_PROXIMITY_GUN:		return 8;
		case WEAPON_ROCKET_LAUNCHER:	return 9;
		case WEAPON_LIGHTNING:			return 10;
		case WEAPON_LASER_CANNON:		return 11;
		case WEAPON_PLASMA:				return 12;

		default:					return 0;
	}
}


typedef struct {
	weaponclass_t weaps[4];
	float qt;
} weaponslot_t;

weaponslot_t weaponslots[9] = {
	{{wpc_no_weapon}, 1},
	{{wpc_axe, wpc_chainsaw}, 2},
	{{wpc_shotgun}, 1},
	{{wpc_supershotgun}, 1},
	{{wpc_nailgun}, 1},
	{{wpc_supernailgun}, 1},
	{{wpc_grenade,wpc_proximity}, 2},
	{{wpc_rocket}, 1},
	{{wpc_lg,wpc_laser,wpc_plasma}, 3}
};


enum {
	WEAPONSTAT_NOWEAPON,
	WEAPONSTAT_NOAMMO,
	WEAPONSTAT_AVAILABLE
};

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame = {
	if (self.button0 && time > self.connect_time + 0.2) {
		if (self.attackpressed) self.attackhold = 1;
		else self.attackhold = 0;

		self.attackpressed = 1;

		W_Attack();
	}
	else {
		self.attackpressed = 0;
		self.attackhold = 0;
	}
}


// syncs up current ammo with its correspondent ammo_* field
void() W_UpdateCurrentAmmo = {
	weaponclass_t weap = weaponsclass[getWeapon(self.weapon)];
	self.currentammo = self.(weap.ammofield);
}

float(float weapons, entity cl, float waterlevel) W_BestWeaponParms =
{
	if (W_CheckWeapon(WEAPON_PLASMA, cl) == WEAPONSTAT_AVAILABLE)
		return WEAPON_PLASMA;
	if (W_CheckWeapon(WEAPON_LIGHTNING, cl) == WEAPONSTAT_AVAILABLE && waterlevel <= 1)
		return WEAPON_LIGHTNING;
	if (W_CheckWeapon(WEAPON_LASER_CANNON, cl) == WEAPONSTAT_AVAILABLE)
		return WEAPON_LASER_CANNON;
	if (W_CheckWeapon(WEAPON_SUPER_NAILGUN, cl) == WEAPONSTAT_AVAILABLE)
		return WEAPON_SUPER_NAILGUN;
	if (W_CheckWeapon(WEAPON_SUPER_SHOTGUN, cl) == WEAPONSTAT_AVAILABLE)
		return WEAPON_SUPER_SHOTGUN;
	if (W_CheckWeapon(WEAPON_NAILGUN, cl) == WEAPONSTAT_AVAILABLE)
		return WEAPON_NAILGUN;
	if (W_CheckWeapon(WEAPON_SHOTGUN, cl) == WEAPONSTAT_AVAILABLE)
		return WEAPON_SHOTGUN;
	if (W_CheckWeapon(WEAPON_CHAINSAW, cl) == WEAPONSTAT_AVAILABLE)
		return WEAPON_CHAINSAW;
	if (W_CheckWeapon(WEAPON_AXE, cl) == WEAPONSTAT_AVAILABLE)
		return WEAPON_AXE;

	return WEAPON_NO_WEAPON; 
};

float() W_BestWeapon = {
	return W_BestWeaponParms(self.weapons, self, self.waterlevel);
};

float(float weap, entity cl) W_CheckWeapon = {
	weaponclass_t weapcl = weaponsclass[getWeapon(weap)];

	if (!(cl.weapons & weap)) return WEAPONSTAT_NOWEAPON;

	if (self.(weapcl.ammofield) < weapcl.ammo_usage) {
		return WEAPONSTAT_NOAMMO;
	}

	return WEAPONSTAT_AVAILABLE;
};



void() W_Attack = {
	
	weaponclass_t weap = weaponsclass[getWeapon(self.weapon)];

	if (W_CheckWeapon(self.weapon, self) != WEAPONSTAT_AVAILABLE) {
		return;
	}

	makevectors(self.v_angle);			// calculate forward angle for velocity
	self.show_hostile = time + 1;	// wake monsters up

	weap.animfunction();

};



int(float weap) W_ChangeWeapon = {

	float weapstat = W_CheckWeapon(weap, self);

	if (weapstat < WEAPONSTAT_AVAILABLE){
		return weapstat;
	}

	weaponclass_t weapcl = weaponsclass[getWeapon(weap)];
	self.weapon = weap;
	self.currentammo = self.(weapcl.ammofield);
	self.items &~= (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS);
	self.items |= weapcl.ammo_item;

	self.weaponmodel = weapcl.model;
	self.weaponframe = 0;

	self.attackpressed = 0;
	self.attackhold = 0;

	self.think = player_run;

	return weapstat;
}


int(float imp) W_ChangeSlot = {
	
	weaponslot_t newSlot = weaponslots[imp];

	weaponclass_t currentWeapon = weaponsclass[getWeapon(self.weapon)];

	float startSlotPos;

	if (currentWeapon.slot == imp)
		startSlotPos = wrap(currentWeapon.slotPos + 1, 0, newSlot.qt - 1);
	else
		startSlotPos = 0;

	float i;
	weaponclass_t w;
	float weaponstat;

	while (i < newSlot.qt) {
		weaponstat = W_CheckWeapon(newSlot[startSlotPos].id, self);
		if (weaponstat == WEAPONSTAT_AVAILABLE){
			W_ChangeWeapon(newSlot[startSlotPos].id);
			return TRUE;
		}
		startSlotPos = wrap(startSlotPos + 1, 0, newSlot.qt - 1);
		i++;
	}

	return FALSE;
}


void(float stp) W_CycleWeapon = {

	float currentWeapon = getWeapon(self.weapon);

	float next = wrap(currentWeapon + stp, 1, MAX_WEAPON_NUM);

	while (next != currentWeapon) {
		//dprint3("Testing slot ", ftos(next), "...\n");
		if (W_CheckWeapon(weaponsclass[next].id, self) == WEAPONSTAT_AVAILABLE) {
		//	dprint3("Fund! slot ", ftos(next), "\n");
			W_ChangeWeapon(weaponsclass[next].id);
			return;
		}

		next = wrap(next + stp, 1, MAX_WEAPON_NUM);
	}
}

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
