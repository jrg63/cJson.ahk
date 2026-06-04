SHELL := /bin/bash
HOMEDIR := /home/$(USER)
AHK_BIN := "/mnt/c/Program Files/AutoHotkey/v2/AutoHotkey64.exe"
DOCDIR := /mnt/f/OneDrive/Documents
LIB := cJson.ahk
DESTLIBDIR := $(DOCDIR)/AutoHotkey/Lib
DEVHOME := $(DOCDIR)/dev/projects
SRCDIR := $(DEVHOME)/Lib/$(LIB)
DISTDIR := $(SRCDIR)/Dist
DISTFILE := $(DISTDIR)/JSON.ahk
DESTFILE := $(DESTLIBDIR)/cJSON.ahk

# Windows-format paths (for cmd.exe)
AHK_BIN_WIN := "C:\\Program Files\\AutoHotkey\\v2\\AutoHotkey64.exe"

.PHONY: all build install clean submodules

all: submodules build install
	@echo All done at $$(date)

submodules:
	@echo "==> Initializing git submodules..."
	@cd "$(SRCDIR)" && git submodule update --init --recursive
	@echo "==> Submodules ready at $$(date)"

build: submodules
	@echo "==> Building with AutoHotkey (this may take a moment)..."
	@cd "$(SRCDIR)" && cmd.exe /c $(AHK_BIN_WIN) Build.ahk
	@echo "==> Build completed at $$(date)"

install:
	@echo "==> Installing cJSON.ahk to AHK v2 library..."
	@mkdir -p "$(DESTLIBDIR)"
	@cp -v "$(DISTFILE)" "$(DESTFILE)"
	@echo "==> Install completed at $$(date)"

clean:
	@echo "==> Cleaning build artifacts..."
	@rm -rfv "$(DISTDIR)"
	@rm -fv "$(DESTFILE)"
	@echo "==> Clean completed at $$(date)"
