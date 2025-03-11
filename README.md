# Reflow4PLC
Reflow analyses a Twincat structured text code, asks for the state var and renumbers the state machine in 10 steps

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

## Disclaimer :
the script wont work if you do state:=state+1 syntaxis, its analyses the code for state:= and the 10:  notations.
Although it works it be wise to verify your state machine code with notepads++ file compare.
No monkeys have been killed for this product.
