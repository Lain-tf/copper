/*
=============================================================================

	INFO_STORYCAMERA

developed for lunsp2 which will never come out

muchas gracias to sock for figuring out a lot of the slick presentation like 
screen tints

=============================================================================
*/



/*
============
centerprintlong

different engine ports impose various buffer length limits on the text
that centerprint() will accept, but SVC_CENTERPRINT is not so limited
============
*/
void(entity client, string s) centerprintlong =
{
	msg_entity = client;
	WriteByte(MSG_ONE, SVC_CENTERPRINT);
	WriteString(MSG_ONE, s);
}




/*
============
MooshPlayerIntoCamera

moosh the player into a camera
============
*/
void(entity who, entity cam) MooshPlayerIntoCamera
{
	// change screen tint right away after a page jump
	// FIXME: there's still a 1 frame jump between camera move and tint change
	if (!(cam.spawnflags & 1))
		TintScreen(who, cam.strength);
	
	who.angles = who.v_angle = cam.mangle;
	who.fixangle = TRUE;		// turn this way immediately
	who.wait = 0;				// stop shootin'
	setorigin (who, cam.origin);
	who.model = string_null;
	who.weaponmodel = string_null;

	centerprint(who, string_null);
	fog_setFromEnt(who, cam);
	stuffcmd(who,"+strafe\n");	// block camera view yanking in some engines

	who.nextthink = time + 0.6;
}


/*
============
StashClientInfoes

safely and reversibly convert a player into a view entity
============
*/
void(entity who) StashClientInfoes
{
	//bprint("stashing\n");
	who.view_ofs = '0 0 0';
	who.dest = who.velocity;
	who.velocity = '0 0 0';
	
	who.mangle = who.v_angle;
	who.oldorigin = who.origin;
	who.takedamage = DAMAGE_NO;
	who.solid = SOLID_NOT;
	
	who.movetype = MOVETYPE_NONE;
	who.jump_flag = who.flags;
	who.flags = not(who.flags | FL_NOTARGET, FL_ONGROUND);

	who.fog_color2 = who.fog_color;
	who.fog_density2 = who.fog_density;
	who.skyfog_density2 = who.skyfog_density;
	
	//HideCrosshair();
	ClearItemEffects(who);
}


/*
============
RestoreClientInfoes

convert a player in view entity mode back into a real boy
============
*/
void(entity who) RestoreClientInfoes
{
	//bprint("restoring\n");
	
	//who.modelindex = modelindex_player;
	setmodel(who,"progs/player.mdl");
	setorigin (who, who.oldorigin);
	who.view_ofs = '0 0 22';
	who.angles = who.v_angle = who.mangle;
	
	who.fixangle = TRUE;		// turn this way immediately
	who.takedamage = DAMAGE_AIM;
	who.solid = SOLID_SLIDEBOX;
	who.movetype = MOVETYPE_WALK;
	who.flags = who.jump_flag;
	if (!(who.flags & FL_ONGROUND)) who.velocity = who.dest;	// restore velocity if flying
	//who.flags = not(who.flags, FL_NOTARGET);
	
	//RestoreCrosshair();
	stuffcmd(who,"-strafe\n");
	RestoreItemEffects(who);
	fog_set(who, who.fog_density2, who.fog_color2);
	skyfog_set(who, who.skyfog_density2);
	who.nextthink = time;
	who.think = player_stand1;
}


/*
============
StoryCamera_FreezeMonsters
StoryCamera_UnfreezeMonsters

avoid that dumb thing where monsters attack the camera
============
*/
void() StoryCamera_FreezeMonsters =
{
	entity m = world;
	m = nextent(m);
	while (m != world)
	{
		if (m.flags & FL_MONSTER)
		{
			ai_freeze_monster(m);
		}
		m = nextent(m);
	}
}

void() StoryCamera_UnfreezeMonsters =
{
	entity m = world;
	m = nextent(m);
	while (m != world)
	{
		if (m.flags & FL_MONSTER)
			ai_unfreeze_monster(m);
		m = nextent(m);
	}
}


float() StoryCameraText =
{
	switch (storyCam.count)
	{
	case 0:
		centerprintlong( self, storyCam.message ); return (storyCam.message != string_null);
	case 1:
		centerprintlong( self, storyCam.noise ); return (storyCam.noise != string_null);
	case 2:
		centerprintlong( self, storyCam.noise1 ); return (storyCam.noise1 != string_null);
	case 3:
		centerprintlong( self, storyCam.noise2 ); return (storyCam.noise2 != string_null);
	case 4:
		centerprintlong( self, storyCam.noise3 ); return (storyCam.noise3 != string_null);
	case 5:
		centerprintlong( self, storyCam.noise4 ); return (storyCam.noise4 != string_null);
	default:
		centerprint( self, string_null ); return FALSE;
	}
}



