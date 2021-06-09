static float DEXPLODE_FRAMETIME = 0.03;

void() d_explode1 = [0, d_explode2]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode2 = [1, d_explode3]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode3 = [2, d_explode4]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode4 = [3, d_explode5]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode5 = [4, d_explode6]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode6 = [5, d_explode7]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode7 = [6, d_explode8]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode8 = [7, d_explode9]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode9 = [8, d_explode10]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode10 = [9, d_explode11]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode11 = [10, d_explode12]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode12 = [11, d_explode13]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode13 = [12, SUB_Remove]{};


void() FuelTankExplode = 
{
	local vector dir;
	self.effects = self.effects | EF_MUZZLEFLASH;
	sound(self, CHAN_AUTO, "weapons/fuelexp.wav", 1, ATTN_NORM);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	Fire_bomb(self.origin, dir);
	Fire_bomb(self.origin, dir);
	Fire_bomb(self.origin, dir);
	Fire_bomb(self.origin, dir);
	Fire_bomb(self.origin, dir);
};

void(vector org, vector dir) Fire_bomb = 
{
	//local float x;
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_NOCLIP;
	newmis.solid = SOLID_BBOX;
	newmis.touch = SUB_Remove;
	newmis.flags = newmis.flags | FL_PROJECTILE;

	setorigin(newmis, org);
	setmodel(newmis, "progs/d_explod.spr");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	/*WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, newmis.origin_x);
	WriteCoord (MSG_BROADCAST, newmis.origin_y);
	WriteCoord (MSG_BROADCAST, newmis.origin_z);*/

	//if (random() > 0.5)	x = -1;
	//else x = 1;

	newmis.nextthink = time;
	newmis.think = d_explode1;
	newmis.velocity_x = crandom() * 400;
	newmis.velocity_y = crandom() * 400;
	newmis.velocity_z = random() * 200;
};