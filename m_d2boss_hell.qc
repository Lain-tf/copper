/*
==============================================================================

Ep. 2 Boss - Sculptor

==============================================================================
*/

// DEFENITIONS --
// COS FOR X
// SIN FOR Y
// 22.5 degree step - 16 projectiles in total
//                  0     1     2     3     4     5     6     7     8     9     10    11    12    13    14    15    16    17    18    19    20    21    22    23
float c16x[16] =  { 1.00, 0.92, 0.71, 0.38, 0.00,-0.38,-0.71,-0.92,-1.00,-0.92,-0.71,-0.38, 0.00, 0.38, 0.71, 0.92 };
float c16y[16] =  { 0.00, 0.38, 0.71, 0.92, 1.00, 0.92, 0.71, 0.38, 0.00,-0.38,-0.71,-0.92,-1.00,-0.92,-0.71,-0.38 };
// 15 degree step - 24 projectiles in total
//                  0     15    30    45    60    75    90    105   120   135   150   165   180   195   210   225   240   255   270   285   300   315   330   345
float c24Ax[24] = { 1.00, 0.97, 0.87, 0.71, 0.50, 0.26, 0.00,-0.26,-0.50,-0.71,-0.87,-0.97,-1.00,-0.97,-0.87,-0.71,-0.50,-0.26, 0.00, 0.26, 0.50, 0.71, 0.87, 0.97 };
float c24Ay[24] = { 0.00, 0.26, 0.50, 0.71, 0.87, 0.97, 1.00, 0.97, 0.87, 0.71, 0.50, 0.26, 0.00,-0.26,-0.50,-0.71,-0.87,-0.97,-1.00,-0.97,-0.87,-0.71,-0.50,-0.26 };
//                  7.5   22.5  37.5  52.5  67.5  82.5  97.5  112.5 127.5 142.5 157.5 172.5 187.5 202.5 217.5 232.5 247.5 262.5 277.5 292.5 307.5 322.5 337.5 352.5
float c24Bx[24] = { 0.99, 0.92, 0.79, 0.61, 0.38, 0.13,-0.13,-0.38,-0.61,-0.79,-0.92,-0.99,-0.99,-0.92,-0.79,-0.61,-0.38,-0.13, 0.13, 0.38, 0.61, 0.79, 0.92, 0.99 };
float c24By[24] = { 0.13, 0.38, 0.61, 0.79, 0.92, 0.99, 0.99, 0.92, 0.79, 0.61, 0.38, 0.13,-0.13,-0.38,-0.61,-0.79,-0.92,-0.99,-0.99,-0.92,-0.79,-0.61,-0.38,-0.13 };

// mix of A and B patterns will make a 48 directions circle
float c48x[48] = { 1.00, 0.99, 0.97, 0.92, 0.87, 0.79, 0.71, 0.61, 0.50, 0.38, 0.26, 0.13, 0.00,-0.13,-0.26,-0.38,-0.50,-0.61,-0.71,-0.79,-0.87,-0.92,-0.97,-0.99,
                  -1.00,-0.99,-0.97,-0.92,-0.87,-0.79,-0.71,-0.61,-0.50,-0.38,-0.26,-0.13, 0.00, 0.13, 0.26, 0.38, 0.50, 0.61, 0.71, 0.79, 0.87, 0.92, 0.97, 0.99 };
float c48y[48] = { 0.00, 0.13, 0.26, 0.38, 0.50, 0.61, 0.71, 0.79, 0.87, 0.92, 0.97, 0.99, 1.00, 0.99, 0.97, 0.92, 0.87, 0.79, 0.71, 0.61, 0.50, 0.38, 0.26, 0.13,
                   0.00,-0.13,-0.26,-0.38,-0.50,-0.61,-0.71,-0.79,-0.87,-0.92,-0.97,-0.99,-1.00,-0.99,-0.97,-0.92,-0.87,-0.79,-0.71,-0.61,-0.50,-0.38,-0.26,-0.13 };
//--------------------------------------------------
//defaults
float BULLET_FADETIME = 1.5;
float BULLET_SPEED = 200.0;
float BULLET_DAMAGE = 5;
float JUMPABLE_HEIGHT = 0;
float UNJUMPABLE_HEIGHT = 24;

float ONELINE_SPEED = 700.0;
float ONELINE_DAMAGE = 10;
float ONELINE_HEIGHT = 0;

float TWOLINES_SPEED = 800.0;
float TWOLINES_DAMAGE = 5;
float TWOLINES_HEIGHT = 0;

float CIRCLE_SPEED = 300;
float CIRCLE_DAMAGE = 5;
float CIRCLE_HEIGHT = 0;

float SPIRAL_SPEED = 200;
float SPIRAL_DAMAGE = 5;
float SPIRAL_HEIGHT = 0;

float WHEEL_SPEED = 100;
float WHEEL_DAMAGE = 2;
float WHEEL_HEIGHT = 0;

