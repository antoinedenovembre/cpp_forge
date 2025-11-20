#!/usr/bin/env bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════╗"
    echo "║                                        ║"
    echo "║             Forge Installer            ║"
    echo "║                                        ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
}

error() {
    echo -e "${RED}✗ Error: $1${NC}" >&2
    exit 1
}

success() {
    echo -e "${GREEN}✓ $1${NC}"
}

info() {
    echo -e "${YELLOW}→ $1${NC}"
}

check_requirements() {
    info "Checking requirements..."
    
    command -v git >/dev/null 2>&1 || error "git is required. Install with: apt install git / brew install git"
    command -v jq >/dev/null 2>&1 || error "jq is required. Install with: apt install jq / brew install jq"
    
    if ! command -v g++ >/dev/null 2>&1 && ! command -v clang++ >/dev/null 2>&1; then
        error "C++ compiler required. Install with: apt install g++ / brew install gcc"
    fi
    
    success "All requirements met"
}

install_forge() {
    local install_dir="/usr/local/bin"
    local lib_dir="/usr/local/lib/forge"
    
    info "Installing forge to $install_dir..."
    
    # Check if we need sudo
    if [ ! -w "$install_dir" ]; then
        info "Requesting sudo permissions..."
        SUDO="sudo"
    else
        SUDO=""
    fi
    
    # Create lib directory
    $SUDO mkdir -p "$lib_dir"
    
    # Copy library files
    $SUDO cp -r lib/* "$lib_dir/"
    success "Copied library files to $lib_dir"
    
    # Copy and modify main script
    $SUDO cp bin/forge "$install_dir/forge"
    
    # Update paths in the forge script to point to /usr/local/lib/forge
    $SUDO sed -i.bak 's|LIB_DIR="$SCRIPT_DIR/lib"|LIB_DIR="/usr/local/lib/forge"|g' "$install_dir/forge"
    $SUDO rm "$install_dir/forge.bak" 2>/dev/null || true
    
    # Make executable
    $SUDO chmod +x "$install_dir/forge"
    success "Installed forge to $install_dir"
}

verify_installation() {
    info "Verifying installation..."
    
    if command -v forge >/dev/null 2>&1; then
        local version=$(forge --version)
        success "Installation successful!"
        echo ""
        echo -e "${GREEN}$version${NC}"
        echo ""
        echo "Try it out:"
        echo "  forge init my_project"
        echo "  cd my_project"
        echo "  forge build"
        echo "  forge run"
        echo "  forge test"
    else
        error "Installation failed. forge command not found in PATH"
    fi
}

uninstall() {
    info "Uninstalling forge..."
    
    if [ ! -w "/usr/local/bin" ]; then
        SUDO="sudo"
    else
        SUDO=""
    fi
    
    $SUDO rm -f /usr/local/bin/forge
    $SUDO rm -rf /usr/local/lib/forge
    
    success "Forge uninstalled"
    exit 0
}

print_header

# Handle uninstall flag
if [ "$1" = "--uninstall" ] || [ "$1" = "-u" ]; then
    uninstall
fi

check_requirements
echo ""
install_forge
echo ""
verify_installation