# openXC7-TetriSaraj
Xilinx Basys3 demo for how to use openXC7 open-source tools to implement a RISC-V SoC + SW for this classic game, now with a twist.

**<h3> Tetris recap </h3>**

Most of us know what is Tetris and how it's played, but here is a short introduction for those who don't. Tetris is a game where players maneuver differently shaped pieces called tetrominoes as they descend onto the playing field. The objective is to complete lines by filling them with tetrominoes. When a line is completed, it disappears, and the player earns points. The player can then utilize the cleared spaces to continue playing. The game ends if the lines reach the top of the playing field without being cleared. The longer the player can delay this outcome, the higher their score. In multiplayer games, players compete to outlast their opponents. 

![Typical_Tetris_Game](https://github.com/chili-chips-ba/openXC7-TetriSaraj/assets/113244867/bbd94950-8c0d-4dce-a1da-66681715f41d)

**<h3> TetriSaraj introduction <h3/>**

TetriSaraj is Tetris-like game where the pieces(tetrominoes) are not coming from the top but from sides. The side chosing is completely random so that gives a player less time to think. Pieces are "falling" horizontally from both sides one at the time and the logic is the same. The objective is to complete vertical lines by filling them with tetrominoes.

<img width="408" alt="tetrisaraj" src="https://github.com/chili-chips-ba/openXC7-TetriSaraj/assets/113244867/ceb74ee9-2ee2-461a-ab3f-e279f34bf71e">

**<h3> Math and ga,e logic behind TetriSaraj <h3/>**
