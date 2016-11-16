package {

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.Stage;

	public class mcBullet extends Sprite {

		private var stageRef: Stage; //we'll use this to check if the bullet leaves the screen borders
		private var speed: Number = 10; //speed that the bullet will travel at
		private var xVel: Number = 0; //current x velocity
		private var yVel: Number = 0; //current y velocity
		private var rotationInRadians = 0; //convenient to store our rotation in radians instead of degrees

		public function mcBullet(tageRef:Stage, X:int, Y:int, rotationInDegrees:Number):void {
			// constructor code

			this.stageRef = stageRef;
			this.x = X;
			this.y = Y;
			this.rotation = rotationInDegrees;
			this.rotationInRadians = rotationInDegrees * Math.PI / 180; //convert degrees to radians, for trigonometry

			//listen for the event that adds the bullet to the stage
			addEventListener(Event.ADDED_TO_STAGE, onAdd);
		}

		private function onAdd(evt: Event): void {

			removeEventListener(Event.ADDED_TO_STAGE, onAdd);

			init();

		}

		private function init(): void {

			addEventListener(Event.ENTER_FRAME, bulletGo);

		}

		private function bulletGo(evt: Event): void {

			xVel = Math.cos(rotationInRadians) * speed; //uses the cosine to get the xVel from the speed and rotation
			yVel = Math.sin(rotationInRadians) * speed; //uses the sine to get the yVel

			x += xVel; //updates the position
			y += yVel;

		}

		public function destroyBullet(): void {

			//remove object from the stage
			parent.removeChild(this);

			//remove event listeners
			removeEventListener(Event.ENTER_FRAME, bulletGo);

		}

	}

}