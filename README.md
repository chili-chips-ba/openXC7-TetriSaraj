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
We'll just store the original 7 shapes in a matrix (7x16) of 1s and 0s, where 1s represent blocks and 0s represent empty space. For example we can take the 2nd tetromino, squared one, and write it row by row going from left to right: 0, 0, 0, 0; 0, 1, 1, 0; 0, 1, 1, 0 ; 0, 0, 0, 0; and then we store this as an array of 16 elements. We do this for all shapes.

Now that we have shapes written inside of a 7x16 matrix, how can we handle the rotation?

Basically, we "rotate" block by block or better said we return the index of the rotated pixel on original shape. For example, let's have a look at this shape:

![image](https://github.com/chili-chips-ba/openXC7-TetriSaraj/assets/113244867/7cb8b1d4-f416-4e36-8ed8-bdb3f070f1d6)

The original shape is the first one and when we rotate it clockwise we get 3 different shapes. Let's observe marked block, since "rotation" is being executed block by block. The coordinates of the marked block in the 1st shape are 1 and 1 and when we call the rotation function we get index 9. How is it 9 shouldn't it be 5? Basically our function thinks of the 1st shape as the rotated one and the 4th one is the original. You can see if we rotate 4th one by 90 degrees clockwise we get the 1st one. And that means the coordinates of a rotated block are 1 and 1 and that is the same block as block 9 on 4th shape.