/*
============
EndStory

text is done, user has clicked out, fade-in is done, so clean up everything
============
*/
void() EndStory =
{
	storyCam.count = 0;	// reset counter for reusable cams
	
	RestoreClientInfoes(self);
	StoryCamera_UnfreezeMonsters();
	storytime_running = FALSE;
	
	self.air_finished = time + 12;		// no gasping
	self.wait = 0;		// stop shootin'
	TintScreen(self,0);
	W_ResetWeaponState();
	
	SUB_UseEntTargets(storyCam);	// must be after restoreclientinfoes, if a target is a teleport_dest
	storyCam = world;
}


/*
============
AdvanceStory

user has clicked during a story camera, so skip to next state, next camera, or exit out
============
*/
void() AdvanceStory =
{	
	//bprint("advancing\n");
	if (storyCam.count == -1) return;
	
	if ( time > storyCamTime + storyCam.length )
	{
		// raise the count to advance the print to the next largest chunk
		storyCam.count += 1;
	}
	// let impatient players even skip the fades, to not waste any precious 
	// fragging time on dumb shit like "well-composed camera angles" or "words"
	else if (time > storyCamTime)
	{
		// skip the fadeout
		storyCamTime = time - storyCam.length;
		StoryCameraText();
		return;
	}
	else //if (time < storyCamTime)
	{
		// skip the fadein
		storyCamTime = time;
		EndStory();
		return;
	}
	
	// if there's no more text to add to this one
	if ( !StoryCameraText() )
	{
		if (storyCam.enemy)	// if there's a camera after this one, jump to it and start over
		{
			SUB_UseEntTargets(storyCam);
			storyCam.count = 0;	// reset counter for reusable cams
			storyCam = storyCam.enemy;
			MooshPlayerIntoCamera(self, storyCam);
		}
		else if (time >= storyCamTime)
		{
			// this signals playerCameraThink to bring the house lights back up
			storyCamTime = time + storyCam.length + 1;
		}
	}
}


/*
============
PlayerCameraPreThink

When the player presses attack or jump, advance the story
============
*/
void() PlayerCameraPreThink =
{
	//bprint("playercameraprethinking\n");
	if (self.movetype == MOVETYPE_NOCLIP)
		self.movetype = MOVETYPE_NONE;
	
	self.angles = self.v_angle = storyCam.mangle;
	self.fixangle = TRUE;		// turn this way immediately
	
	// wait is set to 1 if one of these buttons is down
	// if these buttons are up and wait is 1, it's a button release
	if (!self.button0 && !self.button1 && !self.button2) {
		if (self.wait) AdvanceStory ();
		self.wait = 0;
		return;
	}
	self.wait = 1;
}


/*
============
StoryCameraPlayerThink

Fade the screen in/out and spam centerprintlong() with text from story.qc

storyCamTime is a universal marker for camera timing:
- if it's in the future, we reduce the tint as it approaches to fade in
- if it's in the recent past, we increase the tint to fade out
- if it's longer ago than that, we're done fading out so spam text
============
*/
void() StoryCameraPlayerThink =
{
	float dim;
	self.think = StoryCameraPlayerThink;
	
	// fade interval is done, begin looping the text print to keep it on screen
	if ( time > storyCamTime + storyCam.length )
	{
		TintScreen(self, storyCam.strength);
		StoryCameraText();
		self.nextthink = self.nextthink + 1.9;
	}
	else
	{
		if ( time >= storyCamTime)
		{
			// storyCamTime is in the recent past, so we've just started a camera fade
			dim = lerpCosine(0,1,( time - storyCamTime ) / storyCam.length);
		}
		else// if ( time < storyCamTime )
		{
			// we've reached the end of the text and storyCamTime has been set 
			// in the future, so fade back in
			dim = lerpCosine(0,1,( storyCamTime - time - 1 ) / storyCam.length);
			// silly nonsense hack: the extra "- 1" is to provide a full 1-second window
			// where dim is 0 and the storycamera will end, or else we skip right over it 
			// and fade back out again when time goes above storyCamTime
			if ( dim <= 0 )
			{
				EndStory();
				return;
			}
		}
		TintScreen(self, storyCam.strength * dim );
		self.nextthink = time + (1/24);
	}
}


