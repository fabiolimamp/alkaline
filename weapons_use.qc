typedef struct {
	float id;
	float slot;
	float slotPos;
	string name;
	string model;
	float ammofield;
	float ammo_item;
	float ammo_usage;
	float() animfunction;
	void() idlefunction;
} weaponclass_t;

.float ammofieldlist[5] = {
	currentammo,
	ammo_shells,
	ammo_nails, 
	ammo_rockets,
	ammo_cells
};

float() weaponanim_null = {return FALSE;}

weaponclass_t wpc_no_weapon = {
	WEAPON_NO_WEAPON,
	0, // slot
	0, // slotPos
	"No weapon", // name
	"", // model
	0, // ammofield
	0, // ammo_item
	0, // ammo_usage
	weaponanim_null, // animfunction
	SUB_Null // idlefunction
};

weaponclass_t wpc_axe = {
	WEAPON_AXE,
	1, // slot
	0, // slotPos
	"Axe", // name
	"progs/v_alkaxe20fps.mdl", // model
	0, // ammofield
	0, // ammo_item
	0, // ammo_usage
	weaponanim_axe, // animfunction
	SUB_Null // idlefunction
};

weaponclass_t wpc_chainsaw = {
	WEAPON_CHAINSAW,
	1, // slot
	1, // slotPos
	"Chainsaw", // name
	"progs/v_saw.mdl", // model
	0, // ammofield
	0, // ammo_item
	0, // ammo_usage
	weaponanim_chainsaw, // animfunction
	weaponanim_chainsaw_idle // idlefunction
};

weaponclass_t wpc_shotgun = {
	WEAPON_SHOTGUN,
	2, // slot
	0, // slotPos
	"Shotgun", // name
	"progs/v_shot40fps.mdl", // model
	1, // ammofield
	IT_SHELLS, // ammo_item
	1, // ammo_usage
	weaponanim_shotgun, // animfunction
	SUB_Null // idlefunction
};

weaponclass_t wpc_supershotgun = {
	WEAPON_SUPER_SHOTGUN,
	3, // slot
	0, // slotPos
	"Super Shotgun", // name
	"progs/v_shot2_40fps.mdl", // model
	1, // ammofield
	IT_SHELLS, // ammo_item
	1, // ammo_usage
	weaponanim_supershotgun, // animfunction
	SUB_Null // idlefunction
};

weaponclass_t wpc_nailgun = {
	WEAPON_NAILGUN,
	4, // slot
	0, // slotPos
	"Nailgun", // name
	"progs/v_nail_alk40fps.mdl", // model
	2, // ammofield
	IT_NAILS, // ammo_item
	1, // ammo_usage
	weaponanim_nailgun, // animfunction
	SUB_Null // idlefunction
};

weaponclass_t wpc_supernailgun = {
	WEAPON_SUPER_NAILGUN,
	5, // slot
	0, // slotPos
	"Super Nailgun", // name
	"progs/v_nail3_v2.mdl", // model
	2, // ammofield
	IT_NAILS, // ammo_item
	1, // ammo_usage
	weaponanim_supernailgun, // animfunction
	SUB_Null // idlefunction
};

weaponclass_t wpc_grenade = {
	WEAPON_GRENADE_LAUNCHER,
	6, // slot
	0, // slotPos
	"Grenade Launcher", // name
	"progs/v_rock_40fps.mdl", // model
	3, // ammofield
	IT_ROCKETS, // ammo_item
	1, // ammo_usage
	weaponanim_grenade, // animfunction
	SUB_Null // idlefunction
};

weaponclass_t wpc_proximity = {
	WEAPON_PROXIMITY_GUN,
	6, // slot
	1, // slotPos
	"Proximity Launcher", // name
	"progs/v_mine_40fps.mdl", // model
	3, // ammofield
	IT_ROCKETS, // ammo_item
	1, // ammo_usage
	weaponanim_proximity, // animfunction
	SUB_Null // idlefunction
};

weaponclass_t wpc_rocket = {
	WEAPON_ROCKET_LAUNCHER,
	7, // slot
	0, // slotPos
	"Rocket Launcher", // name
	"progs/v_rock2_40fps.mdl", // model
	3, // ammofield
	IT_ROCKETS, // ammo_item
	1, // ammo_usage
	weaponanim_rocket, // animfunction
	SUB_Null // idlefunction
};

weaponclass_t wpc_lg = {
	WEAPON_LIGHTNING,
	8, // slot
	0, // slotPos
	"Lightning gun", // name
	"progs/v_light.mdl", // model
	4, // ammofield
	IT_CELLS, // ammo_item
	1, // ammo_usage
	weaponanim_lg, // animfunction
	SUB_Null // idlefunction
};

