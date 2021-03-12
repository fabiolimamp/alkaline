//Supa's random offset function
vector(float offset_amt) RandomOffset =
{
	local vector offset;

	offset_x = crandom() * offset_amt;
	offset_y = crandom() * offset_amt;
	offset_z = crandom() * offset_amt;
	
	return offset;
};

void(string noise)	MonsterIdleSound =	//ijed, play idlesound only if not AMBUSH, can also play it while stood
{
	local float r;
	r = random();
	
	if ((self.enemy == world) && (self.spawnflags & 3))
		return;
	
	if (self.enemy == world)		//quieter if not angry at anyone
	{
		if (r < 0.1)
			sound (self, CHAN_VOICE, noise, 1, ATTN_IDLE);
	}
	else if (r < 0.2)
		sound (self, CHAN_VOICE, noise, 1, ATTN_IDLE);
};
