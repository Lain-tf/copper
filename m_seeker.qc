/*
==============================================================================

HUNTER / SEEKER
almost entirely just adapted Enforcer/Fiend code by lun
otherwise by fw w/ help from snaut, khreathor and lun

==============================================================================
*/

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8
$frame stand9 stand10 stand11 stand12 stand13 stand14 stand15 stand16 stand17 // 0-16

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8
$frame walk9 walk10 walk11 walk12 // 17-28

$frame walkshot1 walkshot2 walkshot3 walkshot4 walkshot5 walkshot6 walkshot7 walkshot8
$frame walkshot9 walkshot10 walkshot11 //29-40

$frame run1 run2 run3 run4 run5 run6 run7 run8 //41-48

$frame dash1 dash2 dash3 dash4 dash5 dash6 dash7 dash8 //49-56

$frame shotdwn_bogus shotdwn //57-58

$frame shotup //59

$frame ded //60

void() seek_stand1	=[	$stand1,	seek_stand2] 	{ai_stand();}
void() seek_stand2	=[	$stand2,	seek_stand3] 	{ai_stand();}
void() seek_stand3	=[	$stand3,	seek_stand4] 	{ai_stand();}
void() seek_stand4	=[	$stand4,	seek_stand5] 	{ai_stand();}
void() seek_stand5	=[	$stand5,	seek_stand6] 	{ai_stand();}
void() seek_stand6	=[	$stand6,	seek_stand7] 	{ai_stand();}
void() seek_stand7	=[	$stand7,	seek_stand8] 	{ai_stand();}
void() seek_stand8	=[	$stand8,	seek_stand9] 	{ai_stand();}
void() seek_stand9	=[	$stand9,	seek_stand10] 	{ai_stand();}
void() seek_stand10	=[	$stand10,	seek_stand11]	{ai_stand();}
void() seek_stand11	=[	$stand11,	seek_stand12]	{ai_stand();}
void() seek_stand12	=[	$stand12,	seek_stand13]	{ai_stand();}
void() seek_stand13	=[	$stand13,	seek_stand14]	{ai_stand();}
void() seek_stand14	=[	$stand14,	seek_stand15]	{ai_stand();}
void() seek_stand15	=[	$stand15,	seek_stand16]	{ai_stand();}
void() seek_stand16	=[	$stand16,	seek_stand17]	{ai_stand();}
void() seek_stand17	=[	$stand16,	seek_stand1]	{ai_stand();}

void() seek_walk1	=[	$walk1,		seek_walk2 ] {ai_walk(10);}
void() seek_walk2	=[	$walk2,		seek_walk3 ] {ai_walk(9);}
void() seek_walk3	=[	$walk3,		seek_walk4 ] {ai_walk(9);}
void() seek_walk4	=[	$walk4,		seek_walk5 ] {ai_walk(5);}
void() seek_walk5	=[	$walk5,		seek_walk6 ] {ai_walk(6);}
void() seek_walk6	=[	$walk6,		seek_walk7 ] {ai_walk(12);}
void() seek_walk7	=[	$walk7,		seek_walk8 ] {ai_walk(8);}
void() seek_walk8	=[	$walk8,		seek_walk9 ] {ai_walk(3);}
void() seek_walk9	=[	$walk9,		seek_walk10] {ai_walk(13);}
void() seek_walk10	=[	$walk10,	seek_walk11] {ai_walk(9);}
void() seek_walk11	=[	$walk11,	seek_walk12] {ai_walk(7);}
void() seek_walk12	=[	$walk12,	seek_walk1] {ai_walk(9);}

void() seek_run1	=[	$walk1,		seek_run2 ] {ai_run(15);}
void() seek_run2	=[	$walk2,		seek_run3 ] {ai_run(15);}
void() seek_run3	=[	$walk3,		seek_run4 ] {ai_run(15);}
void() seek_run4	=[	$walk4,		seek_run5 ] {ai_run(15);}
void() seek_run5	=[	$walk5,		seek_run6 ] {ai_run(15);}
void() seek_run6	=[	$walk6,		seek_run7 ] {ai_run(15);}
void() seek_run7	=[	$walk7,		seek_run8 ] {ai_run(15);}
void() seek_run8	=[	$walk8,		seek_run9 ] {ai_run(15);}
void() seek_run9	=[	$walk9,		seek_run10] {ai_run(15);}
void() seek_run10	=[	$walk10,	seek_run11] {ai_run(15);}
void() seek_run11	=[	$walk11,	seek_run12] {ai_run(15);}
void() seek_run12	=[	$walk11,	seek_run1 ] {ai_run(15);}

//============================================================================

