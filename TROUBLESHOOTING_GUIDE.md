# Phoenix Static Site Setup - Complete Guide

## Issues Encountered and Solutions

### Issue 1: Poor Typography in Article Page ❌ → ✅

**Problem:**
The article page used Tailwind's `prose` classes which didn't render well with daisyUI components.

**Solution:**
Replaced generic `prose` classes with custom Tailwind utilities for better control:

```heex
<!-- BEFORE: Using prose classes -->
<article class="prose lg:prose-xl">
  <h1>Building Static Sites...</h1>
  <p>Phoenix Framework combined...</p>
</article>

<!-- AFTER: Custom typography with better spacing -->
<article class="space-y-6">
  <div>
    <h1 class="text-5xl font-bold mb-4">Building Static Sites...</h1>
    <p class="text-xl text-base-content/80 leading-relaxed">
      Phoenix Framework combined...
    </p>
  </div>
  <div class="divider"></div>
  <!-- More sections with proper spacing -->
</article>
```

**Key Improvements:**
- ✅ **Larger headings:** `text-5xl` for H1, `text-3xl` for H2
- ✅ **Better spacing:** `space-y-6` between sections, `leading-relaxed` for paragraphs
- ✅ **Readable text sizes:** `text-xl` for intro, `text-lg` for body
- ✅ **Visual separators:** Added `divider` components between sections
- ✅ **Proper list styling:** `list-disc list-inside space-y-2 text-lg ml-4`

**File Changed:** `lib/elixir_t2_web/controllers/page_html/article.html.heex`

---

### Issue 2: GitHub Actions Regex Compilation Error ❌ → ✅

**Problem:**
```
** (Regex.CompileError) invalid_option at position E
    (elixir 1.17.3) lib/regex.ex:257: Regex.compile!/2
    (elixir 1.17.3) expanding macro: Kernel.sigil_r/2
    /home/runner/work/elixir_t2/elixir_t2/config/config.exs:55: (file)
```

**Root Cause:**
Phoenix generator created regex patterns with an invalid `E` modifier in `config/dev.exs`:

```elixir
# WRONG - 'E' is not a valid regex modifier
~r"priv/static/(?!uploads/).*\.(js|css|png|jpeg|jpg|gif|svg)$"E
```

The `E` at the end is invalid. In Elixir regex sigils, valid modifiers are:
- `i` - case insensitive
- `u` - Unicode
- `s` - dotall mode
- `m` - multiline mode
- `r` - ungreedy

**Solution:**
Remove the invalid `E` modifier from all regex patterns in `config/dev.exs`:

```elixir
# CORRECT - No invalid modifier
~r"priv/static/(?!uploads/).*\.(js|css|png|jpeg|jpg|gif|svg)$"
```

