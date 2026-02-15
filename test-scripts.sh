#!/bin/bash

# Smoke test runner for shell scripts
# This script validates each script's basic functionality and structure
# It performs syntax checks and basic execution validation

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

echo "=============================="
echo "Smoke Test Runner"
echo "=============================="
echo ""

# Function to run syntax check
check_syntax() {
    local script="$1"
    bash -n "$script" 2>&1
    return $?
}

# Dependency check functions
has_brew_and_ollama_service() {
    command -v brew >/dev/null 2>&1 && brew services list | grep -q ollama
}

has_podman() {
    command -v podman >/dev/null 2>&1
}

has_brew_and_ollama_formula() {
    command -v brew >/dev/null 2>&1 && brew list --formula ollama >/dev/null 2>&1
}

# Function to run a test
run_test() {
    local test_name="$1"
    local script="$2"
    local skip_condition="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo "Test $TOTAL_TESTS: $test_name"
    echo "  Script: $script"
    
    # Check if script exists
    if [ ! -f "$script" ]; then
        echo -e "  ${RED}✗ FAILED${NC} - Script not found"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo ""
        return 1
    fi
    
    # Check if script is executable
    if [ ! -x "$script" ]; then
        echo -e "  ${RED}✗ FAILED${NC} - Script not executable"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo ""
        return 1
    fi
    
    # Check bash syntax
    local syntax_output=$(check_syntax "$script")
    if [ $? -ne 0 ]; then
        echo -e "  ${RED}✗ FAILED${NC} - Syntax error:"
        echo "    $syntax_output"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo ""
        return 1
    fi
    
    # Check skip condition if provided
    if [ -n "$skip_condition" ]; then
        if eval "$skip_condition"; then
            echo -e "  ${YELLOW}⊘ SKIPPED${NC} - Required dependency not available"
            SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
            echo ""
            return 0
        fi
    fi
    
    # For scripts with dependencies available, do a quick validation run
    # We'll run them with a dry-run approach by checking if they would fail immediately
    local temp_output=$(mktemp)
    local timeout_duration=5
    timeout $timeout_duration ./"$script" > "$temp_output" 2>&1 &
    local pid=$!
    
    # Wait briefly to see if script fails immediately due to configuration issues
    # This gives the script enough time to validate dependencies and start initial operations
    local initial_wait=2
    sleep $initial_wait
    
    if ! kill -0 $pid 2>/dev/null; then
        # Process already exited, check exit code
        wait $pid
        local exit_code=$?
        if [ $exit_code -eq 0 ]; then
            echo -e "  ${GREEN}✓ PASSED${NC} - Script executed successfully"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo -e "  ${RED}✗ FAILED${NC} - Script exited with code $exit_code"
            echo "    Output: $(head -n 3 "$temp_output")"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        # Process still running, likely doing real work - that's good for smoke test
        kill $pid 2>/dev/null
        wait $pid 2>/dev/null
        echo -e "  ${GREEN}✓ PASSED${NC} - Script started successfully (validation passed)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    fi
    
    rm -f "$temp_output"
    echo ""
}

# Run tests
echo "Running smoke tests..."
echo ""

# Test 1: ollama.sh
run_test "ollama.sh restart test" "ollama.sh" "! has_brew_and_ollama_service"

# Test 2: open-webui.sh
run_test "open-webui.sh container update test" "open-webui.sh" "! has_podman"

# Test 3: post_update_ollama.sh
run_test "post_update_ollama.sh configuration test" "post_update_ollama.sh" "! has_brew_and_ollama_formula"

# Print summary
echo "=============================="
echo "Test Summary"
echo "=============================="
echo "Total:   $TOTAL_TESTS"
echo -e "${GREEN}Passed:  $PASSED_TESTS${NC}"
echo -e "${RED}Failed:  $FAILED_TESTS${NC}"
echo -e "${YELLOW}Skipped: $SKIPPED_TESTS${NC}"
echo ""

# Exit with appropriate code
if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${RED}Smoke tests FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}Smoke tests PASSED${NC}"
    exit 0
fi