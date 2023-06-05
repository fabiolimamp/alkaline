vector screensize;
float st_items, st_items2, previtems2;
float st_weapons, st_activeweapon, prevweapons;
float st_boots, st_boots_finished;
float st_health;

float baralpha, hudalpha;
float hudviewsize;

// Default sizes for HUD elements
vector HUDSIZE_24 = '24 24 0';		// Status Bar
vector HUDSIZE_16 = '16 16 0';		// Inventory/Powerups
vector HUDSIZE_1624 = '16 24 0';	// Special key background
vector HUDSIZE_816 = '8 16 0';		// Old Vertical Runes
vector HUDSIZE_168 = '16 8 0';		// Silver/Gold/Custom Keys
vector HUDSIZE_8  = '8 8 0';		// Ammo numbers
vector HUDSIZE_C8 = '8 0 0';		// Character sizes

// 8 pixel font table (index positions)
float HUDFONT_WHITE = 0;	// Default index = 48-57
float HUDFONT_YELLOW = 1;	// index = index - 30
float HUDFONT_RED = 2;		// index = index + 128

vector HUDRGB_DEF = '1 1 1';

string number[10] = {
	"gfx/xnum_0",
	"gfx/xnum_1",
	"gfx/xnum_2",
	"gfx/xnum_3",
	"gfx/xnum_4",
	"gfx/xnum_5",
	"gfx/xnum_6",
	"gfx/xnum_7",
	"gfx/xnum_8",
	"gfx/xnum_9"
};
string anumber[10] = {
	"gfx/xanum_0",
	"gfx/xanum_1",
	"gfx/xanum_2",
	"gfx/xanum_3",
	"gfx/xanum_4",
	"gfx/xanum_5",
	"gfx/xanum_6",
	"gfx/xanum_7",
	"gfx/xanum_8",
	"gfx/xanum_9"
};

string number2[10] = {
	"gfx/num_0",
	"gfx/num_1",
	"gfx/num_2",
	"gfx/num_3",
	"gfx/num_4",
	"gfx/num_5",
	"gfx/num_6",
	"gfx/num_7",
	"gfx/num_8",
	"gfx/num_9"
};
string anumber2[10] = {
	"gfx/anum_0",
	"gfx/anum_1",
	"gfx/anum_2",
	"gfx/anum_3",
	"gfx/anum_4",
	"gfx/anum_5",
	"gfx/anum_6",
	"gfx/anum_7",
	"gfx/anum_8",
	"gfx/anum_9"
};

string faceid[10] = {
	"face5", "face4", "face3", "face2", "face1",
	"face_p5", "face_p4", "face_p3", "face_p2", "face_p1"
};

string weaponprefix[12] = {
	"gfx/",
	"gfx/",
	"gfx/",
	"gfx/",
	"gfx/",
	"gfx/",
	"gfx/",
	"gfx/",
	"gfx/",
	"gfx/",
	"gfx/",
	"gfx/"
};

string weaponname[12] = {
	"axe",//"axe.lmp",
	"chainsaw",//"chainsaw.lmp",
	"shotgun",
	"sshotgun",
	"nailgun",
	"snailgun",
	"rlaunch",
	"plaunch",//"plaunch.lmp",
	"srlaunch",
	"alightng",
	"laser",//"laser.lmp",
	"plasma"//"plasma.lmp"
};

float weaponflags[12] = {
	WEAPON_AXE,
	WEAPON_CHAINSAW,
	WEAPON_SHOTGUN,
	WEAPON_SUPER_SHOTGUN,
	WEAPON_NAILGUN,
	WEAPON_SUPER_NAILGUN,
	WEAPON_GRENADE_LAUNCHER,
	WEAPON_PROXIMITY_GUN,
	WEAPON_ROCKET_LAUNCHER,
	WEAPON_LIGHTNING,
	WEAPON_LASER_CANNON,
	WEAPON_PLASMA
};

string weaponframes[7] = {
	"inv_", "inv2_", "inva1_", "inva2_", "inva3_", "inva4_", "inva5_"
};

// Total actual weapon slots
float WPN_ICONS = 12;

// Record when weapons have been added (flash mechanic)
float weapontime[WPN_ICONS];



float runeflags[4] = {
	32, 64, 128, 256
};
// Record when runes have been added (flash mechanic)
float runetime[4];

