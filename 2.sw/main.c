/*
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include "uart.h"

#define RAM_TOTAL 0x4000 // 16 KB

#define reg_uart_clkdiv (*(volatile uint32_t*)0x02000004)
#define reg_uart_data (*(volatile uint32_t*)0x02000008)

#define reg_gpio (*(volatile uint32_t*) 0x03000000)
#define reg_video_char	((volatile uint32_t*)0x05100000)
#define reg_video_map	((volatile uint32_t*)0x05200000)
//#define reg_video_xofs  (*(volatile uint32_t*)0x05000000)
//#define reg_video_yofs  (*(volatile uint32_t*)0x05000004)

#define BUTTON_UP 0x01
#define BUTTON_RIGHT 0x02
#define BUTTON_LEFT 0x04
#define BUTTON_DOWN 0x08
#define BUTTON_CENTER 0x10

// --------------------------------------------------------

uint8_t buttons;

/* Private functions */
static void delay_ms(int);
static void chars_init(void);
static void board_init(void);
static void get_input(void);

#define DELAY   122000  // Equivalent to 1 msec
static uint32_t delay = 0;
static uint8_t x = 0;
static uint8_t y = 0;
static uint8_t z = 0;

int nFieldWidth = 40;
int nFieldHeight = 30;
uint16_t pField[1200];

void get_input() {  
	buttons = (uint8_t)(reg_gpio >> 16)&0xFF;
}

void board_init() {
	
		for (int y = 0; y < 30; y++) 
			for (int x = 0; x < 40; x++) // Board Boundary
			{
				if(y==1 || y==30 || x+1==40/2 || x==40/2){
					reg_video_map[y*40+x]=15;
				}
				else{
					reg_video_map[y*40+x]=14;
				}
			
			}

	//reg_video_map[0] = 1; 			// Green square	on the corner x = 0, y = 0
	//reg_video_map[39] = 4; 			// Yellow square on the corner x = 39, y = 0
	//reg_video_map[29*40+0] = 14; 	// White square	on the corner x = 0, y = 29
	//reg_video_map[29*40+39] = 15; 	// Black square on the corner x = 39, y = 29

}

void chars_init() {
	uint32_t pixel = 0x00000FFF;
	for(int z=0; z<16; z++) {
		for(int y=0; y<16; y++) {
			for(int x=0; x<16; x++) {
				if(z == 0) {
					if(x==0 || x==15) pixel = 0x00000FF0;
					else if (y==0 || y==15) pixel = 0x000000F0;
					else pixel = 0x00000F00;				
				} else if(z == 1) {
					pixel = 0x000000F0;
				} else if(z == 2) {
					pixel = 0x0000000F;
				} else if(z == 3) {
					pixel = 0x00000AAA;
				} else if(z == 4) {
					pixel = 0x00000FF0;
				} else if(z == 5) {
					pixel = 0x000000FF;
				} else if(z == 6) {
					pixel = 0x00000F0F;
				} else if(z == 7) {
					pixel = 0x00000A00;		
				} else if(z == 8) {
					pixel = 0x000000A0;		
				} else if(z == 9) {
					pixel = 0x0000000A;		
				} else if(z == 10) {
					pixel = 0x00000EEE;		
				} else if(z == 11) {
					pixel = 0x00000AA0;		
				} else if(z == 12) {
					pixel = 0x000000AA;		
				} else if(z == 13) {
					pixel = 0x00000A0A;
				} else if(z == 14) {
					pixel = 0x00000FFF;					
				} else {
					pixel = 0x00000000;
				}
				reg_video_char[z*256+y*16+x] = pixel;
			}
		}	
	}
}

void delay_ms(int msec) {
	for(int i=0; i<msec; i++) {
		delay = 0;
		while (delay < DELAY) {
			delay = delay + 1;
		}
	}
}
// Dodajemo nas dio 
uint8_t tetromino[7][16]={{0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0},
					      {0,0,1,0,0,1,1,0,0,0,1,0,0,0,0,0},
					      {0,0,0,0,0,1,1,0,0,1,1,0,0,0,0,0},
						  {0,0,1,0,0,1,1,0,0,1,0,0,0,0,0,0},
						  {0,1,0,0,0,1,1,0,0,0,1,0,0,0,0,0},
						  {0,1,0,0,0,1,0,0,0,1,1,0,0,0,0,0},
						  {0,0,1,0,0,0,1,0,0,1,1,0,0,0,0,0}};
						  


