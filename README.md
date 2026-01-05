# Compress PDF - Raycast Script

A Raycast script command for compressing PDF files using Ghostscript with PDF Squeezer-like quality settings.

## Features

- **Three compression levels** - Low, Medium, High
- **Batch processing** - Compress multiple PDFs at once
- **Smart detection** - Skips files that can't be compressed further
- **Size feedback** - Shows total space saved after compression

## Compression Levels

| Level | DPI | Best For |
|-------|-----|----------|
| Low | 72 | Web, email attachments |
| **Medium** | 150 | General use (default) |
| High | 300 | Printing |

## Requirements

- macOS
- [Raycast](https://raycast.com)
- [Ghostscript](https://www.ghostscript.com/)

## Installation

### 1. Install Ghostscript

```bash
brew install ghostscript
```

### 2. Install the script

Copy `compress-pdf.sh` to your Raycast scripts folder:

```bash
cp compress-pdf.sh ~/.config/raycast/scripts/
chmod +x ~/.config/raycast/scripts/compress-pdf.sh
```

Or add your custom scripts folder in Raycast preferences.

### 3. Reload Raycast

Open Raycast and the "Compress PDF" command should appear.

## Usage

1. Select one or more PDF files in Finder
2. Open Raycast (`⌘ + Space` or your hotkey)
3. Type "Compress PDF"
4. Choose compression level (optional, defaults to Medium)
5. Press Enter

Compressed files are saved in the same directory with `_compressed` suffix.

## How It Works

The script uses Ghostscript with optimized settings that rival commercial tools like PDF Squeezer:

- **Font compression** - Compresses and subsets embedded fonts
- **Image downsampling** - Bicubic resampling for smooth results
- **Duplicate detection** - Removes redundant embedded images
- **Smart quality presets** - Ghostscript's `/screen`, `/ebook`, `/printer` profiles

### Why not use the existing Raycast PDF plugin?

The [birkhoff/pdf-compression](https://www.raycast.com/birkhoff/pdf-compression) plugin uses basic Ghostscript settings that often fail to compress already-optimized PDFs. This script adds aggressive compression flags that achieve results comparable to PDF Squeezer.

## Examples

```
# Before: document.pdf (2.4 MB)
# After:  document_compressed.pdf (586 KB)
# Result: ✅ Compressed 1 PDF(s) (saved ~1.8MB)
```

## License

MIT

## Author

Marcin
