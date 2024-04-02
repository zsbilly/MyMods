# About this mod

This mod allows you to preset skillset for each job class. When you are a Warfarer, and using Rearmament skill switch to a new weapon, it will read the config and set the skillset accordingly.

The mod is NOT based on hotkeys. It hooks the Rearmament skill.

For those people want more skill slots. This mod is made for you. Can be used with True Warfarer.
An Alternative Skill Swapper

The mod is NOT based on hotkeys. It hooks the Rearmament skill itself, which means you will not be bothered with aligning the sequence of your skillset.

## Installation

Download the mod file, Drag the zip to Fluffy or Unzip to the game folder.
Make sure 
1. TrueWarfarer.lua located in gamefolder\reframework\autorun

## How to use

1. Press Insert to open ReFramework.
2. Go to section Script Generated UI -> True Warfarer
3. Set skills for each class. Make sure each of them contains Rearmament skill(Or you can't switch back).
4. Try it out.

## Troubleshooting Guide

If you found this mod not working as expected, please checks the following items:
1. You have installed all requirements.
2. You put the mod file to the correct path.
3. You have set the skills in ReFramework panel. The skills set in panel MUST be unlocked in your game.
4. Each skillset contains Rearmament skill in it.

## New feature:
### v1.1.0 
- Makes this mod easier to use.
  1. Support for Fluffy. Now you can just download it, and drag the zip file to Fluffy.
  2. Set all skillset with Rearm skill by default. (If it is your first time to use this mod).
  3. Add a "Apply to all" button. Which can apply rearm skill to all Left/Top/Right/Down skill slot.
- Add a toggle that can remove the stamina cost by Rearm skill. Default OFF.
- Change the hook to a more accurate one. Changing weapon in equipment menu won't trigger the skillset replacement. Only Rearm skill will.