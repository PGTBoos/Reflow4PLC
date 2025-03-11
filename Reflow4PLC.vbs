' VBScript to renumber state machine states and state variable assignments with sequential, evenly spaced numbers
' Handles drag-and-drop functionality with customizable state variable name
' Preserves state 0 if it exists in the state machine
' Outputs mapping information to a separate file
' Usage: Drag and drop a file onto this script

' Check if a file was dropped on the script
If WScript.Arguments.Count = 0 Then
    MsgBox "Please drop a file onto this script.", vbExclamation, "No File Provided"
    WScript.Quit
End If

' Get the input file path from the dropped file
inputFilePath = WScript.Arguments(0)

' Prompt for the state variable name
stateVarName = InputBox("Enter the name of your state machine variable:" & vbCrLf & _
                        "(e.g. _state, currentState, nState, etc.)" & vbCrLf & vbCrLf & _
                        "Leave blank to use the default '_state'", _
                        "State Variable Name", "_state")

' If canceled, exit
If stateVarName = "" Then
    stateVarName = "_state" ' Default value
End If

' Create output file path by adding "_updated" before the extension
Set fso = CreateObject("Scripting.FileSystemObject")
inputFolder = fso.GetParentFolderName(inputFilePath)
inputFileName = fso.GetFileName(inputFilePath)
baseName = fso.GetBaseName(inputFilePath)
extension = fso.GetExtensionName(inputFilePath)

If extension <> "" Then
    outputFileName = baseName & "_updated." & extension
    mappingFileName = baseName & ".mapping.info.txt"
Else
    outputFileName = inputFileName & "_updated"
    mappingFileName = inputFileName & ".mapping.info.txt"
End If

outputFilePath = fso.BuildPath(inputFolder, outputFileName)
mappingFilePath = fso.BuildPath(inputFolder, mappingFileName)

' Increment value for renumbering (e.g., 10 for states like 10, 20, 30, etc.)
incrementValue = 10

' Read the input file
On Error Resume Next
Set inputFile = fso.OpenTextFile(inputFilePath, 1) ' 1 = ForReading
If Err.Number <> 0 Then
    MsgBox "Error opening file: " & Err.Description, vbCritical, "Error"
    WScript.Quit
End If
codeText = inputFile.ReadAll
inputFile.Close
On Error GoTo 0