/*
============
StoryCameraUse
============
*/
void() StoryCameraUse =
{
	local float p;
		
	if (intermission_running) return;
	if (!(self.spawnflags & 1)) return;	// can only trigger first camera
	
	local entity who;
	
	who = find (world, classname, "player");
	while ( who )
	{
		if ( !(who.customflags & CFL_PLUNGE || who.health <= 0) )	// nobody dead or doomed
		{
			// save player's stuff
			StashClientInfoes(who);
			
			// move him to this camera
			storyCam = self;
			MooshPlayerIntoCamera(who, storyCam);
			
			// set his think to continually centerprint
			who.think = StoryCameraPlayerThink;
			who.nextthink = time;
			// a separate per-frame prethink checks for input to advance camera state
			
			p++;
		}
		who = find (who, classname, "player");
	}
	
	if (p == 0) return; // all players are (ie 'the player is') dead
	
	storytime_running = TRUE;
	storyCamTime = time;
	
	StoryCamera_FreezeMonsters();
}


/*
============
StoryCameraChain

storycameras can target other storycameras for multi-page stories. we use spawnflags
to inform each camera where it is in a chain because this used to be manual.

note: this makes story camera chains static. they can't be branched or have pages
added or skipped if you want a story that reacts to player choices (at least, not at
the entity control flow level).
TODO: figure all this out at storytime and not level start to fix the above
============
*/
void() StoryCameraChain =
{
	if (self.target == string_null)	return;
	
	local entity t;
	t = world;
	do	{
		t = find (t, targetname, self.target);
		if (!t) break;
		if (t.classname == "info_storycamera" ) {	// this camera leads to another, so
			t.spawnflags = not(t.spawnflags, 1);	// the next one isn't 'first'
			t.use = SUB_Null;
			self.spawnflags = not(self.spawnflags, 2);	// and the current one isn't 'last'
			self.enemy = t;
		}
	} while ( 1 );
}


// ================================================================


/*QUAKED info_storycamera (0 0.5 1) (-16 -16 -16) (16 16 16) 
Mid-mission intermission camera with story text.  When finished, deposits the player where he was previously, meaning you probably only want to fire this from a trigger_once.

"message" - set to first line of the text you want to print. subsequent blocks go in 'noise','noise1', etc. for the 'adding to the text on screen' effect, previous paragraphs must be duplicated in later ones.
"target" - set to anything you want to trigger when the player clicks out of the sequence.  this can be another camera with more text.
"mangle" - view angle. Pitch (positive down), yaw, roll. matches info_intermission.
"strength" - how dark to tint the screen during storytime, 1-255 (255 is fully black). default 160.
"length" - fade in/out time in seconds, default 1
*/
/*FGD
@PointClass base(Fog, Appearflags, Target, Targetname) = info_storycamera : "Story camera
Mid-mission intermission camera with story text. When finished, deposits the player where he was previously, meaning you probably only want to fire this from a trigger_once. Totally not coop compatible at all, in any way.

Target this entity at whatever you want to activate when the sequence is over. If targets include another storycamera, the screen tint will appropriately transition into the next camera. If the targets include an info_teleport_destination, player will be placed there instead of at their previous position." 
[
	mangle(string) : "Camera angle (Pitch Yaw Roll, positive pitch down)"
	message(string) : "Part 1 of lore dump (required)"
	noise(string) : "Part 2 of lore dump"
	noise1(string) : "Part 3 of lore dump"
	noise2(string) : "Part 4 of lore dump"
	noise3(string) : "Part 5 of lore dump"
	noise4(string) : "Part 6 of lore dump"
	strength(integer) : "Fade intensity, 1-255" : 160
	length(string) : "Fade time in seconds" : "1.0"
]
*/
void() info_storycamera =
{
	if (!SUB_ShouldSpawn()) return;
	if (self.message == string_null)
		objerror("info_storycamera has no message");

	if (!self.strength)
		self.strength = 160;

	self.use = StoryCameraUse;
	self.enemy = world;
	self.count = 0;
	if (!self.length)
		self.length = 1;
	
	self.spawnflags |= 3;	// set them all to 'first' and 'last' - StoryCameraChain will set them appropriately
	self.think = StoryCameraChain;
	self.nextthink = time + 0.1;	// link cameras together once they've all spawned
}

