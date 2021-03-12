/*
==============================================================================

trigger_setgravity (per entity)

==============================================================================
*/

.float return_gravity;

void(float g) SetGlobalGravity =
{
	localcmd("sv_gravity ");
	localcmd(ftos(g));
	localcmd("\n");
	//bprint("\n\n\n\n");
};

void() SetGlobalGravity_Use =
{
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
	entity	ent;

	ent = find (world, classname, "gravity_global");
	
	if(ent && ent.gravity)
	{
		if(ent.state)
		{
			SetGlobalGravity(ent.gravity);
		}
		else
		{
			SetGlobalGravity(ent.return_gravity);
		}
	}
};