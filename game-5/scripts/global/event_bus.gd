extends Node

# Tell Godot to ignore warnings of unused signals
@warning_ignore("UNUSED_SIGNAL")

# Emitted when pellet is consumed #
signal pelletConsumed()

# Emitted when the ghosts need to change state #
@warning_ignore("UNUSED_SIGNAL")
signal spawnFruit()

# Emitted when the ghosts need to change state #
@warning_ignore("UNUSED_SIGNAL")
signal fruitEaten()

# Emitted when the ghosts need to change state #
@warning_ignore("UNUSED_SIGNAL")
signal ghostState()

# Emitted when a level reset occurs, either due to a death or completion of the level #
@warning_ignore("UNUSED_SIGNAL")
signal restart(death, level)

# Emitted to signal the end of the game #
@warning_ignore("UNUSED_SIGNAL")
signal endGame(death)

# Emitted to freeze everyone #
@warning_ignore("UNUSED_SIGNAL")
signal freeze()

# Emitted to start the level #
@warning_ignore("UNUSED_SIGNAL")
signal startLevel()

# Emitted when a ghost is eaten
@warning_ignore("UNUSED_SIGNAL")
signal ghostEaten()

# Emit to flash ghosts
@warning_ignore("UNUSED_SIGNAL")
signal ghostFlash(final)

# Check if Inky is release
@warning_ignore("UNUSED_SIGNAL")
signal checkInky()

# Release Inky early
@warning_ignore("UNUSED_SIGNAL")
signal inkyReleased()

# Check if Clyde is release
@warning_ignore("UNUSED_SIGNAL")
signal checkClyde()

# Release Clyde early
@warning_ignore("UNUSED_SIGNAL")
signal clydeReleased()

# Disable shadows on mobile
@warning_ignore("UNUSED_SIGNAL")
signal disableShadows()

# Disable shadows on mobile
@warning_ignore("UNUSED_SIGNAL")
signal toggleMute()

# Disable shadows on mobile
@warning_ignore("UNUSED_SIGNAL")
signal togglePause()

# Disable shadows on mobile
@warning_ignore("UNUSED_SIGNAL")
signal lifeChanged(anim_name)
