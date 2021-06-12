/*
==============================================================================

trigger_setgravity (per entity)

==============================================================================
*/

.float return_gravity;
entity current_gravity_ent;

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