' Regular expression for state transitions (stateVarName := X)
' Escape special characters in the stateVarName for regex
stateVarNameEscaped = stateVarName
stateVarNameEscaped = Replace(stateVarNameEscaped, "\", "\\")
stateVarNameEscaped = Replace(stateVarNameEscaped, ".", "\.")
stateVarNameEscaped = Replace(stateVarNameEscaped, "*", "\*")
stateVarNameEscaped = Replace(stateVarNameEscaped, "+", "\+")
stateVarNameEscaped = Replace(stateVarNameEscaped, "?", "\?")
stateVarNameEscaped = Replace(stateVarNameEscaped, "[", "\[")
stateVarNameEscaped = Replace(stateVarNameEscaped, "]", "\]")
stateVarNameEscaped = Replace(stateVarNameEscaped, "(", "\(")
stateVarNameEscaped = Replace(stateVarNameEscaped, ")", "\)")
stateVarNameEscaped = Replace(stateVarNameEscaped, "^", "\^")
stateVarNameEscaped = Replace(stateVarNameEscaped, "$", "\$")

Set stateAssignRegex = New RegExp
stateAssignRegex.Global = True
stateAssignRegex.IgnoreCase = True
stateAssignRegex.Pattern = stateVarNameEscaped & "\s*:=\s*(\d+)(?:\s*;|\s*$)" ' Ensures it's an actual assignment

' Find all state variable assignments
Set stateAssignMatches = stateAssignRegex.Execute(codeText)

' Create a dictionary to store validated state numbers
Set stateMap = CreateObject("Scripting.Dictionary")

' First collect state assignments - these are our primary indicators
For Each match In stateAssignMatches
    oldState = CInt(match.SubMatches(0))
    If Not stateMap.Exists(oldState) Then
        stateMap.Add oldState, 0 ' Temporary value, will be set correctly later
    End If
Next

' Check if any states were found
If stateMap.Count = 0 Then
    MsgBox "No state assignments (" & stateVarName & " := X) found in the file.", vbInformation, "No States Found"
    WScript.Quit
End If

' Now look for state labels only if they match our validated state numbers
For Each stateNum In stateMap.Keys
    ' Look for patterns like "10:" but only for numbers we found in state assignments
    statePattern = "(^|\n)\s*(" & stateNum & ")\s*:"
    
    Set stateLabelRegex = New RegExp
    stateLabelRegex.Global = True
    stateLabelRegex.IgnoreCase = True
    stateLabelRegex.Pattern = statePattern
    
    ' No need to store these matches, we just need them for replacement later
    Set labelMatches = stateLabelRegex.Execute(codeText)
Next

' Get unique state numbers and sort them
uniqueStates = stateMap.Keys
SortAscending uniqueStates

' Check if state 0 exists and needs to be preserved
hasStateZero = False
For Each oldState In uniqueStates
    If oldState = 0 Then
        hasStateZero = True
        Exit For
    End If
Next

' Assign new state numbers in sequence while preserving state 0 if it exists
stateIndex = 0 ' For tracking position in the sequence
For i = 0 To UBound(uniqueStates)
    oldState = uniqueStates(i)
    
    If oldState = 0 And hasStateZero Then
        ' Preserve state 0
        stateMap(oldState) = 0
    Else
        ' Increment stateIndex only for non-zero states
        stateIndex = stateIndex + 1
        newState = stateIndex * incrementValue
        stateMap(oldState) = newState
    End If
Next

' Create mapping information text for both display and file
mappingInfo = "State Machine Renumbering Mapping Information" & vbCrLf
mappingInfo = mappingInfo & "=====================================" & vbCrLf & vbCrLf
mappingInfo = mappingInfo & "Source file: " & inputFilePath & vbCrLf
mappingInfo = mappingInfo & "Date: " & Now & vbCrLf
mappingInfo = mappingInfo & "State variable: " & stateVarName & vbCrLf & vbCrLf
mappingInfo = mappingInfo & "Found " & stateMap.Count & " unique states." & vbCrLf

If hasStateZero Then
    mappingInfo = mappingInfo & "State 0 was preserved as it's typically used as an initial state." & vbCrLf
End If

mappingInfo = mappingInfo & vbCrLf & "State number mapping:" & vbCrLf
mappingInfo = mappingInfo & "--------------------" & vbCrLf
For Each oldState In uniqueStates
    mappingInfo = mappingInfo & "Old: " & oldState & " -> New: " & stateMap(oldState) & vbCrLf
Next

' Display summary for verification
displayInfo = "Found " & stateMap.Count & " unique states using variable '" & stateVarName & "'." & vbCrLf

If hasStateZero Then
    displayInfo = displayInfo & "State 0 will be preserved." & vbCrLf
End If

displayInfo = displayInfo & vbCrLf & "State number mapping:" & vbCrLf
For Each oldState In uniqueStates
    displayInfo = displayInfo & "Old: " & oldState & " -> New: " & stateMap(oldState) & vbCrLf
Next

mapResult = MsgBox(displayInfo & vbCrLf & _
                   "Is this mapping correct? Press Yes to continue with renumbering or No to cancel.", _
                   vbYesNo + vbQuestion, "Confirm Mapping")

If mapResult <> vbYes Then
    MsgBox "Operation cancelled by user.", vbInformation, "Cancelled"
    WScript.Quit
End If

' Write the mapping information to a file
On Error Resume Next
Set mappingFile = fso.CreateTextFile(mappingFilePath, True) ' True = Overwrite
If Err.Number <> 0 Then
    MsgBox "Error creating mapping file: " & Err.Description, vbExclamation, "Warning"
Else
    mappingFile.Write mappingInfo
    mappingFile.Close
End If
On Error GoTo 0

' Sort the state numbers in descending order for replacement
sortedOldStates = stateMap.Keys
SortDescending sortedOldStates

' Replace state numbers and state assignments in descending order
For Each oldState In sortedOldStates
    newState = stateMap(oldState)
    
    ' Skip replacement if the state number hasn't changed
    If oldState <> newState Then
        ' Replace state labels (e.g., "10:") with better boundary detection
        Set stateRegex = New RegExp
        stateRegex.Global = True
        stateRegex.IgnoreCase = True
        stateRegex.Pattern = "(^|\n)(\s*)(" & oldState & ")(\s*:)"
        codeText = stateRegex.Replace(codeText, "$1$2" & newState & "$4")
        
        ' Replace state assignments (e.g., "stateVarName := 10") with better boundary detection
        Set stateAssignRegex = New RegExp
        stateAssignRegex.Global = True
        stateAssignRegex.IgnoreCase = True
        stateAssignRegex.Pattern = "(" & stateVarNameEscaped & "\s*:=\s*)(" & oldState & ")(\s*;|\s*$)"
        codeText = stateAssignRegex.Replace(codeText, "$1" & newState & "$3")
    End If
Next

' Write the updated code to the output file
On Error Resume Next
Set outputFile = fso.CreateTextFile(outputFilePath, True) ' True = Overwrite
If Err.Number <> 0 Then
    MsgBox "Error creating output file: " & Err.Description, vbCritical, "Error"
    WScript.Quit
End If
outputFile.Write codeText
outputFile.Close
On Error GoTo 0

MsgBox "State machine renumbering complete!" & vbCrLf & vbCrLf & _
       "Input file: " & inputFilePath & vbCrLf & _
       "Output file: " & outputFilePath & vbCrLf & _
       "Mapping file: " & mappingFilePath, vbInformation, "Success"

' Function to sort an array in descending order
Sub SortDescending(arr)
    For i = 0 To UBound(arr) - 1
        For j = i + 1 To UBound(arr)
            If arr(i) < arr(j) Then
                temp = arr(i)
                arr(i) = arr(j)
                arr(j) = temp
            End If
        Next
    Next
End Sub

' Function to sort an array in ascending order
Sub SortAscending(arr)
    For i = 0 To UBound(arr) - 1
        For j = i + 1 To UBound(arr)
            If arr(i) > arr(j) Then
                temp = arr(i)
                arr(i) = arr(j)
                arr(j) = temp
            End If
        Next
    Next
End Sub
