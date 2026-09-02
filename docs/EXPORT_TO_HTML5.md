# Exporting Survive60sec to HTML5 (Browser) and deploying to GitHub Pages

This document explains how to build the Godot project as an HTML5 (WebAssembly) build and deploy it to GitHub Pages. It includes: local export instructions, a helper script, and a GitHub Actions workflow that can run the export on the runner if you provide a Godot download URL.

---

## 1) Overview

- The project is a Godot 4 project (see project.godot). Godot can export to HTML5 (WASM) using the HTML5 export preset. To export you need:
  - Godot 4.x editor or headless binary
  - Godot HTML5 export templates for the matching Godot version

- Typical produced files: `index.html`, `game.wasm`, `game.data`, `game.pck` (names vary). These must be served from an HTTP server.

---

## 2) Local export (recommended first)

Prerequisites (local machine):
- Godot 4.x editor installed (download from godotengine.org)
- Matching HTML5 export templates installed (in Godot Editor: Editor → Manage Export Templates)

Manual GUI export:
1. Open the project in Godot Editor.
2. Project → Export. If you don't have an HTML5 preset, click Add → HTML5.
3. Configure export options (index name, compression, etc.).
4. Click Export Project and choose an output folder (e.g. `build/html5`).

Command-line export (headless Godot):
- Example command (adjust paths & export preset name):

  ./Godot_v4_x_x-stable_linux_headless --export "HTML5" build/html5/index.html

Note: the exact Godot binary filename differs per download. You must ensure the binary is executable.

Serve locally to test:
- Use a simple HTTP server in the `build/html5` folder:

  python3 -m http.server 8000

Then open: http://localhost:8000/index.html

---

## 3) Helper script (scripts/export_html.sh)

A helper script is included in `scripts/export_html.sh`. It expects environment variables or command args pointing to the Godot binary. Usage:

  # mark executable then run locally
  chmod +x scripts/export_html.sh
  GODOT_BIN=/path/to/godot ./scripts/export_html.sh build/html5

The script will:
- check GODOT_BIN exists
- run Godot headless export using preset name "HTML5"

---

## 4) GitHub Actions workflow (automatic export + deploy)

A GitHub Actions workflow is provided at `.github/workflows/export-and-deploy.yml`. It is set up to run manually (workflow_dispatch). For the runner to perform the export you must provide a downloadable Godot binary URL that is compatible with the project (same major.minor Godot version as your export templates). The workflow inputs:

- `godot_url` (required): direct URL to a Godot headless/editor binary tar.gz or zip that can run on the runner (Linux x86_64 recommended).
- `export_preset`: name of the export preset; default `HTML5`.

Notes:
- You must ensure the Godot binary you point to includes the ability to run headless exports and that the matching export templates are available. The workflow attempts a straightforward download/extract and run; if your chosen Godot distribution requires different extraction steps you may need to edit the workflow.

The workflow will:
- download the Godot archive you provide
- extract and run the export command
- publish the resulting exported files to GitHub Pages using the standard `upload-pages-artifact` + `deploy-pages` actions

This automation is convenient but requires you to provide a valid `godot_url` when dispatching the workflow. If you'd like, I can help find a stable Godot binary URL for the runner.

---

## 5) GitHub Pages deployment (manual)

If you prefer to export locally and push to GitHub Pages manually:
1. Export to `build/html5`
2. Commit the exported files to `docs/` folder (or set Pages to serve `gh-pages` branch). Example (docs/ approach):

  rm -rf docs/*
  cp -r build/html5/* docs/
  git add docs
  git commit -m "Update HTML5 build"
  git push

3. Enable GitHub Pages to serve the `docs/` folder (Repository Settings → Pages → Source → `docs/` branch).

---

## 6) Troubleshooting / Notes
- Audio autoplay restrictions: browsers may block audio until user interacts with page — add a start-button that resumes audio if needed.
- WASM MIME type: GitHub Pages serves `.wasm` with the correct MIME type; if you host elsewhere, ensure `application/wasm` is set.
- Large PCK size: if your `.pck` is large, consider compressing assets or enabling streaming support.

---

If you want, I can also:
- Find one or two recommended Godot download URLs for Linux x86_64 headless to use with the workflow
- Commit the helper script and workflow to the repo now

Which of those should I do next? (I can commit the script + workflow for you.)
