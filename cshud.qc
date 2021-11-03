vector screensize;
float st_items, st_items2, st_weapons, st_activeweapon, prevweapons;
float st_boots, st_boots_finished;

float baralpha, hudalpha;

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
	"num_0",
	"num_1",
	"num_2",
	"num_3",
	"num_4",
	"num_5",
	"num_6",
	"num_7",
	"num_8",
	"num_9"
};
string anumber[10] = {
	"anum_0",
	"anum_1",
	"anum_2",
	"anum_3",
	"anum_4",
	"anum_5",
	"anum_6",
	"anum_7",
	"anum_8",
	"anum_9"
};

string faceid[14] = {
	"face5", "face4", "face3", "face2", "face1",
	"face_p5", "face_p4", "face_p3", "face_p2", "face_p1",
	"face_inv2", "face_quad", "face_invis", "face_invul2"
};

string weaponprefix[12] = {
	"gfx/",
	"gfx/",
	"",
	"",
	"",
	"",
	"",
	"gfx/",
	"",
	"gfx/",
	"gfx/",
	"gfx/"
};

string weaponname[12] = {
	"axe.lmp",//"axe.lmp",
	"chainsaw.lmp",//"chainsaw.lmp",
	"shotgun",
	"sshotgun",
	"nailgun",
	"snailgun",
	"rlaunch",
	"lightng.lmp",//"plaunch.lmp",
	"srlaunch",
	"lightng.lmp",
	"lightng.lmp",//"laser.lmp",
	"lightng.lmp"//"plasma.lmp"
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

string(float num, float fr) getWeaponName = {
	return strcat(weaponprefix[num], weaponframes[fr], weaponname[num]);
}

void(float num, vector pos) Hud_DrawWeapon = {
	float flash, fr;
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

		name = getWeaponName(num, fr);
		drawpic(pos, name, '24 16 0', '1 1 1', 1, 0);
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

void(vector pos, float value, float threshhold) Hud_DrawLargeValue =
{
	float c;
	float len;
	string s;
	if (value < 0)
		value = 0;	//hrm
	if (value>999)
		value = 999;

	s = ftos(floor(value));
	len = strlen(s);

	pos_x += 24 * (3-len);
	

	if (value <= threshhold)
	{	//use alternate (red) numbers

		while(len>0)
		{
			len--;
			c = str2chr(s, len);

			drawpic(pos+len * '24 0 0', anumber[c-'0'], '24 24 0', '1 1 1', 1, 0);
		}
	}
	else
	{	//use normal numbers

		while(len>0)
		{
			len--;
			c = str2chr(s, len);

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

	// Start with InvRing as it has two states
	if (st_items & IT_INVISIBILITY) {
		// InvRing + Pentagram!?! WTF!?! SandyP E4 design!
		if (st_items & IT_INVULNERABILITY) face = faceid[10];
		// Just InvRing only
		else face = faceid[12];
	}
	// Quad only
	else if (st_items & IT_QUAD) face = faceid[11];
	// Pentagram only
	else if (st_items & IT_INVULNERABILITY) face = faceid[13];
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

void(vector pos) Hud_CoopScores_SBar =
{
	string s;
	float secs;
	float mins;
	//When you press tab in single player/coop, you get some replacement info over the sbar
	vector sbar = screensize_y * ' 0 1 0' - '0 24 0';
	drawpic(sbar, "scorebar", '320 24 0', '1 1 1', 0.333, 0);

	s = strcat("Monsters:", FormatFloat(getstatf(STAT_KILLEDMONSTERS), 3, " "), "/", FormatFloat(getstatf(STAT_TOTALMONSTERS), 3, " "));
	drawstring(sbar + '8 4', s, '8 8 0', '1 1 1', 1, 0);
	s = strcat("Secrets :", FormatFloat(getstatf(STAT_FOUNDSECRETS), 3, " "), "/", FormatFloat(getstatf(STAT_TOTALSECRETS), 3, " "));
	drawstring(sbar + '8 12', s, '8 8 0', '1 1 1', 1, 0);

	mins = floor(time/60);
	secs = floor(time - mins*60);
	s = strcat("Time :", FormatFloat(mins, 3, " "), ":", FormatFloat(secs, 2, "0"));
	drawstring(sbar + '184 4', s, '8 8 0', '1 1 1', 1, 0);

	drawstring(sbar + '232 12' - strlen(levelname)*'4 0', levelname, '8 8 0', '1 1 1', 1, 0);
};

void Hud_DrawSBar(vector pos)
{
	drawpic(pos, "gfx/alk_sbar.lmp", '448 24 0', '1 1 1', baralpha, 0);

	if (st_items & IT_INVULNERABILITY)
	{
		drawpic(pos, "disc", '24 24 0', '1 1 1', 1, 0);
		Hud_DrawLargeValue(pos+'24 0 0', 999, 25);
	}
	else
	{
		Hud_DrawLargeValue(pos+'24 0 0', getstatf(STAT_ARMOR), 25);
		if (st_items & IT_ARMOR3)
			drawpic(pos, "sb_armor3", '24 24 0', '1 1 1', 1, 0);
		else if (st_items & IT_ARMOR2)
			drawpic(pos, "sb_armor2", '24 24 0', '1 1 1', 1, 0);
		else if (st_items & IT_ARMOR1)
			drawpic(pos, "sb_armor1", '24 24 0', '1 1 1', 1, 0);
	}

	Hud_DrawFace(pos+'240 0 0');
	Hud_DrawLargeValue(pos+'264 0 0', getstatf(STAT_HEALTH), 25);

	if (st_items & IT_SHELLS)
		drawpic(pos+'352 0 0', "sb_shells", '24 24 0', '1 1 1', 1, 0);
	else if (st_items & IT_NAILS)
		drawpic(pos+'352 0 0', "sb_nails", '24 24 0', '1 1 1', 1, 0);
	else if (st_items & IT_ROCKETS)
		drawpic(pos+'352 0 0', "sb_rocket", '24 24 0', '1 1 1', 1, 0);
	else if (st_items & IT_CELLS)
		drawpic(pos+'352 0 0', "sb_cells", '24 24 0', '1 1 1', 1, 0);
	Hud_DrawLargeValue(pos+'376 0 0', getstatf(STAT_AMMO), 10);
};

void Hud_DrawIBar(vector pos)
{
	drawpic(pos, "gfx/alk_ibar.lmp", '448 24 0', '1 1 1', baralpha, 0);

	float i;
	vector offset;
	for (i = 0; i < 12; i++) {
		offset = '0 8 0';
		offset_x = i * 24;
		Hud_DrawWeapon(i, pos + offset);
	}
	

	Hud_DrawAmmoCount(0, pos + '10 0 0', FALSE);
	Hud_DrawAmmoCount(1, pos + '58 0 0', FALSE);
	Hud_DrawAmmoCount(2, pos + '106 0 0', FALSE);
	Hud_DrawAmmoCount(3, pos + '154 0 0', FALSE);

	if (st_items & IT_KEY1)
		drawpic(pos+'288 8 0', "sb_key1", '16 16 0', '1 1 1', 1, 0);
	if (st_items & IT_KEY2)
		drawpic(pos+'304 8 0', "sb_key2", '16 16 0', '1 1 1', 1, 0);

	if (st_items & IT_INVISIBILITY)
		drawpic(pos+'320 8 0', "sb_invis", '16 16 0', '1 1 1', 1, 0);
	if (st_items & IT_INVULNERABILITY)
		drawpic(pos+'336 8 0', "sb_invuln", '16 16 0', '1 1 1', 1, 0);
	if (st_items & IT_SUIT)
		drawpic(pos+'352 8 0', "sb_suit", '16 16 0', '1 1 1', 1, 0);
	if (st_items & IT_QUAD)
		drawpic(pos+'368 8 0', "sb_quad", '16 16 0', '1 1 1', 1, 0);
	if (st_items & IT_TRIFECTA)
		drawpic(pos+'384 8 0', "gfx/sb_trifecta.lmp", '16 16 0', '1 1 1', 1, 0);
	if (st_boots)
		drawpic(pos+'400 8 0', "gfx/sb_boots.lmp", '16 16 0', '1 1 1', 1, 0);

	if (st_items2 & 32)
		drawpic(pos+'416 8 0', "sb_sigil1", '8 16 0', '1 1 1', 1, 0);
	if (st_items2 & 64)
		drawpic(pos+'424 8 0', "sb_sigil2", '8 16 0', '1 1 1', 1, 0);
	if (st_items2 & 128)
		drawpic(pos+'432 8 0', "sb_sigil3", '8 16 0', '1 1 1', 1, 0);
	if (st_items2 & 256)
		drawpic(pos+'440 8 0', "sb_sigil4", '8 16 0', '1 1 1', 1, 0);
};

//======================================================================
// SCOREBOARD BARS
//
// - shows monster/secret quantities and map info
// - multiple setups for different hud layouts
//
//======================================================================
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


void(vector pos) Hud_DrawScoreBar_QSClock =
{
	local string skill_str, map_str;
	local float digit, skill_no;
	local float nsecs, nmins;
	
	// Clear status bar ready for map info/scores
	drawpic(pos, "gfx/alk_scorebar.lmp", [448, 24], '1 1 1', baralpha, 0);

	// Display headings
	

	drawstring(pos+[8,12], "Kills:", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
	Hud_DrawNoFont8(pos+[56,12], getstatf(STAT_KILLEDMONSTERS), 3, FALSE, HUDFONT_WHITE);
	drawstring(pos+[80,12], "/", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);	
	
	if (getstatf(STAT_TOTALMONSTERS) < 100) digit = 2;
	else digit = 3;

	Hud_DrawNoFont8(pos+[88,12], getstatf(STAT_TOTALMONSTERS), digit, FALSE, HUDFONT_WHITE);



	// Display monster/secret totals



	// Work out time passed
	//drawstring(pos+[112,12], "Time", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
	nmins = floor(time/60);
	nsecs = floor(time - nmins*60);
	Hud_DrawNoFont8(pos+[120,12], nmins, 3, FALSE, HUDFONT_WHITE);
	drawstring(pos+[144,12], ":", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);	
	Hud_DrawNoFont8(pos+[156,12], nsecs, 2, TRUE, HUDFONT_WHITE);



	drawstring(pos+[192,12], "Secrets:", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
	Hud_DrawNoFont8(pos+[256,12], getstatf(STAT_FOUNDSECRETS), 2, FALSE, HUDFONT_WHITE);
	drawstring(pos+[272,12], "/", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
	Hud_DrawNoFont8(pos+[280,12], getstatf(STAT_TOTALSECRETS), 2, FALSE, HUDFONT_WHITE);

	// Display map skill level
	skill_no = stof(autocvar(skill, "1"));
	if (skill_no == 0) skill_str = "Easy";
	else if (skill_no == 1) skill_str = "Normal";
	else if (skill_no == 2) skill_str = "Hard";
	else if (skill_no == 3) skill_str = "Nightmare";
	else skill_str = "Unknown";

	drawstring(pos+[320, 12], strcat(skill_str, " skill"), HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);

	// Level designers Map name + Skill level name
	map_str = strcat(world.message, " (", mapname, ")");
	Hud_ScrollTextBox(pos, 8, 4, 432, 8, 16, map_str);
};

void() Hud_Init
{
	float i;
	precache_pic("sbar", TRUE);
	for (i = 0; i < 10; i++)
	{
		precache_pic(number[i], TRUE);
		precache_pic(anumber[i], TRUE);
	}
};

nonstatic void Hud_Draw(float hudtype, float scoreboard, float width, float height)
{
	vector pos;
	float hudviewsize;
	float i;
	screensize_x = width;
	screensize_y = height;
	screensize_z = 0;

	prevweapons = st_weapons;

	pos_x = (screensize_x-448)/2;
	pos_y = screensize_y;

	//st_items = getstatbits(STAT_ITEMS, 0, 23);
	st_items = getstatf(STAT_IT);
	st_items2 = getstatbits(STAT_ITEMS, 23, 9);
	st_weapons = getstatf(STAT_WEAPONS);
	st_activeweapon = getstatf(STAT_ACTIVEWEAPON);
	st_boots = getstatf(STAT_BOOTS);
	st_boots_finished = getstatf(STAT_BOOTS_FINISHED);

	hudviewsize = cvar("viewsize");

	baralpha = cvar("scr_sbaralpha");
	if (baralpha == 0) baralpha = 0.333;
	// Default is 1 for everything else
	hudalpha = 1;

	for (i = 0; i < WPN_ICONS; i++) {
		if ((st_weapons & weaponflags[i]) && !(prevweapons & weaponflags[i]))
			weapontime[i] = time;
	}

	//if hudtype == 0 then the engine already drew it.

	
	if (scoreboard)
	{
		//Hud_CoopScores_SBar(pos - '0 24 0');
		Hud_DrawScoreBar_QSClock(pos - '0 24 ');
	}
	else
	{
		if (hudviewsize <= 110) Hud_DrawSBar(pos - '0 24 0');
	}
	if (hudviewsize <= 100) Hud_DrawIBar(pos - '0 48 0');
	
};
