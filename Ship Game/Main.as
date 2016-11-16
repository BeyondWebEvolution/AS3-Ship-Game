package {
	
	import agent.Agent;
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.Stage;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import Segment;
	
	

	public class Main extends MovieClip {
		
		private var agents:Vector.<Agent>;
		
		public var mcPlayer: MovieClip;
		public var mcFreighter: MovieClip;
		public var scoreText: TextField;
		public var ammoText: TextField;
		public var menuEnd: mcEndGameScreen;
		public var turret:MovieClip;
		public var phb:Sprite;
				

		private var speed:Number = 0;
		private var speedMax:Number = 10;
		private var speedMaxReverse:Number = -3;
		private var speedAcceleration:Number = .15;
		private var speedDeceleration:Number = .90;
		private var groundFriction:Number = .95;
		
		private var steering:Number = 0;
		private var steeringMax:Number = 2;
		private var steeringAcceleration:Number = .10;
		private var steeringFriction:Number = .98;
		
		private var vx:Number = 0;
		private var vy:Number = 0;
		
		private var up: Boolean = false;
		private var down: Boolean= false;
		private var left: Boolean= false;
		private var right: Boolean= false;
		
		private var touchLayer: Sprite;
		private var bulletArray: Array;
		private var enemyBulletArray: Array;
		private var numScore: Number;
		private var numAmmo: Number;

		public var enemyArray: Array;

		private var enemyTimer: Timer;
		private var firingRange:Boolean = false;
		
		public var segments:Array; 
		public var numSegments:uint = 4;
		
		static const theDriveSound:DriveSound = new DriveSound();
		private var currentSound:Object;
		private var driveSoundChannel:SoundChannel;
		
	
		
		public function Main() 
		{
			// constructor code
		
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
						
			var startMenu:StartScreen = new StartScreen();
			addChild(startMenu);
			startMenu.startButton.addEventListener(MouseEvent.CLICK, tutorial);
			
			menuEnd.addEventListener("PLAY_AGAIN", playAgain);
			menuEnd.hideScreen();
			
		}
			
		public function tutorial(evt:MouseEvent):void
		{
			removeChild(evt.currentTarget.parent);  
			
			evt.currentTarget.removeEventListener(MouseEvent.CLICK, tutorial);
			var startMenu2:Tutorial = new Tutorial();
			addChild(startMenu2);
			startMenu2.playButton.addEventListener(MouseEvent.CLICK, removeLoader);
			startMenu2.btnLoad.addEventListener(MouseEvent.CLICK, doLoad);
			
			var loader:Loader = new Loader();
			this.addChild(loader);
			loader.x = 200;
			loader.y = 40;
			
			var picsArray:Array = ["scene1.jpg","scene2.jpg","scene3.jpg","scene4.jpg"];
			var numPics:int = picsArray.length;
			var nextPic:int = 0;
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, doneLoad);
			
			loadInitImg();
			
			function loadInitImg():void
			{
				loader.load(new URLRequest(picsArray[nextPic]));
			}
			
			function doLoad(e:MouseEvent):void
			{
				loader.load(new URLRequest(picsArray[nextPic]));
			}
			
			function doneLoad(e:Event):void
			{
				nextPic = (nextPic + 1) %numPics;
			}
			
			function removeLoader(e:Event):void
			{
				
				removeChild(loader);
				removeChild(e.currentTarget.parent);
				e.currentTarget.removeEventListener(MouseEvent.CLICK, removeLoader);
				createGame();		
			}
			
		}
		
		private function createGame():void
		{
			playAgain(null);
		}
		
		private function playAgain (e:Event):void {
			
			stage.focus = this;	
			init();
			
			bulletArray = new Array();
			enemyBulletArray = new Array();
			enemyTimer = new Timer(1000);
			enemyTimer.addEventListener(TimerEvent.TIMER, enemyFire);
			enemyTimer.start();
			
			numScore = 0;
			numAmmo = 20;

			updateScore();
			updateAmmo();

			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
						
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			
			stage.addEventListener(Event.ENTER_FRAME, gameLoop);
			
//removing touch layer
/*			touchLayer = new Sprite();

			addEventListener(Event.ADDED_TO_STAGE, setupTouchLayer);
			touchLayer.addEventListener(MouseEvent.CLICK, startFiring, false, 0, true);


			addChild(touchLayer);
*/			
			
			
			turret = new Turret();
			addChild(turret);
			turret.x = mcPlayer.x;
			turret.y = mcPlayer.y;
			
			phb = new HealthBar((stage.stageWidth/2) - 150, 20, 300, 20, 0x000000, 0xFF0000);
			addChild(phb);
			
			menuEnd.visible = false;
			mcPlayer.visible = true;
			mcFreighter.visible = true;
			turret.visible = true;
			
			
		}
		
		private function init(e:Event = null):void 
		{
			agents = new Vector.<Agent>();
			addEventListener(Event.ENTER_FRAME, gameLoop);
			for (var i:int = 0; i < 3; i++) 
			{
				var a:Agent = new Agent();
				addChild(a);
				agents.push(a);
				//a.x = stage.stageWidth/2
				//a.y = stage.stageHeight/2
				a.x = Math.random() * 1100;
				a.y = Math.random() * 400;
								
			}
			
			
			segments = new Array();
			addEventListener(Event.ENTER_FRAME, gameLoop);
			for(var k:uint = 0; k < numSegments; k++)
			{
				var segment:Segment = new Segment(25, 5);
				addChild(segment);
				segments.push(segment);
			}
			
		}

/*  disabling the function that sets up the touch layer		
		private function setupTouchLayer(evt: Event): void {
			touchLayer.graphics.beginFill(0x000000, 0);
			touchLayer.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			touchLayer.graphics.endFill();
		}
*/		

		private function startFiring(evt: MouseEvent): void {

			//test if ammo available
			if (numAmmo > 0) {

				numAmmo--;
				updateAmmo();

				fireBullet();

			}
		}

		private function gameLoop(e: Event): void {

			stage.addEventListener(MouseEvent.CLICK, startFiring, false, 0, true);
			
			for (var i:int = 0; i < agents.length; i++) {
				agents[i].update();
				
				for each (var currentAgent:Agent in agents)  
				{   //player's distance from agents
					var dx:Number = mcPlayer.x - currentAgent.x;
					var dy:Number = mcPlayer.y - currentAgent.y;
					var dist:Number = Math.sqrt(dx*dx + dy*dy);
					//player-agent collision detection
					if (mcPlayer.hitTestObject(currentAgent))
					{
						mcPlayer.x -= vx;
						mcPlayer.y -= vy;
					}
					
				}
				
			}
			
			movePlayer();
			makeBoundry();
			makeBoundry2();
			killBullet();
			enemyHitTest();
			endGame();
			checkRange();
			killEnemyBullet();
			playerHitTest()
			
			turret.x = mcPlayer.x;
			turret.y = mcPlayer.y;
			
						
			//this keeps the turret pointed at the mouse at all times
			var target:Point = new Point(stage.mouseX, stage.mouseY);
			var angleRad:Number = Math.atan2(target.y - turret.y, target.x - turret.x);
			turret.rotation = angleRad * 180 / Math.PI;
			
			
			//mcPlayer.update();
			handleSetPlayerLoc();
			
			drag(segments[0], mcPlayer.x, mcPlayer.y);
			for(var k:uint = 1; k < numSegments; k++)
			{
				var segmentA:Segment = segments[k];
				var segmentB:Segment = segments[k - 1];
				drag(segmentA, segmentB.x, segmentB.y);
			}

		}
		
		public function drag(segment:Segment, xpos:Number, ypos:Number):void  //changed from private
		{
			var dx:Number = xpos - segment.x;
			var dy:Number = ypos - segment.y;
			var angle:Number = Math.atan2(dy, dx);
			segment.rotation = angle * 180 / Math.PI;
			
			var w:Number = segment.getPin().x - segment.x;
			var h:Number = segment.getPin().y - segment.y;
			segment.x = xpos - w;
			segment.y = ypos - h;
		}
		
		
		private function handleSetPlayerLoc():void {
					
			Agent.playerLocX = mcPlayer.x;
			Agent.playerLocY = mcPlayer.y;
				
		}
		
		
		

		private function endGame(): void {
			
			if (agents.length == 0) {
				
				mcFreighter.x += 2;
				
			}

			//check for the conditions to end the game
			//if (healthBar.width < 1 && enemyArray.length == 0) {
			if (phb.width <= 1 || mcFreighter.x >= 1100 || numAmmo == 0) {

				//stop player movement
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
				stage.removeEventListener(KeyboardEvent.KEY_UP, keyUp);

				//hide the player
				mcPlayer.visible = false;
				mcFreighter.visible = false;
				turret.visible = false;
				
				driveSoundChannel.stop();
				
				for each (var currentSegment:Segment in segments)
				{
				currentSegment.visible = false;
				}	

				//stop adding enemies
				//enemyTimer.stop();

				//clear enemies from the stage
				for (var i: int = 0; i < agents.length; i++) {

				//get the next enemy in the array
				var currentAgent: Agent = agents[i];

				//check the position of the enemy
				//if (currentEnemy.x < -(currentEnemy.width / 2)) {

					//remove current enemy from the array
					agents.splice(i, 1);

					//remove current enemy from the stage
					currentAgent.destroyAgent();
					trace(agents.length);
				}

				//stop the game loop
				if (agents.length == 0) {

					//trace("enemy length 0");

					removeEventListener(Event.ENTER_FRAME, gameLoop);


				}

				//show the end game screen
				menuEnd.showScreen();

			}

		}

		private function updateScore(): void {

			scoreText.text = "Score: " + numScore;
			

		}

		private function updateAmmo(): void {

			ammoText.text = "Ammo: " + numAmmo;
			//numSegments = numSegments - 1;

		}
		
		private function checkRange():void {
			
			for (var i: int = 0; i < agents.length; i++) {

				var currentAgent: Agent = agents[i];
			
				var dx:Number = currentAgent.x - mcPlayer.x;
				var dy:Number = currentAgent.y - mcPlayer.y;
				var range = Math.sqrt(dx * dx + dy * dy);
				
				if (range <= 300) {
					firingRange = true;
				}
				else {
					firingRange = false;
				}
			
			}
		}

		private function enemyFire(evt: TimerEvent): void {

			
			if (firingRange) {
			
				for (var i: int = 0; i < agents.length; i++) {

					var currentAgent: Agent = agents[i];
					var enemyBullet: mcBullet = new mcBullet(stage, currentAgent.x, currentAgent.y, currentAgent.pirate.rotation);
					enemyBullet.x = currentAgent.x;
					enemyBullet.y = currentAgent.y;
					stage.addChild(enemyBullet);
				
					enemyBulletArray.push(enemyBullet);
					trace(enemyBulletArray.length);
					
				}

			}

		}
		
		private function killEnemyBullet(): void {
			//get rid of bullets off screen
			for (var i: int = 0; i < enemyBulletArray.length; i++) {
				//get the next bullet in teh array
				var currentBullet: mcBullet = enemyBulletArray[i];
				//check the position of the current bullet
				if (currentBullet.x > 1100 || currentBullet.x < 0 || currentBullet.y > 800 || currentBullet.y < 0) {
					//remove current bullet from the array
					enemyBulletArray.splice(i, 1);
					//remove current bullet from the stage
					currentBullet.destroyBullet();

				}
			}

		}
		
		private function playerHitTest(): void {

			//loop through current bullets
			for (var i: int = 0; i < enemyBulletArray.length; i++) {

				//check current bullet
				var currentBullet: mcBullet = enemyBulletArray[i];

				//check if current bullet is touching current enemy
				if (currentBullet.hitTestObject(mcPlayer)) {

					//create an explosion animation
					//create a new instance of the explosion object
					var newExplosion: mcExplosion = new mcExplosion();
					//add it to the stage
					stage.addChild(newExplosion);
					//position it over the current enemy
					newExplosion.x = mcPlayer.x;
					newExplosion.y = mcPlayer.y;
					//scale the explosion down
					newExplosion.width = (newExplosion.width / 2);
					newExplosion.height = (newExplosion.height / 2);
					//remove the lasers and enemies from the stage and arrays
					currentBullet.destroyBullet();
					enemyBulletArray.splice(i, 1);

					//decrease health bar
					phb.width -= 50;

				}

			}

		}
		

		private function fireBullet(): void {

			var newBullet: mcBullet = new mcBullet(stage, mcPlayer.x, mcPlayer.y, turret.rotation);

			stage.addChild(newBullet);

			newBullet.x = mcPlayer.x;
			newBullet.y = mcPlayer.y;

			bulletArray.push(newBullet);
			//trace(bulletArray.length);

		}

		private function killBullet(): void {
			//get rid of bullets off screen
			for (var i: int = 0; i < bulletArray.length; i++) {
				//get the next bullet in teh array
				var currentBullet: mcBullet = bulletArray[i];
				//check the position of the current bullet
				if (currentBullet.x > 1100 || currentBullet.x < 0 || currentBullet.y > 800 || currentBullet.y < 0) {
					//remove current bullet from the array
					bulletArray.splice(i, 1);
					//remove current bullet from the stage
					currentBullet.destroyBullet();

				}
			}

		}

		private function enemyHitTest(): void {

			//loop through current lasers
			for (var i: int = 0; i < bulletArray.length; i++) {

				//check current laser
				var currentBullet: mcBullet = bulletArray[i];

				//loop through enemies
				for (var j: int = 0; j < agents.length; j++) {

					//check current enemy
					var currentAgent: Agent = agents[j];

					//check if current laser is touching current enemy
					if (currentBullet.hitTestObject(currentAgent)) {

						//create an explosion animation
						//create a new instance of the explosion object
						var newExplosion: mcExplosion = new mcExplosion();
						//add it to the stage
						stage.addChild(newExplosion);
						//position it over the current enemy
						newExplosion.x = currentAgent.x;
						newExplosion.y = currentAgent.y;

						//remove the lasers and enemies from the stage and arrays
						currentBullet.destroyBullet();
						bulletArray.splice(i, 1);
						
						
						currentAgent.destroyAgent();
						agents.splice(j, 1);
						

						//increase score on enemy kill
						numScore++;
						updateScore();


					}

				}
			}

		}

		private function makeBoundry(): void {

			if (mcPlayer.y < mcPlayer.height / 2) {
				mcPlayer.y = mcPlayer.height / 2;
			} else if (mcPlayer.y > stage.stageHeight - (mcPlayer.height / 2)) {
				mcPlayer.y = stage.stageHeight - (mcPlayer.height / 2);
			}

			if (mcPlayer.x < mcPlayer.width / 2) {
				mcPlayer.x = mcPlayer.width / 2;
			} else if (mcPlayer.x > stage.stageWidth - (mcPlayer.width / 2)) {
				mcPlayer.x = stage.stageWidth - (mcPlayer.width / 2);
			}

		}

		public function makeBoundry2(): void {

			for (var j: int = 0; j < agents.length; j++) {

					//check current enemy
					var currentAgent: Agent = agents[j];
			
			if (currentAgent.y < currentAgent.height / 2) {
				currentAgent.y = currentAgent.height / 2;
			} else if (currentAgent.y > stage.stageHeight - (currentAgent.height / 2)) {
				currentAgent.y = stage.stageHeight - (currentAgent.height / 2);
			}

			if (currentAgent.x < currentAgent.width / 2) {
				currentAgent.x = currentAgent.width / 2;
			} else if (currentAgent.x > stage.stageWidth - (currentAgent.width / 2)) {
				currentAgent.x = stage.stageWidth - (currentAgent.width / 2);
			}
		}

		}

		private function keyUp(evt: KeyboardEvent): void {

		//trace(evt.keyCode);

			if (evt.keyCode == 87) {
				up = false;
			}


			if (evt.keyCode == 83) {
				down = false;
			}

			if (evt.keyCode == 65) {
				left = false;
			}


			if (evt.keyCode == 68) {
				right = false;
			}
		}
		
		private function keyDown(evt: KeyboardEvent): void {

			if (evt.keyCode == 87) {
				up = true;
			}

			if (evt.keyCode == 83) {
				down = true;
			}

			if (evt.keyCode == 65) {
				left = true;
			}

			if (evt.keyCode == 68) {
				right = true;
			}
			//event.updateAfterEvent();
		}
		
		private function movePlayer(): void {
			
			var newSound:Object = theDriveSound;
			
			if (!up && !down) {
				newSound = null;
			}
			
			// if a new sound, switch sound
			if (newSound != currentSound) {
				if (driveSoundChannel != null) {
					driveSoundChannel.stop();
				}
				currentSound = newSound;
				if (currentSound != null) {
					driveSoundChannel = currentSound.play(0,9999);
				}
			}

			if (up)
			{
				//check if below speedMax
				if (speed < speedMax)
				{
					//speed up
					speed += speedAcceleration;
					//check if above speedMax
					if (speed > speedMax)
					{
						//reset to speedMax
						speed = speedMax;
					}
				}
			}
			
			if (down)
			{
				//check if below speedMaxReverse
				if (speed > speedMaxReverse)
				{
					//speed up (in reverse)
					speed -= speedAcceleration;
					//check if above speedMaxReverse
					if (speed < speedMaxReverse)
					{
						//reset to speedMaxReverse
						speed = speedMaxReverse;
					}
				}
			}
			
			if (left)
			{
				//turn left
				steering -= steeringAcceleration;
				//check if above steeringMax
				if (steering > steeringMax)
				{
					//reset to steeringMax
					steering = steeringMax;
				}
			}
			
			if (right)
			{
				//turn right
				steering += steeringAcceleration;
				//check if above steeringMax
				if (steering < -steeringMax)
				{
					//reset to steeringMax
					steering = -steeringMax;
				}
			}
			
			// friction    
			speed *= groundFriction;
			
			// prevent drift
			if(speed > 0 && speed < 0.05)
			{
				speed = 0
			}
			
			// calculate velocity based on speed
			vx = Math.sin (mcPlayer.rotation * Math.PI / 180) * speed;
			vy = Math.cos (mcPlayer.rotation * Math.PI / 180) * -speed;
			
			// update position	
			mcPlayer.x += vx;
			mcPlayer.y += vy;
			
			// prevent steering drift (right)
			if(steering > 0)
			{
				// check if steering value is really low, set to 0
				if(steering < 0.05)
				{
					steering = 0;
				}		
			}
			// prevent steering drift (left)
			else if(steering < 0)
			{
				// check if steering value is really low, set to 0
				if(steering > -0.05)
				{
					steering = 0;
				}		
			}
			
			// apply steering friction
			steering = steering * steeringFriction;
			
			// make car go straight after driver stops turning
			steering -= (steering * 0.1);
			
			// rotate
			mcPlayer.rotation += steering * speed;

		}
		
		public function playSound(soundObject:Object) {
			var channel:SoundChannel = soundObject.play(0);
		}
		
	}

}