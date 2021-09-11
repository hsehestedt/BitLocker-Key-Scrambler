' BitLocker Key Scrambler
'
' Version 1.0.1.2
' September 11, 2021

Option _Explicit
Rem $DYNAMIC
$ExeIcon:'lock.ico'
$Console:Only
_Source _Console
Width 120, 30
Option Base 1
_ConsoleTitle "BitLocker Key Scrambler 1.0.1.2 by Hannes Sehestedt"

BeginProgram:
Clear

Dim BitLockerKey As String ' Original BitLocker key
Dim Comment As String ' User comment to be saved to file along with key
Dim CryptoCount As Integer ' Counter
Dim CryptoKey As String ' Key used to scramble / unscramble BitLocker key
Dim CryptoKeyLength As Integer ' Length of the Crypto Key supplied by the user
Dim ff As Integer ' Stores the number of first available free file number
Dim ScrambledKey As String ' Used to store the key after encryption / decryption
Dim Operation As Integer ' Set to "1" to scramble, "2" to unscramble
Dim ProgramStartDir As String ' Stores the location from which the program is run
Dim Shared RawBitLockerKey As String ' BitLocker key with dashes stripped off
Dim RunAgain As String ' Yes or No response when asked if program should be run again
Dim SaveAComment As String ' Will be set to "Y" if user wants to save a comment, "N" if not
Dim SaveKey As String ' Save a Yes or No response indicating whether to save the scrambled / unscrambled key to a file
Dim Temp As String ' Temporary storage
Dim Shared TestStatus As Integer
Dim x As Integer ' General purpose variable used as counter in FOR NEXT loops
Dim Shared YN As String ' Yes or No response from user

' Save the location from which the program is being run. If user wants to save key to a file, it will be saved here.

ProgramStartDir$ = _CWD$

' Gather all the data needed from user

GetBitLockerKey:
Do
    ClearScreen
    Print "Please enter the BitLocker key to scramble or the scrambled key to unscramble."
    Print "You can enter the key with or without dashes in it."
    Print
    Print "Enter HELP for help in using this program."
    Print
    Input "Enter key: ", BitLockerKey$
Loop While BitLockerKey$ = ""

If UCase$(Left$(BitLockerKey$, 4)) = "HELP" Then
    ClearScreen
    Print "Assume you use a laptop that uses BitLocker encryption. What would you do if you ran into a situation where you had"
    Print "to supply your BitLocker recovery key?"
    Print
    Print "This program will perform a very simple scramble operation on your BitLocker recovery key so that you can safely carry"
    Print "a copy of the key with you without worrying that your key will be compromised if someone gets your scrambled key. You"
    Print "can easily unscramble the key even if you don't have access to another computer or this program. Assume that you have"
    Print "the following key: 000000-111111-222222-333333-444444-777777-888888-999999. You run this program and provide 1097 as"
    Print "the crypto key to scramble your recovery key with. The program will repeat the value that you specify repeatedly"
    Print "until you have 48 digits (the length of the BitLocker Key). This key is placed below the BitLocker key like this:"
    Print
    Print "000000-111111-222222-333333-444444-777777-888888-999999"
    Print "109710 971097 109710 971097 109710 971097 109710 971097"
    Print
    Print "Now simply add the upper and lower numerals and write the result. If the number is greater than 9, simply drop the 1"
    Print "from the tens column. In this example, the result would look like this:"
    Print
    Print "000000-111111-222222-333333-444444-777777-888888-999999"
    Print "109710 971097 109710 971097 109710 971097 109710 971097"
    Print "-------------------------------------------------------"
    Print "109710-082108-321932-204320-543154-648764-987598-860986"
    Print
    Print "The result is the scrambled key.To unscramble, simply reverse the process and subtract the line with your repeating"
    Print "crypto key from the scrambled key. When subtracting a number would take you below zero just act as if the upper"
    Print "number had ten added to it."
    Print
    Print "Example: 3 - 4 would result in 9 (as if the 3 was actually 13)."
    Pause
    ClearScreen
    Print "Of course, you can always use this program to unscramble your scrambled key if you have access to another computer and"
    Print "this program, but the whole point is that the process is very easy to reverse manually but still secure since only you"
    Print "know the crypto key used to scramble and unscramble the BitLocker recovery key."
    Pause
    GoTo GetBitLockerKey
