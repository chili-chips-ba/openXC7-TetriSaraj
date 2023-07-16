# openXC7-TetriSaraj

**<h3> Tetris recap </h3>**

Even though most of us know what Tetris is and how to play it, let's start with a brief explanation of its logic and rules.

Tetris is a combinatorial game where a player maneuvers differently-shaped pieces (aka <i>'tetrominoes'</i>) as they descend onto the playing field. The objective is to complete the lines by filling them with <i>tetrominoes</i>. When a line is fully filled, it gets automatically cleared, and the player earns points. The player can then utilize the cleared space to continue the game. It's <i>Game Over</i> when the lines with gaps (thus not cleared) reach the top of the playing field. The longer a player can delay this outcome, the higher his/her score. In the multiplayer games, the players compete to outlast their opponent(s). 

![Typical_Tetris_Game](https://github.com/chili-chips-ba/openXC7-TetriSaraj/assets/113244867/bbd94950-8c0d-4dce-a1da-66681715f41d)

**<h3> TetriSaraj introduction </h3>**

For our <i>TetriSaraj</i>, the pieces (<i>tetrominoes</i>) are sliding in from from the sides, in the random fashion, so leaving less time to think about approach and strategy. While our pieces are <i>"falling"</i> horizontally from both sides, one at the time, the logic is otherwise the same as ordinary Tetris, and the objective is to complete vertical lines by filling them with <i>tetrominoes</i>.

  <img width="408" alt="tetrisaraj" src="https://github.com/chili-chips-ba/openXC7-TetriSaraj/assets/113244867/ceb74ee9-2ee2-461a-ab3f-e279f34bf71e">

**<h3> Development Methodology </h3>**

There are two main parts of our solution: HW and SW. To save time, and in the spirit of FPGA parallism, we've worked on them in parallel. 

The first development track was the construction of Basys3 SOC with soft-core CPU, complemented with our special, simple, yet capable <i>Mega-Character (MC) Video Controller</i> for game visualization. This work was undertaken by the HW (RTL in System Verilog) group within our team.

At the same time, the SW group was working out the game algorithm in the comfortable <i>WinOS PC Visual Studio</i> setting, where the hi-res graphic output was emulated on a low-res terminal, as illustrated in the image below:

  ![image](https://github.com/chili-chips-ba/openXC7-TetriSaraj/assets/113244867/146a804c-dc82-46a3-8c0f-a984b1f0f3dc)

When the logic of our game was fully worked out, we've switched to integration activities. Integration in this context is the merge of SW and HW track. 

Porting to the bare-metal RISC-V was a sizeable part of this integration/merge effort. To expedite the software iterations without having to rebuild the entire FPGA, we've developed a simple, robust and platform-agnostic own method for CPU program uploads <b>via UART</b>. That's a notable departure from what is used in most other projects:
  - <b>via JTAG</b>, directly into internal FPGA BRAM: 
     >> Not possible due to lack of openXC7 support for BSCANE2 Xilinx component
  - indirectly, into external <b>SPI Flash</b>, which CPU boot code then copies to on-chip BRAM
     >> Not possible with Basys3, due to shortsightedness of board designers, coupled with openXC7 shortcomings wrt STARTUPE2 Xilinx component

The beauty of our CPU code download method is that it's fully portable across FPGA vendors and boards -- It's without inherent dependencies on the special, vendor-specific IP.
     
Other than the terminal emulation of game logic, we opted out of logic simulation. Even the hardware team found it more productive to validate the Video Controller directly on the board, using test patterns much simpler than the final game, which they wrote in 'C', indepedently from the software team. 

The hard-core digital design puritans may declare it as a bad practice, and may even bring Formal into the fray, which we counter with: <i>Welcome to the world of full field programmability!</i> Joking aside, it was the nature and low complexity of the problem at hand that allowed us to take this shortcut -- The CPU was already proven, through both dynamic and static methods, taken as-is from the libary, and our brand new Video Controller design was a straight datapath, without large inter-connected FSMs, and without significant exceptions.

**<h3> Game logic </h3>**

This section is about the algorithm basics, i.e. the logic of the game. It's worth emphasizing that this the heart of our app, and stays the same for both full-fledged PC and bare-metal RISC-V implementation. 

The other SW parts are: <b>Game controls</b>, <b>Timing</b> and <b>Rendering</b>. They depened on the HW platform, and have to be adapted to it through porting process from PC host to embedded CPU. 

<i>Tetrominoes</i> are the essence of the Game logic element. They're illustrated in the figure below.

  ![image](https://github.com/chili-chips-ba/openXC7-TetriSaraj/assets/113244867/3f4bd9aa-19b2-46f8-92a8-beec3c671afe)

There are 7 primary <i>tetromino</i> shapes. Including rotations, we get to 28 different shapes. However, to save memory, we store only the original shapes, using a 7x16 matrix of 1s and 0s, where 1s represent blocks, and 0s represent empty space. For example, let's take the 2nd <i>tetromino</i>, the squared one, and write it row-by-row from left to right: <br />
       0, 0, 0, 0; <br />
       0, 1, 1, 0; <br />
       0, 1, 1, 0; <br />
       0, 0, 0, 0; <br />
This is clearly an array of 16 elements. Seven such arrays make the full primary <i>tetromino</i> set. The entire 40x30 playing field is stored in a similar array, for which we use "<i>field</i>" variable.

So, how can this 7x16 primary <i>tetromino</i> matrix account for all 28x16 rotations? The answer is: <i>By using algorithmic smarts in lieu of the brute force</i>. For that, we have <i>rotate</i> function with 3 input arguments: <b>X</b> coordinate, <b>Y</b> coordinate, and <b>R</b>otation. This function returns the <b>I</b>ndex of the so-rotated block in the original piece. We should note that the X, Y coordinates take values from 0..3; R is {0, 90, 180, 270}; and returned Index is 0..15. Rotation is executed clockwise.

For example, let's have a look at this shape and its rotations:
  ![rotacija_bez](https://github.com/chili-chips-ba/openXC7-TetriSaraj/assets/113244867/88ec5169-c7a7-4ad1-a3b8-18fb19fd305e)

The 1st piece is the original, primary <i>tetromino</i>. The remaining 3 are its rotations. We now want to find the Index in the original piece for the corresponding mutant with coordinates X=2, Y=1, R=90 degrees. The relation between shapes rotated by 90 degrees is: <i>"Index = 12 + Y - (X * 4)"</i>. Which means that this specific block is on Index=5 of the original piece. 

The same applies to other rotations and other figures. Let's now have a look at R=270 degrees. We observe the block on coordinates X=1, Y=2. The relation for this case is <i>"Index = 3 - Y + (X * 4)"</i>. That gives us 5 again, meaning that this specific block is the same as the block on Index 5 of the original piece.

So, what is the game logic? 

Upon receiving a game tick, we first look at the commands. If one of the command buttons is pressed, we try to move the piece in the specified direction, or rotate it. For that, we first check whether the moved-or-rotated piece can fit in the position the command wants it to be in. If it cannot fit, we lock the piece in the field /* write a shape-specific values in the <i>field</i> variable */, i.e. don't honor the command. 

If it can fit, we honor the command, check whether any vertical lines were formed, and store the X coordinates of the formed lines so we can delete them. The erasing of the vertical is straightforward -- We just set the current line to empty and move all lines "above" it to one place "below". When all this is done, we generate a new random piece. 

So, how do we check if the piece can fit in a specific position?! That's a 4-step process: <br />
    - find the correct Index in the rotated piece - variable "<i>pi</i>" in the function <br />
    - find the correct Index in the <i>field</i>  - variable "<i>fi</i>" in the function <br />
    - check the boundaries <br />
    - check if the piece can fit <br />
    
This fit test is done by checking if both: <br />
 - piece block on index <i>pi</i> <br />
 - and <i>field</i> block on index <i>fi</i> <br />
 are not empty. Both being not-empty means collision, for which our <i>DoesPieceFit</i> function returns <i>false</i>.

**<h3> Game timing </h3>**

The timing of the game is controlled by our own ticks. As the game progresses, the game ticks become more frequent, making it more challenging for the player.

On the PC side (implemented in C++), we use "<i>this_thread::sleep_for</i>" method, where the <i>sleep</i> is 50ms, and also a counter which we increment after the <i>sleep</i>. When the counter gets to a certain value (let's call it <i>speed</i>) we move our piece. This is one game tick. As the game progresses, and we've stacked a few blocks, the <i>speed</i> value decrements, which is perceived as a faster play. 

A similar method was used for Basys3. Except that, in the absence of "<i>this_thread::sleep_for</i>" there, we had to come up with our own embedded <i>sleep</i> methods. Other than that, the rest of the logic is the same. 

**<h3> Game controls </h3>**

On the PC side we used "<i>GetAsyncKeyState</i>" method to detect if a keyboard button was pressed. The controls are: <i>Left, Right, Up, Down arrow</i>, and <i>"Z" key for rotation</i>. Upon detecting that a key was pressed, we first check whether the piece can be moved at all. That's covered by "<i>DoesPieceFit</i>" function. 

The same logic applies to Basys3, where FPGA provides a GPIO register for the pushbuttons, from which we then read the button values. This is accomplished by "<i>GetButtonsState</i>" function.

**<h3> Rendering </h3>**

For video on the PC side we use <i>Windows.h</i> library to create a console screen and draw on it. This drawing is based on our <i>field</i> variable, which keeps the complete info about the playfield, with all the shapes on it, including the current game state. 

The video rendering on the FPGA side is a bit more complicated and involves writting into <i>MC Frame Buffer</i> registers from the same <i>field</i> variable.

**<h3> The Platform </h3>**

This HW/SW setup is more than the mere <i>TetriSaraj</i> game. It's a plaform, the solid foundation for developing other apps and retro games in the <b>40x30</b> <i>Mega-Character (MC) Frame Buffer</i> paradigm, yet with the full resolution graphics of the host board. We support <b>16 unique MCs</b>. The MCs can be viewed as mini-Sprites with course XY positioning. For more on this topic, see: https://www.youtube.com/watch?v=Pfy2vHygRaI .

Given Basys3 max resolution of 640x480 RGB444, one MC in this case is a 16x16 block with 4096 colors for each of its 256 dots. That's a rather impressive level of detail, given the meager memory footprint of our <i>MC Frame Buffer</i>. It would otherwise not be possible to accomodate such resolution even in the comparatively resourceful Artix7-35T.

For example, the 4x smaller, 12x less expensive TangNano9K could also easily host our game. On it, and without having to change the game logic, the same 40x30 <i>MC Frame Buffer</i> would be rendered on the considerably larger 1280x720 RGB888 HDMI screen, by using 32x24 MCs with 16,777,216 colors for each of its 768 dots. Other than the static load of the MCs, and slightly modified RTL for the video back-end, the rest remains the same. This makes for low-effort porting.  

The next section brings about additional detail on our HW platform, and its video sub-system in particular.

**<h3> Screen organization </h3>**
The video interface between hardware and software consists of:
- Screen of 640x480 RGB444 pixels divided into 40x30 (=1200) squares, each square being 16x16 pixels.
- Hardware implements a character set of 16 elements. Each element is a 16x16 pixel image in full RGB444 color palette, requiring 384 bytes of memory for one element.
- Software can program each of these 16 unique characters with arbitrary content.
- Software uses these 16 arbitrary characters through a 40x30 FrameBuffer, where each location is represented by 4 bits, indicating to the hardware which of the 16 characters to display at that location.
  
The image illustrating the screen organization is showed below.

![screen organization](https://github.com/chili-chips-ba/openXC7-TetriSaraj/assets/127020599/998e4dfb-b04a-4d86-b838-fc6c62dfbd28)


**<h3> Memory map </h3>**
One of the first steps involves creating a memory map that governs the interaction between the CPU software and the hardware responsible for rendering the 40x30 = 1200 elements on the screen. This memory map can be viewed as the Instruction Set Architecture (ISA) of our graphic mini-controller, serving as a contract or interface between the software and hardware components.

In this context, each element on the screen requires 4 bits of memory, while the CPU operates on a 32-bit architecture. Consequently, one CPU word can accommodate 8 elements. To represent a single line on the screen, we would need 5 such CPU words, as each line consists of 40 elements. Extrapolating this further, considering the entire screen, which comprises 30 lines, we would require a total of 5x30 = 150 CPU words to store the graphical information for the entire display.

By organizing the memory in this manner and establishing the memory map, we enable effective communication between the CPU software and the hardware, facilitating the rendering of graphics on the screen. This approach ensures efficient utilization of memory and allows the CPU to access and manipulate the graphical data in a structured and predictable manner, thereby enabling smooth and controlled display updates.

![cfb memory](https://github.com/chili-chips-ba/openXC7-TetriSaraj/assets/127020599/41f832c8-d255-4cda-9bbf-6e44ffb6d460)



