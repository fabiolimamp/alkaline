void (vector org) spawn_tfog;
void() W_SetCurrentAmmo;
void() weapon_plasmagun;

/* ALL LIGHTS SHOULD BE 0 1 0 IN COLOR ALL OTHER ITEMS SHOULD
BE .8 .3 .4 IN COLOR */

float ITEM_SPAWNSILENT = 32;
float ITEM_SPAWNED = 64;
float ITEM_SUSPENDED = 128;
float ITEM_RESPAWNDM = 16384;
float ITEM_DONTDROP = 32768;

// internal use only! do not expose in the FGD
// used to drop items from enemies
float ITEM_DONTPRECACHE = 8388608; 

void() SUB_regen =
{
	self.model = self.mdl;		// restore original model
	self.solid = SOLID_TRIGGER;	// allow it to be touched again
	if (deathmatch || (self.spawnflags & ITEM_RESPAWNDM))	// Respawn with DM effects
		sound (self, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);	// play respawn sound
	else
		spawn_tfog (self.origin + self.particles_offset);	// play teleport sound and display particles
	setorigin (self, self.origin);
};

// Supa, Quoth respawning items support Respawn item like in DM if 'ritem' TRUE,
// override respawn time with 'respawndelay' if set, inc 'cnt' with each respawn
// and if 'respawncount' is set we'll remove the item if cnt > respawncount
// remember that SUB_Regen is already set on every item that can respawn, all we
// need to do is give a nextthink time in order to trigger it


void(entity whatitem, float defaultdelay) CheckItemRespawn =
{
	if (!whatitem.ritem)	// respawn item if true, otherwise abort
		return;

	whatitem.cnt = whatitem.cnt + 1;	// inc before check to account for zero indexing

	if (whatitem.respawncount)	// limited respawns
	if (whatitem.respawncount < whatitem.cnt)
		return;

	// okay, we're clear to set up a respawn

	if (whatitem.respawndelay)	// custom respawn delay?
		whatitem.nextthink = time + whatitem.respawndelay;
	else
		whatitem.nextthink = time + defaultdelay;
};


/*QUAKED noclass (0 0 0) (-8 -8 -8) (8 8 8)
prints a warning message when spawned
*/
void() noclass =
{
	dprint ("noclass spawned at");
	dprint (vtos(self.origin));
	dprint ("\n");
	remove (self);
};

/*
============
DelaySpawnItem //this is from rmq-items.qc

Makes a SPAWNED item ready for pickup on a trigger event - modified a bit -- dumptruck_ds
============
*/
void() DelaySpawnItem =
{
	self.solid = SOLID_TRIGGER;
	setmodel (self, self.mdl);
	setsize (self, self.pos1, self.pos2);

	if (!(self.spawnflags & ITEM_SPAWNSILENT)) 			// SILENT, gb
		// sound (self, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);
		spawn_tfog (self.origin + self.particles_offset);

	self.use = SUB_Null;
};


// Supa, restore old hull and lock movement
void() RefreshHull =
{
	// setsize (self, self.dest, self.dest2);
	setsize (self, '0 0 0', '32 32 56'); //dumptruck_ds -- fix for bounding boxes

	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
};

/*
================================
ItemSize
jigger the origin and bounds of items with off-center origins so their models
appear in the center of their bboxes using MATHS
================================
*/
void() ItemSize =
{
	if (self.mins != '0 0 0')
		return;	// not a silly corner-bbox item

	vector offset;
	offset = '16 16 0';
	
	setorigin(self, self.origin + offset);
	setsize(self, self.mins - offset, self.maxs - offset);
}

/*
============
PlaceItem

plants the object on the floor
============
*/
void() PlaceItem =
{
	// local float	oldz;

	self.mdl = self.model;		// so it can be restored on respawn
	self.flags = FL_ITEM;
	self.solid = SOLID_TRIGGER;

	if ((self.spawnflags & ITEM_SUSPENDED)) 
	{
		self.movetype = MOVETYPE_FLY;
		self.velocity = '0 0 0';
	}
	else {
		self.movetype = MOVETYPE_TOSS;

		if(!(self.spawnflags & ITEM_DONTDROP)) {	
			self.velocity = '0 0 0';
			setorigin (self, self.origin + '0 0 6');

	//		oldz = self.origin_z;
			if (!droptofloor())
			{
				dprint ("Bonus item fell out of level at ");
				dprint (vtos(self.origin));
				dprint ("\n");
				remove(self);
				return;
			}
		}
	}

	if ((self.spawnflags & ITEM_SPAWNED))		// SPAWNED, gb
	{
		self.pos1 = self.mins;
		self.pos2 = self.maxs;

		self.model = "";
		self.solid = SOLID_NOT;

		self.use = DelaySpawnItem;
	}
};


/*
============
StartItem

Sets the clipping size and plants the object on the floor
============
*/
void() StartItem =
{
	if(self.itemstyle == ITEMSTYLE_MDL) ItemSize();
	self.nextthink = time + 0.2;	// items start after other solids
	self.think = PlaceItem;
};

