/*
========================================================================

FUNCTIONS WHICH DEAL WITH KEY ITEM BITFLAGS AND NAMES

========================================================================


This file was created for progs_dump by Ian "iw" Walshaw, January 2020.

It defines functions which deal with the bitflags and names which refer
to the key items, including the new item_key_custom.

These functions are a dependency of the updated code for the key items
(in items.qc) and also the updated code for unlockable entities (in
keylock.qc).


========================================================================
*/


string() SilverKeyName;
string() GoldKeyName;
float(string key_name) CustomKeyFlag;
entity(string key_name) SpawnCustomKeyDef;
entity(string key_name) FindCustomKeyDef;
float(entity client, float item_flags, float customkey_flags) HasKeys;
void(entity client, float item_flags, float customkey_flags) GiveKeys;
void(entity client) GiveAllKeys;
void(entity client, float item_flags, float customkey_flags) RemoveKeys;


// The highest bitflag that will be assigned to a custom key.
float FINAL_CUSTOM_KEY = 4194304;

// The highest bitflag that has been assigned to a custom key.
float highest_custom_key;


/*
============
SilverKeyName

Return the name that should be used for the silver key as per
world.worldtype.  -- iw
============
*/
string() SilverKeyName =
{
	if (world.worldtype == WORLDTYPE_BASE)
		return "silver keycard";
	if (world.worldtype == WORLDTYPE_METAL)
		return "silver runekey";
	return "silver key";
};


/*
============
GoldKeyName

Return the name that should be used for the gold key as per
world.worldtype.  -- iw
============
*/
string() GoldKeyName =
{
	if (world.worldtype == WORLDTYPE_BASE)
		return "gold keycard";
	if (world.worldtype == WORLDTYPE_METAL)
		return "gold runekey";
	return "gold key";
};


/*
================
CustomKeyFlag

Return the bitflag that should be used to represent the custom key named
key_name.

More specifically, if this is the first time that this function has been
called for the specified key_name, then return a bitflag which has not
previously been returned by this function for any key_name.  Otherwise,
return the same bitflag that was previously returned for the specified
key_name.  -- iw
================
*/
float(string key_name) CustomKeyFlag =
{
	local entity key_def;

	key_def = FindCustomKeyDef (key_name);
	if (key_def == world)
		key_def = SpawnCustomKeyDef (key_name);
	return key_def.customkeys;
};


/*
================
SpawnCustomKeyDef

Spawn and return a new custom_key_def entity which will define the
custom key named key_name.

The value of the entity's customkeys field will be a bitflag which has
not yet been used to represent a custom key.  -- iw
================
*/
entity(string key_name) SpawnCustomKeyDef =
{
	local entity key_def;

	if (highest_custom_key == FINAL_CUSTOM_KEY)
		error ("too many custom keys");

	if (highest_custom_key == 0)
		highest_custom_key = 1;
	else
		highest_custom_key = highest_custom_key * 2;

	key_def = spawn ();
	key_def.classname = "custom_key_def";
	key_def.netname = key_name;
	key_def.customkeys = highest_custom_key;

	return key_def;
};


/*
================
FindCustomKeyDef

If a custom_key_def entity exists which defines the custom key named
key_name, then find and return it, otherwise return world.

If a custom_key_def entity is returned, then the value of its customkeys
field will be the bitflag that should be used to represent the custom
key named key_name.  -- iw
================
*/
entity(string key_name) FindCustomKeyDef =
{
	local entity key_def;

	key_def = find (world, classname, "custom_key_def");
	while (key_def != world)
	{
		if (key_def.netname == key_name)
			return key_def;
		key_def = find (key_def, classname, "custom_key_def");
	}
	return world;
};


/*
================
HasKeys

Return TRUE if the specified client has all of the non-custom keys
represented by the item_flags and all of the custom keys represented by
the customkey_flags, otherwise return FALSE.  -- iw
================
*/
float(entity client, float item_flags, float customkey_flags) HasKeys =
{
	return (client.items & item_flags) == item_flags &&
			(client.customkeys & customkey_flags) == customkey_flags;
};


