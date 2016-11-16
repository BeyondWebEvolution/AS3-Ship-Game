package {
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;

	public class mcEndGameScreen extends MovieClip {

		public var mcPlayAgain: MovieClip;

		public function mcEndGameScreen() {
			// constructor code


			mcPlayAgain.buttonMode = true;
			mcPlayAgain.addEventListener(MouseEvent.CLICK, playAgain);



		}

		private function playAgain(evt: MouseEvent): void {

			//create a custom event
			dispatchEvent(new Event("PLAY_AGAIN"));

		}

		public function showScreen(): void {

			this.visible = true;

		}

		public function hideScreen(): void {

			this.visible = false;

		}

	}

}