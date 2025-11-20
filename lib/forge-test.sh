#!/usr/bin/env bash

forge_test() {
    if [ ! -f "$FORGE_CONFIG" ]; then
        error "No forge.json found. Run 'forge init' first."
    fi
    
    # Check if tests directory exists
    if [ ! -d "tests" ]; then
        info "No tests directory found. Creating tests/"
        mkdir -p tests
        _create_example_test
        info "Created example test in tests/example_test.cpp"
        echo ""
    fi
    
    # Find all test files
    local test_files=$(find tests -name "*_test.cpp" -o -name "test_*.cpp" 2>/dev/null)
    
    if [ -z "$test_files" ]; then
        info "No test files found in tests/"
        info "Test files should match: *_test.cpp or test_*.cpp"
        info "Creating example test..."
        _create_example_test
        info "Created example test in tests/example_test.cpp and running it."
        # Find newly created test file
        test_files=$(find tests -name "*_test.cpp" -o -name "test_*.cpp" 2>/dev/null)
        echo ""
    fi
    
    info "Running tests..."
    echo ""
    
    # Parse forge.json
    local compiler=$(jq -r '.compiler' "$FORGE_CONFIG")
    local std=$(jq -r '.std' "$FORGE_CONFIG")
    local flags=$(jq -r '.flags | join(" ")' "$FORGE_CONFIG")
    local include_dirs=$(jq -r '.include_dirs | map("-I" + .) | join(" ")' "$FORGE_CONFIG")
    
    # Add libs include directories
    local libs_includes=""
    if [ -d "libs" ]; then
        for lib in libs/*; do
            if [ -d "$lib/include" ]; then
                libs_includes="$libs_includes -I$lib/include"
            fi
        done
    fi
    
    local passed=0
    local failed=0
    local total=0
    
    # Run each test
    for test_file in $test_files; do
        local test_name=$(basename "$test_file" .cpp)
        local test_bin="build/tests/$test_name"
        
        mkdir -p build/tests
        
        info "Compiling $test_name..."
        
        # Compile test
        if $compiler -std=$std $flags $include_dirs $libs_includes "$test_file" -o "$test_bin" 2>&1; then
            # Run test
            if "$test_bin" 2>&1; then
                success "$test_name passed"
                ((passed++))
            else
                error_no_exit "$test_name failed"
                ((failed++))
            fi
        else
            error_no_exit "$test_name compilation failed"
            ((failed++))
        fi
        
        ((total++))
        echo ""
    done
    
    # Summary
    echo "════════════════════════════════════════"
    if [ $failed -eq 0 ]; then
        success "All tests passed ($passed/$total)"
        return 0
    else
        error_no_exit "$failed/$total tests failed"
        return 1
    fi
}

error_no_exit() {
    echo -e "${RED}✗ $1${NC}" >&2
}

_create_example_test() {
    cat > tests/example_test.cpp << 'EOF'
#include <iostream>
#include <cassert>

void test_addition() {
    assert(2 + 2 == 4);
    std::cout << "  ✓ Addition works" << std::endl;
}

void test_subtraction() {
    assert(5 - 3 == 2);
    std::cout << "  ✓ Subtraction works" << std::endl;
}

int main() {
    std::cout << "Running example tests..." << std::endl;
    
    try {
        test_addition();
        test_subtraction();
        
        std::cout << std::endl;
        std::cout << "All tests passed!" << std::endl;
        return 0;
    } catch (...) {
        std::cerr << "Test failed!" << std::endl;
        return 1;
    }
}
EOF
}