float PULSE_DAMAGE = 2;
float PULSE_HEIGHT = 0;

float NO_DELAY = 0.0;
//--------------------------------------------------
//eChildA used by Boss to target Director
//eChildA used by Director to target Program
//fUtilI used as progress indicator for Program
//fUtilF used by Boss to tell Programs and FireTasks to terminate ongoing tasks


//we don't use difficulty points, so this is obsolete
void() updatePlayersCount =
{
	local entity leEdict;
	local float lfCount;

	lfCount = 0;
	
	leEdict = find (world, classname, "player"); //start at world
	
	while (leEdict != world)
	{
		lfCount += 1;
		leEdict = find (leEdict, classname, "player"); //start at current entity, returns world if no more
	}	
	
	playerscount = lfCount;
	//dprint3("Players count:", ftos(playerscount), "\n");
};


//*****************************
// START BULLET HELL WITH DIRECTOR SPAWN
//*****************************
// spawnDirector();
// returns director as .eChildA field
// call this ONCE at the begining of the fight, don't call it on spawn it will not work properly

void() spawnDirector =
{
//SELF STATUS: d2 Boss
	local entity leDirector;
	local entity leHellEpicenter;
	
	leDirector = spawn ();
	leDirector.owner = self;
	leDirector.classname = "Director";
	leDirector.fUtilA = 0; // alternate circle patterns
	leDirector.fUtilI = 0; // program progress indicator
	
//boss entity should have link to an entity (.include) that would be used as bullet hell center point
	leHellEpicenter = find( world, targetname, self.include );
	
	if (leHellEpicenter == world)
	{
		setorigin( leDirector, '0 0 0' );
		dprint("Error: Can't find bullet hell origin point! (caller entity .include field)\n");
	}
	else
		setorigin( leDirector, leHellEpicenter.origin );
	
	//dprint("Director has been spawned \n");
	self.eChildA = leDirector; 
};


//*****************************
// TERMINATOR
//*****************************
// SUB_CallAsSelf(terminateAllTasks, self.eChildA);
// call this in the end of phase, this would stop all tasks on their next think

void() terminateAllTasks =
{
//SELF STATUS: Director

	self.fUtilF = 1;
};


//*****************************
// BULLET HELL PROGRAM INITIALIZATION
//*****************************
// SUB_CallAsSelf(initiateProgram, self.eChildA);
// in case you wanna use this way of scripting patterns instead

void() initiateProgram =
{
//SELF STATUS: Director
	local float lfChoice;
	
	self.fUtilF = 0; // allow repeating tasks
	self.fUtilI = 0; // reset progress
	lfChoice = rint( random() * 2 );
	
	switch (lfChoice)
	{
		case 0:
			self.think = runProgramA;
			self.nextthink = time + 0.1;
			break;
		case 1:
			self.think = runProgramA;
			self.nextthink = time + 0.1;
			break;
		case 2:
			self.think = runProgramA;
			self.nextthink = time + 0.1;
			break;
	}	
};


void(void() pmMethod, float pfDelay ) continueProgram =
{
//SELF STATUS: Director

	if (self.fUtilF) //termination marker
	{
		self.fUtilI = 0;
		self.think = SUB_Null;
		self.nextthink = -1;
		return;
	}
	else
	{
		self.nextthink = time + pfDelay;
		self.think = pmMethod;
		self.fUtilI++;
	}
};


void() runProgramA =
{
//SELF STATUS: Director
	
	if (self.fUtilF) //termination marker
	{
		self.fUtilI = 0;
		self.think = SUB_Null;
		self.nextthink = -1;
		return;
	}
	else
	{
		switch (self.fUtilI) //progress
		{
			case 0:
				continueProgram(runProgramA, 1.0);
				break;
			case 1:
				startOneLine(1, 10, 0.1, NO_DELAY);
				continueProgram(runProgramA, 1.5);
				break;
			case 2:
				startTwoLines(0, 10, 15, 0.1, NO_DELAY);
				continueProgram(runProgramA, 1.5);
				break;
			case 3:
				startCircle( 0 , 24, 2, 1, 1, BULLET_FADETIME, NO_DELAY);
				startCircle( 0 , 12, 1, 0, 1, BULLET_FADETIME, 2.5);
				startCircle( 12, 24, 1, 0, 1, BULLET_FADETIME, 3.0);
				startCircle( 0 , 12, 1, 0, 1, BULLET_FADETIME, 3.5);
				startCircle( 12, 24, 1, 0, 1, BULLET_FADETIME, 4.0);
				continueProgram(runProgramA, 4);
				break;
			case 4:
				startSpiral(0, 24, 1, 0.05, BULLET_FADETIME, NO_DELAY);
				startSpiral(24, 0, 0, 0.05, BULLET_FADETIME, NO_DELAY);
				continueProgram(runProgramA, 2);
				break;
			case 5:
				startSpiral(24, 48, 1, 0.05, BULLET_FADETIME, NO_DELAY);
				startSpiral( 0, 24, 1, 0.05, BULLET_FADETIME, NO_DELAY);
				continueProgram(runProgramA, 2);
				break;
			case 6:
				startSpiral(  0, 48, 1, 0.05, 0, NO_DELAY);
				startSpiral(  8,  7, 1, 0.05, 0, NO_DELAY);
				startSpiral( 16, 15, 1, 0.05, 0, NO_DELAY);
				startSpiral( 24, 23, 1, 0.05, 0, NO_DELAY);
				startSpiral( 32, 31, 1, 0.05, 0, NO_DELAY);
				startSpiral( 40, 39, 1, 0.05, 0, NO_DELAY);
				continueProgram(runProgramA, 4);
				break;
			case 7:
				startMovingWheel([crandom()*1000, crandom()*1000, self.origin_z],  0.5,  6, NO_DELAY);
				startMovingWheel([crandom()*1000, crandom()*1000, self.origin_z], 0.75,  8, 1);
				startMovingWheel([crandom()*1000, crandom()*1000, self.origin_z],  1.0, 10, 2);
			//end of program, loop
				self.fUtilI = 0; //reset progress
				continueProgram(runProgramA, 3);
				break;
		}
	}
};