weaponclass_t wpc_laser = {
	WEAPON_LASER_CANNON,
	8, // slot
	1, // slotPos
	"Laser Cannon", // name
	"progs/v_laserg40fps.mdl", // model
	4, // ammofield
	IT_CELLS, // ammo_item
	1, // ammo_usage
	weaponanim_laser, // animfunction
	SUB_Null // idlefunction
};

weaponclass_t wpc_plasma = {
	WEAPON_PLASMA,
	8, // slot
	2, // slotPos
	"Plasma Gun", // name
	"progs/v_plasma.mdl", // model
	4, // ammofield
	IT_CELLS, // ammo_item
	1, // ammo_usage
	weaponanim_plasma, // animfunction
	SUB_Null // idlefunction
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
	self.currentammo = self.(ammofieldlist[weap.ammofield]);
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

	if (weap == WEAPON_NO_WEAPON) return WEAPONSTAT_AVAILABLE;

	if (!(cl.weapons & weap)) return WEAPONSTAT_NOWEAPON;

	if (cl.(ammofieldlist[weapcl.ammofield]) < weapcl.ammo_usage) {
		return WEAPONSTAT_NOAMMO;
	}
	//dprint3("Ammo: ", ftos(cl.(weapcl.ammofield)), "\n");
	return WEAPONSTAT_AVAILABLE;
};



void() W_Attack = {
	
	weaponclass_t weap = weaponsclass[getWeapon(self.weapon)];

	if (W_CheckWeapon(self.weapon, self) != WEAPONSTAT_AVAILABLE) {
		return;
	}

	makevectors(self.v_angle);			// calculate forward angle for velocity
	
	float fired = weap.animfunction();

	if (fired) self.show_hostile = time + 1;	// wake monsters up
};



float(float weap) W_ChangeWeapon = {
	//dprint3("Changing weapon to ", ftos(weap), "\n");
	//	(self);
	float weapstat = W_CheckWeapon(weap, self);

	if (weapstat < WEAPONSTAT_AVAILABLE){
		return weapstat;
	}

	weaponclass_t weapcl = weaponsclass[getWeapon(weap)];
	self.weapon = weap;
	self.currentammo = self.(ammofieldlist[weapcl.ammofield]);
	self.items &~= (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS);
	self.items |= weapcl.ammo_item;

	if (weapcl.ammo_usage > 0) {
		self.currentammo = self.(ammofieldlist[weapcl.ammofield]);
	}
	else {
		self.currentammo = 0;
	}

	self.weaponmodel = weapcl.model;
	self.weaponframe = 0;

	self.attackpressed = 0;
	self.attackhold = 0;

	self.animcontroller.think = player_run;
	self.think = SUB_Null;
	if (weapcl.idlefunction != SUB_Null) weapcl.idlefunction();

	return weapstat;
}


float(float imp) W_ChangeSlot = {
	
	weaponslot_t newSlot = weaponslots[imp];

	weaponclass_t currentWeapon = weaponsclass[getWeapon(self.weapon)];

	float startSlotPos;

	if (currentWeapon.slot == imp)
		startSlotPos = wrap(currentWeapon.slotPos + 1, 0, newSlot.qt - 1);
	else
		startSlotPos = 0;

	float i;
	
	float weaponstat, firstweaponstat;

	while (i < newSlot.qt) {
		weaponstat = W_CheckWeapon(newSlot.weaps[startSlotPos].id, self);
		if (i == 0 || weaponstat == WEAPONSTAT_NOAMMO) firstweaponstat = weaponstat;
		if (weaponstat == WEAPONSTAT_AVAILABLE){
			W_ChangeWeapon(newSlot.weaps[startSlotPos].id);
			return weaponstat;
		}
		startSlotPos = wrap(startSlotPos + 1, 0, newSlot.qt - 1);
		i++;
	}

	return firstweaponstat;
}


void(float stp) W_CycleWeapon = {

	float currentWeapon = getWeapon(self.weapon);

	float next = wrap(currentWeapon + stp, 1, MAX_WEAPON_NUM);
	float i;
	while (next != currentWeapon && i <= MAX_WEAPON_NUM) {
		//dprint3("Testing slot ", ftos(next), "...\n");
		if (W_CheckWeapon(weaponsclass[next].id, self) == WEAPONSTAT_AVAILABLE) {
		//	dprint3("Fund! slot ", ftos(next), "\n");
			W_ChangeWeapon(weaponsclass[next].id);
			return;
		}

		next = wrap(next + stp, 1, MAX_WEAPON_NUM);
		i++;
	}

	if (i > MAX_WEAPON_NUM) W_ChangeWeapon(WEAPON_NO_WEAPON);
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


