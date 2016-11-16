Added start screen and tutorial with opening scenes telling background story

Added turret graphic to coast guard ship

Added collision detection between player and agents

Added 2nd flee radius with increased speed. If the agent remains in this heightened state for several cycles, the speed will increase again.

Added kinematics...sort of. There is a length of segments attached to the turret, but I'm not sure what to call it. A length of chain? A banner that reads, "Die pirate scum?" I thought it could be a round of ammo and it could shorten as ammo is used, but this isn't a machine gun (can you tell I know nothing about guns?). I couldn't make it a wake because I couldn't attach it to the back of the player/ship. It needs to attach to the registration point, and that needs to be near the front of the ship for the turret positioning. Moving the reg point to the back of the ship would mean totally rewriting the collision detection and hitTest detection. I also couldn't figure out how to change its starting position so that it doesn't look like it's pointing straight up. However, it moves great. If anyone has a better solution, I'm all for it.


