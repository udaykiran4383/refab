#!/bin/bash

# ReFab App - Repository Test Runner
# This script runs comprehensive tests for all repository layers

echo "🧪 ReFab App - Repository Test Runner"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_header() {
    echo -e "${PURPLE}$1${NC}"
}

print_subheader() {
    echo -e "${CYAN}$1${NC}"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

print_status "Flutter found: $(flutter --version | head -n 1)"

# Check if we're in the correct directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found. Please run this script from the project root."
    exit 1
fi

print_status "Running from project root directory"

# Function to run individual repository tests
run_repository_test() {
    local repository=$1
    local test_file=$2
    
    print_subheader "Testing $repository Repository..."
    
    if flutter test "$test_file" --verbose; then
        print_status "$repository Repository tests passed"
        return 0
    else
        print_error "$repository Repository tests failed"
        return 1
    fi
}

# Function to run all repository tests
run_all_tests() {
    print_header "🧪 Running All Repository Tests"
    echo ""
    
    local failed_tests=0
    
    # Run each repository test
    repositories=(
        "Tailor:test/repository/tailor_repository_test.dart"
        "Customer:test/repository/customer_repository_test.dart"
        "Admin:test/repository/admin_repository_test.dart"
        "Warehouse:test/repository/warehouse_repository_test.dart"
        "Logistics:test/repository/logistics_repository_test.dart"
        "Volunteer:test/repository/volunteer_repository_test.dart"
    )
    
    for repo_test in "${repositories[@]}"; do
        IFS=':' read -r repo_name test_file <<< "$repo_test"
        
        if ! run_repository_test "$repo_name" "$test_file"; then
            ((failed_tests++))
        fi
        
        echo ""
    done
    
    # Summary
    print_header "📊 Test Summary"
    if [ $failed_tests -eq 0 ]; then
        print_status "All repository tests passed! 🎉"
    else
        print_error "$failed_tests repository test(s) failed"
    fi
    
    return $failed_tests
}

# Function to run specific repository test
run_specific_test() {
    local repository=$1
    
    case $repository in
        "tailor")
            run_repository_test "Tailor" "test/repository/tailor_repository_test.dart"
            ;;
        "customer")
            run_repository_test "Customer" "test/repository/customer_repository_test.dart"
            ;;
        "admin")
            run_repository_test "Admin" "test/repository/admin_repository_test.dart"
            ;;
        "warehouse")
            run_repository_test "Warehouse" "test/repository/warehouse_repository_test.dart"
            ;;
        "logistics")
            run_repository_test "Logistics" "test/repository/logistics_repository_test.dart"
            ;;
        "volunteer")
            run_repository_test "Volunteer" "test/repository/volunteer_repository_test.dart"
            ;;
        *)
            print_error "Unknown repository: $repository"
            print_info "Available repositories: tailor, customer, admin, warehouse, logistics, volunteer"
            exit 1
            ;;
    esac
}

# Function to show help
show_help() {
    echo "Usage: $0 [OPTION] [REPOSITORY]"
    echo ""
    echo "Options:"
    echo "  -a, --all              Run all repository tests"
    echo "  -s, --specific REPO    Run tests for specific repository"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "Repositories:"
    echo "  tailor                 Tailor repository tests"
    echo "  customer               Customer repository tests"
    echo "  admin                  Admin repository tests"
    echo "  warehouse              Warehouse repository tests"
    echo "  logistics              Logistics repository tests"
    echo "  volunteer              Volunteer repository tests"
    echo ""
    echo "Examples:"
    echo "  $0 --all               Run all repository tests"
    echo "  $0 --specific tailor   Run only tailor repository tests"
    echo "  $0 -s customer         Run only customer repository tests"
}

# Main script logic
case "${1:-}" in
    -a|--all)
        run_all_tests
        exit $?
        ;;
    -s|--specific)
        if [ -z "$2" ]; then
            print_error "Repository name required for --specific option"
            show_help
            exit 1
        fi
        run_specific_test "$2"
        exit $?
        ;;
    -h|--help|"")
        show_help
        exit 0
        ;;
    *)
        print_error "Unknown option: $1"
        show_help
        exit 1
        ;;
esac 