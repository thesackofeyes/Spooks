# The unit is carrying out an action (moving, attacking, playing an animation).
# Combat enters this before an action runs and returns to Idle once it finishes;
# while in it, the action and End Turn buttons are unavailable
extends State
class_name UnitActingState