void() runProgramB =
{
//SELF STATUS: Director
	
};

void() runProgramC =
{
//SELF STATUS: Director
	
};


//*****************************
// Choose and start random task
//*****************************
// SUB_CallAsSelf(chooseRandomTask, self.eChildA);
// simply call a random task
void() chooseRandomTask =
{
//SELF STATUS: Director
	local float lfChoice;
	
	self.fUtilF = 0; //allow repeating tasks
	
	lfChoice = rint( random() * 6 );
	//lfChoice = 6;
	switch (lfChoice)
	{
		case 0:
		// Follow player (0/1); Shots count; firerate (time bitween shots); execute after some delay
			startOneLine(1, 10, 0.1, NO_DELAY);
			break;
		case 1:
		// Follow player (0/1); how wide V shape gonna be; Shots count(for both); firerate (time bitween shots); execute after some delay
			startTwoLines(0, 10, 15, 0.1, NO_DELAY);
			break;
		case 2:
		// Start; End position on a circle: [0-24, be aware!]; repeat count(at least 1); repeat cycle; 
		// alternate between two patterns or not (slight shift in coordinates);
		// Time after which projectile gonna fade (fade itself takes like 0.3-0.5 sec); execute after some delay
			startCircle( 0 , 24, 1, 0.1, 1, BULLET_FADETIME, NO_DELAY);
			break;
		case 3:
		// Start; End position on a circle: [0-48, be aware!]; clockwise or not (1/0); fade time as above; execute after some delay
			startSpiral(0, 48, 1, 0.05, BULLET_FADETIME, NO_DELAY);
			startSpiral(0, 48, 1, 0.05, BULLET_FADETIME, 2.4);
			break;
		case 4:
		// direction; time when projectiles start to spin, basically corresponds with radius; time to fade; execute after some delay  
			startMovingWheel([crandom()*1000, crandom()*1000, self.origin_z], 1.0, 8, NO_DELAY);
			break;
		case 5:
			startRocketBarrage(NO_DELAY);
			break;
		case 6:
		//float pfMinRadius, float pfMaxRadius, float pfIdleAtMin, float pfIdleAtMax, float pfSpeed, float pfPulses, float pfDelay
			startPulse(64, 320, 0.5, 0.5, 640, 2, NO_DELAY);
			break;
	}
};


//  *  FIRE TASKS  *  FIRE TASKS  *  FIRE TASKS  *  FIRE TASKS  *  FIRE TASKS  *  FIRE TASKS  *  FIRE TASKS  *  FIRE TASKS  *  

//*****************************
// ONE LINE
//*****************************
void(float pfFollowTarget, float pfShotsCount, float pfCycleTime, float pfDelay) startOneLine =
{
//SELF STATUS: Director
	local entity leEdict;
	local entity leTask;
	
	leEdict = find (world, classname, "player"); //start at world
	
	while (leEdict != world)
	{
		if (leEdict.deadflag >= DEAD_DYING)
		{
			leEdict = find (leEdict, classname, "player"); //skip dead player
		}
		else
		{
			leTask = spawn();
			leTask.owner = self;
			setorigin( leTask, [self.origin_x, self.origin_y, self.origin_z + ONELINE_HEIGHT] );
			leTask.classname = "firetask";
			leTask.type = "oneline";
			
		// we will not follow player, so store it's position for further use
			if (!(pfFollowTarget))
				leTask.vUtilA = leEdict.origin;
			
			leTask.fUtilA = pfFollowTarget;
			leTask.fUtilB = pfShotsCount;
			leTask.fUtilC = pfCycleTime;
			leTask.enemy = leEdict;
			leTask.speed = ONELINE_SPEED;
			leTask.dmg = ONELINE_DAMAGE;
			
			leTask.think = repeatOneLine;
			leTask.nextthink = time + pfDelay;

			leEdict = find (leEdict, classname, "player"); //start at current entity, returns world if no more
		}
	}	
};

