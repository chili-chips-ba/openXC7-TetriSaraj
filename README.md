# openXC7-TetriSaraj
Xilinx Basys3 demo for how to use openXC7 open-source tools to implement a RISC-V SoC + SW for this classic game, now with a twist.

**<h3> Tetris recap </h3>**

Most of us know what is Tetris and how it's played, but here is a short introduction for those who don't. Tetris is a game where players maneuver differently shaped pieces called tetrominoes as they descend onto the playing field. The objective is to complete lines by filling them with tetrominoes. When a line is completed, it disappears, and the player earns points. The player can then utilize the cleared spaces to continue playing. The game ends if the lines reach the top of the playing field without being cleared. The longer the player can delay this outcome, the higher their score. In multiplayer games, players compete to outlast their opponents. 

![Typical_Tetris_Game](https://github.com/chili-chips-ba/openXC7-TetriSaraj/assets/113244867/bbd94950-8c0d-4dce-a1da-66681715f41d)

**<h3> TetriSaraj introduction </h3>**

TetriSaraj is Tetris-like game where the pieces(tetrominoes) are not coming from the top but from sides. The side chosing is completely random so that gives a player less time to think. Pieces are "falling" horizontally from both sides one at the time and the logic is the same. The objective is to complete vertical lines by filling them with tetrominoes.

<img width="408" alt="tetrisaraj" src="https://github.com/chili-chips-ba/openXC7-TetriSaraj/assets/113244867/ceb74ee9-2ee2-461a-ab3f-e279f34bf71e">

**<h3> Game logic of TetriSaraj </h3>**

The implementation contains 4 main phases:
- Game timing
- Game controls
- Game logic
- Rendering

We will go through each one of these phases in detail. In this section we'll just go through Game logic phase since it's common for both implementations - the PC one and the Basys3 one.

Let's start with tetrominoes, they're shown on the image below.

![image](https://github.com/chili-chips-ba/openXC7-TetriSaraj/assets/113244867/3f4bd9aa-19b2-46f8-92a8-beec3c671afe)

As you can see there are 7 shapes in Tetris as well as TetriSaraj and when you include rotation we get 28 different shapes, so how can we store them? 
We'll just store the original 7 shapes in a matrix (7x16) of 1s and 0s, where 1s represent blocks and 0s represent empty space. For example we can take the 2nd tetromino, squared one, and write it row by row going from left to right: 0, 0, 0, 0; 0, 1, 1, 0; 0, 1, 1, 0 ; 0, 0, 0, 0; and then we store this as an array of 16 elements. We do this for all shapes. As for the playing field, infos about i t are kept in the array named "field".

Now that we have shapes written inside of a 7x16 matrix, how can we handle the rotation?

Basically, we "rotate" block by block or better said we return the index of the rotated pixel on original shape. For example, let's have a look at this shape:

![image](https://github.com/chili-chips-ba/openXC7-TetriSaraj/assets/113244867/7cb8b1d4-f416-4e36-8ed8-bdb3f070f1d6)

The original shape is the 1st one and when we rotate it clockwise we get 3 different shapes. Let's observe marked block, since "rotation" is being executed block by block. The coordinates of the marked block in the 1st shape are 1 and 1 and when we call the rotation function we get index 9. How is it 9 shouldn't it be 5? Basically our function thinks of the 1st shape as the rotated one and the 4th one is the original. You can see if we rotate 4th one by 90 degrees clockwise we get the 1st one. And that means the coordinates of a rotated block are 1 and 1 and that is the same block as block 9 on 4th shape. The relation between shapes rotated by 90 degrees is: "index = 12 + y - (x * 4)"

The same applies to other rotations and other figures. 

So what's the game logic? After a game tick happened we first look at the commands (more about them in the chapter below). If one of them is pressed we try to move the piece in that direction or rotate it. So first we check if it can fit on the position we want to move it on. Let's say it cannot fit. Then we have to lock the piece in the field (write some shape specific values in the field variable). After that we have to check if any lines were formed and store the x coordinates of the formed lines so we can delete them. The lines erasing is relatively easy, we just need to set the current line to empty and move all lines, that are "above" it, one place "below". After all that we generate a new random piece. 

**<h3> Game timing and controls of TetriSaraj </h3>**
As for the timing of the game, we used our own game ticks. As the game progresses the game ticks become more frequent, how did we achive this? So for the PC side (implemented in C++), we used "this_thread::sleep_for" method where the sleep is 50ms and also a counter we increment after the sleep. When the counter gets to a certain value (let's call it speed) we move our piece and this is one game tick. As the game progresses and we've stacked few blocks speed value decrements and the game gets faster. The similar thing was done on Basys3 board, but since we don't have access to "this_thread::sleep_for" method we had to improvize with our own sleep methods. But the rest of the logic is the same.

As for the controls, on the PC side we used "GetAsyncKeyState" method to detect if some keyboard buttons were pressed. The controls are: left, right and up arrow and Z key for rotation. So when we detect some key was pressed we first need to check if the piece can be moved at all. That's covered by "DoesPieceFit" function. The same logic applies to Basys3 implementation, but we have to create a gpio register on FPGA side and then read the register values. This is done by "GetButtonsState" function.

**<h3> Rendering of TetriSaraj </h3>**
For video on PC side we use Windows.h library, where we can create a console screen and draw on it. We said that we keep the info about playing field, where all the shapes are and everything else, so using that we draw on the screen. For the FPGA side, this was a bit more complicated, but as for the C side, we kept the info in the same matrix (field) and we wrote these values to a register on FPGA side. The details will be explained in the next chapters. The PC console TetriSaraj is shown below:

![image](https://github.com/chili-chips-ba/openXC7-TetriSaraj/assets/113244867/146a804c-dc82-46a3-8c0f-a984b1f0f3dc)