void() seek_death1      =[      $ded,       seek_death2     ] {}
void() seek_death2      =[      $ded,       seek_death3     ] {}
void() seek_death3      =[      $ded,       seek_death4     ] {}
void() seek_death4      =[      $ded,       seek_death5     ] {self.solid = SOLID_NOT;}
void() seek_death5      =[      $ded,       seek_death6     ] {}
void() seek_death6      =[      $ded,       seek_death7     ] {}
void() seek_death7      =[      $ded,       seek_death8     ] {}
void() seek_death8      =[      $ded,       seek_death9     ] {}
void() seek_death9      =[      $ded,       seek_death10    ] {}
void() seek_death10     =[      $ded,      seek_death11    ] {}
void() seek_death11     =[      $ded,      SUB_Null    ] 	{PostDeathLogic();}

void() seek_die =
{
	seek_death1();
}

//============================================================================

void() seek_preranged1      =[	$walkshot1,		seek_preranged2	] {ai_charge(10); }
void() seek_preranged2      =[	$walkshot2,		seek_preranged3	] {ai_charge(10); }
void() seek_preranged3      =[	$walkshot3,		seek_preranged4	] {ai_charge(10); }
void() seek_preranged4      =[	$walkshot4,		seek_preranged5	] {ai_charge(10); }
void() seek_preranged5      =[	$walkshot5,		seek_preranged6	] {ai_charge(10); }
void() seek_preranged6      =[	$walkshot6,		seek_preranged7	] {ai_charge(10); }
void() seek_preranged7      =[	$walkshot7,		seek_preranged8	] {ai_charge(10); }
void() seek_preranged8      =[	$walkshot8,		seek_preranged9	] {ai_charge(10); }
void() seek_preranged9      =[	$walkshot9,		seek_preranged10] {ai_charge(10); }
void() seek_preranged10	 	=[	$walkshot10,	seek_preranged11] {ai_charge(10); }
void() seek_preranged11     =[	$walkshot11,		seek_ranged1] {ai_charge(10); }

void() seek_ranged1      =[	$walkshot1,			seek_ranged2	] {ai_charge(10); seek_fire(FALSE);}
void() seek_ranged2      =[	$walkshot2,			seek_ranged3	] {ai_charge(10); seek_fire(TRUE); }
void() seek_ranged3      =[	$walkshot3,			seek_ranged4	] {ai_charge(10); seek_fire(FALSE);}
void() seek_ranged4      =[	$walkshot4,			seek_ranged5	] {ai_charge(10); seek_fire(FALSE);}
void() seek_ranged5      =[	$walkshot5,			seek_ranged6	] {ai_charge(10); seek_fire(TRUE); }
void() seek_ranged6      =[	$walkshot6,			seek_ranged7	] {ai_charge(10), seek_fire(FALSE);}
void() seek_ranged7      =[	$walkshot7,			seek_ranged8	] {ai_charge(10), seek_fire(FALSE);}
void() seek_ranged8      =[	$walkshot8,			seek_ranged9	] {ai_charge(10), seek_fire(TRUE); }
void() seek_ranged9      =[	$walkshot9,			seek_ranged10	] {ai_charge(10), seek_fire(FALSE);}
void() seek_ranged10	 =[	$walkshot10,		seek_ranged11	] {ai_charge(10), seek_fire(FALSE);}
void() seek_ranged11     =[	$walkshot11,		seek_run1		] {ai_charge(10), seek_fire(TRUE); seeker_endcheck();}

void() seek_shotdwn1     =[	$shotdwn,		seek_shotdwn2	] {ai_face(); seek_fire(FALSE);}
void() seek_shotdwn2     =[	$shotdwn,		seek_shotdwn3	] {ai_face(); seek_fire(TRUE); }
void() seek_shotdwn3     =[	$shotdwn,		seek_run1		] {ai_face(); seek_fire(FALSE); seeker_endcheck();}

void() seek_shotup1      =[	$shotup,		seek_shotup2	] {ai_face(); seek_fire(FALSE); dprint("1\n");}
void() seek_shotup2      =[	$shotup,		seek_shotup3	] {ai_face(); seek_fire(TRUE); dprint("2\n");}
void() seek_shotup3      =[	$shotup,		seek_run1		] {ai_face(); seek_fire(FALSE); seeker_endcheck();}

void() seeker_endcheck =
{
	if (!enemy_alive() || self.enemy.customflags & CFL_LIMBO )
		return;

	if (angledif(self.ideal_yaw, self.angles_y) > 40)	// player got behind us
		return;

	if ((self.enemy.origin_z - (self.origin_z + 16)) > 128)	 // player got above us
	{	
		seek_shotup1();
		dprint("\babove\b\n");
		return;
	}

	if ((self.enemy.origin_z - (self.origin_z + 16)) < -128)	// player got below us
	{	
		seek_shotdwn1();
		dprint("\bbelow\b\n");
		return;
	}

	if (has_invis(self.enemy) && random() > 0.80)
	{
		ai_attack_finished(0.25 + random()); // randomly break volley if player is being sneaky
		return;
	}

	if (!seek_clearranged())
	{
		ai_attack_finished(1 + random());	// force a little maneuvering if LOS is broken
		return;
	}
	
	self.think = seek_ranged1;
}