void() repeatOneLine =
{
//SELF STATUS: Fire Task
	
	if ( self.fUtilB < 1 || self.owner.fUtilF) //no more shots or termination marker
	{	
		self.think = SUB_Remove;
		self.nextthink = time + 0.1;
	}
	else
	{
		if (self.fUtilA)
			setupProjectile(self.origin, self.enemy.origin, BULLET_FADETIME); //update
		else
			setupProjectile(self.origin, self.vUtilA, BULLET_FADETIME); //use old position
		
		self.fUtilB--;
		self.think = repeatOneLine;
		self.nextthink = time + self.fUtilC;
	}
};


//*****************************
// TWO LINES IN V SHAPE
//*****************************
void(float pfFollowTarget, float pfShotsCount, float pfAngle, float pfCycleTime, float pfDelay) startTwoLines =
{
//SELF STATUS: Director
	local entity leEdict;
	local entity leTask;
	
	leEdict = find (world, classname, "player"); //start at world
	
	while (leEdict != world)
	{
		if (leEdict.deadflag >= DEAD_DYING)
		{
			leEdict = find (leEdict, classname, "player"); //skip dead player
		}
		else
		{
			leTask = spawn();
			leTask.owner = self;
			setorigin( leTask, [self.origin_x, self.origin_y, self.origin_z + TWOLINES_HEIGHT] );
			leTask.classname = "firetask";
			leTask.type = "twolines";
		// we will not follow player, so store it's position for further use
			if (!(pfFollowTarget))
				leTask.vUtilA = leEdict.origin;
			
			leTask.fUtilA = pfFollowTarget;
			leTask.fUtilB = pfShotsCount;
			leTask.fUtilC = pfCycleTime;
			leTask.fUtilD = pfAngle;
			leTask.enemy = leEdict;
			leTask.speed = TWOLINES_SPEED;
			leTask.dmg = TWOLINES_DAMAGE;
			
			leTask.think = repeatTwoLines;
			leTask.nextthink = time + pfDelay;

			leEdict = find (leEdict, classname, "player"); //start at current entity, returns world if no more
		}
	}
};

void() repeatTwoLines =
{
//SELF STATUS: Fire Task
	local vector lvDestination;
	local float lfYaw;
	local vector lvAngles;

	if ( self.fUtilB < 1 || self.owner.fUtilF) //no more shots or termination marker
	{
		self.think = SUB_Remove;
		self.nextthink = time + 0.1;
	}
	else
	{
		if (self.fUtilA)
			lvDestination = self.enemy.origin;
		else
			lvDestination = self.vUtilA;
		
		lfYaw = vectoyaw(lvDestination - self.origin);
		lvAngles = [0, lfYaw, 0];
		makevectors (lvAngles);
		
		setupProjectile(self.origin, self.origin + v_forward * 100 + v_right * self.fUtilD, BULLET_FADETIME); 
		setupProjectile(self.origin, self.origin + v_forward * 100 - v_right * self.fUtilD, BULLET_FADETIME); 
		
		self.fUtilB--;
		self.think = repeatTwoLines;
		self.nextthink = time + self.fUtilC;
	}
};


//*****************************
// CIRCLE
//*****************************
void(float pfStartPosition, float pfEndPosition, float pfRepeatCount, float pfCycleTime, float pfAlternate, float pfFadeTime, float pfDelay ) startCircle =
{
//SELF STATUS: Director
	local entity leTask;
	
	leTask = spawn();
	leTask.owner = self;
	setorigin( leTask, [self.origin_x, self.origin_y, self.origin_z + CIRCLE_HEIGHT] );
	leTask.classname = "firetask";
	leTask.type = "circle";
	leTask.fUtilA = pfStartPosition;
	leTask.fUtilB = pfEndPosition;
	leTask.fUtilC = pfCycleTime;
	leTask.fUtilD = pfRepeatCount;
	leTask.fUtilG = pfAlternate;
	leTask.fUtilH = pfFadeTime;
	leTask.speed = CIRCLE_SPEED;
	leTask.dmg = CIRCLE_DAMAGE;
	
	leTask.think = repeatCircle;
	leTask.nextthink = time + pfDelay;
};

void() repeatCircle =
{
//SELF STATUS: Fire Task
	local float i;
	local vector lvOffset;

	if ( self.fUtilD < 1 || self.owner.fUtilF) //no more shots or termination marker
	{
		self.think = SUB_Remove;
		self.nextthink = time + 0.1;
	}
	else
	{
		for ( i = self.fUtilA; i != self.fUtilB; i++ ) 
		{
			if (i == 24)
				i = 0;
			
			if (self.owner.fUtilA) //circles alternation
			{
				lvOffset_x = self.origin_x + c24Ax[i] * 100;
				lvOffset_y = self.origin_y + c24Ay[i] * 100;
			}
			else
			{
				lvOffset_x = self.origin_x + c24Bx[i] * 100;
				lvOffset_y = self.origin_y + c24By[i] * 100;
			}
			//lvOffset_z = self.origin_z;
			setupProjectile(self.origin, lvOffset, self.fUtilH);
		}
		
		if (self.fUtilG)
			self.owner.fUtilA = !(self.owner.fUtilA);//circles alternation
		
		self.fUtilD--;
		self.think = repeatCircle;
		self.nextthink = time + self.fUtilC;
	}
};