/*
=========================================================================

HEALTH BOX

=========================================================================
*/
//
// T_Heal: add health to an entity, limiting health to max_health
// "ignore" will ignore max_health limit
//
float (entity e, float healamount, float ignore) T_Heal =
{
//	local entity oldself; 
//johnfitz

	if (e.health <= 0)
		return 0;
	if ((!ignore) && (e.health >= other.max_health))
		return 0;
	healamount = ceil(healamount);

	e.health = e.health + healamount;
	if ((!ignore) && (e.health >= other.max_health))
		e.health = other.max_health;
		
	if (e.health > 250)
		e.health = 250;
		
	StopBurning(e); //johnfitz -- healing will stop a player from burning
		
	return 1;
};

/*QUAKED item_health (.3 .3 1) (0 0 0) (32 32 32) rotten megahealth
Health box. Normally gives 25 points.
Rotten box heals 5-10 points,
megahealth will add 100 health, then 
rot you down to your maximum health limit, 
one point per second.
*/

float	H_ROTTEN = 1;
float	H_MEGA = 2;
void() health_touch;
void() item_megahealth_rot;


void() item_health =
{	
	local string model;
	self.touch = health_touch;
	if(!self.itemstyle) self.itemstyle = world.itemstyle;

	if (self.spawnflags & H_ROTTEN)
	{
		if(self.itemstyle == ITEMSTYLE_MDL) model = "progs/m_h15.mdl";
		else model = "maps/b_bh10.bsp";
		self.noise = "items/r_item1.wav";
		self.healamount = 15;
		self.healtype = 0;
	}
	else if (self.spawnflags & H_MEGA)
	{
		if(self.itemstyle == ITEMSTYLE_MDL)	model = "progs/m_h100.mdl";
		else model = "maps/b_bh100.bsp";
		self.noise = "items/r_item2.wav";
		self.healamount = 100;
		self.healtype = 2;
	}
	else
	{
		if(self.itemstyle == ITEMSTYLE_MDL) model = "progs/m_h25.mdl";
		else model = "maps/b_bh25.bsp";
		self.noise = "items/health1.wav";
		self.healamount = 25;
		self.healtype = 1;
	}
	precache_model(model);
	setmodel(self, model);
	precache_sound(self.noise);

	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};


void() health_touch =
{
//	local	float amount;
	local	string	s;
	
	if (other.classname != "player")
		return;
	
	if (self.healtype == 2) // Megahealth?  Ignore max_health...
	{
		if (other.health >= 250)
			return;
		if (!T_Heal(other, self.healamount, 1))
			return;
	}
	else
	{
		if (!T_Heal(other, self.healamount, 0))
			return;
	}
	
	sprint(other, "You receive ");
	s = ftos(self.healamount);
	sprint(other, s);
	sprint(other, " health\n");
	
// health touch sound
	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);

	stuffcmd (other, "bf\n");
	
	self.model = string_null;
	self.solid = SOLID_NOT;

	self.think = SUB_regen;

	// Megahealth = rot down the player's super health
	if (self.healtype == 2)
	{
		other.items = other.items | IT_SUPERHEALTH;
		self.nextthink = time + 5;
		self.think = item_megahealth_rot;
		self.owner = other;
	}
	else
	{
		if (deathmatch != 2)		// deathmatch 2 is the silly old rules
		{
			if (deathmatch)	self.nextthink = time + 20;
			else CheckItemRespawn(self, 30); // checks if item is set to respawn and sets nextthink
		}
	}
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};	


void() item_megahealth_rot =
{
	other = self.owner;
	
	if (other.health > other.max_health)
	{
		other.health = other.health - 1;
		self.nextthink = time + 1;
		return;
	}

// it is possible for a player to die and respawn between rots, so don't
// just blindly subtract the flag off
	other.items = other.items - (other.items & IT_SUPERHEALTH);
	
	if (deathmatch == 1)	// deathmatch 2 is silly old rules
	{
		self.nextthink = time + 20;
		self.think = SUB_regen;
	}
};

/*
===============================================================================

ARMOR

===============================================================================
*/

void() armor_touch;

