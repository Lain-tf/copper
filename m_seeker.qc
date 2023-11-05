/*
==============================================================================

HUNTER / SEEKER
almost entirely just adapted Enforcer/Fiend code by lun
otherwise by fw w/ help from snaut, khreathor and lun

==============================================================================
*/

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8
$frame stand9 stand10 stand11 stand12 stand13 stand14 stand15 stand16 stand17 // 0-16

$frame seek_walk1 seek_walk2 seek_walk3 seek_walk4 seek_walk5 seek_walk6 seek_walk7 seek_walk8
$frame seek_walk9 seek_walk10 seek_walk11 seek_walk12 // 17-28

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

void() seek_walk1	=[	$seek_walk1,		seek_walk2 ] {ai_walk(10);}
void() seek_walk2	=[	$seek_walk2,		seek_walk3 ] {ai_walk(9);}
void() seek_walk3	=[	$seek_walk3,		seek_walk4 ] {ai_walk(9);}
void() seek_walk4	=[	$seek_walk4,		seek_walk5 ] {ai_walk(5);}
void() seek_walk5	=[	$seek_walk5,		seek_walk6 ] {ai_walk(6);}
void() seek_walk6	=[	$seek_walk6,		seek_walk7 ] {ai_walk(12);}
void() seek_walk7	=[	$seek_walk7,		seek_walk8 ] {ai_walk(8);}
void() seek_walk8	=[	$seek_walk8,		seek_walk9 ] {ai_walk(3);}
void() seek_walk9	=[	$seek_walk9,		seek_walk10] {ai_walk(13);}
void() seek_walk10	=[	$seek_walk10,	seek_walk11] {ai_walk(9);}
void() seek_walk11	=[	$seek_walk11,	seek_walk12] {ai_walk(7);}
void() seek_walk12	=[	$seek_walk12,	seek_walk1] {ai_walk(9);}

void() seek_run1	=[	$seek_walk1,		seek_run2 ] {ai_run(15);}
void() seek_run2	=[	$seek_walk2,		seek_run3 ] {ai_run(15);}
void() seek_run3	=[	$seek_walk3,		seek_run4 ] {ai_run(15);}
void() seek_run4	=[	$seek_walk4,		seek_run5 ] {ai_run(15);}
void() seek_run5	=[	$seek_walk5,		seek_run6 ] {ai_run(15);}
void() seek_run6	=[	$seek_walk6,		seek_run7 ] {ai_run(15);}
void() seek_run7	=[	$seek_walk7,		seek_run8 ] {ai_run(15);}
void() seek_run8	=[	$seek_walk8,		seek_run9 ] {ai_run(15);}
void() seek_run9	=[	$seek_walk9,		seek_run10] {ai_run(15);}
void() seek_run10	=[	$seek_walk10,	seek_run11] {ai_run(15);}
void() seek_run11	=[	$seek_walk11,	seek_run12] {ai_run(15);}
void() seek_run12	=[	$seek_walk11,	seek_run1 ] {ai_run(15);}

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

void() seek_preranged1   =[	$walkshot6,		seek_preranged2	] {ai_charge(10); self.width = 0;}
void() seek_preranged2   =[	$walkshot7,		seek_preranged3	] {ai_charge(10); }
void() seek_preranged3   =[	$walkshot8,		seek_preranged4	] {ai_charge(10); }
void() seek_preranged4   =[	$walkshot9,		seek_preranged5	] {ai_charge(10); }
void() seek_preranged5   =[	$walkshot10,	seek_preranged6	] {ai_charge(10); }
void() seek_preranged6   =[	$walkshot11,	seek_run1		] {ai_charge(10); seek_checkatk(); seeker_endfiringcheck();}

