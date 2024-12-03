CC = aarch64-linux-gnu-gcc
CurseFLAGS = -I/usr/aarch64-linux-gnu/include/ncurses -L/usr/aarch64-linux-gnu/lib

intro:
	@echo "Build project with: make build"
	@echo "Build project without ncurses: make buildNoCurses"
	@echo "Run Project with: make run"

build:
	@echo "Compiling..."
	@$(CC) $(CurseFLAGS) -c ./src/codeModel.c -o ./tmp/codeModel.o 
	@$(CC) $(CurseFLAGS) -c ./src/startMenu.c -o ./tmp/startMenu.o	
	@echo "Assembling..."
	@$(CC) $(CurseFLAGS) -c ./src/startMenu.s -o ./tmp/startMenuS.o
	@echo "Linking..."
	$(CC) $(CurseFLAGS) ./tmp/*.o -o ./dist/myprogram -lncurses -ltinfo
	@echo "Done! Output in /dist/. Run with: make run"

buildNoCurses:
	@echo "Compiling..."
	@$(CC) -c ./src/codeModel.c -o ./tmp/codeModel.o 
	@$(CC) -c ./src/startMenu.c -o ./tmp/startMenu.o	
	@echo "Assembling..."
	@$(CC) -c ./src/startMenu.s -o ./tmp/startMenuS.o
	@echo "Linking..."
	@$(CC)  ./tmp/*.o -o ./dist/myprogram
	@echo "Done! Output in /dist/. Run with: make run"


run:
	@echo "Running"
	LD_LIBRARY_PATH=/usr/aarch64-linux-gnu/lib qemu-aarch64 ./dist/myprogram