/*
================
GiveKeys

Give the specified client all of the non-custom keys represented by the
item_flags and all of the custom keys represented by the
customkey_flags.  -- iw
================
*/
void(entity client, float item_flags, float customkey_flags) GiveKeys =
{
	client.items = client.items | item_flags;
	client.customkeys = client.customkeys | customkey_flags;
};


/*
================
GiveAllKeys

Give the specified client the silver key, the gold key, and all of the
custom keys that have been defined for the current map.  -- iw
================
*/
void(entity client) GiveAllKeys =
{
	GiveKeys (client, IT_KEY1 | IT_KEY2, highest_custom_key * 2 - 1);
};


/*
================
RemoveKeys

Remove all of the non-custom keys represented by the item_flags and all
of the custom keys represented by the customkey_flags from the specified
client's inventory.  -- iw
================
*/
void(entity client, float item_flags, float customkey_flags) RemoveKeys =
{
	client.items = client.items -
			(client.items & item_flags);
	client.customkeys = client.customkeys -
			(client.customkeys & customkey_flags);
};





/*
========================================================================

COMMON CODE FOR ENTITIES WHICH CAN BE UNLOCKED WITH KEYS

========================================================================


This file was created for progs_dump by Ian "iw" Walshaw, December 2019.

It defines functions which implement the logic of the player using a key
to unlock a locked entity.  These functions are based on parts of the
func_door code from the original game.

In the original game, func_door was the only type of entity which could
be unlocked with a key, however progs_dump also has trigger_usekey,
which previously duplicated the same unlocking logic as func_door.  The
functions in this file were written to eliminate that duplication;
func_door and trigger_usekey have now both been refactored to call these
functions.

This file was created as part of the prep work for implementing
item_key_custom, with the intention of removing as much duplication as
possible in order to make the code easier to modify and extend.


Fields Set By These Functions
-----------------------------

The functions in this file set the following fields, therefore code
calling these functions must not use these fields for other purposes:

    - self.customkeys
    - self.items
    - self.netname
    - self.noise3
    - self.noise4


========================================================================
*/


/*
================
keylock_init

Initialize self for use with the other keylock_* functions.

The following fields will be set to default values if they have not
already been set:

    - self.noise3 (the "key required" sound file).

    - self.noise4 (the "key used" sound file).

The default values are determined by world.worldtype.  -- iw
================
*/
void() keylock_init =
{
	local string default_noise3;
	local string default_noise4;

	if (world.worldtype == WORLDTYPE_BASE)
	{
		default_noise3 = "doors/basetry.wav";
		default_noise4 = "doors/baseuse.wav";
	}
	else if (world.worldtype == WORLDTYPE_METAL)
	{
		default_noise3 = "doors/runetry.wav";
		default_noise4 = "doors/runeuse.wav";
	}
	else
	{
		default_noise3 = "doors/medtry.wav";
		default_noise4 = "doors/meduse.wav";
	}

	if (self.noise3 == "")
		self.noise3 = default_noise3;
	if (self.noise4 == "")
		self.noise4 = default_noise4;

	precache_sound (self.noise3);
	precache_sound (self.noise4);
};


/*
================
keylock_set_silver_key

Make it so that the player will need to use the silver key in order to
unlock self.  -- iw
================
*/
void() keylock_set_silver_key =
{
	self.items = IT_KEY1;
	self.customkeys = 0;  // support for item_key_custom -- iw
	self.netname = SilverKeyName ();
};


/*
================
keylock_set_gold_key

Make it so that the player will need to use the gold key in order to
unlock self.  -- iw
================
*/
void() keylock_set_gold_key =
{
	self.items = IT_KEY2;
	self.customkeys = 0;  // support for item_key_custom -- iw
	self.netname = GoldKeyName ();
};


// support for item_key_custom -- iw
/*
================
keylock_set_custom_key

Make it so that the player will need to use the custom key named
key_name in order to unlock self.  -- iw
================
*/
void(string key_name) keylock_set_custom_key =
{
	self.items = 0;
	self.customkeys = CustomKeyFlag (key_name);
	self.netname = key_name;
};


