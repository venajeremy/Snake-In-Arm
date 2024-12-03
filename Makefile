CC = aarch64-linux-gnu-gcc
CFLAGS = -I/usr/aarch64-linux-gnu/include/ncurses -L/usr/aarch64-linux-gnu/lib

intro:
	@echo "Build project with: make build"
	@echo "Run Project with: make run"

build:
	@echo "Compiling..."
	@$(CC) $(CFLAGS) -c ./src/codeModel.c -o ./tmp/codeModel.o 
	@$(CC) $(CFLAGS) -c ./src/startMenu.c -o ./tmp/startMenu.o	
	@echo "Assembling..."
	@$(CC) $(CFLAGS) -c ./src/startMenu.s -o ./tmp/startMenuS.o
	@echo "Linking..."
	@$(CC) -lncurses -ltinfo ./tmp/*.o -o ./dist/myprogram
	@echo "Done! Output in /dist/. Run with: make run"

run:
	@echo "Running"
	LD_LIBRARY_PATH=/usr/aarch64-linux-gnu/lib qemu-aarch64 ./dist/myprogram
