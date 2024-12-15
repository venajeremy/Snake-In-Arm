CC = aarch64-linux-gnu-gcc
CurseFLAGS = -I/usr/aarch64-linux-gnu/include/ncurses -L/usr/aarch64-linux-gnu/lib

intro:
	@echo "Build project with: make build"
	@echo "Build project without ncurses: make buildNoCurses"
	@echo "Run Project with: make run"

build:
	@echo "Compiling..."
	@$(CC) $(CurseFLAGS) -c ./src/snakeGame.c -o ./tmp/snakeGameC.o
	@echo "Assembling..."
	@$(CC) $(CurseFLAGS) -c ./src/snakeGame.s -o ./tmp/snakeGameS.o
	@echo "Linking..."
	@$(CC) -lncurses -ltinfo ./tmp/*.o -o ./dist/myprogram
	@echo "Done! Output in /dist/. Run with: make run"

buildNoCurses:
	@echo "Compiling..."
	@$(CC) -c ./src/snakeGame.c -o ./tmp/snakeGameC.o
	@echo "Assembling..."
	@$(CC) -c ./src/snakeGame.s -o ./tmp/snakeGameS.o
	@echo "Linking..."
	@$(CC) -fPIC ./tmp/*.o -o ./dist/myprogram
	@echo "Done! Output in /dist/. Run with: make run"


run:
	@echo "Running"
	@LD_LIBRARY_PATH=/usr/aarch64-linux-gnu/lib qemu-aarch64 ./dist/myprogram