string(float num, float fr) getWeaponName = {
	return strcat(weaponprefix[num], weaponframes[fr], weaponname[num]);
}

void(float num, vector pos, vector selected_offset) Hud_DrawWeapon = {
	float flash, fr;
	vector ofs;
	string name;

	if (st_weapons & weaponflags[num]) {

		flash = (time - weapontime[num])*10;

		if (flash < 10) {
			// Is the flash into second phase?
			if (flash < 0) flash = 0;
			else if (flash >= 5) flash = flash - 5;
			// flash is only 0-4 frames
			fr = flash + 2;
		}
		else {
			if (st_activeweapon == weaponflags[num])
				fr = 1;
			else	
				fr = 0;
		}

		if (st_activeweapon == weaponflags[num]) ofs = selected_offset;

		name = getWeaponName(num, fr);
		drawpic(pos + ofs, name, '24 16 0', '1 1 1', 1, 0);
	}
}

void(float num, vector pos, vector selected_offset) Hud_DrawWeaponFrame = {
	float flash, fr;
	vector ofs;
	string name;

	if (st_weapons & weaponflags[num]) {

		flash = (time - weapontime[num])*10;

		if (flash < 10) {
			// Is the flash into second phase?
			if (flash < 0) flash = 0;
			else if (flash >= 5) flash = flash - 5;
			// flash is only 0-4 frames
			fr = flash + 2;
		}
		else {
			if (st_activeweapon == weaponflags[num])
				fr = 1;
			else	
				fr = 0;
		}

		if (st_activeweapon == weaponflags[num]) ofs = selected_offset;

		name = strcat(weaponprefix[num], weaponframes[fr], "wframe");
		drawpic(pos + ofs, name, '32 16 0', '1 1 1', 1, 0);
	}
}


//----------------------------------------------------------------------
// Draws small 8 pixel numbers to HUD (white/yellow/red text options)
//----------------------------------------------------------------------
void(vector pos, float value, float digit, float zerofill, float fontcol) Hud_DrawNoFont8 =
{
	local string val_str;
	local float disp_len, disp_no;

	// Make sure value is within range
	if (value < 0) value = 0;
	// Check max range against max digits
	else if (value > 999 && digit >= 3) value = 999;
	else if (value > 99 && digit == 2) value = 99;
	else if (value > 9 && digit <= 1) value = 9;
	
	// Round number down (floor) and work out length
	val_str = ftos(floor(value));
	disp_len = strlen(val_str);
	
	// Zero fill number?
	if (zerofill) {
		while (disp_len < digit) {
			// Keep adding more zero's
			val_str = strcat("0", val_str);
			// Exit condition?
			disp_len = strlen(val_str);
		}
	}

	// Move to the lowest digit position first
	pos_x = pos_x + (digit * HUDSIZE_8_x);
	
	while (disp_len > 0) {
		// Countdown first (digit positions = 0-2)
		disp_len = disp_len - 1;
		// Move backward to display a digit
		pos_x = pos_x - HUDSIZE_8_x;
		// Convert character to number (font table index 48-57)
		disp_no = str2chr(val_str, disp_len);
		if (fontcol == HUDFONT_YELLOW) disp_no = disp_no - 30;
		else if (fontcol == HUDFONT_RED) disp_no = disp_no + 128;
		// Draw character from ascii font table (right-justified)
		drawcharacter(pos, disp_no, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);	
	}	
};

void(vector pos, float value, float threshhold, float style) Hud_DrawLargeValue =
{
	float c;
	float len;
	string s;
	if (value < 0)
		value = 0;	//hrm
	if (value>999)
		value = 999;

	//for (len = 0; len < 3; len++) {
	//	drawpic(pos+ len * '24 0 0', "gfx/numbk_non", '24 24 0', '1 1 1', 1, 0);
	//}

	s = ftos(floor(value));
	len = strlen(s);

	pos_x += 24 * (3-len);
	
	if (value <= threshhold)
	{	//use alternate (red) numbers

		while(len>0)
		{
			len--;
			c = str2chr(s, len);

			if (style == 2)
				drawpic(pos+len * '24 0 0', anumber2[c-'0'], '24 24 0', '1 1 1', 1, 0);
			else
				drawpic(pos+len * '24 0 0', anumber[c-'0'], '24 24 0', '1 1 1', 1, 0);
		}
	}
	else
	{	//use normal numbers

		while(len>0)
		{
			len--;
			c = str2chr(s, len);

			if (style == 2)
				drawpic(pos+len * '24 0 0', number2[c-'0'], '24 24 0', '1 1 1', 1, 0);
			else
				drawpic(pos+len * '24 0 0', number[c-'0'], '24 24 0', '1 1 1', 1, 0);
		}
	}
};