//*****************************
// SPIRAL
//*****************************
void(float pfStartPosition, float pfEndPosition, float pfClockwise, float pfCycleTime, float pfFadeTime, float pfDelay) startSpiral =
{
//SELF STATUS: Director
	local entity leTask;
	
	leTask = spawn();
	leTask.owner = self;
	setorigin( leTask, [self.origin_x, self.origin_y, self.origin_z + SPIRAL_HEIGHT] );
	leTask.classname = "firetask";
	leTask.type = "spiral";
	leTask.fUtilA = pfStartPosition;
	leTask.fUtilB = pfEndPosition;
	leTask.fUtilC = pfCycleTime;
	leTask.fUtilE = pfClockwise;
	leTask.fUtilG = pfStartPosition; // current position
	leTask.fUtilH = pfFadeTime;
	leTask.speed = SPIRAL_SPEED;
	leTask.dmg = SPIRAL_DAMAGE;
	
	if (pfClockwise)
	{
		if (pfStartPosition > pfEndPosition)
			leTask.fUtilD = (48 - pfStartPosition) + pfEndPosition;
		else
			leTask.fUtilD = pfEndPosition - pfStartPosition;
	}
	else
	{
		if (pfStartPosition < pfEndPosition)
			leTask.fUtilD = pfStartPosition + (48 - pfEndPosition);
		else
			leTask.fUtilD = pfStartPosition - pfEndPosition;
	}
	//leTask.fUtilD++; //do we want to? 
	
	leTask.think = repeatSpiral;
	leTask.nextthink = time + pfDelay;
};

void() repeatSpiral =
{
//SELF STATUS: Fire Task
	local vector lvOffset;
	
	if ( self.fUtilD < 1 || self.owner.fUtilF) //no more shots or termination marker
	{
		self.think = SUB_Remove;
		self.nextthink = time + 0.1;
	}
	else
	{
		lvOffset_x = self.origin_x + c48x[self.fUtilG] * 100;
		lvOffset_y = self.origin_y + c48y[self.fUtilG] * 100;
		setupProjectile(self.origin, lvOffset, self.fUtilH);
		
		self.fUtilD--;
		
		if (self.fUtilE)
		{
		//clockwise
			self.fUtilG++;
			if (self.fUtilG == 48)
				self.fUtilG = 0;
		}
		else
		{
		//counter clockwise
			self.fUtilG--;
			if (self.fUtilG == -1)
				self.fUtilG = 47;
		}
		
		self.think = repeatSpiral;
		self.nextthink = time + self.fUtilC;
	}
};


//*****************************
// MOVING WHEEL
//*****************************
void(vector pvDirection, float pfCircleSize, float pfFadeTime, float pfDelay) startMovingWheel =
{
//SELF STATUS: Director
	local entity leTask;
	
	leTask = spawn();
	leTask.owner = self;
	setorigin( leTask, [self.origin_x, self.origin_y, self.origin_z + WHEEL_HEIGHT] );
	leTask.classname = "firetask";
	leTask.type = "wheel";
	leTask.vUtilA = pvDirection;
	leTask.fUtilA = pfCircleSize;
	leTask.fUtilH = pfFadeTime;
	
	leTask.think = repeatMovingWheel;
	leTask.nextthink = time + pfDelay;
};

void() repeatMovingWheel =
{
//SELF STATUS: Fire Task
	local entity leLeader;
	
	leLeader = returnProjectile(self.origin, self.vUtilA);
	leLeader.fUtilA = self.fUtilA;
	leLeader.fUtilH = time + self.fUtilH;
	leLeader.think = deploySatelites;
	leLeader.nextthink = time + 0.5;
};