void() armor_touch =
{
	local	float	type, value, bit;
	
	if (other.health <= 0)
		return;
	if (other.classname != "player")
		return;

	if (self.classname == "item_armor1")
	{
		type = 0.3;
		value = 100;
		bit = IT_ARMOR1;
	}
	if (self.classname == "item_armor2")
	{
		type = 0.6;
		value = 150;
		bit = IT_ARMOR2;
	}
	if (self.classname == "item_armorInv")
	{
		type = 0.8;
		value = 200;
		bit = IT_ARMOR3;
	}
	if (other.armortype*other.armorvalue >= type*value)
		return;
		
	other.armortype = type;
	other.armorvalue = value;
	other.items = other.items - (other.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + bit;

	self.solid = SOLID_NOT;
	self.model = string_null;
	// Supa, SP respawning items support
	if (!deathmatch)
		CheckItemRespawn(self, 30);
	else if (deathmatch == 1)
		self.nextthink = time + 20;
	self.think = SUB_regen;

	sprint(other, "You got armor\n");
// armor touch sound
	sound(other, CHAN_ITEM, "items/armor1.wav", 1, ATTN_NORM);
	stuffcmd(other, "bf\n");
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};


void() shard_touch = // this from RMQ shard_touch
{
	if (other.health <= 0)
		return;
	if (other.classname != "player")
		return;

	local	float	bit;

	if (other.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3))	{
		// Supa, check bounds, original armourvalue + 25
		if (other.items & IT_ARMOR1 && other.armorvalue >= 125)	return;
		if (other.items & IT_ARMOR2 && other.armorvalue >= 175)	return;
		if (other.items & IT_ARMOR3 && other.armorvalue >= 225)	return;

		other.armorvalue = other.armorvalue + 5;	// was 2, RMQ team

		// Supa, now cap armourvalue to bounds
		if		(other.items & IT_ARMOR1 && other.armorvalue >= 125)	other.armorvalue = 125;
		else if (other.items & IT_ARMOR2 && other.armorvalue >= 175)	other.armorvalue = 175;
		else if (other.items & IT_ARMOR3 && other.armorvalue >= 225)	other.armorvalue = 225;
	}
	else {
		other.armortype = 0.3;	// shard = Green armor level
		other.armorvalue = 5;
		bit = IT_ARMOR1;
		other.items = other.items - (other.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + bit;
	}

	self.solid = SOLID_NOT;
	self.model = string_null;

	// Supa, SP respawning items support
	if (!deathmatch)
		CheckItemRespawn(self, 30);
	else if (deathmatch == 1)  // doesn't respawn in "deathmatch 2"
		self.nextthink = time + 20;

	self.think = SUB_regen;

	sprint(other, "You got armor\n");
	sound(other, CHAN_ITEM, "items/shard_pickup.wav", 1, ATTN_NORM);
	stuffcmd(other, "bf\n");

	activator = other;
	SUB_UseTargets();	// fire all targets / killtargets
};


/*QUAKED item_armor1 (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() item_armor_shard = {
	self.touch = shard_touch;
	precache_model("progs/shard.mdl");
	setmodel(self, "progs/shard.mdl");
	precache_sound("items/shard_pickup.wav");
	self.skin = 0;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

void() item_armor1 =
{
	self.touch = armor_touch;
	precache_model ("progs/armor.mdl");
	setmodel (self, "progs/armor.mdl");
	self.skin = 0;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED item_armor2 (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() item_armor2 =
{
	self.touch = armor_touch;
	precache_model ("progs/armor.mdl");
	setmodel (self, "progs/armor.mdl");
	self.skin = 1;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED item_armorInv (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() item_armorInv =
{
	self.touch = armor_touch;
	precache_model ("progs/armor.mdl");
	setmodel (self, "progs/armor.mdl");
	self.skin = 2;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*
===============================================================================

WEAPONS

===============================================================================
*/

void() bound_other_ammo =
{
	if (other.ammo_shells > 100)
		other.ammo_shells = 100;
	if (other.ammo_nails > 200)
		other.ammo_nails = 200;
	if (other.ammo_rockets > 100)
		other.ammo_rockets = 100;		
	if (other.ammo_cells > 100)
		other.ammo_cells = 100;		
};


float(float w) RankForWeapon =
{
	if (w == WEAPON_LIGHTNING)
		return 1;
	if (w == WEAPON_PLASMA)
		return 2;
	if (w == WEAPON_CHAINSAW)
		return 3;
	if (w == WEAPON_ROCKET_LAUNCHER)
		return 4;
	if (w == WEAPON_LASER_CANNON)
		return 5;
	if (w == WEAPON_SUPER_NAILGUN)
		return 6;
	if (w == WEAPON_GRENADE_LAUNCHER)
		return 7;
	if (w == WEAPON_PROXIMITY_GUN)
		return 8;
	if (w == WEAPON_SUPER_SHOTGUN)
		return 9;
	if (w == WEAPON_NAILGUN)
		return 10;
	return 10;
};

/*
=============
Deathmatch_Weapon

Deathmatch weapon change rules for picking up a weapon

=============
*/
void(float new) Deathmatch_Weapon =
{
	local float or, nr;

// change self.weapon if desired
	or = RankForWeapon (self.weapon);
	nr = RankForWeapon (new);
	if ( nr < or )
		self.weapon = new;
};

/*
=============
weapon_touch
=============
*/
float() W_BestWeapon;

void() weapon_touch =
{
	local	float	best, new;
	local	entity	stemp;
	local	float	leave;

	if (!(other.flags & FL_CLIENT))
		return;

// if the player was using his best weapon, change up to the new one if better		
	stemp = self;
	self = other;
	best = W_BestWeapon();
	self = stemp;

	if (deathmatch == 2 || coop)
		leave = 1;
	else
		leave = 0;

	if(!self.weapon)
		objerror ("weapon_touch: entity's weapon not set");
	
	if (leave && (other.weapons & self.weapon) )
		return;		
	
	new = self.weapon;

	other.ammo_shells += self.ammo_shells;
	other.ammo_nails += self.ammo_nails;
	other.ammo_rockets += self.ammo_rockets;
	other.ammo_cells += self.ammo_cells;

	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other, "\n");
// weapon touch sound
	sound (other, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	bound_other_ammo ();

	if(HUD_WEAPONS & new) { // player.items still needed for weapons to show up in the HUD
		other.items = other.items | new;
	}
	
	other.weapons = other.weapons | new;

	stemp = self;
	self = other;

	if (!deathmatch)
		self.weapon = new;
	else
		Deathmatch_Weapon (new);


	W_SetCurrentAmmo();
	
	self = stemp;

	if (leave)
		return;

// remove it in single player, or setup for respawning in deathmatch
	self.model = string_null;
	self.solid = SOLID_NOT;
	// Supa, SP respawning items support
	if (!deathmatch)
		CheckItemRespawn(self, 30);
	else if (deathmatch == 1)
		self.nextthink = time + 30;
	self.think = SUB_regen;
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};

// johnfitz new items
/*QUAKED weapon_axe (0 .5 .8) (-16 -16 0) (16 16 32)
Axe
*/
void() weapon_axe =
{
	if(!(self.spawnflags & ITEM_DONTPRECACHE)) precache_model ("progs/g_axe_alk.mdl");
	setmodel (self, "progs/g_axe_alk.mdl");
	self.weapon = WEAPON_AXE;
	self.netname = "Axe";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};
/*QUAKED weapon_shotgun (0 .5 .8) (-16 -16 0) (16 16 32)
Shotgun
*/

void() weapon_shotgun =
{
	if(!(self.spawnflags & ITEM_DONTPRECACHE)) precache_model ("progs/g_shotgn.mdl");
	setmodel (self, "progs/g_shotgn.mdl");
	self.weapon = WEAPON_SHOTGUN;
	self.netname = "Shotgun";
	self.touch = weapon_touch;
	if(!self.ammo_shells) self.ammo_shells = 5;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};
// johnfitz


/*QUAKED weapon_supershotgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_supershotgun =
{
	if(!(self.spawnflags & ITEM_DONTPRECACHE)) precache_model ("progs/g_shot.mdl");
	setmodel (self, "progs/g_shot.mdl");
	self.weapon = WEAPON_SUPER_SHOTGUN;
	self.netname = "Double-barrelled Shotgun";
	self.touch = weapon_touch;
	if(!self.ammo_shells) self.ammo_shells = 5;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_nailgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_nailgun =
{
	if(!(self.spawnflags & ITEM_DONTPRECACHE)) precache_model ("progs/g_nail.mdl");
	setmodel (self, "progs/g_nail.mdl");
	self.weapon = WEAPON_NAILGUN;
	self.netname = "nailgun";
	self.touch = weapon_touch;
	if(!self.ammo_nails) self.ammo_nails = 30;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_supernailgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_supernailgun =
{
	if(!(self.spawnflags & ITEM_DONTPRECACHE)) precache_model ("progs/g_nail2.mdl");
	setmodel (self, "progs/g_nail2.mdl");
	self.weapon = WEAPON_SUPER_NAILGUN;
	self.netname = "Super Nailgun";
	self.touch = weapon_touch;
	if(!self.ammo_nails) self.ammo_nails = 30;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_grenadelauncher (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_grenadelauncher =
{
	if(!(self.spawnflags & ITEM_DONTPRECACHE)) precache_model ("progs/g_rock.mdl");
	setmodel (self, "progs/g_rock.mdl");
	self.weapon = WEAPON_GRENADE_LAUNCHER;
	self.netname = "Grenade Launcher";
	self.touch = weapon_touch;
	if(!self.ammo_rockets) self.ammo_rockets = 5;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_proximity_gun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_proximity_gun =
{
	if(!(self.spawnflags & ITEM_DONTPRECACHE)) precache_model ("progs/g_mine.mdl");
	setmodel (self, "progs/g_mine.mdl");
	self.weapon = WEAPON_PROXIMITY_GUN;
	self.netname = "Proximity Launcher";
	self.touch = weapon_touch;
	if(!self.ammo_rockets) self.ammo_rockets = 5;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_rocketlauncher (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_rocketlauncher =
{
	if(!(self.spawnflags & ITEM_DONTPRECACHE)) precache_model ("progs/g_rock2.mdl");
	setmodel (self, "progs/g_rock2.mdl");
	self.weapon = WEAPON_ROCKET_LAUNCHER;
	self.netname = "Rocket Launcher";
	self.touch = weapon_touch;
	if(!self.ammo_rockets) self.ammo_rockets = 5;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};


/*QUAKED weapon_lightning (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_lightning =
{
	if(!(self.spawnflags & ITEM_DONTPRECACHE)) precache_model ("progs/g_light.mdl");
	setmodel (self, "progs/g_light.mdl");
	self.weapon = WEAPON_LIGHTNING;
	self.netname = "Thunderbolt";
	self.touch = weapon_touch;
	if(!self.ammo_cells) self.ammo_cells = 15;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_chainsaw (0 .5 .8) (-16 -16 0) (16 16 32)
*/
void() weapon_chainsaw =
{
	if(!(self.spawnflags & ITEM_DONTPRECACHE)) precache_model ("progs/g_saw.mdl");
	setmodel (self, "progs/g_saw.mdl");
	self.weapon = WEAPON_CHAINSAW;
	self.netname = "Chainsaw";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
	//dprint("ERROR: change to weapon_nailgun with 'dmg' '1'\n");
};

/*
QUAKED weapon_laser_gun (0 .5 .8) (-16 -16 0) (16 16 32)
*/
void() weapon_laser_gun =
{
	if(!(self.spawnflags & ITEM_DONTPRECACHE)) precache_model ("progs/g_laserg.mdl");
	setmodel (self, "progs/g_laserg.mdl");
	self.weapon = WEAPON_LASER_CANNON;
	self.netname = "Laser Cannon";
	self.touch = weapon_touch;
	if(!self.ammo_cells) self.ammo_cells = 30;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};
/*
===============================================================================

AMMO

===============================================================================
*/

void() ammo_touch =
{
local entity	stemp;
local float		best;

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

// if the player was using his best weapon, change up to the new one if better		
	stemp = self;
	self = other;
	best = W_BestWeapon();
	self = stemp;


// shotgun
	if (self.weapon == 1)
	{
		if (other.ammo_shells >= 100)
			return;
		other.ammo_shells = other.ammo_shells + self.aflag;
	}

// spikes
	if (self.weapon == 2)
	{
		if (other.ammo_nails >= 200)
			return;
		other.ammo_nails = other.ammo_nails + self.aflag;
	}

//	rockets
	if (self.weapon == 3)
	{
		if (other.ammo_rockets >= 100)
			return;
		other.ammo_rockets = other.ammo_rockets + self.aflag;
	}

//	cells
	if (self.weapon == 4)
	{
		if (other.ammo_cells >= 100)
			return;
		other.ammo_cells = other.ammo_cells + self.aflag;
	}

	bound_other_ammo ();
	
	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other, "\n");
// ammo touch sound
	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

// change to a better weapon if appropriate

	if ( other.weapon == best && (!(deathmatch)))
	{
		stemp = self;
		self = other;
		self.weapon = W_BestWeapon();
		if (self.weapon != WEAPON_CHAINSAW)
		   W_SetCurrentAmmo ();
		self = stemp;
	}

// if changed current ammo, update it
	stemp = self;
	self = other;
	if (self.weapon != WEAPON_CHAINSAW)
	   W_SetCurrentAmmo();
	self = stemp;

// remove it in single player, or setup for respawning in deathmatch
	self.model = string_null;
	self.solid = SOLID_NOT;
	// Supa, SP respawning items support
	if (!deathmatch)
		CheckItemRespawn(self, 30);
	else if (deathmatch == 1)
		self.nextthink = time + 30;
	self.think = SUB_regen;

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};