End If

BitLockerKey$ = LTrim$(RTrim$(BitLockerKey$))
TestBitLockerKey (BitLockerKey$)

If TestStatus = 0 Then
    ClearScreen
    Print "You did not enter a valid key. The key must contain 48 numerical digits or 8 groups of 6 numerical digits"
    Print "seperated by dashes."
    Print
    Print "Please enter a valid key."
    Pause
    GoTo GetBitLockerKey
End If

' If BitLockerKey$ is 55 characters long then it already has dashes in it. If it does not, then add dashes so that
' it is properly formatted for later. Note that RawBitLockerKey$ now holds the key with all dashes removed.

If Len(BitLockerKey$) = 48 Then
    Temp$ = "" ' Set initial value to an empty string
    For x = 1 To 48
        Temp$ = Temp$ + Mid$(BitLockerKey$, x, 1)
        Select Case x
            Case 6, 12, 18, 24, 30, 36, 42
                Temp$ = Temp$ + "-"
        End Select
    Next x
    BitLockerKey$ = Temp$
End If

GetCryptoKey:

ClearScreen
Input "Enter the Crypto key to scramble or unscramble with. Enter 4 to 12 numerals only: ", CryptoKey$
CryptoKey$ = LTrim$(RTrim$(CryptoKey$))
CryptoKeyValidityCheck (CryptoKey$)

If TestStatus = 0 Then
    ClearScreen
    Print "You did not enter a valid key. The key must be between 4 and 12 numerical digits in length."
    Print
    Print "Please enter a valid key."
    Pause
    GoTo GetCryptoKey
End If

Do
    ClearScreen
    Print "Are we scrambling a bitlocker key or unscrambling an already scrambled key?"
    Print
    Print "Enter 1 to Scramble"
    Print "Enter 2 to Unscramble"
    Print
    Input "Scramble or unscramble? ", Operation
Loop While Operation <> 1 And Operation <> 2

' Set initial values, organize arrays, declare varaibles

ScrambledKey$ = ""
CryptoKeyLength = Len(CryptoKey$)

' Store each individual digit of the Crypto Key and the Bitlocker Key in arrays

Dim CryptoKeyArray(CryptoKeyLength) As Integer
Dim BitLockerKeyArray(48) As Integer

For x = 1 To CryptoKeyLength
    CryptoKeyArray(x) = Val(Mid$(CryptoKey$, x, 1))
Next x

For x = 1 To 48
    BitLockerKeyArray(x) = Val(Mid$(RawBitLockerKey$, x, 1))
Next x

' Based upon the choice made by the user, go to the routine to scramble or unscramble

Select Case Operation
    Case 1
        GoTo Scramble
    Case 2
        GoTo Unscramble
End Select

' If we reach this point, then neither encryption or decryption was selected. Exit the program.

End

Scramble:

' This routine will encrypt an existing bitlocker key using the Crypto Key provided.

CryptoCount = 0

For x = 1 To 48
    CryptoCount = CryptoCount + 1
    If CryptoCount > CryptoKeyLength Then CryptoCount = 1
    BitLockerKeyArray(x) = BitLockerKeyArray(x) + CryptoKeyArray(CryptoCount)
    If BitLockerKeyArray(x) > 9 Then BitLockerKeyArray(x) = BitLockerKeyArray(x) - 10
Next x

For x = 1 To 48
    ScrambledKey$ = ScrambledKey$ + LTrim$(Str$(BitLockerKeyArray(x)))
    Select Case x
        Case Is = 6, 12, 18, 24, 30, 36, 42
            ScrambledKey$ = ScrambledKey$ + "-"
    End Select
Next x

Print
Print "The scrambled key is: "; ScrambledKey$
Pause
GoSub SaveKeyToFile

RunAgain:
ClearScreen
Do
    Input "Would you like to run the program again"; RunAgain$
Loop While RunAgain$ = ""

YesOrNo RunAgain$

