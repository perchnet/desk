# List available recipes
default:
    @just --list

# Variables
recipe := "recipes/recipe.yml"
dist := "dist"
build := "build"
build-driver := "buildah"
inspect-driver := "skopeo"
run-driver := "podman"

# Generate necessary files (e.g., protobuf, OpenAPI specs)
generate:
    @echo "Generating Containerfile..."
    # bluebuild generate --{B,I,R}buildah {{recipe}}
    bluebuild generate --build-driver {{build-driver}} --inspect-driver {{inspect-driver}} --run-driver {{run-driver}} {{recipe}}
    # Add your generation commands here
    # Example:
    # protoc --go_out=. proto/*.proto
    # swagger generate spec -o api/swagger.json

# Build the project
build:
    @echo "Building project..."
    bluebuild build --build-driver {{build-driver}} --inspect-driver {{inspect-driver}} --run-driver {{run-driver}} {{recipe}}
    # Add your build commands here
    # Example:
    # go build -o bin/app cmd/app/main.go
    # npm run build

# Clean build artifacts
clean:
    @echo "Cleaning build artifacts..."
    # Remove all untracked files and directories, but respect .gitignore rules
    git clean --force --directories --exclude-standard

# Build and switch the current OSTree to the build output
switch:
    @echo "Building and switching OSTree..."
    bluebuild switch --build-driver {{build-driver}} --inspect-driver {{inspect-driver}} --run-driver {{run-driver}} {{recipe}}

# Run tests
test: validate

validate:
    @echo "Validating..."
    bluebuild validate --all-errors --verbose {{recipe}}