void() seek_ranged1      =[	$walkshot1,		seek_ranged2	] {ai_charge(10); seek_fire(FALSE); self.width = 0; seeker_midchk();}
void() seek_ranged2      =[	$walkshot2,		seek_ranged3	] {ai_charge(10); seek_fire(TRUE); seeker_midchk();}
void() seek_ranged3      =[	$walkshot3,		seek_ranged4	] {ai_charge(10); seek_fire(FALSE);seeker_midchk();}
void() seek_ranged4      =[	$walkshot4,		seek_ranged5	] {ai_charge(10); seek_fire(TRUE); seeker_midchk();}
void() seek_ranged5      =[	$walkshot5,		seek_ranged6	] {ai_charge(10); seek_fire(FALSE);seeker_midchk();}
void() seek_ranged6      =[	$walkshot6,		seek_ranged7	] {ai_charge(10), seek_fire(TRUE); seeker_midchk();}
void() seek_ranged7      =[	$walkshot7,		seek_ranged8	] {ai_charge(10); seek_fire(FALSE);seeker_midchk();}
void() seek_ranged8      =[	$walkshot8,		seek_ranged9	] {ai_charge(10), seek_fire(TRUE); seeker_midchk();}
void() seek_ranged9      =[	$walkshot9,		seek_ranged10	] {ai_charge(10); seek_fire(FALSE);seeker_midchk();}
void() seek_ranged10	 =[	$walkshot10,	seek_ranged11	] {ai_charge(10), seek_fire(TRUE); seeker_midchk();}
void() seek_ranged11     =[	$walkshot11,	seek_run1		] {ai_charge(10); seek_fire(FALSE); seek_checkatk(); seeker_endfiringcheck();}

void() seek_shotdwn1     =[	$shotdwn,		seek_shotdwn2	] {ai_face(); seek_fire(FALSE); self.width = 1;}
void() seek_shotdwn2     =[	$shotdwn,		seek_shotdwn3	] {ai_face(); seek_fire(TRUE); seeker_midchk();}
void() seek_shotdwn3     =[	$shotdwn,		seek_shotdwn4	] {ai_face(); seek_fire(FALSE);seeker_midchk();}
void() seek_shotdwn4     =[	$shotdwn,		seek_shotdwn5	] {ai_face(); seek_fire(TRUE);seeker_midchk();}
void() seek_shotdwn5     =[	$shotdwn,		seek_shotdwn6	] {ai_face(); seek_fire(FALSE);seeker_midchk();}
void() seek_shotdwn6     =[	$shotdwn,		seek_shotdwn7	] {ai_face(); seek_fire(TRUE); seeker_midchk();}
void() seek_shotdwn7     =[	$shotdwn,		seek_run1		] {ai_face(); seek_fire(FALSE); seek_checkatk(); seeker_endfiringcheck();}

void() seek_shotup1      =[	$shotup,		seek_shotup2	] {ai_face(); seek_fire(FALSE); self.width = 2;seeker_midchk();}
void() seek_shotup2      =[	$shotup,		seek_shotup3	] {ai_face(); seek_fire(TRUE); seeker_midchk();}
void() seek_shotup3      =[	$shotup,		seek_shotup4	] {ai_face(); seek_fire(FALSE);seeker_midchk();}
void() seek_shotup4      =[	$shotup,		seek_shotup5	] {ai_face(); seek_fire(TRUE); seeker_midchk();}
void() seek_shotup5      =[	$shotup,		seek_shotup6	] {ai_face(); seek_fire(FALSE);seeker_midchk();}
void() seek_shotup6      =[	$shotup,		seek_shotup7	] {ai_face(); seek_fire(TRUE); seeker_midchk();seeker_midchk();}
void() seek_shotup7      =[	$shotup,		seek_run1		] {ai_face(); seek_fire(FALSE); seek_checkatk(); seeker_endfiringcheck();}

void() seeker_endfiringcheck =
{
	if ((!alive(self.enemy)) || self.enemy.customflags & CFL_LIMBO )
		return;

	if (angledif(self.ideal_yaw, self.angles_y) > 40)	// player got behind us
		return;

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

	dprint(ftos(self.width));
	dprint("\n");

	if (self.height == 2)
		seek_shotup1();
	else if (self.height == 1)
		seek_shotdwn1();
	else if (self.height == 0)
		seek_ranged1();
}

void() seeker_midchk =
{
	if ((self.enemy.origin_z - (self.origin_z + 16)) > 128)	 // player is above us	
		self.height = 2;
	else if ((self.enemy.origin_z - (self.origin_z + 16)) < -128)	// player is below us	
		self.height = 1;
	else
		self.height =0;

	if ((self.height == 2) && (self.width != 2)) 
		seek_shotup1();
	else if ((self.height == 1) && (self.width != 1)) 
		seek_shotdwn1();
	else if ((self.height == 0) && (self.width != 0))
		seek_ranged1();

	self.height = self.height;
}