Select Case YN$
    Case "X"
        GoTo RunAgain
    Case "Y"
        GoTo BeginProgram
    Case "N"
        Exit Select
End Select

GoTo EndProgram

Unscramble:

' This routine will decrypt an encrypted bitlocker key using the Crypto Key provided.

CryptoCount = 0

For x = 1 To 48
    CryptoCount = CryptoCount + 1
    If CryptoCount > CryptoKeyLength Then CryptoCount = 1
    BitLockerKeyArray(x) = BitLockerKeyArray(x) - CryptoKeyArray(CryptoCount)
    If BitLockerKeyArray(x) < 0 Then BitLockerKeyArray(x) = BitLockerKeyArray(x) + 10
Next x

For x = 1 To 48
    ScrambledKey$ = ScrambledKey$ + LTrim$(Str$(BitLockerKeyArray(x)))
    Select Case x
        Case Is = 6, 12, 18, 24, 30, 36, 42
            ScrambledKey$ = ScrambledKey$ + "-"
    End Select
Next x

Print
Print "Unscrambled key is: "; ScrambledKey$
Pause
GoSub SaveKeyToFile

RunAgain2:

ClearScreen
Do
    Input "Would you like to run the program again"; RunAgain$
Loop While RunAgain$ = ""

YesOrNo RunAgain$

Select Case YN$
    Case "X"
        GoTo RunAgain2
    Case "Y"
        GoTo BeginProgram
    Case "N"
        Exit Select
End Select

' End of main program

GoTo EndProgram


' Local subroutines


SaveKeyToFile:

' This procedure will ask user if they want to save the scrambled or unscrambled key to a file.
' If no file by the name of "Key.txt" exists in the location from where the program was run
' the we will create a file to which the key will be saved. Otherwise, we will append the key
' to the existing file without deleting the previous file.

ClearScreen

Do
    Input "Do you want to save a copy of this key to a file for easy access"; SaveKey$
Loop While SaveKey$ = ""

YesOrNo SaveKey$
SaveKey$ = YN$
Select Case SaveKey$
    Case "X"
        GoTo SaveKeyToFile
    Case "Y"

        ' User wants to save a comment. Get the comment from user

        GetComment:

        Do
            ClearScreen
            Input "Do you want to save a comment along with the key"; SaveAComment$
        Loop While SaveAComment$ = ""

        YesOrNo SaveAComment$
        SaveAComment$ = YN$

        Select Case YN$
            Case "X"
                GoTo GetComment
            Case "Y"
                Do
                    ClearScreen
                    Input "Please enter your comment: ", Comment$
                Loop While Comment$ = ""
            Case "N"

                ' If user does not want to save a comment, make sure that Comment$ is an empty string.

                Comment$ = ""
        End Select

        ff = FreeFile

        If _FileExists(ProgramStartDir$ + "\Key.txt") Then
            Open (ProgramStartDir$ + "\Key.txt") For Append As #ff
        Else
            Open (ProgramStartDir$ + "\Key.txt") For Output As #ff
        End If

        Print #ff, "---------------------------------------------------------------------------"
        Print #ff, "Key saved on "; Date$; " at "; Time$

        ' If the user supplied a comment, save it to the file.

        If Comment$ <> "" Then
            Print #ff, "Comment: "; Comment$
        End If

        Print #ff, "Original Key:    "; BitLockerKey$

        If Operation = 1 Then
            Print #ff, "Scrambled Key:   ";
        Else
            Print #ff, "Unscrambled Key: ";
        End If

        Print #ff, ScrambledKey$
        Print #ff, "Crypto Key:      "; CryptoKey$
        Print #ff, "---------------------------------------------------------------------------"
        Print #ff, ""
        Close #ff

        ClearScreen
        Print "Key has been saved to the following file:"
        Print
        Color 0, 10: Print ProgramStartDir$; "\Key.txt": Color 15
        Print
        Print "If this file was already present, this key was added to the file. Previously saved keys have NOT been erased."
        Print "The crypto key you supplied is also saved to this file so make sure to ";: Color 0, 10: Print "PROTECT THIS FILE!": Color 15
        Pause
    Case "N"
        Exit Select
