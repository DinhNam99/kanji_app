#!/usr/bin/env bash
#
# Run the full Flutter test suite and export the coverage result as LCOV + HTML.
#
# Outputs (both gitignored):
#   coverage/lcov.info       raw LCOV data — the same file CI uploads
#   coverage/html/index.html browsable HTML report (line/function coverage)
#
# Usage:
#   ./scripts/test_coverage.sh                # run tests, then generate HTML
#   ./scripts/test_coverage.sh --open         # ...and open the HTML report
#   ./scripts/test_coverage.sh --no-tests     # skip tests, rebuild HTML from existing LCOV
#   ./scripts/test_coverage.sh --install-deps # install `lcov` (genhtml) if missing
#   ./scripts/test_coverage.sh --help
#
# The HTML report needs `genhtml` from the `lcov` package:
#   macOS:  brew install lcov
#   Debian: sudo apt-get install -y lcov
# Or just run this script with --install-deps.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

COVERAGE_DIR="$ROOT_DIR/coverage"
LCOV_FILE="$COVERAGE_DIR/lcov.info"
HTML_DIR="$COVERAGE_DIR/html"
REPORT_FILE="$HTML_DIR/index.html"

RUN_TESTS=true
OPEN_REPORT=false
INSTALL_DEPS=false

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

usage() {
  sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
}

for arg in "$@"; do
  case "$arg" in
    --no-tests) RUN_TESTS=false ;;
    --open) OPEN_REPORT=true ;;
    --install-deps) INSTALL_DEPS=true ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      warn "unknown option: $arg"
      usage
      exit 2
      ;;
  esac
done

command -v flutter >/dev/null 2>&1 || die "flutter not found on PATH. Install the Flutter SDK first."

install_lcov() {
  if command -v brew >/dev/null 2>&1; then
    info "Installing 'lcov' via Homebrew..."
    brew install lcov
  elif command -v apt-get >/dev/null 2>&1; then
    info "Installing 'lcov' via apt-get..."
    sudo apt-get update && sudo apt-get install -y lcov
  else
    die "Cannot auto-install 'lcov': neither Homebrew nor apt-get is available."
  fi
}

ensure_genhtml() {
  command -v genhtml >/dev/null 2>&1 && return 0

  if [ "$INSTALL_DEPS" = true ]; then
    install_lcov
  else
    die "'genhtml' not found — it ships with the 'lcov' package.
    Install it, then re-run:
      macOS:  brew install lcov
      Debian: sudo apt-get install -y lcov
    Or re-run this script with --install-deps."
  fi

  command -v genhtml >/dev/null 2>&1 || die "'genhtml' is still unavailable after installing 'lcov'."
}

# 1. Run the whole suite with coverage.
if [ "$RUN_TESTS" = true ]; then
  info "Running full test suite with coverage (flutter test --coverage)..."
  rm -rf "$COVERAGE_DIR"
  flutter test --coverage
else
  info "Skipping tests (--no-tests); reusing existing LCOV data."
fi

[ -f "$LCOV_FILE" ] || die "No LCOV data found at $LCOV_FILE. Run the script without --no-tests first."

# 2. Turn LCOV into a browsable HTML report.
ensure_genhtml
info "Generating HTML report..."
genhtml "$LCOV_FILE" \
  --output-directory "$HTML_DIR" \
  --title "Kanji Beginner — test coverage" \
  --legend \
  --show-details \
  >/dev/null

# 3. Print a short summary (lcov ships with genhtml, so it is normally present).
if command -v lcov >/dev/null 2>&1; then
  echo
  info "Coverage summary:"
  lcov --summary "$LCOV_FILE" 2>&1 | sed 's/^/    /'
fi

echo
info "LCOV: $LCOV_FILE"
info "HTML: $REPORT_FILE"

if [ "$OPEN_REPORT" = true ]; then
  if command -v open >/dev/null 2>&1; then
    open "$REPORT_FILE"
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$REPORT_FILE"
  else
    warn "No file opener found; open $REPORT_FILE manually."
  fi
fi
