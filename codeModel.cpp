#include <iostream>
#include <cstdlib>
#include <ctime>

using namespace std;

void printBoard(int boardWidth, int boardHeight, char **graph){

    for(int i = 0 ; i < boardHeight ; i++){
        for(int j = 0 ; j < boardWidth ; j++){
            cout << graph[i][j];
        }
        cout <<endl;
    }

}

void placeFood(int boardWidth, int boardHeight, char **graph){
    // Bad method: randomly placing food
    srand(time(0));

    int x = rand() % boardWidth;
    int y = rand() % boardHeight;

    while(graph[y][x]=='#'){
        x = rand() % boardWidth;
        y = rand() % boardHeight;
    }

    graph[y][x] = '@';
    

}

struct snakePart{
    snakePart *forward=nullptr;
    snakePart *backward=nullptr;
    int xpos;
    int ypos;
};

int main(){

    const int height = 20;  // must be greater than or 6 to fit snake
    const int width = 20;   // must be greater than or 6 to fit snake

    char **map = new char*[height];

    for(int i = 0 ; i < height ;  i++){
        map[i] = new char[width];
        for(int j = 0 ; j < width ;  j++){
            map[i][j] = ' ';
        }   
    }

    snakePart *head = new snakePart();
    snakePart *body = new snakePart();
    snakePart *tail = new snakePart();

    // Initialize head
    head->xpos = width/2;
    head->ypos = height/2;
    head->backward = body;

    // Initialize middle piece
    body->xpos = (width/2)-1;
    body->ypos = (height/2);
    body->forward = head;
    body->backward = tail;

    // Initialize tail
    tail->xpos = (width/2)-2;
    tail->ypos = (height/2);
    tail->forward = body;

    // Paint snake onto map
    snakePart *tempPart = head;
    while(tempPart!=nullptr){
        map[tempPart->ypos][tempPart->xpos]='#';
        tempPart=tempPart->backward;
    }

    // First food
    placeFood(width, height, map);

    char input;
    bool gameover=false;
    snakePart *moveHead;
    // Main game loop
    while(!gameover){
        printBoard(width, height, map);
        cin >> input;

        // Create new Head
        moveHead = new snakePart();
        head->forward=moveHead;
        moveHead->backward=head;
        moveHead->xpos=head->xpos;
        moveHead->ypos=head->ypos;

        if(input=='a'){
            moveHead->xpos = (head->xpos)-1;
        }
        if(input=='d'){
            moveHead->xpos = (head->xpos)+1;
        }
        if(input=='w'){
            moveHead->ypos = (head->ypos)-1;
            cout << moveHead->ypos<<endl;
        }
        if(input=='s'){
            moveHead->ypos = (head->ypos)+1;
            cout << moveHead->ypos<<endl;
        }
        if(input=='q'){
            gameover=true;
        }
        
        head=moveHead;

        // If eating
        if(map[head->ypos][head->xpos]=='@'){
            // Dont remove tail
            map[head->ypos][head->xpos] = '#';
            placeFood(width, height, map);
        } else {
            // Remove
            map[head->ypos][head->xpos] = '#';
            map[tail->ypos][tail->xpos] = ' ';
            tail=tail->forward;
            delete[] tail->backward;
        }
        

    }

    
    // Delete snake
    tempPart=head;
    snakePart *next=head->backward;
    while(next!=nullptr){
        delete[] tempPart;
        tempPart=next;
        next=next->backward;
    }
    delete[] tempPart;
    
    



    return 0;
}