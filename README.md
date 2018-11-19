## PHR

Welcome to PHR, an addon for tabletop-style roleplay in World of Warcraft! 
Currently, it simply provides a system for rolling and outputting dice rolls.
For example:

```
/phc SAY
/phs INT=2
/phr 3d6 + INT - 1
```

Will set the output channel to SAY, set the saved value "INT" to 2, and roll 
three six-sided dice, add 2, and subtract 1 from it. Your character will say
something like:

```
"9 = 3d6 (4,3,1) + INT (2) - 1"
```

### Installation from GitHub

Download the ZIP file by clicking the green "Clone or download" button on the 
left side, then click "Download ZIP". Extract the folder and place in your 
Addons directory, usually something like:

`C:\Program Files (x86)\World of Warcraft\Interface\AddOns`

### Commands

* **/ph**: Lists the commands in PHR. 
* **/phr**: Rolls dice using dice specifiers, numbers, and named modifiers stored beforehand. /phr 3d20 - 4 + INT" will roll three 20-sided dice, subtract 4, and add the number stored as "INT" (using /phs) to the result.
* **/phs**: Set a named value. "/phs AGI=-2" will store the value -2 with the key "AGI". When you add AGI to a roll, -2 will be substituted in. These values are stored per-character.
* **/phc**: Set the output channel for rolls and easter egg text. "/phc EMOTE" will cause rolls to be output as emotes. Available values are SILENT (only you will see the result), SAY, RAID, EMOTE and YELL.