int Rotate(int px, int py, int r)
{
    int pi = 0;
    switch (r % 4)
    {
        case 0: // 0 degrees			// 0  1  2  3
            pi = py * 4 + px;			// 4  5  6  7
            break;						// 8  9 10 11
            //12 13 14 15

        case 1: // 90 degrees			//12  8  4  0
            pi = 12 + py - (px * 4);	//13  9  5  1
            break;						//14 10  6  2
            //15 11  7  3

        case 2: // 180 degrees			//15 14 13 12
            pi = 15 - (py * 4) - px;	//11 10  9  8
            break;						// 7  6  5  4
            // 3  2  1  0

        case 3: // 270 degrees			// 3  7 11 15
            pi = 3 - py + (px * 4);		// 2  6 10 14
            break;						// 1  5  9 13
    }								// 0  4  8 12

    return pi;
}

bool DoesPieceFit(uint8_t nTetromino, uint8_t nRotation, uint8_t nPosX, uint8_t nPosY)
{
    // All Field cells >0 are occupied
    for (uint8_t px = 0; px < 4; px++)
        for (uint8_t py = 0; py < 4; py++)
        {
            // Get index into piece
            uint8_t pi = Rotate(px, py, nRotation);

            // Get index into field
            uint16_t fi = (nPosY + py) * nFieldWidth + (nPosX + px);

            // Check that test is in bounds. Note out of bounds does
            // not necessarily mean a fail, as the long vertical piece
            // can have cells that lie outside the boundary, so we'll
            // just ignore them
            if (nPosX + px >= 0 && nPosX + px < nFieldWidth)
            {
                if (nPosY + py >= 0 && nPosY + py < nFieldHeight)
                {
                    // In Bounds so do collision check
                    if (tetromino[nTetromino][pi] != 0 && pField[fi] != 0)
                        return false; // fail on first hit
                }
            }
        }

    return true;
}