void() startSpin =
{
//SELF STATUS: Satelite	
	local vector lvOffset;
	local float lfLength;
	
	if (self.fUtilH < time)
	{
		fadeSatelite();
		if (self.fUtilF)
		{
			self.think = SUB_Remove;
			self.nextthink = time + 0.1;
			return;
		}
	}
	
	if (!(self.fUtilC)) //do all this shit only once
	{
		setmodel ( self, "progs/e2/hell_rocket.mdl" );
		setsize  ( self, '0 0 0', '0 0 0' );	//set after model, so we don't have this cringe box size
		self.solid = SOLID_BBOX;
		self.touch = simpleTouch;
		self.fUtilC = 1;
	}
	
	lfLength = vlen(self.owner.origin - self.origin);
	lvOffset_x = self.owner.origin_x + c16x[self.fUtilI] * lfLength;
	lvOffset_y = self.owner.origin_y + c16y[self.fUtilI] * lfLength;

	lfLength = vlen(lvOffset - self.origin); // radius (distance to Leader)
	self.velocity = normalize(lvOffset - self.origin) * lfLength * 10; // 10 times the speed result in 1/x = 0.1 second to reach goal position
	self.velocity_z = 0;
	self.angles = vectoangles(self.velocity);
	self.velocity += self.owner.velocity; //keep leader momentum
	
	self.fUtilI += 1;
	
	if (self.fUtilI > 15)
		self.fUtilI = 0;
	
	self.think = startSpin;
	self.nextthink = time + 0.1; // 1/speed
};

void() deploySatelites =
{
//SELF STATUS: Leader
	local vector lvOffset;
	local entity leSatelite;
	local float i;
	
		for ( i = 0; i < 16; i++ ) 
		{
			lvOffset_x = self.origin_x + c16x[i] * 100;
			lvOffset_y = self.origin_y + c16y[i] * 100;
			lvOffset_z = self.origin_z;

			leSatelite = returnProjectile(self.origin, lvOffset);
			
		// keep it being invisible and nonsolid until it start to spin
			//setmodel ( leSatelite, "progs/e2/hell_rocket.mdl" );
			//setsize  ( leSatelite, '0 0 0', '0 0 0' ); //set after model, so we don't have this cringe box size
			//leSatelite.solid = SOLID_BBOX;
			//leSatelite.touch = simpleTouch;
			leSatelite.owner = self;
			leSatelite.movetype = MOVETYPE_FLYMISSILE;
			leSatelite.angles = vectoangles(leSatelite.velocity);
			leSatelite.velocity += self.velocity;
			leSatelite.fUtilI = i + 1;
			leSatelite.fUtilH = self.fUtilH;
			
			if (leSatelite.fUtilI > 15)
				leSatelite.fUtilI = 0;
			leSatelite.think = startSpin;
			leSatelite.nextthink = time + self.fUtilA;
		}
	self.think = SUB_Remove;
	self.nextthink = self.fUtilH + 1;
};


//*****************************
// ROCKET BARRAGE
//*****************************
void(float pfDelay) startRocketBarrage =
{
//SELF STATUS: Director
};

void() repeatRocketBarrage =
{
	
};


//*****************************
// CIRCLE PULSE
//*****************************
void(float pfMinRadius, float pfMaxRadius, float pfIdleAtMin, float pfIdleAtMax, float pfSpeed, float pfPulses, float pfDelay) startPulse =
{
//SELF STATUS: Director
	local float i;
	local entity leSector;
	local entity leTask;
	local vector lvOffset;
	
	leTask = spawn();
	leTask.classname = "firetask";
	leTask.type = "pulse";
	setorigin( leTask, [self.origin_x, self.origin_y, self.origin_z + PULSE_HEIGHT] );
	leTask.think = doPulseDamage;
	leTask.nextthink = time + pfDelay + 0.3; //do not do damage while fading in time
	
	for ( i = 0; i < 24; i++ ) 
	{
		leSector = spawn();
		leSector.owner = leSector.trueowner = leTask; 
		leSector.classname = "sector";
		leSector.fUtilA = pfMinRadius;
		leSector.fUtilB = pfMaxRadius;
		leSector.fUtilH = (pfMaxRadius - pfMinRadius) / pfSpeed; //time on the move
		leSector.fUtilC = pfIdleAtMin;
		leSector.fUtilD = pfIdleAtMax;
		leSector.fUtilE = pfPulses;
		leSector.fUtilG = time; //current idle timer
		leSector.fUtilI = 1; //current state: 1 - idle at min, 2 - move to max, 3 - idle at max, 4 - move to min, 5 - end of line\reset, 0 - fadeout
		leSector.speed = pfSpeed;
		leSector.movetype = MOVETYPE_NOCLIP;
		leSector.solid = SOLID_NOT;
		lvOffset_x = leTask.origin_x + c24Ax[i] * pfMinRadius;
		lvOffset_y = leTask.origin_y + c24Ay[i] * pfMinRadius;
		lvOffset_z = leTask.origin_z;
		setorigin( leSector, lvOffset );
		setmodel ( leSector, "progs/e2/hell_bullet.mdl" ); // replace with special sector model
		setsize  ( leSector, '0 0 0', '0 0 0' );	
		leSector.vUtilA = normalize (lvOffset - leTask.origin) * pfSpeed; //save velocity
		leSector.vUtilA_z = 0;
		leSector.angles = vectoangles(leSector.vUtilA);
		leSector.think = fadePulseIn;
		leSector.nextthink = time + pfDelay;
		leSector.cnt = 0; //fade steps
		leSector.alpha = 0.01;
		
		if (i == 0) 
			leTask.eChildA = leSector;
	}
};