float WEAPON_BIG2 = 1;

/*QUAKED item_shells (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() item_shells =
{
	local string model;
	self.touch = ammo_touch;
	if(!self.itemstyle) self.itemstyle = world.itemstyle;

	if (self.spawnflags & WEAPON_BIG2)
	{
		if(self.itemstyle == ITEMSTYLE_MDL) model = "progs/m_shell2.mdl";
		else model = "maps/b_shell1.bsp";
		self.aflag = 40;
	}
	else
	{
		if(self.itemstyle == ITEMSTYLE_MDL) model = "progs/m_shell1.mdl";
		else model = "maps/b_shell0.bsp";
		self.aflag = 20;
	}

	if(!(self.spawnflags & ITEM_DONTPRECACHE)) precache_model (model);
	setmodel (self, model);
	self.weapon = 1;
	self.netname = "shells";
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};

/*QUAKED item_spikes (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() item_spikes =
{
	local string model;
	self.touch = ammo_touch;
	if(!self.itemstyle) self.itemstyle = world.itemstyle;

	if (self.spawnflags & WEAPON_BIG2)
	{
		if(self.itemstyle == ITEMSTYLE_MDL) model = "progs/m_nails2.mdl";
		else model = "maps/b_nail1.bsp";
		self.aflag = 50;
	}
	else
	{
		if(self.itemstyle == ITEMSTYLE_MDL) model = "progs/m_nails1.mdl";
		else model = "maps/b_nail0.bsp";
		self.aflag = 25;
	}

	if(!(self.spawnflags & ITEM_DONTPRECACHE)) precache_model (model);
	setmodel (self, model);
	self.weapon = 2;
	self.netname = "nails";
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};

/*QUAKED item_rockets (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() item_rockets =
{
	local string model;
	self.touch = ammo_touch;
	if(!self.itemstyle) self.itemstyle = world.itemstyle;

	if (self.spawnflags & WEAPON_BIG2)
	{
		if(self.itemstyle == ITEMSTYLE_MDL) model = "progs/m_rock2.mdl";
		else model = "maps/b_rock1.bsp";
		self.aflag = 10;
	}
	else
	{
		if(self.itemstyle == ITEMSTYLE_MDL) model = "progs/m_rock1.mdl";
		else model = "maps/b_rock0.bsp";
		self.aflag = 5;
	}

	if(!(self.spawnflags & ITEM_DONTPRECACHE)) precache_model (model);
	setmodel (self, model);
	self.weapon = 3;
	self.netname = "rockets";
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};


/*QUAKED item_cells (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() item_cells =
{
	local string model;
	self.touch = ammo_touch;
	if(!self.itemstyle) self.itemstyle = world.itemstyle;

	if (self.spawnflags & WEAPON_BIG2)
	{
		if(self.itemstyle == ITEMSTYLE_MDL) model = "progs/m_cells2.mdl";
		else model = "maps/b_batt1.bsp";
		self.aflag = 12;
	}
	else
	{
		if(self.itemstyle == ITEMSTYLE_MDL) model = "progs/m_cells1.mdl";
		else model = "maps/b_batt0.bsp";
		self.aflag = 6;
	}

	if(!(self.spawnflags & ITEM_DONTPRECACHE)) precache_model (model);
	setmodel (self, model);
	self.weapon = 4;
	self.netname = "cells";
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};


/*QUAKED item_weapon (0 .5 .8) (0 0 0) (32 32 32) shotgun rocket spikes big
DO NOT USE THIS!!!! IT WILL BE REMOVED!
*/
/*
float WEAPON_SHOTGUN = 1;
float WEAPON_ROCKET = 2;
float WEAPON_SPIKES = 4;
float WEAPON_BIG = 8;
void() item_weapon =
{
	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_SHOTGUN)
	{
		if (self.spawnflags & WEAPON_BIG)
		{
			precache_model ("maps/b_shell1.bsp");
			setmodel (self, "maps/b_shell1.bsp");
			self.aflag = 40;
		}
		else
		{
			precache_model ("maps/b_shell0.bsp");
			setmodel (self, "maps/b_shell0.bsp");
			self.aflag = 20;
		}
		self.weapon = 1;
		self.netname = "shells";
	}

	if (self.spawnflags & WEAPON_SPIKES)
	{
		if (self.spawnflags & WEAPON_BIG)
		{
			precache_model ("maps/b_nail1.bsp");
			setmodel (self, "maps/b_nail1.bsp");
			self.aflag = 40;
		}
		else
		{
			precache_model ("maps/b_nail0.bsp");
			setmodel (self, "maps/b_nail0.bsp");
			self.aflag = 20;
		}
		self.weapon = 2;
		self.netname = "spikes";
	}

	if (self.spawnflags & WEAPON_ROCKET)
	{
		if (self.spawnflags & WEAPON_BIG)
		{
			precache_model ("maps/b_rock1.bsp");
			setmodel (self, "maps/b_rock1.bsp");
			self.aflag = 10;
		}
		else
		{
			precache_model ("maps/b_rock0.bsp");
			setmodel (self, "maps/b_rock0.bsp");
			self.aflag = 5;
		}
		self.weapon = 3;
		self.netname = "rockets";
	}
	
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};

*/
/*
===============================================================================

END OF LEVEL RUNES

===============================================================================
*/

