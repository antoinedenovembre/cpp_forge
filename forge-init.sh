#!/usr/bin/env bash

forge_init() {
    local project_name="${1:-my_project}"
    
    if [ -f "$FORGE_CONFIG" ]; then
        error "Project already initialized (forge.json exists)"
    fi
    
    info "Initializing project: $project_name"
    
    # Create project directory
    mkdir -p "$project_name"
    cd "$project_name" || error "Failed to enter project directory"

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
    echo ""
    echo "Project structure:"
    echo "  src/       - Source files"
    echo "  include/   - Header files"
    echo "  libs/      - Dependencies"
    echo "  build/     - Build output"
    echo "  tests/     - Test files"
    echo ""
    info "Next steps:"
    echo "  forge build    - Build your project"
    echo "  forge run      - Run your project"
}