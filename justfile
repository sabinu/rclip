# Build AppImage
build-appimage:
    poetry run appimage-builder --recipe ./release-utils/appimage/appimage-builder.yml

# Check code style with ruff
lint-style:
    poetry run ruff check

# Fix code style issues
fix-style:
    poetry run ruff check --fix
    poetry run ruff format

# Check types with pyright
lint-types:
    poetry run pyright .

# Run all linters
lint: lint-style lint-types

# Run tests
test:
    poetry run pytest tests

# Run system rclip tests
test-system-rclip:
    RCLIP_TEST_RUN_SYSTEM_RCLIP=true poetry run pytest tests/e2e

# Build Docker image
build-docker:
    DOCKER_DEFAULT_PLATFORM=linux/amd64 docker build . -t rclip

# Build Windows executable (CI runs release-brew as part of the release action)
build-windows:
    poetry run pyinstaller -y ./release-utils/windows/pyinstaller.spec

# Release Homebrew formula (CI runs this as part of the release action)
release-brew:
    poetry run ./release-utils/homebrew/release.sh

# Create a new release with the specified version
release VERSION:
    poetry version {{ VERSION }}
    {{ if os() == "macos" { `sed -i '' "s/version: .*/version: $(poetry version -s)/" snap/snapcraft.yaml` } else { `sed -i "s/version: .*/version: $(poetry version -s)/" snap/snapcraft.yaml` } }}
    {{ if os() == "macos" { `sed -i '' "s|source: .*|source: ./snap/local/rclip-$(poetry version -s).tar.gz|" snap/snapcraft.yaml` } else { `sed -i "s|source: .*|source: ./snap/local/rclip-$(poetry version -s).tar.gz|" snap/snapcraft.yaml` } }}
    git commit -am "release: v$(poetry version -s)"
    git push origin $(git branch --show-current)
    git tag v$(poetry version -s)
    git push origin v$(poetry version -s)
