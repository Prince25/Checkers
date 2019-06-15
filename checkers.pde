
final int WIDTH   = 640;
final int HEIGHT  = 640;
final int BLOCK_W = WIDTH / 8;
final int BLOCK_H = HEIGHT / 8;
final int TEXT_DURATION = 2000; // 2 Seconds

String turn;
String winner;
int time;
int[] showMovesXY;
boolean gameOver;
boolean clicked;  // First click selects piece, second click moves
boolean promote;
boolean doubleJump;
boolean mustJump;
int doubleJumpX, doubleJumpY;

PImage[][] board;
PImage red, red_king, black, black_king;


// Reset the game
void keyPressed() {
  if (key == 'r')  startPosition();
}


// Initital Setup
void setup(){
  surface.setSize(WIDTH, HEIGHT);  // size(WIDTH, HEIGHT);
  noStroke();
  textSize(WIDTH/8);
  textAlign(CENTER);
  
  red = loadImage("red.png");
  red_king = loadImage("red_king.png");
  black = loadImage("black.png");
  black_king = loadImage("black_king.png");
  red.resize(BLOCK_W, BLOCK_H);
  black.resize(BLOCK_W, BLOCK_H);
  red_king.resize(BLOCK_W, BLOCK_H);
  black_king.resize(BLOCK_W, BLOCK_H);
  
  showMovesXY = new int[2];
  startPosition();
}


// Updates the board. Called frequently.
void draw(){
  showboard();
     
  // Show player's turn
  if( !gameOver && millis() < time + TEXT_DURATION){
    if (turn == "red") {
      fill(255, 0, 0);
      if (!doubleJump) text("Red's Turn", WIDTH/2, HEIGHT/2);
    } else if (turn == "black") {
      fill(0);
      if (!doubleJump) text("Black's Turn", WIDTH/2, HEIGHT/2);
    }
  }
  
  // Show game over
  if (gameOver && millis() > time + TEXT_DURATION) {
    background(0);
    fill(255);
    text("GAME OVER", WIDTH/2, HEIGHT/2);
    text(winner + " Wins!", WIDTH/2, HEIGHT/3);
  }
  
}


// Initial Checkers board setup 
void startPosition() {
  turn     = "red";
  winner   = "";
  time = millis();
  gameOver = false;
  clicked  = false;
  promote = false;
  doubleJump = false;
  mustJump = false;
  
  board = new PImage[8][8];  // board[Horizontal][Vertical]
  for (int horizontal = 0; horizontal < 8; horizontal++) {
    for (int vertical = 0; vertical < 8; vertical++) {
      if (horizontal % 2 == 1) {
          if (vertical == 0 || vertical == 2) board[horizontal][vertical] = black;
          if (vertical == 6) board[horizontal][vertical] = red;
      } else {
        if (vertical == 1) board[horizontal][vertical] = black;
        if (vertical == 5 || vertical == 7) board[horizontal][vertical] = red;
      }
    }  
  }
  
}


// Draws background and pieces
void showboard() {
  
  for (int i = 0; i < 8; i ++) {
    for (int j = 0; j < 8; j ++) {
      if ((i + j) % 2 == 1) {
        fill(255, 255, 255); // white
      } else {
        fill(222,184,135);   // Burly wood
      }
      rect(i * BLOCK_W, j * BLOCK_H, (i + 1) * BLOCK_W, (j + 1) * BLOCK_H);  // Draw background checkerboard
      
      if (board[i][j] != null) image(board[i][j], i * BLOCK_W, j * BLOCK_H); // Draw Pieces 
      
      if (clicked) {
        int x = showMovesXY[0];
        int y = showMovesXY[1];
      
        if (x == i && y == j && board[x][y] != null){
          fill(0, 0, 255, 100);
          rect(i * BLOCK_W, j * BLOCK_H, BLOCK_W, BLOCK_H);  // Highlight selected piece
        }
        
        if (isValidMove(x, y, i, j, turn)) {
          fill(0, 255, 255, 100);
          rect(i * BLOCK_W, j * BLOCK_H, BLOCK_W, BLOCK_H);// Highlight possible moves
        }
      }
    } 
  }
}


// When mouse is pressed
void mousePressed() {
  if (gameOver) startPosition();
  
  int x = mouseX/80;
  int y = mouseY/80;
  
  if (!clicked && isValidStart(x,y)) {
    showMovesXY[0] = x;
    showMovesXY[1] = y;
    clicked = true;
  }
  else if (clicked) {
    if (x == showMovesXY[0] && y == showMovesXY[1])
      clicked = false;
      
    else if (isValidMove(showMovesXY[0],showMovesXY[1], x, y, turn)) {
      movePiece(showMovesXY[0], showMovesXY[1], x, y);
      clicked = false;
      time = millis();
    }

    else if (isValidStart(x,y)){
      showMovesXY[0] = x;
      showMovesXY[1] = y;
      clicked = true;
    }
  }
}


// Determines if the chosen starting piece is valid
boolean isValidStart(int x, int y) {
  
  // Square is empty
  if (board[x][y] == null) return false;
  
  // Piece is of other team
  if ( (turn == "red" && (board[x][y] == black || board[x][y] == black_king)) ||
       (turn == "black" && (board[x][y] == red || board[x][y] == red_king))) return false;
    
  return true;
}


