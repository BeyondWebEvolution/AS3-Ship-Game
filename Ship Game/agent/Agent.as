package agent {
	
	import agent.states.ChaseState;
	import agent.states.ConfusionState;
	import agent.states.FleeState;
	import agent.states.IAgentState;
	import agent.states.IdleState;
	import agent.states.WanderState;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.display.MovieClip;
	

	import Main;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Stage;
		
	public class Agent extends MovieClip {
		
		public static const IDLE:IAgentState = new IdleState();
		public static const WANDER:IAgentState = new WanderState();
		public static const CHASE:IAgentState = new ChaseState();
		public static const FLEE:IAgentState = new FleeState();
		public static const CONFUSED:IAgentState = new ConfusionState();
		
		private const RAD_DEG:Number = 180 / Math.PI;
		
		
				
		//these variables store the player's x and y coordinates
		public static var _iPlayerLocX:Number;  
		public static var _iPlayerLocY:Number;
		
		private var _previousState:IAgentState;
		private var _currentState:IAgentState;
		private var _pointer:Shape;
		private var _tf:TextField;
		public var pirate:MovieClip;
		
		public var velocity:Point = new Point();
		public var speed:Number = 0;
		
		public var fleeRadius1:Number = 100;
		public var fleeRadius2:Number = 50;  //2nd level flee with increased speed
		public var chaseRadius:Number = 400;
		public var numCycles:int = 0;
		

		public function Agent() {
			// constructor code
			
			_tf = new TextField();
			_tf.defaultTextFormat = new TextFormat("_sans", 10);
			_tf.autoSize = TextFieldAutoSize.LEFT;
			
			/*_pointer = new Shape();
			var g:Graphics = _pointer.graphics;
			g.beginFill(0);
			g.drawCircle(0, 0, 5);
			g.endFill();
			g.moveTo(0, -5);
			g.beginFill(0);
			g.lineTo(10, 0);
			g.lineTo(0, 5);
			g.endFill();
			addChild(_pointer);*/
			
			addChild(_tf);
			//graphics.lineStyle(0, 0xFF0000, .2);
			//graphics.drawCircle(0, 0, fleeRadius);
			//graphics.lineStyle(0, 0x00FF00, .2);
			//graphics.drawCircle(0, 0, chaseRadius);
			
			pirate = new Pirate();
			addChild(pirate);
			
			var hb:HealthBar = new HealthBar(this.x - 20, this.y - 25, 40, 5, 0x000000, 0xFF0000);
			addChild(hb);
			
			_currentState = IDLE; //sets the initial state
			
			
		}
		
		public function say(str:String):void {
			
			_tf.text = str;
			//_tf.y = -_tf.height - 2;
			_tf.y = -_tf.height - 25;
			
		}
		
		public function get canSeeMouse():Boolean {
			
			var dot:Number = _iPlayerLocX * velocity.x + _iPlayerLocY * velocity.y;
			return dot > 0;
			
		}
		
		public function get distanceToMouse():Number {
			
			var dx:Number = x - _iPlayerLocX;
			var dy:Number = y - _iPlayerLocY;
			return Math.sqrt(dx * dx + dy * dy);
			
		}
		
		public function randomDirection():void {
			
			var a:Number = Math.random() * 6.28;
			velocity.x = Math.cos(a);
			velocity.y = Math.sin(a);
			
		}
		
		public function faceMouse(multiplier:Number = 1):void {
			
			var dx:Number = _iPlayerLocX - x;
			var dy:Number = _iPlayerLocY - y;
			var rad:Number = Math.atan2(dy, dx);
			velocity.x = multiplier*Math.cos(rad);
			velocity.y = multiplier*Math.sin(rad);
			
		}
		
		//update the current state, then update the graphics
		public function update():void {
			
			
			
			if (!_currentState) return; //if there is no behavior, do nothing
			numCycles++;
			_currentState.update(this);
			x += velocity.x*speed;
			y += velocity.y*speed;
			if (x + velocity.x > stage.stageWidth || y + velocity.y < 0) {
				
				x = Math.max(0, Math.min(stage.stageHeight, y));
				velocity.y *= -1;
				
			}
			if (y + velocity.y > stage.stageHeight || y + velocity.y < 0) {
				
				y = Math.max(0, Math.min(stage.stageHeight, y));
				velocity.y *= -1;
				
			}

			
			//_pointer.rotation = RAD_DEG * Math.atan2(velocity.y, velocity.x);
			pirate.rotation = RAD_DEG * Math.atan2(velocity.y, velocity.x);
			
		}
		
		public function setState(newState:IAgentState):void {
			
			if (_currentState == newState) return;
			if (_currentState) {
				_currentState.exit(this);
				
			}
			_previousState = _currentState;
			_currentState = newState;
			_currentState.enter(this);
			numCycles = 0;
			
		}
		
		public function get previousState():IAgentState { 
			
			return _previousState;
			
		}
		
		public function get currentState():IAgentState {
			
			return _currentState;
			
		}
		
		public function destroyAgent():void {
			
			parent.removeChild(this);
			
		}
		
		public static function set playerLocX(value:Number)  //this receives the player's x position from the Main class and stores it in the variable _iPlayerLocX
		{
			_iPlayerLocX = value;
			//trace("playerLocX = " + _iPlayerLocX);
		}
		
		public static function set playerLocY(value:Number) //this receives the player's x position from the Main class and stores it in the variable _iPlayerLocX
		{
			_iPlayerLocY = value;
			//trace("playerLocY = " + _iPlayerLocY);
		}


		
		//public static function set freighterLocX(value:Number)
		//{
		//	_iFreighterLocX = value;
		//	//trace("freighterLocX = " + _iFreighterLocX);
		//}
		//
		//public static function set freighterLocY(value:Number)
		//{
		//	_iFreighterLocY = value;
		//	//trace("freighterLocY = " + _iFreighterLocY);
		//}
		
		
		
		

	}
	
}
