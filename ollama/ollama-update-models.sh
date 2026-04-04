#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

if ! command -v ollama &> /dev/null; then
    print_error "ollama is not installed or not in PATH"
    echo "Please install ollama first: https://ollama.ai"
    exit 1
fi

if ! ollama list &> /dev/null; then
    print_error "Unable to connect to ollama. Is the ollama service running?"
    echo "Try starting ollama with: ollama serve"
    exit 1
fi

print_info "Fetching list of installed models..."
echo ""

models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

if [ -z "$models" ]; then
    print_warning "No models found. Nothing to update."
    exit 0
fi

model_count=$(echo "$models" | wc -l)
print_info "Found $model_count model(s) to check for updates"
echo ""

succeeded=0
failed=0
current=0

for model in $models; do
    current=$((current + 1))
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_info "[$current/$model_count] Pulling model: $model"
    
    if ollama pull "$model"; then
        print_success "Successfully pulled: $model"
        succeeded=$((succeeded + 1))
    else
        print_error "Failed to update: $model"
        failed=$((failed + 1))
    fi
    echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_info "Update Summary"
echo "  Total models: $model_count"
echo -e "  ${GREEN}Successful:${NC} $succeeded"
if [ $failed -gt 0 ]; then
    echo -e "  ${RED}Failed:${NC} $failed"
fi
echo ""

if [ $failed -gt 0 ]; then
    print_warning "Some models failed to update. Check the output above for details."
    exit 1
else
    print_success "All models have been checked for updates!"
    exit 0
fi