/*
================
keylock_has_key_set

Return TRUE if one of the keylock_set_*_key functions has been called
for self, otherwise return FALSE.  -- iw
================
*/
float() keylock_has_key_set =
{
// support for item_key_custom -- iw
	return self.items != 0 || self.customkeys != 0;
};


/*
================
keylock_try_to_unlock

Handle the logic of the specified client trying to unlock self.

More specifically, if the client has the correct key to unlock self,
then do the following:

    1. Remove the key from the client's inventory, unless self.cnt is
       non-zero, in which case leave it in the client's inventory.

    2. Print a message to let the player know which key they used.

    3. Play the "key used" sound effect (self.noise4).

    4. Call the function specified as the success_func parameter, which
       should perform whatever entity-specific actions are required for
       self.

Otherwise, if the client does not have the correct key to unlock self,
then do the following:

    1. Centerprint the message "You need the [key name]", unless the
       custom_message parameter is non-empty, in which case centerprint
       that instead.

    2. Play the "key required" sound effect (self.noise3).

The self.cnt functionality is a feature of progs_dump and was not part
of the original game.  -- iw
================
*/
void(entity client, string custom_message, void() success_func) keylock_try_to_unlock =
{
	local string s;

// support for item_key_custom -- iw
	if (!HasKeys (client, self.items, self.customkeys))
	{
		if (custom_message != "")
			centerprint (client, custom_message);
		else
			//if (isKex)
			//	centerprint2 (client, "You need the {0}", self.netname);
			//else
				centerprint2 (client, "You need the ", self.netname);
			
		sound (self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
		return;
	}

// the old code in door_touch included a comment from dumptruck_ds
// thanking RennyC re self.cnt
	if (self.cnt)
	{
		s = "You used (and kept) the ";
	}
	else
	{
	// support for item_key_custom -- iw
		RemoveKeys (client, self.items, self.customkeys);
		s = "You used the ";
	}

	sprint (client, s);
	sprint (client, self.netname);
	sprint (client, "\n");

// the old code in door_fire included a comment from dumptruck_ds
// thanking c0burn re changing CHAN_VOICE to CHAN_ITEM
	sound (self, CHAN_ITEM, self.noise4, 1, ATTN_NORM);

	success_func ();
};




//Selections from hiptrig.qc NOT the entire file

/* Trigger QuickC program
   By Jim Dose'  12/2/96
   Copyright (c)1996 Hipnotic Interactive, Inc.
   All rights reserved.
   Do not distribute.
*/

float USE_SILV_KEY = 8;
float USE_GOLD_KEY = 16;

/*
================
keytrigger_unlock

Perform the actions which should be performed when self is successfully
unlocked with a key.

This function exists so that it can be passed as an argument to the new
keylock_try_to_unlock function.  This code was previously part of the
keytrigger_use function.  -- iw
================
*/
void() keytrigger_unlock =
{
	// we can't just remove (self) here, because this is a touch function
	// called while C code is looping through area links...
	self.touch = SUB_Null;
	self.use = SUB_Null;
	self.nextthink = time + 0.1;
	self.think = SUB_Remove;
	self.message = "";

	SUB_UseTargets();
};

void() keytrigger_use =
{
	if (other.classname != "player")
		return;

	if (other.health <= 0)
		return;

	if (self.attack_finished > time)
		return;

	self.attack_finished = time + 2;
	keylock_try_to_unlock (activator, self.message, keytrigger_unlock);
};

void() keytrigger_touch =
{
	if(self.estate != STATE_ACTIVE)
		return;

	activator = other;
	keytrigger_use();
};

/*QUAKED trigger_usekey (0 .5 0) ? X X X USE_SILV_KEY USE_GOLD_KEY X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY

Variable sized single use trigger that requires a key to trigger targets.  Must be targeted at one or more entities.

"cnt"     if 1, leave a used key in the player's inventory (0 default).
"keyname" if set, this is the keyname of the item_key_custom which unlocks this entity.
"message" is printed when the trigger is touched without having the right key.
"noise1"  sound file for the "key required" sound (default is per worldtype).
"noise2"  sound file for the "key used" sound (default is per worldtype).
*/

void() trigger_usekey =
{


// the keylock_* functions use self.noise3 and self.noise4 internally,
// but trigger_usekey doesn't use the self.noise1 or self.noise2 fields
// for anything, so we allow the mapper to specify custom sound files by
// setting self.noise1 and self.noise2, but we move those values into
// self.noise3 and self.noise4 -- iw
	self.noise3 = self.noise1;
	self.noise4 = self.noise2;
	self.noise1 = "";
	self.noise2 = "";

	keylock_init ();

	if (self.spawnflags & USE_SILV_KEY) //dumptruck_ds
		keylock_set_silver_key ();
	if (self.spawnflags & USE_GOLD_KEY) //dumptruck_ds
		keylock_set_gold_key ();

// support for item_key_custom -- iw
	if (self.keyname != "")
	{
		keylock_set_custom_key (self.keyname);
		self.keyname = "";  // this should not be referenced again
	}

	if (!keylock_has_key_set ())
	{
		objerror ("no key specified!");
		return;
	}

	self.use = keytrigger_use;
	self.touch = keytrigger_touch;

	InitTrigger ();

	SUB_CheckWaiting();
};

// void() remove_touch =
// {
// 	if (other.flags & self.cnt)
// 		return;
// 	other.touch = SUB_Null;
// 	other.model = "";
// 	remove(self);
// };
//
// /*QUAKED trigger_remove (.5 .5 .5) ? ignoremonsters ignoreplayers
// Variable sized trigger that removes the thing
// that touches it.  Does not affect monsters or
// players.
// */
// void() trigger_remove =
// {
// 	if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
// 		return;
//
// 	self.cnt = FL_CLIENT|FL_MONSTER;
// 	if (self.spawnflags & 1)
// 		self.cnt = self.cnt - FL_MONSTER;
// 	if (self.spawnflags & 2)
// 		self.cnt = self.cnt - FL_CLIENT;
// 	InitTrigger ();
// 	self.touch = remove_touch;
// };



// item_key_custom is a brand-spanking-new entity class created for
// progs_dump -- iw

/*QUAKED item_key_custom (0 .5 .8) (-16 -16 -24) (16 16 32) X X X X X SPAWN_SILENT TRIGGER_SPAWNED SUSPENDED_IN_AIR NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
{
	model ({"path" : "progs/pd_wiz_key.mdl", "skin" : 1});
}
A customizable key item.

"keyname"  name of the key, e.g. "bronze key" (required)
"mdl"      model file (required)
"noise"    sound file for the pickup sound (default is per worldtype)
"skin"     skin index (default 0)

The "keyname" value is used both for the pickup message and to associate
the key with the entity that it unlocks.

To make a func_door or trigger_usekey require this key, set the
"keyname" value of that entity so that it matches the "keyname" value of
the key.

If different item_key_custom entities have the same "keyname" value,
they will be treated as different copies of the same key and may be used
interchangeably.

A map may have a maximum of 23 unique "keyname" values across all
entities.

The behavior of an item_key_custom should be as the player expects
(based on the behavior of the silver and gold keys), except for the fact
that it will not appear as an icon in the player's status bar when
picked up.  This is a limitation of the engine.
*/

/*
============
key_start

Finish initializing self as a key item.  -- iw
============
*/

void() key_setsounds;
void() key_touch;


void() key_start =
{
	key_setsounds ();
	self.particles_offset = '0 0 18';
	self.touch = key_touch;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

void() item_key_custom =
{

	if (self.keyname == "")
	{
		objerror ("no keyname specified");
		return;
	}

	if (self.mdl == "")
	{
		objerror ("no mdl specified");
		return;
	}

	precache_model (self.mdl);
	setmodel (self, self.mdl);
	self.mdl = "";  // this should not be referenced again

	self.netname = self.keyname;
	self.keyname = "";  // this should not be referenced again

	self.items = 0;  // ignore any mapper-set value
	self.customkeys = CustomKeyFlag (self.netname);

	key_start ();
};



void() key_touch =
{
//local entity	stemp;
//local float		best;

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	if (HasKeys (other, self.items, self.customkeys)){
		if (!self.state) {
			sprint (other, "You already got the ");
			sprint (other, self.netname);
			sprint (other,"\n");

			sound (other, CHAN_ITEM, self.noise1, 1, ATTN_NORM);

			activator = other;
			SUB_UseTargets();
			self.state = 1;
		}
		return;
	}

	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other,"\n");

	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

// support for item_key_custom -- iw
	GiveKeys (other, self.items, self.customkeys);

	if (!coop)
	{
		self.solid = SOLID_NOT;
		self.model = string_null;
	}

	if (!self.state) {
		activator = other;
		SUB_UseTargets();
		self.state = 1;
	}
};


void() key_setsounds =
{
	if (self.noise != "")
	{
		precache_sound (self.noise);
		return;
	}
	
	if (world.worldtype == WORLDTYPE_METAL)
	{
		precache_sound ("misc/runekey.wav");
		precache_sound ("doors/runetry.wav");
		self.noise = "misc/runekey.wav";
	}
	else if (world.worldtype == WORLDTYPE_BASE)
	{
		precache_sound ("misc/basekey.wav");
		precache_sound ("doors/basetry.wav");
		self.noise = "misc/basekey.wav";
	}
	else
	{
		precache_sound ("misc/medkey.wav");
		precache_sound ("doors/medtry.wav");
		self.noise = "misc/medkey.wav";
	}
};

/*QUAKED item_key1 (0 .5 .8) (-16 -16 -24) (16 16 32) X X X X X SPAWN_SILENT TRIGGER_SPAWNED SUSPENDED_IN_AIR NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
{	model("progs/w_s_key.mdl");	}
SILVER key
In order for keys to work you MUST set your map's worldtype to one of the following:
0: medieval
1: metal
2: base
*/
void() item_key1 =
{

	if (world.worldtype == WORLDTYPE_METAL)
	{
		precache_model ("progs/m_s_key.mdl");
		setmodel (self, "progs/m_s_key.mdl");
	}
	else if (world.worldtype == WORLDTYPE_BASE)
	{
		precache_model2 ("progs/b_s_key.mdl");
		setmodel (self, "progs/b_s_key.mdl");
	}
	else
 	{
		precache_model ("progs/w_s_key.mdl");
		setmodel (self, "progs/w_s_key.mdl");
	}
	self.netname = SilverKeyName ();
	self.items = IT_KEY1;

// support for item_key_custom -- iw
	self.customkeys = 0;  // ignore any mapper-set value
	self.noise = "";  // ignore any mapper-set value

	key_start ();
};


/*QUAKED item_key2 (0 .5 .8) (-16 -16 -24) (16 16 32) X X X X X SPAWN_SILENT TRIGGER_SPAWNED SUSPENDED_IN_AIR NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
{
	model ("progs/w_g_key.mdl");
}
GOLD key
In order for keys to work you MUST set your map's worldtype to one of the following:
0: medieval
1: metal
2: base
*/

void() item_key2 =
{
	if (world.worldtype == WORLDTYPE_METAL)
	{
		precache_model ("progs/m_g_key.mdl");
		setmodel (self, "progs/m_g_key.mdl");
	}
	else if (world.worldtype == WORLDTYPE_BASE)
	{
		precache_model2 ("progs/b_g_key.mdl");
		setmodel (self, "progs/b_g_key.mdl");
	}
	else {
		precache_model ("progs/w_g_key.mdl");
		setmodel (self, "progs/w_g_key.mdl");
	}
	self.netname = GoldKeyName ();
	self.items = IT_KEY2;

// support for item_key_custom -- iw
	self.customkeys = 0;  // ignore any mapper-set value
	self.noise = "";  // ignore any mapper-set value

	key_start ();
};
