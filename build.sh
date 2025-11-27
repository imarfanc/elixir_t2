#!/usr/bin/env bash
set -e

rm -rf public/

MIX_ENV=prod mix deps.get
MIX_ENV=prod mix compile
MIX_ENV=prod mix tailwind default --minify
MIX_ENV=prod mix phx.digest
PORT=4000 mix phx.server &

sleep 5

wget --mirror --convert-links --adjust-extension --page-requisites --no-parent http://localhost:4000 -P public

kill %1

echo "Static site exported to public/"
