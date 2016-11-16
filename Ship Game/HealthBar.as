package {
	
	import flash.display.Graphics;
	import flash.display.Sprite;

	public class HealthBar extends Sprite {
		
		var bar: Sprite;

		public function HealthBar(xLoc: Number, yLoc: Number, wid: Number = 100, high: Number = 15,
			bc: uint = 0xFF0000, fc: uint = 0x00FF00) {
				
			this.x = xLoc;
			this.y = yLoc;

			var hbol: Sprite = new Sprite();
			addChild(hbol);

			var ol: Graphics = hbol.graphics;
			ol.lineStyle(1, 0x000000);
			ol.beginFill(bc);
			ol.lineTo(wid, 0);
			ol.lineTo(wid, high);
			ol.lineTo(0, high);
			ol.lineTo(0, 0);
			ol.endFill();

			var hb: Sprite = new Sprite();
			hbol.addChild(hb);
			bar = hb;

			var ins: Graphics = hb.graphics;
			ins.lineStyle(0, 0x000000);
			ins.beginFill(fc);
			ins.lineTo(wid, 0);
			ins.lineTo(wid, high);
			ins.lineTo(0, high);
			ins.lineTo(0, 0);
			ins.endFill();
			
			
			//var hb:HealthBar = new HealthBar(x, y, 400, 50, 0x000000, 0xFF0000);
			//create the healthbar
			
			//addChild(healthbar); 
			//add it to the stage
			
			/*
			if(//player takes  damage)
			{
			healthbar.subtractHealth(20);
			if(healthbar.getHealth() < 0)
				{
				gameOver();
				}
			}
			*/
  
			
			
		}

		public function subtractHealth(amount: Number) {
			
			bar.scaleX -= amount / 100;
			
		}
		
		public function addHealth(amount: Number) {
			
			bar.scaleX += amount / 100;
			
		}
		
		public function getHealth(): Number {
			
			return bar.scaleX * 100;
			
		}
	}
}