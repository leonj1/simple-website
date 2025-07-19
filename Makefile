.PHONY: build clean install start

PROJECT_NAME = dark-theme-landing
BUILD_DIR = build
DIST_FILE = $(PROJECT_NAME).zip

install:
	npm install

start:
	npm start

build:
	npm run build
	cd $(BUILD_DIR) && zip -r ../$(DIST_FILE) .

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(DIST_FILE)
	rm -rf node_modules