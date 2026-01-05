#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Compress PDF
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 📄
# @raycast.argument1 { "type": "dropdown", "placeholder": "Level", "optional": true, "data": [{"title": "Medium (150 DPI)", "value": "medium"}, {"title": "Low (72 DPI)", "value": "low"}, {"title": "High (300 DPI)", "value": "high"}] }
# @raycast.packageName PDF Tools

# Documentation:
# @raycast.description Compress PDF files (PDF Squeezer-like quality)
# @raycast.author Marcin
# @raycast.authorURL https://raycast.com

# Compression level (default: medium - like PDF Squeezer)
LEVEL="${1:-medium}"

# Check if Ghostscript is installed
if ! command -v gs &> /dev/null; then
    echo "❌ Install Ghostscript: brew install ghostscript"
    exit 1
fi

# Get selected files from Finder
FILES=$(osascript -e '
tell application "Finder"
    set selectedItems to selection
    if selectedItems is {} then
        return ""
    end if
    set filePaths to ""
    repeat with i in selectedItems
        set filePaths to filePaths & POSIX path of (i as alias) & linefeed
    end repeat
    return filePaths
end tell
')

if [ -z "$FILES" ]; then
    echo "❌ Select PDF files in Finder"
    exit 1
fi

# Settings based on level (inspired by PDF Squeezer)
case "$LEVEL" in
    "low")
        # Maximum compression - web/screen
        DPI=72
        QUALITY="/screen"
        ;;
    "medium")
        # Balance quality/size - like PDF Squeezer Medium
        DPI=150
        QUALITY="/ebook"
        ;;
    "high")
        # Preserve quality - for printing
        DPI=300
        QUALITY="/printer"
        ;;
    *)
        DPI=150
        QUALITY="/ebook"
        ;;
esac

COUNT=0
SAVED=0

while IFS= read -r file; do
    [ -z "$file" ] && continue
    
    # Check if it's a PDF
    EXT="${file##*.}"
    EXT_LOWER=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$EXT_LOWER" == "pdf" ]]; then
        DIR=$(dirname "$file")
        BASENAME=$(basename "$file" ".$EXT")
        OUTPUT="$DIR/${BASENAME}_compressed.pdf"
        
        # Size before
        SIZE_BEFORE=$(stat -f%z "$file" 2>/dev/null || echo 0)
        
        # Compression with PDF Squeezer-like settings
        gs -sDEVICE=pdfwrite \
           -dCompatibilityLevel=1.5 \
           -dPDFSETTINGS="$QUALITY" \
           -dNOPAUSE \
           -dQUIET \
           -dBATCH \
           -dCompressFonts=true \
           -dSubsetFonts=true \
           -dEmbedAllFonts=true \
           -dColorImageDownsampleType=/Bicubic \
           -dColorImageResolution="$DPI" \
           -dGrayImageDownsampleType=/Bicubic \
           -dGrayImageResolution="$DPI" \
           -dMonoImageDownsampleType=/Subsample \
           -dMonoImageResolution="$DPI" \
           -dDownsampleColorImages=true \
           -dDownsampleGrayImages=true \
           -dDownsampleMonoImages=true \
           -dAutoRotatePages=/None \
           -dDetectDuplicateImages=true \
           -sOutputFile="$OUTPUT" \
           "$file" 2>/dev/null
        
        if [ -f "$OUTPUT" ]; then
            SIZE_AFTER=$(stat -f%z "$OUTPUT" 2>/dev/null || echo 0)
            
            # Check if compression was effective
            if [ "$SIZE_AFTER" -lt "$SIZE_BEFORE" ]; then
                SAVED=$((SAVED + SIZE_BEFORE - SIZE_AFTER))
                ((COUNT++))
            else
                # Compression didn't help - remove and notify
                rm "$OUTPUT"
                echo "⚠️ $(basename "$file") - cannot be compressed further"
            fi
        fi
    fi
done <<< "$FILES"

if [ $COUNT -gt 0 ]; then
    # Format saved space
    if [ $SAVED -gt 1048576 ]; then
        SAVED_FMT="$(echo "scale=1; $SAVED/1048576" | bc)MB"
    elif [ $SAVED -gt 1024 ]; then
        SAVED_FMT="$(echo "scale=1; $SAVED/1024" | bc)KB"
    else
        SAVED_FMT="${SAVED}B"
    fi
    echo "✅ Compressed $COUNT PDF(s) (saved ~$SAVED_FMT)"
elif [ $COUNT -eq 0 ]; then
    echo "❌ No PDF files found to compress"
fi
