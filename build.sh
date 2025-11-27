#!/usr/bin/env bash
set -e

rm -rf public/
mkdir -p public

# Kill any existing process on port 4000
lsof -ti:4000 | xargs kill -9 2>/dev/null || true

MIX_ENV=prod mix deps.get
MIX_ENV=prod mix compile
MIX_ENV=prod mix tailwind default --minify
MIX_ENV=prod mix phx.digest
PORT=4000 mix phx.server &
SERVER_PID=$!

sleep 5

# Check if wget is available, otherwise use curl
if command -v wget &> /dev/null; then
  echo "Using wget to download site..."
  # Download with wget
  cd public
  wget -r -np -nH -E -k http://localhost:4000/
  cd ..
else
  echo "Using curl to download site..."
  # Download all pages with curl
  BASE_URL="http://localhost:4000"
  PAGES=("" "page1" "page2" "page3" "article")

  for page in "${PAGES[@]}"; do
    if [ -z "$page" ]; then
      # Home page
      curl -s "${BASE_URL}/" > public/index.html
    else
      # Other pages
      curl -s "${BASE_URL}/${page}" > "public/${page}.html"
    fi
  done

  # Download assets
  mkdir -p public/assets/css public/assets/js public/images

  # Get CSS
  curl -s "${BASE_URL}/assets/css/app.css" > public/assets/css/app.css 2>/dev/null || true

  # Get JS
  curl -s "${BASE_URL}/assets/js/app.js" > public/assets/js/app.js 2>/dev/null || true

  # Get favicon
  curl -s "${BASE_URL}/favicon.ico" > public/favicon.ico 2>/dev/null || true
fi

# Kill the server
kill $SERVER_PID 2>/dev/null || true

echo "Static site exported to public/"
echo "Files created:"
ls -la public/
