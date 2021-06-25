/*
==============================================================================

trigger_globalgravity

==============================================================================
*/



void(float g) SetGlobalGravity =
{
	cvar_set ("sv_gravity", ftos(g)); 
	bprint("\n\n\n\n");
};

void() SetGlobalGravity_Use =
{
	current_gravity_ent = self;
	
	if(self.state)
	{
		SetGlobalGravity(self.return_gravity);
		self.state = 0;
	}
	else
	{
		SetGlobalGravity(self.gravity);
		self.state = 1;
	}
};

void() trigger_globalgravity =
{
	if(!self.gravity)
	{
		objerror ("gravity key not set!\n");
		remove(self);
	}
	
	self.classname = "gravity_global";
	self.state = 0;
	self.use = SetGlobalGravity_Use;
	
	if(!self.return_gravity)
	{
		self.return_gravity = 800;
	}
};

void() FindAndReadGlobalGravity =
{
	if(current_gravity_ent != world && current_gravity_ent.classname == "gravity_global")
	{
		if(current_gravity_ent.state)
		{
			SetGlobalGravity(current_gravity_ent.gravity);
		}
		else
		{
			SetGlobalGravity(current_gravity_ent.return_gravity);
		}
	}
};



/*
==============================================================================

trigger_setgravity

==============================================================================
*/
float DT_GRAVTOFF = 8;  // trigger will start off
float DT_PLAYERONLY = 16;  // trigger will start off

void() grav_toggle = 
{ 
	//dumptruck_ds based on hipnotic blocker_use
	if ( !self.state )
	{
		self.state = 1;
		self.solid = SOLID_TRIGGER;
	}
	else
	{
		self.state = 0;
		self.solid = SOLID_NOT;
	}
};

void() trigger_gravity_touch = {
  // from Copper -- dumptruck_ds
  // if (!CheckValidTouch()) return;
	if (self.estate != STATE_ACTIVE) return;

	local float temp_grav;

	if (self.spawnflags & DT_PLAYERONLY && other.classname != "player")
		return;

	if (self.gravity == -1)
		temp_grav = 1;
	else
		temp_grav = self.gravity;

	// the player's gravity is now managed in PlayerPreThink(), however
	// other entities don't have special gravity management, so their
	// gravity is still set directly -- iw
	if (other.classname == "player")
		other.wantedgravity = temp_grav;
	else
		other.gravity = temp_grav;
};

/*QUAKED trigger_setgravity (.5 .5 .5) ? X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
set the gravity of a player

"gravity" what to set the players gravity to
 - 0 (default) normal gravity
 - 1 no gravity
 - 2 almost no gravity
 - 10 is a good setting
 - ...
 - 101 normal gravity
 - 102 slightly higher gravity
 - ...
 - 1000 very high gravity

 NOTE: the amount of gravity can only be changed by touching another
 trigger_setgravity with a different setting. The gravity key defaults to 0
 which is normal gravity. Lower numbers (e.g. 25) equal lower gravity. Setting
 100 is normal gravity. Numbers above 100 will make the player “heavier”, i.e.
 harder to jump. If you want multiple trigger setgravity triggers in one room or
 area, make sure the brushes are not touching each other. This can cause the
 triggers not to work properly.

*/

void() trigger_gravity_late_init = 
{
	self.solid = SOLID_NOT;
	self.use = grav_toggle;
	self.touch = trigger_gravity_touch;

	SUB_CheckWaiting();
};

void() trigger_setgravity = {

	InitTrigger ();
	self.solid = SOLID_TRIGGER;
	
	if ( self.spawnflags & DT_GRAVTOFF ) //dumptruck_ds
	{
		self.use = SUB_Null;
		self.touch = SUB_Null;
		self.nextthink = time + 1;
		self.think = trigger_gravity_late_init;
	}
	else
	{
		self.use = grav_toggle; // dumptruck_ds
		self.touch = trigger_gravity_touch;
		self.state = 1;
	}
	
	if (!self.gravity)
		self.gravity = -1;
	else
		self.gravity = ((self.gravity - 1) / 100);
};