**Files Changed:**
- `config/dev.exs` - Lines 51, 53, 55, 56 (removed `E` modifier)
- `.github/workflows/deploy.yml` - Updated Elixir/OTP versions (though this wasn't the root cause)

**Changes Made:**
```diff
# config/dev.exs
  patterns: [
    # Static assets, except user uploads
-   ~r"priv/static/(?!uploads/).*\.(js|css|png|jpeg|jpg|gif|svg)$"E,
+   ~r"priv/static/(?!uploads/).*\.(js|css|png|jpeg|jpg|gif|svg)$",
    # Gettext translations
-   ~r"priv/gettext/.*\.po$"E,
+   ~r"priv/gettext/.*\.po$",
    # Router, Controllers, LiveViews and LiveComponents
-   ~r"lib/elixir_t2_web/router\.ex$"E,
+   ~r"lib/elixir_t2_web/router\.ex$",
-   ~r"lib/elixir_t2_web/(controllers|live|components)/.*\.(ex|heex)$"E
+   ~r"lib/elixir_t2_web/(controllers|live|components)/.*\.(ex|heex)$"
  ]
```


---

### Issue 3: GitHub Pages Deployment Permission Error ❌ → ✅

**Problem:**
```
remote: Permission to imarfanc/elixir_t2.git denied to github-actions[bot].
fatal: unable to access 'https://github.com/imarfanc/elixir_t2.git/': The requested URL returned error: 403
Error: Action failed with "The process '/usr/bin/git' failed with exit code 128"
```

**Root Cause:**
The `peaceiris/actions-gh-pages@v4` action requires different permissions than what was configured. The workflow had `contents: read` but needed `contents: write` to push to the `gh-pages` branch.

**Solution:**
1. Change permissions from `contents: read` to `contents: write`
2. Use version `v3` of the action instead of `v4` (more stable with GITHUB_TOKEN)

```yaml
# BEFORE ❌
permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  build-and-deploy:
    steps:
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./public

# AFTER ✅
permissions:
  contents: write

jobs:
  build-and-deploy:
    steps:
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./public
```

**File Changed:** `.github/workflows/deploy.yml`

**Why This Works:**
- `contents: write` gives the action permission to push to the repository
- Version `v3` of the action works better with the default `GITHUB_TOKEN`
- The action will automatically create and push to the `gh-pages` branch

---

## How to Recreate This App From Scratch (Avoiding These Issues)

### Step 1: Generate Phoenix App

```bash
# Navigate to your project directory
cd /path/to/your/project

# Generate Phoenix app without unnecessary features
mix phx.new . --no-ecto --no-live --no-mailer --no-dashboard

# When prompted about existing directory, type 'Y'
# When prompted to fetch dependencies, type 'Y'
```

### Step 2: Fix the Regex Bug Immediately

**IMPORTANT:** Right after generation, fix the regex patterns in `config/dev.exs`:

```bash
# Open config/dev.exs and remove all 'E' modifiers from regex patterns
# Lines 51, 53, 55, 56 should NOT have 'E' at the end
```

Or use this sed command to fix it automatically:
```bash
sed -i '' 's/\$\"E,/\$\",/g' config/dev.exs
sed -i '' 's/\$\"E$/\$\"/g' config/dev.exs
```

### Step 3: Install Dependencies

```bash
mix deps.get
mix tailwind.install
```

### Step 4: Update Router

Edit `lib/your_app_web/router.ex`:

```elixir
scope "/", YourAppWeb do
  pipe_through :browser

  get "/", PageController, :home
  get "/page1", PageController, :page1
  get "/page2", PageController, :page2
  get "/page3", PageController, :page3
  get "/article", PageController, :article
end
```

### Step 5: Update Controller

Edit `lib/your_app_web/controllers/page_controller.ex`:

```elixir
defmodule YourAppWeb.PageController do
  use YourAppWeb, :controller

  def home(conn, _params), do: render(conn, :home)
  def page1(conn, _params), do: render(conn, :page1)
  def page2(conn, _params), do: render(conn, :page2)
  def page3(conn, _params), do: render(conn, :page3)
  def article(conn, _params), do: render(conn, :article)
end
```

### Step 6: Create Templates

Create files in `lib/your_app_web/controllers/page_html/`:
- `home.html.heex`
- `page1.html.heex`
- `page2.html.heex`
- `page3.html.heex`
- `article.html.heex`

**Pro Tip:** Use custom Tailwind classes instead of `prose` for better control:
```heex
<!-- Good: Custom typography -->
<article class="space-y-6">
  <h1 class="text-5xl font-bold mb-4">Title</h1>
  <p class="text-lg leading-relaxed">Content...</p>
</article>

<!-- Avoid: Generic prose classes with daisyUI -->
<article class="prose lg:prose-xl">
  <h1>Title</h1>
  <p>Content...</p>
</article>
```

### Step 7: Create Build Script

Create `build.sh`:

```bash
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
```

Make it executable:
```bash
chmod +x build.sh
```

### Step 8: Create GitHub Actions Workflow

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy static site to GitHub Pages

on:
  push:
    branches:
      - main

permissions:
  contents: write

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repo
        uses: actions/checkout@v3

      - name: Setup Elixir
        uses: erlef/setup-beam@v1
        with:
          elixir-version: '1.17.3'
          otp-version: '27.1'

      - name: Install dependencies & build static site
        run: |
          mix deps.get
          mix tailwind.install
          chmod +x build.sh
          ./build.sh

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./public
```

### Step 9: Test Locally

```bash
# Start the server
mix phx.server

# Visit http://localhost:4000
# Test all pages to ensure they work
```

### Step 10: Deploy

```bash
# Commit everything
git add .
git commit -m "Initial Phoenix static site setup"
git push origin main

# Enable GitHub Pages in repository settings
# Set source to 'gh-pages' branch
```

---

## Simpler Alternative Approach

If you want an even simpler setup without the regex issues:

### Option 1: Use Older Phoenix Version

```bash
# Install Phoenix 1.6.x which doesn't have this bug
mix archive.install hex phx_new 1.6.16
mix phx.new my_app --no-ecto --no-live
```

### Option 2: Skip Live Reload Configuration

After generating the app, you can comment out the entire `live_reload` section in `config/dev.exs` if you don't need hot reloading:

```elixir
# config :elixir_t2, ElixirT2Web.Endpoint,
#   live_reload: [
#     web_console_logger: true,
#     patterns: [
#       # ... all the problematic regex patterns
#     ]
#   ]
```

### Option 3: Use a Static Site Generator Instead

For truly simple static sites, consider:
- **Astro** - Modern, fast, works with any framework
- **Hugo** - Blazing fast, Go-based
- **Eleventy** - Simple, JavaScript-based
- **Jekyll** - Ruby-based, GitHub Pages native

Phoenix is powerful but might be overkill for simple static sites.

---

## Quick Reference: Common Issues

| Issue | Symptom | Solution |
|-------|---------|----------|
| Regex compile error | `invalid_option at position E` | Remove `E` from regex patterns in `config/dev.exs` |
| Poor typography | Text looks cramped/ugly | Use custom Tailwind classes instead of `prose` |
| Port already in use | `eaddrinuse` error | Kill process: `lsof -ti:4000 \| xargs kill -9` |
| Build fails in CI | GitHub Actions fails | Update Elixir/OTP versions in workflow |
| Static files missing | 404 on assets | Run `mix phx.digest` before serving |
| GitHub Pages deploy fails | `Permission denied to github-actions[bot]` | Change permissions to `contents: write` and use `peaceiris/actions-gh-pages@v3` |

---

## Summary

**What We Fixed:**
1. ✅ Typography - Custom Tailwind classes for better readability
2. ✅ Regex bug - Removed invalid `E` modifier from `config/dev.exs`
3. ✅ GitHub Pages permissions - Changed to `contents: write` and used `peaceiris/actions-gh-pages@v3`

**Key Takeaways:**
- Phoenix generator has a bug with regex modifiers (as of Phoenix 1.7.x)
- Always test your config files after generation
- Custom typography gives better control than generic `prose` classes
- Keep Elixir/OTP versions up to date for CI/CD
- GitHub Actions needs `contents: write` permission to deploy to gh-pages

**Files Modified:**
- `lib/elixir_t2_web/controllers/page_html/article.html.heex` - Typography improvements
- `config/dev.exs` - Fixed regex patterns
- `.github/workflows/deploy.yml` - Updated versions and permissions

Your Phoenix static site should now build and deploy successfully! 🎉
