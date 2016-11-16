package agent.states {
	
	import agent.Agent;
	
	public interface IAgentState {

		// Interface methods:
		function update(a:Agent):void;
		function enter(a:Agent):void;
		function exit(a:Agent):void;		

	}
	
}