vector() seeker_gunpos =
{
	vector vec, left;
	vec = normalize(enemy_vispos() - self.origin);
	left = CrossProduct(vec, '0 0 -1');

	return (self.origin + vec * 22 + left * -25.37 + '0 0 32');
}

float() seek_clearranged =
{
	vector spot1, spot2;

	if (has_invis(self.enemy)) return TRUE;	// blast away

	spot1 = seeker_gunpos();
	spot2 = enemy_vispos() + self.enemy.view_ofs;

	traceline2(spot1, spot2, self, TRACE_WATER);

	//if (trace_inopen && trace_inwater) return FALSE;	// sight line crossed contents
	if (trace_ent != self.enemy) return FALSE;			// don't have a clear shot
	return TRUE;	
}

float() seek_checkranged =
{
	float chance;
	if (time < self.attack_finished) return FALSE;
	if (enemy_range >= RANGE_FAR) return FALSE;
	if (!seek_clearranged()) return FALSE;

	if (enemy_range == RANGE_MELEE)
	{
		chance = 0.9;
		self.attack_finished = 0;
	}
	else if (enemy_range == RANGE_NEAR)
		chance = 0.4;
	else if (enemy_range == RANGE_MID)
		chance = 0.2;
	else
		chance = 0;

	if (random() < chance)
	{
		self.th_missile ();
		ai_attack_finished (2*random());
		return TRUE;
	}

	return FALSE;
}

void(float vol_light) seek_fire =
{
	vector org, vec, rand;
	entity laser;

	sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);

	org = seeker_gunpos();
	rand = crandom();
	vec = normalize(enemy_vispos() - org + enemy_aim_vertical());
	
	makevectors(self.angles);	
	if (angledif(self.ideal_yaw, self.angles_y) > 80)	// no ass lasers
	{
		vec_x = v_forward_x;
		vec_y = v_forward_y;
		vec = normalize(vec);
	}
	
	vec = normalize(vec + v_right*crandom()*.02); 
	laser = launch_laser(org, vec * 1000); // different speed / spread for flavour
	if (!vol_light) //too many dlights, so we make only every 4th laser have one
	laser.effects = 0;
	laser.dmg = 10;
	
	vec = normalize(vec + v_right*crandom()*.1);
	laser = launch_laser(org, vec * 800);
	laser.effects = 0;
	laser.dmg = 10;
}

//============================================================================

void() monster_seeker_spawn =
{
	self.classname = "monster_seeker";
		
	self.solid = SOLID_SLIDEBOX;
	//self.movetype = MOVETYPE_STEP;
	setmodel (self, "progs/e3/mon_seeker.mdl");

	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);

	self.th_stand = seek_stand1;
	self.th_walk = seek_walk1;
	self.th_run = seek_run1;
	self.th_die = seek_die;
//	self.th_melee = ;
	self.th_missile = seek_preranged1;
//	self.th_pain = ;
	self.th_checkattack = seek_checkranged;

	if (self.deathtype == string_null)
		self.deathtype = "was smashed by a seeker";

	walkmonster_start();	
}

void() monster_seeker_spawner = {mon_spawner_use(monster_seeker_spawn);}

/*QUAKED monster_seeker (1 0 0) (-32 -32 -24) (32 32 64) AMBUSH ? ? ? TRIGGERED NOTFOG NOTELEFRAG INSTAWAKE
Seeker, 600 health points.

Flags:
"ambush" only wake up on seeing the player, not another monster getting angry

"Triggered"	will not spawn until triggered - triggering again will wake him up. Set 'count' to make this a multi-use spawner.
"NoTfog" 	supress teleport glitter when spawned with 'triggered'
"NoTelefrag" will silently fail to spawn if doing so would telefrag an existing monster. will try again automatically 2x/second until it succeeds.
"Instawake" spawn angry at activator

Keys:
"target" entity to trigger when killed
"targetname" entity name
"movedir" set to a velocity to make the monster jump on awakening
*/
/*FGD
@PointClass base(Monster) size(-32 -32 -24, 32 32 64) model({ "path": ":progs/e3/mon_seeker.mdl" }) = monster_seeker : "seeker" []
*/
void() monster_seeker =
{
	if (!SUB_ShouldSpawn()) return;
	if (nomonster()) return;
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/e3/mon_seeker.mdl");
	precache_model ("progs/laser.mdl");
	//precache_model ("progs/h_seeks.mdl");
	//precache_model ("progs/bolt.mdl");
	
	precache_sound ("weapons/spike2.wav");
	//precache_sound ("seeker/sboom.wav");
	//precache_sound ("seeker/sdeath.wav");
	//precache_sound ("seeker/shurt2.wav");
	//precache_sound ("seeker/sidle.wav");
	//precache_sound ("seeker/ssight.wav");
	//precache_sound ("seeker/melee1.wav");
	//precache_sound ("seeker/melee2.wav");
	//precache_sound ("seeker/smack.wav");

	self.health = 600;
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);

	if ( monster_spawnsetup( monster_seeker_spawner ) ) return;
	
	addmonster(1);
	monster_seeker_spawn();
}
