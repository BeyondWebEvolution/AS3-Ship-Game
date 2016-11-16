package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class mcExplosion extends MovieClip {

		public function mcExplosion() {
			// constructor code
			
			//check if added to stage
			addEventListener(Event.ADDED_TO_STAGE, onAdd);
			
		}
		
		private function onAdd(evt:Event):void {
			
			//remove the event listener after it is added to the stage
			removeEventListener(Event.ADDED_TO_STAGE, onAdd);
			init();
			
		}
		
		private function init():void {
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
		}
		
		private function onEnterFrame(evt:Event):void {
			
			//get rid of the animation after one loop
			if (this.currentFrame == this.totalFrames) {
				//remove this object
				parent.removeChild(this);
				//remove the event listener
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				
			}
			
		}


	}
	
}
