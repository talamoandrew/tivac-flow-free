# tivac-flow-free

This repo contains the code for an implementation of the game Flow Free which runs on a Texas Instruments TM4C123GH6PM Microcontroller.  The game is programmed entirely in ARM Assmebly.

How to play: https://youtu.be/Odi--hU9QOg

To play the game you need:

- Tiva-C MCU (TM4C123GH6PM)
- Keyboard
- Code Composer Studio
- PuTTy or alternative terminal to output the game to

To start the game:
- Plug in the MCU via USB to your computer
- Open PuTTy (or whatever terminal program you choose to use) and start a terminal with the COM port associated with your MCU
- Open the project in Code Composer Studio
- Run the code
- When the game is running, start by pressing space to pick a random board
- Use W,A,S,D to move the cursor around the board and press space to select/unselect a color to draw with
- You can use the on board button to pause or restart or press Q to quit the game
- The game ends once all boards are completed

  
