#!/bin/sh

URLFILE="/opt/blf/blocklists"
TMPDIR="/tmp/pihole"

mkdir -p "$TMPDIR"
mkdir -p /tmp/bulkfiles

started=$(date)

echo "===== Pi-hole Bulk Downloader ====="
echo "Started at $started"
echo

#######################################
# PASS 1: calculate total size
#######################################

echo "===== Calculating total download size ====="

totalbytes=0
counter=1

while IFS= read -r url
do
    case "$url" in
        ''|\#*) continue ;;
    esac

    size=$(curl -sIL "$url" \
        | awk -F': ' 'tolower($1)=="content-length" {gsub("\r",""); len=$2}
          END {print len+0}')

    [ -z "$size" ] && size=0

    eval SIZE_$counter=$size

    human=$(numfmt --to=iec "$size" 2>/dev/null || echo "?")

    echo "[$counter] $human  $url"

    totalbytes=$((totalbytes + size))
    counter=$((counter + 1))

done < "$URLFILE"

echo
echo "Total size (known parts only): $(numfmt --to=iec "$totalbytes")"
echo

#######################################
# PASS 2: download
#######################################

downloaded=0
counter=1

while IFS= read -r url
do
    case "$url" in
        ''|\#*) continue ;;
    esac

    eval size=\$SIZE_$counter

    percent=$(( totalbytes > 0 ? downloaded * 100 / totalbytes : 0 ))

    donebars=$(( percent / 2 ))
    leftbars=$(( 50 - donebars ))

    echo
    echo "===== Overall Progress ====="

    printf "[%3d%%] [" "$percent"
    printf "%0.s#" $(seq 1 $donebars 2>/dev/null)
    printf "%0.s-" $(seq 1 $leftbars 2>/dev/null)
    printf "] %s / %s\n" \
        "$(numfmt --to=iec "$downloaded")" \
        "$(numfmt --to=iec "$totalbytes")"

    echo
    echo "[$counter] Downloading:"
    echo "$url"
    echo "Size: $(numfmt --to=iec "$size" 2>/dev/null || echo unknown)"

    wget --show-progress -O "$TMPDIR/$counter" "$url"

    downloaded=$((downloaded + size))
    counter=$((counter + 1))

done < "$URLFILE"

#######################################
# cleanup + merge
#######################################

echo
echo "Combining all downloaded adlists into bulk.raw"

find "$TMPDIR" -type f -exec cat {} + \
    > /tmp/bulkfiles/bulk.raw
echo "Getting urls from the raw file, sorting and delete duplicates..."

total=$(wc -l < /tmp/bulkfiles/bulk.raw)

pv -l -s "$total" /tmp/bulkfiles/bulk.raw | grep -E -v '^(#|$)' | grep -Eo '([*]?\.)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}' | sed 's/^\*\.//' | sed 's/^www\.//' | tr '[:upper:]' '[:lower:]' | sort -u > /tmp/bulkfiles/bulk.clean

echo "Copying final file..."
mv /tmp/bulkfiles/bulk.clean /var/www/mysite/bulk.clean

echo "Cleaning temp files..."
rm -rf /tmp/pihole/*
rm -rf /tmp/bulkfiles/*

#######################################
# HTML output
#######################################

echo "Generating HTML..."

howbig=$(du -h /var/www/mysite/bulk.clean | awk '{print $1}')
howlong=$(wc -l /var/www/mysite/bulk.clean | awk '{print $1}')
whenmade=$(ls -al /var/www/mysite/bulk.clean | awk '{print $6" "$7" "$8}')

cat > /var/www/mysite/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Pi-hole Bulk Downloader</title>
    <meta http-equiv="refresh" content="20">
    <meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
<div>
<a href="bulk.clean">
Click here to download the bulk block list ($howbig, $howlong lines, $whenmade)
</a>
</div>
</body>
</html>
EOF

echo
echo "===== DONE ====="
echo "Started:  $started"
echo "Finished: $(date)"