void main()
{
    reg_uart_clkdiv = 217; // 100 MHz / 460800 baud
    print("TetriSaraj!\n");
	
	bool btnR = false, btnD = false, btnC = false, btnU = false, btnL = false;		
	bool videoOn = false, vsync = false, hsync = false;	
	bool tick = false;
	uint32_t tick_counter = 0;	
	
	reg_gpio = 0x0;	
	chars_init();	
	delay_ms(10); 	
	board_init();		
	delay_ms(10);	
	
		//  Kreiranje polja - inicijalne varijable 
	for (int y = 0; y < nFieldHeight; y++) 
	 for (int x = 0; x < nFieldWidth; x++) // Board Boundary
            pField[y * nFieldWidth + x] = (y == 1 ||
                                           y == nFieldHeight - 1 ||
                                           x + 1 == nFieldWidth / 2 ||
                                           x == nFieldWidth / 2 ) ? 9u : 0u;

    // Game Logic
	
	
    uint16_t nCurrentPiece = 0;
    uint8_t nCurrentRotation = 3;
    uint8_t nCurrentX = 0;
    uint8_t nCurrentY = nFieldHeight / 2;
    uint8_t nSpeed = 20;
    uint8_t nSpeedCount = 0;
    bool bForceDown = false;
    bool bRotateHold = true;
    uint16_t nPieceCount = 0;
    uint16_t nScore = 0;

    uint8_t arrayLines[4]={0,0,0,0};
    uint8_t counter=0;
    bool bGameOver = false;
    uint8_t previousSide=0;

    uint8_t randomSideGenerator = 0;  // left - 0, right - 1
	// Kraj - kreiranje polja - inicijalne varijable
	
	int brojac=0;
	
	while (1) {
		delay--;
		get_input();
         if(delay == 0) {
			tick = !tick;			
			delay = DELAY;
		}
		 
		
	/* 	if (buttons & BUTTON_UP){			
			print("BUTTON_UP\n");
		}	
		if (buttons & BUTTON_DOWN){
			
			print("BUTTON_DOWN\n");
		}		
		if (buttons & BUTTON_RIGHT){
			
			print("BUTTON_RIGHT\n");
		}
		if (buttons & BUTTON_LEFT) {			
			print("BUTTON_LEFT\n");
		}
		if (buttons & BUTTON_CENTER){
			print("BUTTON_CENTER\n");
		}*/
		
		// POCETAK random crtanje //
		// Ovo samo koristimo za random crtanje u svrhu testiranja- nema veze sa logikom igre//
/*          for (int y = 0; y < nFieldHeight; y++) {
            for (int x = 0; x < nFieldWidth; x++) {
                if (y == 9) // Black color
					reg_video_map[y*nFieldWidth + x] = brojac;
				else if (y == 0) // White color
					reg_video_map[y*nFieldWidth + x] = 14;
				else // Green color
					reg_video_map[y*nFieldWidth + x] = 1;
			}
		}  
		
		
		reg_video_map[15*40+20] = 0; // O is ID Red Mega_Character */
		// KRAJ  random crtanje //
		
		// Nas dio koda 
		  // Timing =======================
        //delay_ms(50); // Small Step = 1 Game Tick, // ovaj delay_ms se koristio u igri kad smo testirali kroz terminal
        nSpeedCount++;
        bForceDown = (nSpeedCount == nSpeed);


        // Game Logic ===================

        // Handle player movement
        if (!randomSideGenerator) {
            nCurrentY += ((buttons & BUTTON_RIGHT) && DoesPieceFit(nCurrentPiece, nCurrentRotation, nCurrentX, nCurrentY + 1)) ? 1 : 0;
            nCurrentY -= ((buttons & BUTTON_LEFT) && DoesPieceFit(nCurrentPiece, nCurrentRotation, nCurrentX, nCurrentY - 1)) ? 1 : 0;
            nCurrentX += ((buttons & BUTTON_DOWN) && DoesPieceFit(nCurrentPiece, nCurrentRotation, nCurrentX + 1, nCurrentY)) ? 1 : 0;
        }
        else {
            nCurrentY -= ((buttons & BUTTON_RIGHT) && DoesPieceFit(nCurrentPiece, nCurrentRotation, nCurrentX, nCurrentY - 1)) ? 1 : 0;
            nCurrentY += ((buttons & BUTTON_LEFT) && DoesPieceFit(nCurrentPiece, nCurrentRotation, nCurrentX, nCurrentY + 1)) ? 1 : 0;
            nCurrentX -= ((buttons & BUTTON_DOWN) && DoesPieceFit(nCurrentPiece, nCurrentRotation, nCurrentX - 1, nCurrentY)) ? 1 : 0;
        }

        // Rotate, but latch to stop wild spinning
        if (buttons & BUTTON_CENTER)
        {
            nCurrentRotation += (bRotateHold && DoesPieceFit(nCurrentPiece, nCurrentRotation + 1, nCurrentX, nCurrentY)) ? 1 : 0;
            bRotateHold = false;
        }
        else
            bRotateHold = true;
		
		// koristeno samo za random crtanje da se ustanovi period signala bForceDown
		if(bForceDown){
			brojac=brojac+1;
			if(brojac==14)
				brojac=0;
		}

        // Force the piece down the playfield if it's time
         if (bForceDown)
        {
            // Update difficulty every 50 pieces
            nSpeedCount = 0;
            nPieceCount++;
            // if (nPieceCount % 50 == 0)
              //  if (nSpeed >= 10) nSpeed--; 

            // Test if piece can be moved down
            if (DoesPieceFit(nCurrentPiece, nCurrentRotation, nCurrentX + 1, nCurrentY) && !randomSideGenerator)
                nCurrentX++;
            else if (DoesPieceFit(nCurrentPiece, nCurrentRotation, nCurrentX - 1, nCurrentY) && randomSideGenerator)
                nCurrentX--;
            else
            {
                // It can't! Lock the piece in place
                for (int px = 0; px < 4; px++)
                    for (int py = 0; py < 4; py++)
                        if (tetromino[nCurrentPiece][Rotate(px, py, nCurrentRotation)] != 0)
                            pField[(nCurrentY + py) * nFieldWidth + (nCurrentX + px)] = nCurrentPiece + 1;


                // Check for lines
                for (int px = 0; px < 4; px++)
                {
                    bool bLine = true;
                    for (int py = 1; py < nFieldHeight - 1; py++)
                        if (pField[(nCurrentX+px)+nFieldWidth*py] == 0 || pField[(nCurrentX+px)+nFieldWidth*py] == 9u) {
                            bLine = false;
                            break;
                        }


                    if (bLine)
                    {
                        // Remove Line, set to =
                        for (int py = 1; py < nFieldHeight - 1; py++){
                            pField[(nCurrentX+px)+nFieldWidth*py] = 0;
                        }
                        arrayLines[counter] = nCurrentX + px;
                        counter+=1;
                    }


                }
                previousSide = randomSideGenerator;

                nScore += 5;
                if(counter != 0)	nScore += (1 << counter) * 20;

                // Pick New Piece

                nCurrentY = nFieldHeight / 2;
                randomSideGenerator = 0;
                if (!randomSideGenerator) {
                    nCurrentRotation = 3;
                    nCurrentX = 0;
                }
                else {
                    nCurrentRotation = 1;
                    nCurrentX = nFieldWidth - 4;
                }

                nCurrentPiece = 1;

                // If piece does not fit straight away, game over!
                bGameOver = !DoesPieceFit(nCurrentPiece, nCurrentRotation, nCurrentX, nCurrentY);
            }
        } 

        // Display ======================


        // Draw Field
         for (int y = 0; y < nFieldHeight; y++) {
            for (int x = 0; x < nFieldWidth; x++) {
				uint8_t block = pField[y*nFieldWidth + x];
                if (block == 9) // Black color
					reg_video_map[y*nFieldWidth + x] = 13;
				else if (block == 0) // White color
					reg_video_map[y*nFieldWidth + x] = 14;
				else // Green color
					reg_video_map[y*nFieldWidth + x] = 1;
			}
		} 

        // Draw Current Piece
          for (int px = 0; px < 4; px++)
            for (int py = 0; py < 4; py++)
                if (tetromino[nCurrentPiece][Rotate(px, py, nCurrentRotation)] != 0)
					reg_video_map[(nCurrentY + py)*nFieldWidth + (nCurrentX + px)] = 1;  
                    

        // Draw Score
        //swprintf_s(&screen[2 * nScreenWidth + nFieldWidth + 6], 16, L"SCORE: %8d", nScore);


        // Animate Line Completion
        if (counter != 0)
        {
            // Display Frame (cheekily to draw lines)
            //WriteConsoleOutputCharacterW(hConsole, screen, nScreenWidth * nScreenHeight, {0, 0 }, &dwBytesWritten);
            //delay_ms(400); // Delay a bit

            if (previousSide == 0){
                for (int v = 0; v < counter; v++) {


                    for (int px = arrayLines[v]; px > 0; px--) {
                        for (int py = 1; py < nFieldHeight - 1; py++)
                            pField[px + nFieldWidth * py] = pField[px - 1 + nFieldWidth * py];

                    }
                }
            } else{
                for (int v = counter - 1; v >= 0; v--)
                {
                    for (int px = arrayLines[v]; px < nFieldWidth - 1; px++)
                    {
                        for (int py = 1; py < nFieldHeight - 1; py++) {

                            pField[px + nFieldWidth * py] = pField[px + 1 + nFieldWidth * py];

                        }
                    }
                }

            }

            arrayLines[0]=0;
            arrayLines[1]=0;
            arrayLines[2]=0;
            arrayLines[3]=0;

            counter=0; 

			// Kraj - nas dio koda 
		

		
		}
		

		btnU = buttons&BUTTON_UP;			
		btnR = buttons&BUTTON_RIGHT;
		btnL = buttons&BUTTON_LEFT;	
		btnD = buttons&BUTTON_DOWN;
		btnC = buttons&BUTTON_CENTER;
		reg_gpio = 0x00000100 | buttons; // first 9 leds			
		
		videoOn = buttons&0x0020;
		vsync = buttons&0x0040;
		hsync = buttons&0x0080;
			
			
			
	

	}
}

