void(float apilevel, string enginename, float engineversion) CSQC_Init = {

};

float(float save, float take, vector dir) CSQC_Parse_Damage = {
	painfinishtime = time + 0.2;
	return FALSE;
};

void(vector virtsize, float showscores) CSQC_DrawHud = {
	Hud_Draw(2, showscores, virtsize_x, virtsize_y);
};
/*
void(float vwidth, float vheight, float notmenu) CSQC_UpdateView =
{
	local vector ssize;
	ssize_x = vwidth; ssize_y = vheight; ssize_z = 0;

	clearscene();					//wipe entity lists. reset view properties to their defaults.
	//setviewprop(VF_DRAWENGINESBAR, 1);		//draw a status bar (or hud or whatever the engine normally does) around the screen.
	setviewprop(VF_DRAWCROSSHAIR, 1);		//draw a crosshair in the middle of the screen.
	//setviewprop(VF_ORIGIN, '0 0 0');		//view position of the scene (after view_ofs effects).
	//setviewprop(VF_ANGLES, '45 0 0');		//override the view angles. input will work as normal. other players will see your player as normal. your screen will just be pointing a different direction.
	//setviewprop(VF_DRAWWORLD, 1);			//whether the world entity should be drawn. set to 0 if you want a completely empty scene.
	setviewprop(VF_MIN, '0 0 0');			//top-left coord (x,y) of the scene viewport in virtual pixels (or annoying physical pixels in dp).
	setviewprop(VF_SIZE, [vwidth, vheight, 0]);	//virtual size (width,height) of the scene viewport in virtual pixels (or annoying physical pixels in dp).
	//setviewprop(VF_AFOV, cvar("fov"));		//note: fov_x and fov_y control individual axis. afov is general
	//setviewprop(VF_PERSPECTIVE, 1);		//1 means like quake and other 3d games. 0 means isometric.
	addentities((intermission?0:MASK_VIEWMODEL)|MASK_ENGINE);	//add various entities to the scene's lists.
	renderscene();

	CSQC_DrawHud(ssize, 0);
	//Hud_Draw(2, 0, vwidth, vheight);
};*/