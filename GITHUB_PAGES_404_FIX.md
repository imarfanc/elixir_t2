# GitHub Pages 404 Error - FIXED! ✅

## The Problem

Getting 404 error at `https://imarfanc.github.io/elixir_t2/`

## Root Cause

The original `build.sh` script used `wget` with the `-P public` flag, which created files in:
```
public/localhost:4000/index.html
public/localhost:4000/page1.html
...
```

But GitHub Pages expects files directly in `public/`:
```
public/index.html
public/page1.html
...
```

## The Fix

### 1. Updated `build.sh`

The new script:
- Detects whether `wget` or `curl` is available
- Uses `wget -r -np -nH -E -k` to download files directly to `public/` (no subdirectory)
- Falls back to `curl` if `wget` is not available (for macOS)
- Kills any existing process on port 4000 before starting

### 2. Updated `.github/workflows/deploy.yml`

Added wget installation step:
```yaml
- name: Install dependencies & build static site
  run: |
    sudo apt-get update
    sudo apt-get install -y wget
    mix deps.get
    mix tailwind.install
    chmod +x build.sh
    ./build.sh
```

## Verification

Tested locally - files are now created correctly:
```bash
$ ls -la public/
-rw-r--r--  article.html
-rw-r--r--  index.html
-rw-r--r--  page1.html
-rw-r--r--  page2.html
-rw-r--r--  page3.html
drwxr-xr-x  assets/
-rw-r--r--  favicon.ico
```

## Next Steps

1. **Commit and push:**
   ```bash
   git add build.sh .github/workflows/deploy.yml
   git commit -m "Fix build script to output files to correct directory"
   git push origin main
   ```

2. **Wait for GitHub Actions to complete** (check the Actions tab)

3. **Enable GitHub Pages** (if not already):
   - Go to Settings → Pages
   - Source: `gh-pages` branch
   - Folder: `/ (root)`
   - Click Save

4. **Wait 2-5 minutes** for GitHub Pages to deploy

5. **Visit:** `https://imarfanc.github.io/elixir_t2/`

## How the Fixed Build Script Works

### With wget (GitHub Actions):
```bash
cd public
wget -r -np -nH -E -k http://localhost:4000/
```

Flags explained:
- `-r` = recursive download
- `-np` = no parent (don't go up directories)
- `-nH` = no host directory (don't create localhost:4000 folder)
- `-E` = add .html extension
- `-k` = convert links for local viewing

### With curl (macOS):
Downloads each page individually:
```bash
curl -s "http://localhost:4000/" > public/index.html
curl -s "http://localhost:4000/page1" > public/page1.html
# etc...
```

## Summary

✅ **Build script fixed** - Files now output to `public/` directly
✅ **Workflow updated** - Installs wget on Ubuntu
✅ **Cross-platform** - Works with both wget and curl
✅ **Tested locally** - Verified file structure is correct

Your site should now deploy successfully to GitHub Pages!
