#!/usr/bin/env bash

forge_init() {
    local project_name="$1"
    
    # Case 1: forge init (no args) : initialize in current directory
    if [ -z "$project_name" ]; then
        if [ -f "$FORGE_CONFIG" ]; then
            error "Project already initialized (forge.json exists)"
        fi
        
        project_name=$(basename "$PWD")
        info "Initializing project in current directory: $project_name"
        _create_project_structure "$project_name"
        
    # Case 2: forge init my_project : create new directory
    else
        if [ -d "$project_name" ]; then
            error "Directory '$project_name' already exists"
        fi
        
        info "Creating project: $project_name"
        mkdir "$project_name"
        cd "$project_name" || error "Failed to enter project directory"
        _create_project_structure "$project_name"
        
        echo ""
        info "Next steps:"
        echo "  cd $project_name"
        echo "  forge build"
        echo "  forge run"
        echo "  forge test"
    fi
}

_create_project_structure() {
    local project_name="$1"
    
    # Create directory structure
    mkdir -p src include libs build tests
    
    # Create forge.json
    cat > "$FORGE_CONFIG" << EOF
{
  "name": "$project_name",
  "version": "0.1.0",
  "description": "",
  "author": "",
  "dependencies": {},
  "compiler": "g++",
  "std": "c++17",
  "flags": ["-Wall", "-Wextra"],
  "include_dirs": ["include"],
  "output": "build/$project_name"
}
EOF
    
    # Create main.cpp
    cat > src/main.cpp << 'EOF'
#include <iostream>

int main() {
    std::cout << "Hello from Forge!" << std::endl;
    return 0;
}
EOF
    
    # Create .gitignore
    cat > .gitignore << 'EOF'
build/
libs/
*.o
*.out
.DS_Store
EOF
    
    success "Project initialized!"
}