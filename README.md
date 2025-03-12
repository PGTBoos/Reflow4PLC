# Reflow4PLC
Reflow analyses a Twincat structured text code, asks for the state var and renumbers the state machine in 10 step size.  
Or in a different step size say 25 or 100 or 42 etc. 

## Usage 
1) copy the structured code in a txt file.  
2) Drop that txt file onto the script.  
3) A popup will ask you for the name of the variable in your state machine.  
4) a mapping popup is shown

In the location from where you saved the original txt 2 new files will be made.
(the script and the txt files dont have to be in the same folder).

**End result**
- **{yourfilename}_updated.txt**,  here the new code will be outputted to
- **{yourfilename}_mapping.info.txt**, shows a mapping overview (as in the popup)

This is how the mapping info looks like :

~~~
State Machine Renumbering Mapping Information  
=====================================  
  
Source file: \\xxx\xx\xxxxxxx\xxxx\xxxxxx\oldcode.txt  
Date: 12/03/2025 08:53:31  
State variable: _state  
Step size: 10  
  
Found 12 unique states.  
State 0 was preserved as it's typically used as an initial state.  
  
State number mapping:  
--------------------  
Old: 0 -> New: 0  
Old: 5 -> New: 10  
Old: 8 -> New: 20  
Old: 10 -> New: 30  
Old: 11 -> New: 40  
Old: 12 -> New: 50  
Old: 13 -> New: 60   
Old: 14 -> New: 70  
Old: 25 -> New: 80  
Old: 30 -> New: 90  
Old: 50 -> New: 100  
Old: 60 -> New: 110  
~~~

## Disclaimer :
This code is  : Mostly harmless 

The script wont work if you do state:=state+1 syntaxis, it analyses the code for state:= and the 10:  notations.  
Although it works fine, it be wise to verify your state machine code with notepads++ file compare.  

No monkeys (or cats) have been killed for this product.  
Any monkey (or cat) can use this code for free cc0.  
Monkey be warned that you use this at your own risk, (cats you dont know what risks mean).

Dont worry to much as your opriginal code is still in your folder/coding cave.
Be sure to test your code.