void() sigil_touch =
{
//local entity	stemp;
//local float		best;

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	centerprint (other, "You got the rune!");

	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	self.solid = SOLID_NOT;
	self.model = string_null;
	serverflags = serverflags | (self.spawnflags & 15);
	self.classname = "";		// so rune doors won't find it
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};


/*QUAKED item_sigil (0 .5 .8) (-16 -16 -24) (16 16 32) E1 E2 E3 E4
End of level sigil, pick up to end episode and return to jrstart.
*/

void() item_sigil =
{
	if (!self.spawnflags)
		objerror ("no spawnflags");

	precache_sound ("misc/runekey.wav");
	self.noise = "misc/runekey.wav";

	if (self.spawnflags & 1) self.model = "progs/end1.mdl";
	if (self.spawnflags & 2) self.model = "progs/end2.mdl";
	if (self.spawnflags & 4) self.model = "progs/end3.mdl";
	if (self.spawnflags & 8) self.model = "progs/end4.mdl";
	
	if(!(self.spawnflags & ITEM_DONTPRECACHE)) precache_model (self.model);
	setmodel (self, self.model);
	
	self.touch = sigil_touch;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*
===============================================================================

POWERUPS

===============================================================================
*/

void() powerup_touch;


void() powerup_touch =
{
//local entity	stemp;
//local float		best;

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other,"\n");

	// if (deathmatch)
	// {
	// 	self.mdl = self.model;
	//
	// 	if ((self.classname == "item_artifact_invulnerability") ||
	// 		(self.classname == "item_artifact_invisibility"))
	// 		self.nextthink = time + 60*5;
	// 	else
	// 		self.nextthink = time + 60;
	//
	// 	self.think = SUB_regen;
	// }

	// Supa, SP respawning items support
	self.mdl	= self.model;
	self.think	= SUB_regen;

	if (!deathmatch)
	{
		local float spawndelay;

		if (self.classname == "item_artifact_invulnerability" || self.classname == "item_artifact_invisibility")
			spawndelay = 300;
		else
			spawndelay = 60;

		CheckItemRespawn(self, spawndelay);
	}
	else
	{
		if ((self.classname == "item_artifact_invulnerability") ||
		    (self.classname == "item_artifact_invisibility"))
			self.nextthink = time + 60*5;
		else
			self.nextthink = time + 60;
	}

	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM); //johnfitz -- was CHAN_VOICE
	stuffcmd (other, "bf\n");
	self.solid = SOLID_NOT;
	other.items = other.items | self.items;
	self.model = string_null;

