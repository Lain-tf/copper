/*
==============================================================================

IMPULSES

==============================================================================
*/

// --------------------------------
// Cheat_Keys
// --------------------------------
void() Cheat_Keys =
{
	if(deathmatch || coop)
		return;

	key_give_silver(self);
	key_give_gold(self);
	stuffcmd(self,"bf\n");
}


// --------------------------------
// Cheat_Items
// --------------------------------
void() Cheat_Items =
{
	if(deathmatch || coop)
		return;

	self.ammo_shells = MAX_AMMO_SHELLS;
	self.ammo_nails = MAX_AMMO_NAILS;
	self.ammo_rockets = MAX_AMMO_ROCKETS;
	self.ammo_cells = MAX_AMMO_CELLS;
	
	self.items = self.items |
	//	IT_KEY1 | IT_KEY2 | 
		IT_AXE |
		IT_SHOTGUN |
		IT_SUPER_SHOTGUN |
		IT_NAILGUN |
		IT_SUPER_NAILGUN |
		IT_GRENADE_LAUNCHER |
		IT_ROCKET_LAUNCHER;

	self.items = self.items | IT_LIGHTNING;
	self.items2 = self.items2 | IT_QUAD_SHOTGUN | IT_RAILGUN; // IT_RIFLE excluded

	self.weapon = W_ROCKET_LAUNCHER;

	stuffcmd(self,"bf\n");
	W_ResetWeaponState();
}

void() Cheat_Rifle =
{
	if(deathmatch || coop)
		return;

	self.ammo_shells = MAX_AMMO_SHELLS;
	self.items2 = self.items2 | IT_RIFLE ;
	self.weapon = W_RIFLE;

	stuffcmd(self,"bf\n");
	W_ResetWeaponState();
}
// --------------------------------
// Cheat_Genocide
// --------------------------------
void() Cheat_Genocide =
{
	entity t;
	
	t = nextent(world);	
	while(t != world)
	{
		// these monsters haven't spawned yet, turn them into relays so their 
		// deathtargets fire as soon as they're triggered and their absence doesn't
		// break the level
		if(t.customflags & CFL_SPAWNER || t.spawnflags & SPAWN_TRIGGERED)
		{
			t.classname = "trigger_relay";
			t.count = 0;
			t.use = trigger_relay_use;
			t.spawnflags = 0;
		}
		t = nextent(t);
	}
	// kill existing monsters second, so that any monsters triggered by other monsters
	// are already de-monsterized
	t = nextent(world);
	while(t != world)
	{
		if(t.flags & FL_MONSTER)
		{
			// don't forget monsters on the verge of spawning
			if (t.think == mon_spawner_tryspawn || t.modelindex == 0 || t.classname == string_null )
				remove(t);
			else
				T_Damage(t, self, self, t.health);		// waurgh
		}
		t = nextent(t);
	}
}

// --------------------------------
// Cheat_Undying
// --------------------------------
void() Cheat_Undying =
{
	if(deathmatch || coop)
		return;
	if(self.customflags & CFL_UNDYING)
	{
		sprint(self, "Undying mode disabled\n");
		self.customflags = not(self.customflags, CFL_UNDYING);
		return;
	}
	sprint(self, "Undying mode enabled\n");
	self.customflags |= CFL_UNDYING;
}


// --------------------------------
// Cheat_Quad
// --------------------------------
void() Cheat_Quad =
{
	if(deathmatch || coop)
		return;
	stuffcmd(self, "bf\n");
	self.items = self.items | IT_QUAD;
	powerup_super_damage(self, 30);
}

// --------------------------------
// Cheat_Pent
// --------------------------------
void() Cheat_Pent =
{
	if(deathmatch || coop)
		return;
	stuffcmd(self, "bf\n");
	self.items = self.items | IT_INVULNERABILITY;
	powerup_invulnerability(self, 30);
}

// --------------------------------
// Cheat_Ring
// --------------------------------
void() Cheat_Ring =
{
	if(deathmatch || coop)
		return;
	stuffcmd(self, "bf\n");
	self.items = self.items | IT_INVISIBILITY;
	powerup_invisibility(self, 30);
}

// --------------------------------
// Cheat_Suit
// --------------------------------
void() Cheat_Suit =
{
	if(deathmatch || coop)
		return;
	stuffcmd(self, "bf\n");
	self.items = self.items | IT_SUIT;
	powerup_envirosuit(self, 30);
}

// --------------------------------
// Cheat_Haste
// --------------------------------
void() Cheat_Haste =
{
	if(deathmatch || coop)
		return;
	stuffcmd(self, "bf\n");
	self.items2 = self.items2 | IT_HASTE;
	powerup_haste(self, 20);
	self.changevcshift = 1; // apply tint on cheat command (vf)
}