void() doPulseDamage =
{	
//SELF STATUS: Fire Task
	local float lfLength, lfLength2;
	local entity leVictim;
	
	lfLength = vlen(self.eChildA.origin - self.origin); //distance from epicenter to pulse projectile
	leVictim = findradius(self.origin, lfLength);
	
	while (leVictim)
	{
		if (leVictim.classname == "player" || leVictim.flags & FL_MONSTER)
		{
			lfLength2 = vlen(self.origin - leVictim.origin); // distance from epicenter to monster/player
			if (((leVictim.origin_z + leVictim.absmin_z) < self.origin_z) && ((leVictim.origin_z + leVictim.absmax_z) > self.origin_z)) //height check
			{
				if (fabs(lfLength - lfLength2) < 17) // width check
					T_Damage(leVictim, self, self.owner, PULSE_DAMAGE);
			}
		}    
		leVictim = leVictim.chain;
	}
	self.think = doPulseDamage;
	self.nextthink = time + 0.01;
};

void() fadePulseIn =
{
//SELF STATUS: Sector
	self.think = fadePulseIn;
	self.nextthink = time + 0.1;
	self.cnt = self.cnt + 1;
	
	if (self.cnt < 4) 
		self.alpha = self.cnt * 0.3;
	else
	{
		self.alpha = 1;
		self.think = idlePulse;
	}	
};

void() idlePulse =
{
//SELF STATUS: Sector
	if (self.fUtilI == 1 )
	{
		self.fUtilI = 2; // move to max
		self.velocity = '0 0 0';
		self.think = movePulse;
		self.nextthink = time + self.fUtilC;
	}
	else if (self.fUtilI == 3)
	{
		self.fUtilI = 4; // move to min
		self.velocity = '0 0 0';
		self.think = movePulse;
		self.nextthink = time + self.fUtilD;
	}
	else if (self.fUtilI == 5)
	{
		self.fUtilE--;
		self.velocity = '0 0 0';
		if (self.fUtilE == 0)
		{
			self.think = fadeProjectile;
			self.nextthink = time + 0.1;
			self.owner.think = SUB_Remove;
			self.owner.nextthink = time + 0.1;
		}
		else
		{
			self.fUtilI = 1;
			self.think = idlePulse;
			self.nextthink = time;
		}
	}
};

void() movePulse =
{
//SELF STATUS: Sector
	if (self.fUtilI == 2 )
	{
		self.fUtilI = 3;
		self.velocity = self.vUtilA;
		self.think = idlePulse;
		self.nextthink = time + self.fUtilH;
	}
	else if (self.fUtilI == 4 )
	{
		self.fUtilI = 5;
		self.velocity = (-1) * self.vUtilA;
		self.think = idlePulse;
		self.nextthink = time + self.fUtilH;
	} 
};	


//*****************************
// PROJECTILES STUFF
//*****************************
void(vector pvSource, vector pvDirection, float pfFadeTime ) setupProjectile =
{
//SELF STATUS: Fire Task
	local entity leBullet; // bullet hell projectile
	local vector lvDirection;
	
//equalize height
	lvDirection = pvDirection;
	lvDirection_z = pvSource_z;
	
	lvDirection = lvDirection - pvSource;
	lvDirection = normalize(lvDirection);

	leBullet = spawn ();
	leBullet.owner = leBullet.trueowner = self.owner; // director
	leBullet.movetype = MOVETYPE_FLYMISSILE;
	leBullet.solid = SOLID_BBOX;
	leBullet.classname = "SimpleBullet";
	
	//we set speed and damage on firetask spawn if not - use defaults
	if (self.speed)
		leBullet.speed = self.speed;
	else
		leBullet.speed = BULLET_SPEED;
	
	if (self.dmg)
		leBullet.dmg = self.dmg;
	else
		leBullet.dmg = BULLET_DAMAGE;
	
	leBullet.velocity = lvDirection * leBullet.speed;	
	leBullet.angles = vectoangles(leBullet.velocity);
	leBullet.touch = simpleTouch;
	leBullet.think = fadeProjectile;
	leBullet.nextthink = time + pfFadeTime;
	leBullet.cnt = 3; // steps to fade

	setmodel ( leBullet, "progs/e2/hell_bullet.mdl" );
	setsize  ( leBullet, '0 0 0', '0 0 0' );	
	setorigin( leBullet, pvSource );
};