// do the apropriate action
	if (self.classname == "item_artifact_envirosuit")
	{
		other.rad_time = 1;
		other.radsuit_finished = time + 30;
	}
	
	if (self.classname == "item_artifact_invulnerability")
	{
		other.invincible_time = 1;
		other.invincible_finished = time + 30;
	}
	
	if (self.classname == "item_artifact_invisibility")
	{
		other.invisible_time = 1;
		other.invisible_finished = time + 30;
	}

	if (self.classname == "item_artifact_super_damage")
	{
		other.super_time = 1;
		other.super_damage_finished = time + 30;
	}	
	
	if (self.classname == "item_artifact_trifecta")
	{
		other.trif_time = 1;
		other.trif_finished = time + 30;
		self.nextthink = time + 30;
		other.health = other.health + 100;
		self.think = item_megahealth_rot;
		self.owner = other;		
		
	}

	if (self.classname == "item_jboots")	//JCR Superjump boots PERSISTENT with LIMITED CHARGES (max 3 airjumps)
	{
		float limit;

		// if theres a timed boot active, add persistent boot in "background mode"
		if (other.jboots_finished) limit = other.jboots_prevlimit;
		else limit = other.jboots_rechargelimit;

		if (limit >= 3) {
			limit = 3;
			sprint(other, "Jump module limit reached. Module not added.\n");
		}
		else {
			if (limit) sprint(other, "Jump module added.\n");
			limit = limit + 1;
		}

		if (other.jboots_finished) other.jboots_prevlimit = limit;
		else other.jboots_rechargelimit = limit;
		
	}

	if (self.classname == "item_jboots_timed")	//JCR Superjump boots TIMED with INFINITE CHARGES
	{
		other.jboots_prevlimit = other.jboots_rechargelimit;
		other.jboots_time = 1;
		other.jboots_finished = time + 30;
		other.jboots_rechargelimit = defaultFl(self.jboots_rechargelimit, -1);
	}
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};