End Select

Return

' END Local Subroutines


EndProgram:

System


' Sub Procedures


Sub Pause

    ' Displays one blank line and then the message "Press any key to contine"

    Print
    Shell "pause"
End Sub


Sub YesOrNo (YesNo$)

    ' This routine checks whether a user responded with a valid "yes" or "no" response. The routine will return a capital "Y" in YN$
    ' if the user response was a valid "yes" response, a capital "N" if it was a valid "no" response, or an "X" if not a valid response.
    ' Valid responses are the words "yes" or "no" or the letters "y" or "n" in any case (upper, lower, or mixed). Anything else is invalid.

    Select Case UCase$(YesNo$)
        Case "Y", "YES"
            YN$ = "Y"
        Case "N", "NO"
            YN$ = "N"
        Case Else
            YN$ = "X"
    End Select

End Sub


Sub ClearScreen

    ' When a QB64 program is run with display going to the Windows console rather than the Program Console,
    ' the CLS command will not work. This will issue a CLS from the Windows console.

    Shell Chr$(34) + "cls" + Chr$(34)

End Sub


Sub CryptoKeyValidityCheck (CryptoKey$)

    ' Send the crypo key entered by the user to this routine. This routine will verify that the key is
    ' made up of between 4 and 12 numerical digits. If the test passes, then the variable TestStatus will
    ' be set to 1, if it fails it will be set to 0.

    Dim x As Integer
    Dim valid As Integer

    If Len(CryptoKey$) < 4 Or Len(CryptoKey$) > 12 Then
        TestStatus = 0
        GoTo EndValidityCheck
    End If

    For x = 1 To Len(CryptoKey$)
        If Val(Mid$(CryptoKey$, x, 1)) = 0 And Mid$(CryptoKey$, x, 1) <> "0" Then
            valid = 0
        Else
            valid = 1
        End If

        If valid = 0 Then
            TestStatus = 0
            Exit For
        Else
            TestStatus = 1
        End If
    Next x

    EndValidityCheck:

End Sub


Sub TestBitLockerKey (Key$)

    ' Send the BitLocker key or the encrypted key entered by the user to this routine. This routine will
    ' verify that the key is made up of either 48 numerical characters. The key can also be supplied
    ' as 8 groups of 6 characters per group deperated with dashes. The variable TestStatus will be set to
    ' 1 if valid, if it fails it will be set to 0. The key with dashes stripped away will be returned in
    ' RawBitLockerKey$.

    Dim x As Integer
    Dim valid As Integer
    RawBitLockerKey$ = ""
    If Len(Key$) <> 48 And Len(Key$) <> 55 Then
        TestStatus = 0
        GoTo EndValidityCheck2
    End If

    ' Strip off any dashes

    If Len(Key$) = 55 Then
        For x = 1 To 55
            If Mid$(Key$, x, 1) <> "-" Then
                RawBitLockerKey$ = RawBitLockerKey$ + Mid$(Key$, x, 1)
            End If
        Next x
    Else
        RawBitLockerKey$ = Key$
    End If

    ' With all dashes stripped off, we should now have a string 48 characters long

    If Len(RawBitLockerKey$) <> 48 Then
        TestStatus = 0
        GoTo EndValidityCheck2
    End If

    For x = 1 To Len(RawBitLockerKey$)
        If Val(Mid$(RawBitLockerKey$, x, 1)) = 0 And Mid$(RawBitLockerKey$, x, 1) <> "0" Then
            valid = 0
        Else
            valid = 1
        End If

        If valid = 0 Then
            TestStatus = 0
            Exit For
        Else
            TestStatus = 1
        End If
    Next x

    EndValidityCheck2:

End Sub


' END Sub Procedures


' Version History
'
' 1.0.0.1 - Sep 10, 2021
' Initial Release
'
' 1.0.1.2 - Sep 11, 2021
' If the user chooses to save the scrambled / unscrambled key to a file, we will now ask if they would like to
' save a comment as well. We also made the output to file look a bit better. Also fixed a couple minor bugs
' that caused display of data to be a little sloppy.

