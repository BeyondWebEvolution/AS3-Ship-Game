package agent.states {
	
	import agent.Agent;
	import flash.utils.Timer;
	
	public class FleeState implements IAgentState {

		public function FleeState() {
			// constructor code
		}
		
		//INTERFACE agent.states.IAgentState
		
		public function update(a:Agent):void {
			
			if (a.numCycles < 5) return;
			a.say("Run away!");
			a.speed = 2;
			a.faceMouse(-1);
			
			if (a.distanceToMouse < a.fleeRadius2) 
			{
				if (a.numCycles > 5 && a.numCycles < 500)					
				{	
					a.say("Run away faster!");
					a.speed = 5;
					a.faceMouse(-1);
				}
				else if (a.numCycles > 500)					
				{
					a.say("HURRY!");
					a.speed = 7;
					a.faceMouse(-1);
				}
			}
			
			
			if(a.numCycles > 80) {
				if (a.distanceToMouse > a.fleeRadius1) {
					a.setState(Agent.CONFUSED);
				}				
			}			
		}
		
		public function enter(a:Agent):void {
			
			a.say("Oh @#%$&*!");
			a.faceMouse(1);
			a.speed = 0;
			
		}
		
		public function exit(a:Agent):void {
			
			
		}

	}
	
}