// Moves a piece from one square to another
void movePiece(int fromX, int fromY, int toX, int toY) {

 // Check if we should promote
 if (board[fromX][fromY] == red) { 
   if (toY == 0) {
     board[fromX][fromY] = red_king;
     promote = true;
     doubleJump = false;
   }
 } else if (board[fromX][fromY] == black) {
   if (toY == 7) {
     board[fromX][fromY] = black_king;
     promote = true;
     doubleJump = false;
   }
 }

 board[toX][toY] = board[fromX][fromY]; // Move piece
 board[fromX][fromY] = null;            // Remove original piece

 // Jump over
 if (abs(fromX - toX) == 2) {
   board[ (fromX + toX) / 2 ] [ (fromY + toY) / 2 ] = null; // Remove jumped over piece
   if (!promote) { // Check double jump
     if ( isValidMove(toX, toY, toX + 2, toY + 2, turn) || isValidMove(toX, toY, toX + 2, toY - 2, turn) ||
       isValidMove(toX, toY, toX - 2, toY + 2, turn) || isValidMove(toX, toY, toX - 2, toY - 2, turn) ) {
       if (turn == "red") turn = "black";
       else if (turn == "black") turn = "red";
       doubleJump = true;
       doubleJumpX = toX;
       doubleJumpY = toY;
     } else {
       doubleJump = false;
     }
   }
 }

 promote = false;
 String otherPlayer = ((turn == "red") ? "black" : "red");
 
 mustJump = mustJump(otherPlayer, false);

 if ( mustJump(otherPlayer, true) ) {
   winner = turn;
   gameOver = true;
 }

 if (turn == "red") turn = "black";
 else if (turn == "black") turn = "red";
}


// Checks to see if a move is valid given from and to squares
boolean isValidMove(int fromX, int fromY, int toX, int toY, String side) {

 // If, for some reason, square is out of bounds
 if (fromX > 7 ||  fromX < 0 || toX > 7 ||  toX < 0 || fromY > 7 ||  fromY < 0 || toY > 7 ||  toY < 0) {
   return false;
 }

 // Check double jump coordinates
 if(doubleJump && (fromY != doubleJumpY || fromX != doubleJumpX || abs(toX - fromX) != 2))
   return false;

 if(mustJump && abs(toX - fromX) != 2)
   return false;


 if (side == "red") {
   if (board[fromX][fromY] == red) {  // Red piece
     if (abs(toX - fromX) == 1 && toY == fromY - 1 && board[toX][toY] == null) {
       return true;
     }
     if (abs(toX - fromX) == 2 && toY == fromY - 2 && board[toX][toY] == null && 
       (board[(fromX + toX) / 2] [fromY - 1] == black || board[(fromX + toX) / 2] [fromY - 1] == black_king)) {
       return true;
     }
   } else if (board[fromX][fromY] == red_king) {  // Red king
     if (abs(toX - fromX) == 1 && abs(toY - fromY) == 1 && board[toX][toY] == null) {
       return true;
     }
     if (abs(toX - fromX) == 2 && abs(toY - fromY) == 2 && board[toX][toY] == null &&
       (board[(fromX + toX) / 2] [(fromY + toY) / 2] == black || board[(fromX + toX) / 2] [(fromY + toY) / 2] == black_king)) {
       return true;
     }
   }

 } else if (side == "black") {
   if (board[fromX][fromY] == black) {  // Black piece
     if (abs(toX - fromX) == 1 && toY == fromY + 1 && board[toX][toY] == null) {
       return true;
     }
     if (abs(toX - fromX) == 2 && toY == fromY + 2 && board[toX][toY] == null && 
      (board[(fromX + toX) / 2] [fromY + 1] == red || board[(fromX + toX) / 2] [fromY + 1] == red_king)) {
       return true;
     }
   } else if (board[fromX][fromY] == black_king) {  // Black king
     if (abs(toX - fromX) == 1 && abs(toY - fromY) == 1 && board[toX][toY] == null) {
       return true;
     }
     if (abs(toX - fromX) == 2 && abs(toY - fromY) == 2 && board[toX][toY] == null && 
      (board[(fromX + toX) / 2] [(fromY + toY) / 2] == red || board[(fromX + toX) / 2] [(fromY + toY) / 2] == red_king)) {
       return true;
     }
   }
 }

 return false;
}


// Determines if any pieces must jump or if game is finished
boolean mustJump(String side, boolean checkGameOver) {
 for (int k = 0; k < 8; k++) {
   for (int l = 0; l < 8; l++) {

     if (side == "red") {
       if (board[l][k] == black || board[l][k] == black_king || board[l][k] == null)
         continue;
     } else if (board[l][k] == red || board[l][k] == red_king || board[l][k] == null) {
       continue;
     }

     for (int i = 0; i < 8; i++) {
       for (int j = 0; j < 8; j++) {
         if (isValidMove(l, k, i, j, side))
         {
           if (checkGameOver) return false;

           else if (abs(k - j) == 2) return true;
         }
       }
     }
   }
 }
 
 return checkGameOver;
}
