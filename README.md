# BitLocker-Key-Scrambler
Scrambles / Unscrambles a BitLocker recovery key so you can safely keep it with you or your system

I carry a laptop that has BitLocker encryption on the entire hard disk. On a few occasions I have done something that caused Windows to ask me for the BitLocker recovery key before the system was allowed to boot.

In those instances I was lucky because I had access to another machine where I could lookup my key. But what would I do if I was away and didn't have access to another machine?

Now, I have a sticker on the bottom of my laptop that has a scrambled version of my recovery key on it. That key is no use to anyone but me because only I know how to unscramble it. 

So now, I have an easy, readily accessible and secure recovery method on hand.

Here is how this works:

Assume that you have the following key: 000000-111111-222222-333333-444444-777777-888888-999999. You run this program and provide 1097 as the crypto key to scramble your recovery key with. The program will repeat the value that you specify repeatedly until you have 48 digits (the length of the BitLocker Key). This key is placed below the BitLocker key like this:

 000000-111111-222222-333333-444444-777777-888888-999999  
 109710-971097-109710-971097-109710-971097-109710-971097  
   
Now simply add the upper and lower numerals and write the result. If the number is greater than 9, simply drop the 1 from the tens column. In this example, the result would look like this:
  
 000000-111111-222222-333333-444444-777777-888888-999999  
 109710-971097-109710-971097-109710-971097-109710-971097  
"-------------------------------------------------------------------------"  
 109710-082108-321932-204320-543154-648764-987598-860986
   
The result is the scrambled key.To unscramble, simply reverse the process and subtract the line with your repeating crypto key from the scrambled key. When subtracting a number would take you below zero just act as if the upper number had ten added to it.

Example: 3 - 4 would result in 9 (as if the 3 was actually 13).

Of course, you can always use this program to unscramble your scrambled key if you have access to another computer and this program, but the whole point is that the process is very easy to reverse manually but still secure since only you know the crypto key used to scramble and unscramble the BitLocker recovery key.

After scrambling or unscrambling a BitLocker key, you will be given the opportunity to save the information to a file. The file will contain the original key, the crypto key you supplied to either scramble or unscramble the BitLocker key, the resulting key after the scramble / unscramble operation, and any comment you wish to provide.