/*QUAKED item_artifact_invulnerability (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invulnerable for 30 seconds
*/
void() item_artifact_invulnerability =
{
	self.touch = powerup_touch;

	if(!(self.spawnflags & ITEM_DONTPRECACHE)) {
		precache_model ("progs/invulner.mdl");
		precache_sound ("items/protect.wav");
		precache_sound ("items/protect2.wav");
		precache_sound ("items/protect3.wav");
	}
	self.noise = "items/protect.wav";
	setmodel (self, "progs/invulner.mdl");
	self.netname = "Pentagram of Protection";
	self.items = IT_INVULNERABILITY;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*QUAKED item_artifact_trifecta (0 .5 .8) (-16 -16 -24) (16 16 32)
Combine 3 powerups, probably invisibility, quad and pentagram
*/
void() item_artifact_trifecta =
{
	self.touch = powerup_touch;
	if(!(self.spawnflags & ITEM_DONTPRECACHE)) {
		precache_model ("progs/trifecta.mdl");
		precache_sound ("items/trifecta.wav");
		precache_sound ("items/trifecta2.wav");
		precache_sound ("items/trifecta3.wav");
	}
	self.noise = "items/trifecta.wav";
	setmodel (self, "progs/trifecta.mdl");
	self.netname = "Trifecta";
	self.items = IT_TRIFECTA;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};



/*QUAKED item_artifact_envirosuit (0 .5 .8) (-16 -16 -24) (16 16 32)
Player takes no damage from water or slime for 30 seconds
*/
void() item_artifact_envirosuit =
{
	self.touch = powerup_touch;
	if(!(self.spawnflags & ITEM_DONTPRECACHE)) {
		precache_model ("progs/suit.mdl");
		precache_sound ("items/suit.wav");
		precache_sound ("items/suit2.wav");
	}
	self.noise = "items/suit.wav";
	setmodel (self, "progs/suit.mdl");
	self.netname = "Biosuit";
	self.items = IT_SUIT;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};


/*QUAKED item_artifact_invisibility (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invisible for 30 seconds
*/
void() item_artifact_invisibility =
{
	self.touch = powerup_touch;
	if(!(self.spawnflags & ITEM_DONTPRECACHE)) {
		precache_model ("progs/invisibl.mdl");
		precache_sound ("items/inv1.wav");
		precache_sound ("items/inv2.wav");
		precache_sound ("items/inv3.wav");
	}
	self.noise = "items/inv1.wav";
	setmodel (self, "progs/invisibl.mdl");
	self.netname = "Invisibility belt";
	self.items = IT_INVISIBILITY;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};


/*QUAKED item_artifact_super_damage (0 .5 .8) (-16 -16 -24) (16 16 32)
The next attack from the player will do 4x damage
*/
void() item_artifact_super_damage =
{
	self.touch = powerup_touch;
	if(!(self.spawnflags & ITEM_DONTPRECACHE)) {
		precache_model ("progs/quaddama.mdl");
		precache_sound ("items/damage.wav");
		precache_sound ("items/damage2.wav");
		precache_sound ("items/damage3.wav");
	}
	self.noise = "items/damage.wav";
	setmodel (self, "progs/quaddama.mdl");
	self.netname = "Quad Damage";
	self.items = IT_QUAD;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};



/*
===============================================================================

PLAYER BACKPACKS

===============================================================================
*/

void() BackpackTouch =
{
	local string	s;
	local	float	best, old, new;
	local	entity	stemp;
	local	float	acount;
	
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	acount = 0;
	sprint (other, "You get ");

	if (self.items)
	{
		if ((other.items & self.items) == 0)
		{
			acount = 1;
			sprint (other, "the ");
			sprint (other, self.netname);
		}
	}
	else if (self.weapons)
	{
		if ((other.weapons & self.weapons) == 0)
		{
			acount = 1;
			sprint (other, "the ");
			sprint (other, self.netname);
		}
	}
// if the player was using his best weapon, change up to the new one if better		
	stemp = self;
	self = other;
	best = W_BestWeapon();
	self = stemp;

// change weapons
	other.ammo_shells = other.ammo_shells + self.ammo_shells;
	other.ammo_nails = other.ammo_nails + self.ammo_nails;
	other.ammo_rockets = other.ammo_rockets + self.ammo_rockets;
	other.ammo_cells = other.ammo_cells + self.ammo_cells;

	new = self.items;
	if (!new)
		new = other.weapon;
	old = other.weapons;
	other.weapons = other.weapons | new;
	
	bound_other_ammo ();

	if (self.ammo_shells)
	{
		if (acount)
			sprint(other, ", ");
		acount = 1;
		s = ftos(self.ammo_shells);
		sprint (other, s);
		sprint (other, " shells");
	}
	if (self.ammo_nails)
	{
		if (acount)
			sprint(other, ", ");
		acount = 1;
		s = ftos(self.ammo_nails);
		sprint (other, s);
		sprint (other, " nails");
	}
	if (self.ammo_rockets)
	{
		if (acount)
			sprint(other, ", ");
		acount = 1;
		s = ftos(self.ammo_rockets);
		sprint (other, s);
		sprint (other, " rockets");
	}
	if (self.ammo_cells)
	{
		if (acount)
			sprint(other, ", ");
		acount = 1;
		s = ftos(self.ammo_cells);
		sprint (other, s);
		sprint (other, " cells");
	}
	
	sprint (other, "\n");
// backpack touch sound
	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	if (self.classname == "item_backpack") SUB_UseTargets();
	
// remove the backpack, change self to the player
	remove(self);
	self = other;

// change to the weapon
	if (!deathmatch)
		self.weapon = new;
	else
		Deathmatch_Weapon (new);

	W_SetCurrentAmmo ();


};

/*
===============
DropBackpack
===============
*/
void() DropBackpack =
{
	local entity	item;

	if (!(self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells))
		return;	// nothing in it

	item = spawn();
	item.origin = self.origin - '0 0 24';
	
	item.weapons = self.weapon;
	if (item.weapons == WEAPON_AXE)
		item.netname = "Axe";
	else if (item.weapons == WEAPON_SHOTGUN)
		item.netname = "Shotgun";
	else if (item.weapons == WEAPON_SUPER_SHOTGUN)
		item.netname = "Double-barrelled Shotgun";
	else if (item.weapons == WEAPON_NAILGUN)
		item.netname = "Nailgun";
	else if (item.weapons == WEAPON_SUPER_NAILGUN)
		item.netname = "Super Nailgun";
	else if (item.weapons == WEAPON_GRENADE_LAUNCHER)
		item.netname = "Grenade Launcher";
	else if (item.weapons == WEAPON_ROCKET_LAUNCHER)
		item.netname = "Rocket Launcher";
	else if (item.weapons == WEAPON_LIGHTNING)
		item.netname = "Thunderbolt";
	else if (item.weapons == WEAPON_LASER_CANNON)
		item.netname = "Laser Cannon";
	else if (item.weapons == WEAPON_PLASMA)
		item.netname = "Plasma Rifle";
	else if (item.weapons == WEAPON_PROXIMITY_GUN)
		item.netname = "Proximity Launcher";
	else if (item.weapons == WEAPON_CHAINSAW)
		item.netname = "Chainsaw";
	else
		item.netname = "";

	item.ammo_shells = self.ammo_shells;
	item.ammo_nails = self.ammo_nails;
	item.ammo_rockets = self.ammo_rockets;
	item.ammo_cells = self.ammo_cells;

	item.velocity_z = 300;
	item.velocity_x = -100 + (random() * 200);
	item.velocity_y = -100 + (random() * 200);
	
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel (item, "progs/backpack.mdl");
	setsize (item, '-16 -16 0', '16 16 56');
	item.touch = BackpackTouch;
	
	item.nextthink = time + 120;	// remove after 2 minutes
	item.think = SUB_Remove;
};


void() item_backpack = {
	if (!(self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells)) {
		objerror("Empty backpack");
		return;	// nothing in it
	}

	self.flags = FL_ITEM;
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;
	precache_model("progs/supbkpack.mdl");
	setmodel (self, "progs/supbkpack.mdl");
	setsize (self, '-16 -16 0', '16 16 56');

	self.touch = BackpackTouch;
};


void() item_jboots = { //JCR SUPERJUMP BOOTS	PERSISTENT
	precache_model ("progs/jumpblue.mdl");
	precache_sound ("items/jboots_got.wav");
	
	self.noise = "items/jboots_got.wav";
	self.touch = powerup_touch;
	self.netname = "Jump Boots";
	self.items = IT_JBOOTS;

	setmodel (self, "progs/jumpblue.mdl");
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
}

void() item_jboots_timed = { //JCR SUPERJUMP BOOTS	TIMED
	precache_model ("progs/jumpgold.mdl");
	precache_sound ("items/jboots_got.wav");
	
	self.touch = powerup_touch;
	self.noise = "items/jboots_got_timed.wav";
	self.netname = "Super Jump Boots";
	self.items = IT_JBOOTS;

	setmodel (self, "progs/jumpgold.mdl");
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

