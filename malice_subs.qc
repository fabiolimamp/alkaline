void() d_explode1 = [0, d_explode2]{};
void() d_explode2 = [1, d_explode3]{};
void() d_explode3 = [2, d_explode4]{};
void() d_explode4 = [3, d_explode5]{};
void() d_explode5 = [4, d_explode6]{};
void() d_explode6 = [5, d_explode7]{};
void() d_explode7 = [6, d_explode8]{};
void() d_explode8 = [7, d_explode9]{};
void() d_explode9 = [8, d_explode10]{};
void() d_explode10 = [9, d_explode11]{};
void() d_explode11 = [10, d_explode12]{};
void() d_explode12 = [11, d_explode13]{};
void() d_explode13 = [12, SUB_Remove]{};


void() FuelTankExplode = 
{
	local vector dir;
	self.effects = self.effects | EF_MUZZLEFLASH;
	sound(self, CHAN_VOICE, "weapons/fuelexp.wav", 1, ATTN_NORM);
	Fire_bomb(self.origin, dir);
	Fire_bomb(self.origin, dir);
	Fire_bomb(self.origin, dir);
	Fire_bomb(self.origin, dir);
	Fire_bomb(self.origin, dir);
};

void(vector org, vector dir) Fire_bomb = 
{
	local float x;
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_NOCLIP;
	newmis.solid = SOLID_BBOX;
	newmis.touch = SUB_Remove;
	

	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(newmis, org);
	//setmodel(newmis, "progs/d_explod.spr");
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, newmis.origin_x);
	WriteCoord (MSG_BROADCAST, newmis.origin_y);
	WriteCoord (MSG_BROADCAST, newmis.origin_z);
	if (random() > 0.5)
	{
		x = CONTENT_EMPTY;
	}
	else
	{
		x = AS_STRAIGHT;
	}
	newmis.nextthink = time;
	newmis.think = d_explode1;
	newmis.velocity_x = random() * 600 * x;
	newmis.velocity_y = random() * 600 * x;
	newmis.velocity_z = random() * 300;
};