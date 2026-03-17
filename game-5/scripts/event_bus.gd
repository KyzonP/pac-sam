extends Node

# Tell Godot to ignore warnings of unused signals
#warning-ignore:unused_signal

# Emitted when pellet is consumed #
signal pelletConsumed()

# Emitted when the ghosts need to change state #
signal ghostState()

# Emitted when a level reset occurs, either due to a death or completion of the level #
signal restart(death, level)

# Emitted to signal the end of the game #
signal endGame(death)

# Emitted to freeze everyone #
signal freeze()

# Emitted to start the level #
signal startLevel()

# Emitted when a ghost is eaten
signal ghostEaten()
