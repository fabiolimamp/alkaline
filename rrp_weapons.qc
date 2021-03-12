void()	bbullet_explode1	=	[0,	bbullet_explode2]	{};
void()	bbullet_explode2	=	[1,	bbullet_explode3]	{};
void()	bbullet_explode3	=	[2,	SUB_Remove]			{};

//ijed These are for the Mr Big monster's attacks
void() become_big_bullet_explosion =
{
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/big_bullet_blast.mdl");
	self.solid = SOLID_NOT;
	bbullet_explode1 ();
};