vector() seeker_gunpos =
{
	vector ang = vectoangles(enemy_vispos() - self.origin);
	ang_x = 0; //keeping this aligned to the floor
	makevectors(ang);

	if (self.height == 2)
		return self.origin + v_forward*42 - v_right*-18 + v_up*59; //up
	else if (self.height == 1)
		return self.origin + v_forward*44 - v_right*-21 + v_up*11; //down
	else
		return self.origin + v_forward*48 - v_right*-22 + v_up*33; //forward
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

float() seek_checkatk =
{
	float chance;
	if (time < self.attack_finished) return FALSE;
	if (enemy_range >= RANGE_FAR) return FALSE;
	if (!seek_clearranged()) return FALSE;

	if (enemy_range == RANGE_MELEE && z_overlap(self.enemy))
	{
		if (CanDamage (self.enemy, self.origin))
		{
			self.attack_state = AS_MELEE;
			return TRUE;
		}
	}

	if ((self.enemy.origin_z - (self.origin_z + 16)) > 128)	 // player is above us	
		self.height = 2;
	else if ((self.enemy.origin_z - (self.origin_z + 16)) < -128)	// player is below us	
		self.height = 1;
	else
		self.height =0;

		if (enemy_range == RANGE_NEAR)
			chance = 0.5;
		else if (enemy_range == RANGE_MID)
			chance = 0.3;
		else if (enemy_range == RANGE_FAR)
			chance = 0.2;
		else if (enemy_range == RANGE_TOOFAR)
			chance = 0;
		else if (enemy_range == RANGE_MELEE)
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
	laser = launch_laser(org, vec * 700); // different speed / spread for flavour
	if (!vol_light) //too many dlights, so we make only every 4th laser have one
	laser.effects = 0;
	laser.dmg = 4;
	
	vec = normalize(vec + v_right*crandom()*.1);
	laser = launch_laser(org, vec * 800);
	laser.effects = 0;
	laser.dmg = 4;
}

//============================================================================

void() seek_pain1	=[	$shotdwn,		seek_pain2	] {}
void() seek_pain2	=[	$shotup,		seek_pain3	] {}
void() seek_pain3	=[	$shotdwn,		seek_pain4	] {}
void() seek_pain4	=[	$shotdwn,		seek_pain5	] {}
void() seek_pain5	=[	$shotdwn,		seek_pain6	] {}
void() seek_pain6	=[	$shotdwn,		seek_pain7	] {}
void() seek_pain7	=[	$shotup,		seek_run1	] {}

	void(entity attacker, float damage) seek_pain =
	{
		if (self.health <= 0) return;
		if (self.pain_finished > time) return;
		if (random() < .9) return;
	
		//sound (self, CHAN_VOICE, "shalrath/pain.wav", ATTN_NORM);
		seek_pain1();
		
		PainFinished(4);
	}

//============================================================================

void() seek_melee1	=[	$dash1, seek_melee2 	] {ai_charge(8);}
void() seek_melee2	=[	$dash1, seek_melee3 	] {ai_charge(12);}
void() seek_melee3	=[	$dash3, seek_melee4 	] {ai_charge(12); } //sound (self, CHAN_VOICE, "brute/meleeswing.wav", ATTN_NORM);
void() seek_melee4	=[	$dash3, seek_melee5 	] {ai_charge(15); seek_punch();}
void() seek_melee5	=[	$dash3, seek_melee6 	] {ai_charge(8);}
void() seek_melee6	=[	$dash1, seek_melee7 	] {ai_charge(8);}
void() seek_melee7	=[	$dash1, seek_run1 		] {ai_charge(4); ai_attack_finished(1 + 1*random());}

void() seek_punch =
{
	local vector	delta;
	local float 	ldmg;

	if (!self.enemy)
		return;

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 100)
		return;
	if (!CanDamage (self.enemy, self.origin))
		return;
		
	//get the player off the ground so it launches them :D -fw
	if (self.enemy.flags & FL_ONGROUND){
		self.enemy.flags = self.enemy.flags - FL_ONGROUND;
		self.enemy.origin_z = self.enemy.origin_z + 10;
		self.enemy.velocity_z = self.enemy.velocity_z + 270;
	}
	
	ldmg = 60;
	T_Damage(self.enemy, self, self, ldmg, DMGTYPE_MELEE);
	sound (self, CHAN_VOICE, "shambler/smack.wav", 1, ATTN_NORM);

	SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);
	SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);
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
	self.th_melee = seek_melee1;
	self.th_missile = seek_preranged1;
	self.th_pain = seek_pain;
	self.th_checkattack = seek_checkatk;

	if (self.deathtype == string_null)
		self.deathtype = "was hammered/squished by a hunter/seeker";

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
	precache_model ("progs/e3/seeklaser.mdl");
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