void(float type, vector pos, float drawback) Hud_DrawAmmoCount =
{
	string s;
	float value;
	float len;
	float c;
	value = getstati(STAT_SHELLS+type);
	if (value < 0)
		value = 0;	//hrm
	if (value>999)
		value = 999;

	s = ftos(floor(value));
	len = strlen(s);

	pos_x += 8 * (3-len);
	while(len>0)
	{
		len--;
		c = str2chr(s, len);
		drawcharacter(pos+len * '8 0 0', (18-'0') + c, '8 8 0', '1 1 1', 1, 0);
	}
};

//----------------------------------------------------------------------
// Change HUD face to reflect Health, Pain or Powerups
//----------------------------------------------------------------------
void(vector pos) Hud_DrawFace =
{
	string face;
	local float hpframe;

	
	
	if (st_items & IT_TRIFECTA){
		// trifecta + belt
		if (st_items & IT_INVISIBILITY)
			face = "gfx/face_tri2";
		// trifecta only
		else
			face = "gfx/face_tri";
	}
	// belt + pentagram + quad
	else if (st_items & (IT_INVISIBILITY | IT_INVULNERABILITY | IT_QUAD) == (IT_INVISIBILITY | IT_INVULNERABILITY | IT_QUAD))
		face = "gfx/face_allbuttri";
	// belt + pentagram
	else if (st_items & (IT_INVISIBILITY | IT_INVULNERABILITY) == (IT_INVISIBILITY | IT_INVULNERABILITY))
		face = "gfx/face_inv2";
	// belt + quad
	else if (st_items & (IT_INVISIBILITY | IT_QUAD) ==  (IT_INVISIBILITY | IT_QUAD))
		face = "gfx/face_invisquad";
	// pentagram + quad
	else if (st_items & (IT_INVULNERABILITY | IT_QUAD) == (IT_INVULNERABILITY | IT_QUAD))
		face = "gfx/face_inv3";
	// belt only
	else if (st_items & IT_INVISIBILITY)
		face = "gfx/face_invis";
	// quad only
	else if (st_items & IT_QUAD)
		face = "gfx/face_quad";
	// pentagram only
	else if (st_items & IT_INVULNERABILITY){
		face = "gfx/face_invul2";
	}

	// Regular face
	else {
		// Work out face based on HP (100/80/60/40/20)
		hpframe = floor(getstatf(STAT_HEALTH) / 20);
		// Check for negative and upper (MegaHP) limits
		if (hpframe < 0) hpframe = 0;
		else if (hpframe > 4) hpframe = 4;
		// Check for any pain/flinch updates
		if (painfinishtime > time) hpframe = hpframe + 5;
		// Final HP face
		face = faceid[hpframe];
	}
	
		
	// Draw face - always 24x24 size, full rgb/alpha
	drawpic(pos, face, HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
};

string(float f, float chars, string lead) FormatFloat
{
	string s = ftos(f);
	if (f < 10 && chars >= 3)
		s = strcat(lead, lead, s);
	else if (f < 10 && chars == 2)
		s = strcat(lead, s);
	else if (f < 100 && chars >= 3)
		s = strcat(lead, s);
	return s;
};

//=================================================================================================
//                                        Old style HUD
//=================================================================================================

void Hud_DrawSBar(vector pos)
{
	

	if (st_items & IT_TRIFECTA)	{
		drawpic(pos + '16 0 0', "gfx/sb_aarmortri", '112 24 0', '1 1 1', 1, 0);
	}
	else if (st_items & IT_INVULNERABILITY) {
		drawpic(pos + '16 0 0', "gfx/sb_aarmor666", '112 24 0', '1 1 1', 1, 0);
	}
	else {
		if (st_items & IT_ARMOR3)
			drawpic(pos+'16 0 0', "gfx/sb_aarmor3", '24 24 0', '1 1 1', 1, 0);
		else if (st_items & IT_ARMOR2)
			drawpic(pos+'16 0 0', "gfx/sb_aarmor2", '24 24 0', '1 1 1', 1, 0);
		else if (st_items & IT_ARMOR1)
			drawpic(pos+'16 0 0', "gfx/sb_aarmor1", '24 24 0', '1 1 1', 1, 0);

		drawpic(pos+'40 0 0', "gfx/numbk_armorammo", '88 24 0', '1 1 1', 1, 0);
		Hud_DrawLargeValue(pos+'48 0 0', getstatf(STAT_ARMOR), 25, 1);
	}

	Hud_DrawFace(pos+'168 0 0');
	
	drawpic(pos+'192 0 0', "gfx/numbk_health", '88 24 0', '1 1 1', 1, 0);
	Hud_DrawLargeValue(pos+'200 0 0', getstatf(STAT_HEALTH), 25, 1);

	if (st_items & IT_SHELLS)
		drawpic(pos+'320 0 0', "gfx/sb_ashells", '24 24 0', '1 1 1', 1, 0);
	else if (st_items & IT_NAILS)
		drawpic(pos+'320 0 0', "gfx/sb_anails", '24 24 0', '1 1 1', 1, 0);
	else if (st_items & IT_ROCKETS)
		drawpic(pos+'320 0 0', "gfx/sb_arocket", '24 24 0', '1 1 1', 1, 0);
	else if (st_items & IT_CELLS)
		drawpic(pos+'320 0 0', "gfx/sb_cells", '24 24 0', '1 1 1', 1, 0);

	drawpic(pos+'344 0 0', "gfx/numbk_armorammo", '88 24 0', '1 1 1', 1, 0);
	Hud_DrawLargeValue(pos+'352 0 0', getstatf(STAT_AMMO), 10, 1);

	if (st_items2 & 32)
		drawpic(pos+'440 0 0', "gfx/sb_sigil1", '8 16 0', '1 1 1', 1, 0);
	if (st_items2 & 64)
		drawpic(pos+'448 0 0', "gfx/sb_sigil2", '8 16 0', '1 1 1', 1, 0);
	if (st_items2 & 128)
		drawpic(pos+'456 0 0', "gfx/sb_sigil3", '8 16 0', '1 1 1', 1, 0);
	if (st_items2 & 256)
		drawpic(pos+'464 0 0', "gfx/sb_sigil4", '8 16 0', '1 1 1', 1, 0);
};

void Hud_DrawIBar(vector pos)
{

	float i;
	vector offset;
	for (i = 0; i < 12; i++) {
		offset = [i * 24, 8, 0];
		Hud_DrawWeapon(i, pos + offset, '0 0 0');
	}
	

	Hud_DrawAmmoCount(0, pos + '58 0 0', FALSE);
	Hud_DrawAmmoCount(1, pos + '106 0 0', FALSE);
	Hud_DrawAmmoCount(2, pos + '176 0 0', FALSE);
	Hud_DrawAmmoCount(3, pos + '248 0 0', FALSE);

	if (st_items & IT_KEY1)
		drawpic(pos+'288 8 0', "gfx/sb_key1", '16 16 0', '1 1 1', 1, 0);
	if (st_items & IT_KEY2)
		drawpic(pos+'304 8 0', "gfx/sb_key2", '16 16 0', '1 1 1', 1, 0);
	/*
	if (st_items & IT_INVISIBILITY)
		drawpic(pos+'320 8 0', "gfx/sb_invis", '16 16 0', '1 1 1', 1, 0);
	if (st_items & IT_INVULNERABILITY)
		drawpic(pos+'336 8 0', "gfx/sb_invuln", '16 16 0', '1 1 1', 1, 0);
	if (st_items & IT_SUIT)
		drawpic(pos+'352 8 0', "gfx/sb_suit", '16 16 0', '1 1 1', 1, 0);
	if (st_items & IT_QUAD)
		drawpic(pos+'368 8 0', "gfx/sb_quad", '16 16 0', '1 1 1', 1, 0);
	if (st_items & IT_TRIFECTA)
		drawpic(pos+'384 8 0', "gfx/sb_trifecta", '16 16 0', '1 1 1', 1, 0);
	if (st_boots)
		drawpic(pos+'400 8 0', "gfx/sb_boots", '16 16 0', '1 1 1', 1, 0);
	*/

	if (st_items & IT_KEY3)
		drawpic(pos+'320 8 0', "gfx/sb_key3", '16 16 0', '1 1 1', 1, 0);

	if (st_items & IT_INVISIBILITY)
		drawpic(pos+'336 8 0', "gfx/sb_invis", '16 16 0', '1 1 1', 1, 0);
	if (st_items & IT_INVULNERABILITY)
		drawpic(pos+'352 8 0', "gfx/sb_invuln", '16 16 0', '1 1 1', 1, 0);
	if (st_items & IT_SUIT)
		drawpic(pos+'368 8 0', "gfx/sb_suit", '16 16 0', '1 1 1', 1, 0);
	if (st_items & IT_QUAD)
		drawpic(pos+'384 8 0', "gfx/sb_quad", '16 16 0', '1 1 1', 1, 0);
	if (st_items & IT_TRIFECTA)
		drawpic(pos+'400 8 0', "gfx/sb_trifecta", '16 16 0', '1 1 1', 1, 0);
	if (st_boots) {
		drawpic(pos+'416 8 0', "gfx/sb_boots", '16 16 0', '1 1 1', 1, 0);
		if (st_boots != 1) {
			float c;
			if (st_boots < 0 || st_boots > 9) c = str2chr("+", 0);
			else c = str2chr(ftos(st_boots), 0);
			//drawcharacter(left + [24, vertical_left + 4, 0], c, '8 8 0', '1 1 1', 1, 0);
			drawcharacter(pos+'423 15 0', c, '8 8 0', '1 1 1', 1, 0);
		}
	}

};


void(vector pos, float bx, float by, float bwidth, float bheight, float pixelspeed, string draw_str) Hud_ScrollTextBox =
{
	local float str_width, str_double, str_speed;
	local string wide_str;
	
	// draw debug visual box to show area on screen
	//drawfill( pos+[bx,by], [bwidth,bheight], HUDRGB_DEF, 0.1, 0);

	// Find out width of string in pixels (using font 8)
	str_width = stringwidth( draw_str, TRUE, HUDSIZE_8);
	// String less than window width?
	if (str_width < bwidth) {
		// Center the map name string in the box area
		str_double = (bwidth - str_width) / 2;
		// Display string normally (no scrolling required)
		drawstring( pos+[bx+str_double, by], draw_str, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
	}
	else {
		// Create double length string with boundary marker
		wide_str = strcat(draw_str, " /// ", draw_str);
		// Setup clip (scissor) area for exclusive drawing
		drawsetcliparea( pos_x + bx, pos_y + by, bwidth, bheight);
		str_double = stringwidth( wide_str, TRUE, HUDSIZE_8);
		// create offset of string to make it look like its scrolling
		str_speed = mod(cltime * pixelspeed, (str_double - str_width));
		// draw string (with offset) inside of clip (scissor) area only
		drawstring( pos+[bx - str_speed, by], wide_str, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
		// Reset clip string area to default
		drawresetcliparea();
	}
};


void(vector pos) Hud_DrawScoreBar_QSClock = {
	local string skill_str, map_str;
	local float digit, skill_no;
	local float nsecs, nmins;
	
	// Clear status bar ready for map info/scores
	drawpic(pos, "gfx/alk_scorebar", [480, 24], '1 1 1', baralpha, 0);

	// map title + map name
	map_str = strcat(world.message, " (", mapname, ")");
	Hud_ScrollTextBox(pos, 8, 4, 464, 8, 32, map_str);

	// Kills
	drawstring(pos+[8,12], "Kills:", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
	Hud_DrawNoFont8(pos+[56,12], getstatf(STAT_KILLEDMONSTERS), 3, FALSE, HUDFONT_WHITE);
	drawstring(pos+[80,12], "/", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);	
	
	if (getstatf(STAT_TOTALMONSTERS) < 100) digit = 2;
	else digit = 3;
	Hud_DrawNoFont8(pos+[88,12], getstatf(STAT_TOTALMONSTERS), digit, FALSE, HUDFONT_WHITE);


	// Work out time passed
	nmins = floor(time/60);
	nsecs = floor(time - nmins*60);
	Hud_DrawNoFont8(pos+[124,12], nmins, 3, FALSE, HUDFONT_WHITE);
	drawstring(pos+[148,12], ":", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);	
	Hud_DrawNoFont8(pos+[160,12], nsecs, 2, TRUE, HUDFONT_WHITE);


	// Secret totals
	drawstring(pos+[200,12], "Secrets:", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
	Hud_DrawNoFont8(pos+[264,12], getstatf(STAT_FOUNDSECRETS), 2, FALSE, HUDFONT_WHITE);
	drawstring(pos+[280,12], "/", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
	Hud_DrawNoFont8(pos+[288,12], getstatf(STAT_TOTALSECRETS), 2, FALSE, HUDFONT_WHITE);

	// Skill

	//skill_no = stof(autocvar(skill, "1"));
	skill_no = cvar("skill");
	if (skill_no == 0) skill_str = "Easy";
	else if (skill_no == 1) skill_str = "Normal";
	else if (skill_no == 2) skill_str = "Hard";
	else if (skill_no == 3) skill_str = "Nightmare";
	else skill_str = "Unknown";

	drawstring(pos+[332, 12], strcat(skill_str, " skill"), HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);

};


nonstatic void Hud_Draw(float scoreboard, vector pos) {
		
	if (scoreboard)	{
		//Hud_CoopScores_SBar(pos - '0 24 0');
		Hud_DrawScoreBar_QSClock(pos - '0 24 ');
	}

	if (hudviewsize < 110) {
		drawpic(pos - '0 48 0', "gfx/alk_ibar", '480 24 0', '1 1 1', baralpha, 0);
		Hud_DrawIBar(pos - '-8 48 0');

		if (!scoreboard) {
			drawpic(pos - '0 24 0', "gfx/alk_sbar", '480 24 0', '1 1 1', baralpha, 0);
			Hud_DrawSBar(pos - '0 24 0');
		}
	}
	
	else if (hudviewsize == 110 && !scoreboard) {
		drawpic(pos - '0 24 0', "gfx/alk_sbar_solo", '480 24 0', '1 1 1', baralpha, 0);
		Hud_DrawSBar(pos - '0 24 0');
	}


	
};

//=================================================================================================
//                                        New style HUD
//=================================================================================================



void Hud_DrawSBar_2(vector left, vector right) {
	float vertical_left, vertical_right;

	vertical_left -= 24;

	Hud_DrawFace(left + [0, vertical_left, 0]);
	Hud_DrawLargeValue(left + [32, vertical_left, 0], getstatf(STAT_HEALTH), 25, 2);
	

	if (st_items & IT_TRIFECTA)	{
		vertical_left -= 24;
		drawpic(left + [0, vertical_left, 0], "gfx/sb_aarmortri", '112 24 0', '1 1 1', 1, 0);

	}
	else if (st_items & IT_INVULNERABILITY) {
		vertical_left -= 24;
		drawpic(left + [0, vertical_left, 0], "gfx/sb_aarmor666", '112 24 0', '1 1 1', 1, 0);
	}
	else if (st_items & (IT_ARMOR3 + IT_ARMOR2 + IT_ARMOR1)) {
		string armorpic;

		vertical_left -= 24;

		if (st_items & IT_ARMOR3) armorpic = "gfx/sb_armor3";
		else if (st_items & IT_ARMOR2) armorpic = "gfx/sb_armor2";
		else armorpic = "gfx/sb_armor1";
		
		drawpic(left + [0, vertical_left, 0], armorpic, '24 24 0', '1 1 1', 1, 0);
		Hud_DrawLargeValue(left + [32, vertical_left, 0], getstatf(STAT_ARMOR), 25, 2);

		
	}
	
	vertical_left -= 2;
	
	if (hudviewsize < 110) {
		if (st_items & IT_INVISIBILITY) {
			vertical_left -= 16;
			drawpic(left + [4, vertical_left, 0], "gfx/sb_invis", '16 16 0', '1 1 1', 1, 0);
		}
		if (st_items & IT_INVULNERABILITY) {
			vertical_left -= 16;
			drawpic(left + [4, vertical_left, 0], "gfx/sb_invuln", '16 16 0', '1 1 1', 1, 0);
		}
		if (st_items & IT_SUIT) {
			vertical_left -= 16;
			drawpic(left + [4, vertical_left, 0], "gfx/sb_suit", '16 16 0', '1 1 1', 1, 0);
		}
		if (st_items & IT_QUAD) {
			vertical_left -= 16;
			drawpic(left + [4, vertical_left, 0], "gfx/sb_quad", '16 16 0', '1 1 1', 1, 0);
		}
		if (st_items & IT_TRIFECTA) {
			vertical_left -= 16;
			drawpic(left + [4, vertical_left, 0], "gfx/sb_trifecta", '16 16 0', '1 1 1', 1, 0);
		}
		if (st_boots) {
			vertical_left -= 16;
			drawpic(left + [4, vertical_left, 0], "gfx/sb_boots", '16 16 0', '1 1 1', 1, 0);
			
			if (st_boots != 1) {
				float c;
				if (st_boots < 0 || st_boots > 9) c = str2chr("+", 0);
				else c = str2chr(ftos(st_boots), 0);
				//drawcharacter(left + [24, vertical_left + 4, 0], c, '8 8 0', '1 1 1', 1, 0);
				drawcharacter(left + [11, vertical_left + 7, 0], c, '8 8 0', '1 1 1', 1, 0);
			}
		}
	}

	//---------------------------------------------------------------------------------------------
	
	string ammopic;
	if (st_items & IT_SHELLS) ammopic = "gfx/sb_shells";
	else if (st_items & IT_NAILS) ammopic = "gfx/sb_nails";
	else if (st_items & IT_ROCKETS) ammopic = "gfx/sb_rocket";
	else if (st_items & IT_CELLS) ammopic = "gfx/sb_cells";
	
	vertical_right -= 24;

	if (ammopic != "") {
		drawpic(right + [-24, vertical_right, 0], ammopic, '24 24 0', '1 1 1', 1, 0);
		Hud_DrawLargeValue(right + [-104, vertical_right, 0], getstatf(STAT_AMMO), 10, 2);
	}
	else {
		Hud_DrawLargeValue(right + [-72, vertical_right, 0], getstatf(STAT_AMMO), 10, 2);
	}

	if (hudviewsize < 110) {
		vertical_right -= 28;
		
		drawpic(right + [-96, vertical_right, 0], "gfx/bg_ammo.lmp", '96 20 0', '1 1 1', baralpha, 0);

		Hud_DrawAmmoCount(0, right + [-96, vertical_right, 0] + '10 0 0', FALSE);
		Hud_DrawAmmoCount(1, right + [-96, vertical_right, 0] + '58 0 0', FALSE);
		Hud_DrawAmmoCount(2, right + [-96, vertical_right, 0] + '10 10 0', FALSE);
		Hud_DrawAmmoCount(3, right + [-96, vertical_right, 0] + '58 10 0', FALSE);
	}

	vertical_right -= 4;

	if (st_items & IT_KEY1){
		vertical_right -= 16;
		drawpic(right + [-16, vertical_right, 0], "gfx/sb_key1", '16 16 0', '1 1 1', 1, 0);
	}
	if (st_items & IT_KEY2){
		vertical_right -= 16;
		drawpic(right + [-16, vertical_right, 0], "gfx/sb_key2", '16 16 0', '1 1 1', 1, 0);
	}
	if (st_items & IT_KEY3){
		vertical_right -= 16;
		drawpic(right + [-16, vertical_right, 0], "gfx/sb_key3", '16 16 0', '1 1 1', 1, 0);
	}

	vector offset;
	
	if (hudviewsize < 110) {
		for (float i = 0; i < 12; i++) {
			if (st_weapons & weaponflags[i]) {
				offset += '0 -14 0';
				Hud_DrawWeapon(i, [screensize_x - 25, screensize_y/2 + 56, 0] + offset , '-4 0 0');
				Hud_DrawWeaponFrame(i, [screensize_x - 25, screensize_y/2 + 56, 0] + offset , '-4 0 0');
			}
		}
	}

};

float runealpha(float i) {
	if (runetime[i] < 0)
		return 1;

	if (time - runetime[i] > 1.5)
		return 1;
	else if (time - runetime[i] > 1.2)
		return (time - runetime[i] - 1.2)/0.3;
	else if (time - runetime[i] > 0.9)
		return 1 - (time - runetime[i] - 0.9)/0.3;
	else if (time - runetime[i] > 0.6)
		return (time - runetime[i] - 0.6)/0.3;
	else if (time - runetime[i] > 0.3)
		return 1 - (time - runetime[i] - 0.3)/0.3;
	else
		return (time - runetime[i])/0.3;
}

void Hud_DrawRunes_2(vector pos) {
	drawpic(pos+'0 0 0', "gfx/bg_runes.lmp", '32 16 0', '1 1 1', 1, 0);

	if (st_items2 & 32){
		drawpic(pos+'0 0 0', "gfx/sb_sigil1", '8 16 0', '1 1 1', runealpha(0), 0);
	}
	if (st_items2 & 64) {
		drawpic(pos+'8 0 0', "gfx/sb_sigil2", '8 16 0', '1 1 1', runealpha(1), 0);
	}
	if (st_items2 & 128) {
		drawpic(pos+'16 0 0', "gfx/sb_sigil3", '8 16 0', '1 1 1', runealpha(2), 0);
	}
	if (st_items2 & 256){
		drawpic(pos+'24 0 0', "gfx/sb_sigil4", '8 16 0', '1 1 1', runealpha(3), 0);
	}
}



nonstatic void Hud_Draw_2(float scoreboard) {
	if (scoreboard)	{
		//Hud_CoopScores_SBar(pos - '0 24 0');
		Hud_DrawScoreBar_QSClock([(screensize_x-480)/2, screensize_y - 24, 0]);
		Hud_DrawRunes_2([(screensize_x-32)/2, screensize_y - 48, 0]);
		return;
	}

	
	if (hudviewsize <= 110) {
		Hud_DrawSBar_2([16, screensize_y - 10, 0], [screensize_x - 16, screensize_y - 10, 0]);

		float lastrunetime;
		for (float i = 0; i < 4; i++) {
			if (time - runetime[i] < 3 && time - runetime[i] > lastrunetime) lastrunetime = runetime[i];
		}

		if (lastrunetime > 0) 
			Hud_DrawRunes_2([(screensize_x-32)/2, screensize_y - 24, 0]);
	}


	
};


//=================================================================================================
//                                      Engine hooks
//=================================================================================================

void(float apilevel, string enginename, float engineversion) CSQC_Init = {
	previtems2 = -1;
	prevweapons = -1;
};


void(vector virtsize, float showscores) CSQC_DrawHud = {



	screensize_x = virtsize_x;
	screensize_y = virtsize_y;
	screensize_z = 0;

	if (prevweapons >= 0) prevweapons = st_weapons;

	if (previtems2 >= 0) previtems2 = st_items2;

	//st_items = getstatbits(STAT_ITEMS, 0, 23);
	st_items = getstatf(STAT_IT);
	st_items2 = getstatbits(STAT_ITEMS, 23, 9);
	st_weapons = getstatf(STAT_WEAPONS);
	st_activeweapon = getstatf(STAT_ACTIVEWEAPON);
	st_boots = getstatf(STAT_BOOTS);
	st_boots_finished = getstatf(STAT_BOOTS_FINISHED);
	st_health = getstatf(STAT_HEALTH);

	hudviewsize = cvar("viewsize");

	baralpha = cvar("scr_sbaralpha");
	if (baralpha == 0) baralpha = 0.333;
	// Default is 1 for everything else
	hudalpha = 1;

	if (prevweapons < 0) prevweapons = st_weapons;

	for (float i = 0; i < WPN_ICONS; i++) {
		if (weaponflags[i] & st_weapons && !(weaponflags[i] & prevweapons))
			weapontime[i] = time;
	}


	if (previtems2 < 0) previtems2 = st_items2;

	for (float i = 0; i < 4; i++) {
		if (runeflags[i] & st_items2 && !(runeflags[i] & previtems2)){
			runetime[i] = time;
		}
	}

	if (getstatf(STAT_DMGTAKE) > 0) {
		painfinishtime = time + 0.2;
	}

	if (getstatf(STAT_CURRENTHUD) == 1)
		Hud_Draw(showscores, [(screensize_x-480)/2, screensize_y, 0]);
	else
		Hud_Draw_2(showscores);
};