// used by spinning wheel
entity(vector pvSource, vector pvDirection) returnProjectile =
{
//SELF STATUS: caller (director, leader)
	local entity leBullet; // bullet hell projectile
	local vector lvDirection;
	
//equalize z component	
	lvDirection = pvDirection;
	lvDirection_z = pvSource_z;
	lvDirection = lvDirection - pvSource; //pvDirection
	lvDirection = normalize(lvDirection);

	leBullet = spawn ();
	leBullet.owner = leBullet.trueowner = self; // FIX ME: access director or boss
	leBullet.movetype = MOVETYPE_NOCLIP;
	leBullet.solid = SOLID_NOT;
	leBullet.classname = "SpinningBullet";
	leBullet.speed = WHEEL_SPEED;
	leBullet.dmg = WHEEL_DAMAGE;
	leBullet.velocity = lvDirection * leBullet.speed;	
	leBullet.velocity_z = 0;
	leBullet.angles = vectoangles(leBullet.velocity);
	leBullet.cnt = 3; //fade steps

	setsize  ( leBullet, '0 0 0', '0 0 0' );	
	setorigin( leBullet, pvSource );
	return leBullet;
};


void() simpleTouch = 
{
	//if (CheckProjectilePassthru()) return;
	//if (other == self.owner)
	//	return;		// don't explode on owner

	if (other.takedamage == DAMAGE_AIM)
		T_Damage (other, self, self.trueowner, self.dmg);
	remove(self);
};


void() fadeProjectile = 
{
	self.think = fadeProjectile;
	self.nextthink = time + 0.1;

	if (self.cnt > 0) 
		self.alpha = self.cnt * 0.3;
	else
	{
		self.alpha = 0.01;
		self.think = SUB_Remove;
	}
	
	self.cnt = self.cnt - 1;
};


void() fadeSatelite =
{
	if (self.cnt > 0) 
		self.alpha = self.cnt * 0.3;
	else
	{
		self.alpha = 0.01;
		self.fUtilF = 1;
	}
	
	self.cnt = self.cnt - 1;
};


//============================================================================

float BULLET_STYLE_RANDOM = 0;
float BULLET_STYLE_ONELINE = 1;
float BULLET_STYLE_TWOLINES = 2;
float BULLET_STYLE_CIRCLE = 3;
float BULLET_STYLE_SPIRAL = 4;
float BULLET_STYLE_WHEEL = 5;
float BULLET_STYLE_BARRAGE = 6;
float BULLET_STYLE_PULSE = 7;

void() target_bullethell_fire = {
	entity oldself = self;
	self = self.eChildA;

	float choice = oldself.style;

	self.fUtilF = 0; //allow repeating tasks

	if (choice == BULLET_STYLE_RANDOM) choice = 1 + floor(random() * 6.99 );

	switch (choice)
	{
		case BULLET_STYLE_ONELINE:
		// Follow player (0/1); Shots count; firerate (time bitween shots); execute after some delay
			startOneLine(1, 10, 0.1, NO_DELAY);
			break;
		case BULLET_STYLE_TWOLINES:
		// Follow player (0/1); how wide V shape gonna be; Shots count(for both); firerate (time bitween shots); execute after some delay
			startTwoLines(0, 10, 15, 0.1, NO_DELAY);
			break;
		case BULLET_STYLE_CIRCLE:
		// Start; End position on a circle: [0-24, be aware!]; repeat count(at least 1); repeat cycle; 
		// alternate between two patterns or not (slight shift in coordinates);
		// Time after which projectile gonna fade (fade itself takes like 0.3-0.5 sec); execute after some delay
			startCircle( 0 , 24, 1, 0.1, 1, BULLET_FADETIME, NO_DELAY);
			break;
		case BULLET_STYLE_SPIRAL:
		// Start; End position on a circle: [0-48, be aware!]; clockwise or not (1/0); fade time as above; execute after some delay
			startSpiral(0, 48, 1, 0.05, BULLET_FADETIME, NO_DELAY);
			startSpiral(0, 48, 1, 0.05, BULLET_FADETIME, 2.4);
			break;
		case BULLET_STYLE_WHEEL:
		// direction; time when projectiles start to spin, basically corresponds with radius; time to fade; execute after some delay  
			startMovingWheel([crandom()*1000, crandom()*1000, self.origin_z], 1.0, 8, NO_DELAY);
			break;
		case BULLET_STYLE_BARRAGE:
			startRocketBarrage(NO_DELAY);
			break;
		case BULLET_STYLE_PULSE:
		//float pfMinRadius, float pfMaxRadius, float pfIdleAtMin, float pfIdleAtMax, float pfSpeed, float pfPulses, float pfDelay
			startPulse(64, 320, 0.5, 0.5, 640, 2, NO_DELAY);
			break;
	}

	self = oldself;
}

// derived from spawnDirector()
// takes the entity's own origin as epicenter for the director
void() target_bullethell_startup = {

	//SELF STATUS: d2 Boss
	local entity leDirector;
	
	leDirector = spawn ();
	leDirector.owner = self;
	leDirector.classname = "Director";
	leDirector.fUtilA = 0; // alternate circle patterns
	leDirector.fUtilI = 0; // program progress indicator
	
	setorigin(leDirector, self.origin);
	
	//dprint("Director has been spawned \n");
	self.eChildA = leDirector;

	self.use = target_bullethell_fire;
}

void() target_bullethell = {
	self.think = target_bullethell_startup;
	self.nextthink = time + 0.025;
}