// --------------------------------
// Cheat_Berserk
// --------------------------------
void() Cheat_Berserk =
{
	if(deathmatch || coop)
		return;
	stuffcmd(self, "bf\n");
	self.items2 = self.items2 | IT_BERSERK;
	powerup_berserk(self, 30);
	self.changevcshift = 1; // apply tint on cheat command (vf)
}

// --------------------------------
// Speedometer
// --------------------------------
void() Cheat_Speed =
{
	if (self.speedometer == 1)
		self.speedometer = 0;
	else if (self.speedometer == 0)
		self.speedometer = 1;
}

// --------------------------------
// Cheat_Wetsuit
// --------------------------------
void() Cheat_Wetsuit =
{
	if(deathmatch || coop)
		return;
	stuffcmd(self, "bf\n");
	self.items2 = self.items2 | IT_WETSUIT;
	powerup_wetsuit(self, 60);
}

// --------------------------------
// ImpulseCommands
// --------------------------------
void() ImpulseCommands =
{
	switch(self.impulse)
	{
	case 0:
		return;
	case 1: 	// axe bucket
	case 2: 	// rifle - sg
	case 3: 	// qsg - ssg
	case 4: 	// ng bucket
	case 5: 	// sng bucket
	case 6: 	// gl bucket
	case 7: 	// rl bucket
	case 8: 	// rail - lg
	//case 21:	//axe
	case 22:	//sg
	case 23:	//ssg
	//case 24:	//ng
	//case 25:	//sng
	//case 26:	//gl
	//case 27:	//rl
	case 28:	//lg
	//case 29:	//reserved
	//case 30:	//reserved
	//case 31:	//reserved for slot 1
	case 32:	//rifle
	case 33:	//qsg
	//case 34:	//reserved for slot 4
	//case 35:	//reserved for slot 5
	//case 36:	//reserved for slot 6
	//case 37:	//reserved for slot 7
	case 38:	// railgun
	//case 39:	//reserved
	//case 40:	//reserved 
	//41-50 reserved for the third weapon in a slot if we want them later
		if (!W_CanSwitchWeapon()) {
			// Return here so we don't clear the impulse, and the weapon will switch as soon
			// as possible to the last weapon that was selected.
			return;
		}

		W_ChangeWeapon();
		break;
	case 52:
		Cheat_Rifle();
		break;
	case 10:
		CycleWeaponCommand();
		break;
	case 12:
		CycleWeaponReverseCommand();
		break;
	/*
	Impulses from 20 to 50 are reserved for individual weapon selection, for now (vf)
	*/	
/*
	// ai_nav
	case 80:
		nav_toggleEditor();
		break;
	case 81:
		nav_nodeSizeUp();
		break;
	case 82:
		nav_nodeSizeDown();
		break;
	case 83:
		nav_createNode();
		break;
	case 84:
		nav_deleteNode();
		break;
	*/
	case 64:
		dev_i_cant_see();
		break;
	case 72:
		dev_test();
		break;
	case 80:
		dev_add_meatball();
		break;
	case 81:
		dev_remove_meatball();
		break;
	case 100:
		dev_invoke();
		break;
	case 101:
		dev_reveal();
		break;
	case 102:
		dev_trigger();
		break;
	case 103:
		dev_hitpoints();
		break;
	case 104:
		dev_serverflags();
		break;
	case 105:
		dev_warp();
		break;
	case 106:
		dev_whatami();
		break;
	case 108:
		dev_tracetest();
		break;
	case 127:
	case 129:
		coredump();
		break;
	
	case 140:
		sound(self, CHAN_VOICE, "player/tornoff2.wav", 1, ATTN_STATIC);
		centerprint(self, version_s);
		break;
	
	case 9:
		Cheat_Items();
		break;
	case 99:
		Cheat_Keys();
		break;
	case 185:
		Cheat_Wetsuit();
		break;
	case 195:
		Cheat_Haste();
		break;

	//Order 67 was probably to check the jedi were dead, right?
	case 67:
		dev_damageprinter();
		break;
	
	// how about, execute order six?
	// nah. makes it sound like there aren't that many orders
	case 66:
	
	case 205:
		if(!deathmatch && !coop)
			Cheat_Genocide();
		break;
	case 200:
		dev_remaining_monsters();
		break;
	case 210:
		toggle_autosave();
		break;
	case 215:
		Cheat_Undying();
		break;
	case 225: 
		Cheat_Suit();
		break;
	case 235:
		Cheat_Pent();	
		break;
	case 245:
		Cheat_Ring();	
		break;
	case 255:
		Cheat_Quad();	
		break;
	case 254:
		Cheat_Berserk();	
		break;
	case 236:
		Cheat_Speed();		
		break;
	default:
		return;
	}
	
	self.impulse = 0;
}
