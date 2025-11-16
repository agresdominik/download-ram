#!/usr/bin/env bash

download_ram() {

  local requested_size="$1"

  echo "Downloading $requested_size GiB of RAM"

  local total_needed=$(( requested_size + 4 ))

  if check_root_space "$total_needed"; then
    echo ""
  else
    exit 1
  fi

  if actually_download_the_ram "$requested_size"; then
    echo "Done, run (sudo) swapon --show to see your new RAM"
  else
    echo "Failed"
    exit 1
  fi
}

actually_download_the_ram() {

  local size_gb="$1"
  local dir="/var/swap"

  # Create directory to save swapfiles
  mkdir -p "$dir" || {
    echo "Failed to create $dir" >&2; return 1;
  }

  # Find the next available swapfile name
  local i=0
  local swapfile
  while :; do
    swapfile="$dir/swapfile$i"
    [ -e "$swapfile" ] || break
    i=$((i + 1))
  done

  echo "Downloading $swapfile (${size_gb}G) of RAM"

  # Use fallocate (or dd in case no fallocate is installed) to create swapfile
  if ! fallocate -l "${size_gb}G" "$swapfile" 2>/dev/null; then
    echo "fallocate failed, falling back to dd (this may take a while)..."
    if ! dd if=/dev/zero of="$swapfile" bs=1G count="$size_gb" status=progress; then
      echo "fallocate/dd failed in creating swapfile" >&2
      rm -f "$swapfile"
      return 1
    fi
  fi

  # Set file to read and write
  chmod 600 "$swapfile" || {
    echo "chmod failed" >&2;
    rm -f "$swapfile"; return 1;
  }

  # Turn the file to swap type
  if ! mkswap "$swapfile"; then
    echo "mkswap failed" >&2
    rm -f "$swapfile"
    return 1
  fi

  # Run swapon to enable swap
  if ! swapon "$swapfile"; then
    echo "swapon failed" >&2
    return 1
  fi

  # Check if swap is running and write into fstab file
  if swapon --show | awk 'NR>1 {print $1}' | grep -qx "$swapfile"; then
    echo "Successfully 'downloaded' ${size_gb}G of RAM into: $swapfile"
    if ! grep -q -E "^[[:space:]]*${swapfile}[[:space:]]" /etc/fstab; then
      printf "%s\n" "${swapfile} none swap defaults 0 0" >> /etc/fstab
    else
      echo "Entry for $swapfile already exists in /etc/fstab, not adding duplicate"
    fi
    return 0
  else
    echo "Swapfile created but not active. Check 'swapon --show'" >&2
    return 1
  fi

}

check_root_space() {

  local need_gib=$1
  local free_gib

  free_gib=$(df -B1G --output=avail / | tail -n1 | tr -d ' ')

  if (( free_gib >= need_gib )); then
    return 0
  else
    echo "Your system does not have enough space to download the RAM"
    echo "Need at least ${need_gib}GiB free, but only ${free_gib}GiB is available." >&2
    return 1
  fi

}

# -- Start of Script --

# Check if ran as sudo
if [[ "$EUID" -ne 0 ]]; then
    echo "This script must be run as root (try: sudo $0)" >&2
    exit 1
fi

# Check if system is mounted on a ext4 filesystem
fs_type=$(findmnt -no FSTYPE / 2>/dev/null)
if [[ "$fs_type" != "ext4" ]]; then
    echo "Error: /var is on '$fs_type'. This script only supports systems mounted on ext4." >&2
    exit 1
fi

# Message + handle input
echo "Please select how much RAM you want to download:"
echo "1) 4GiB of RAM"
echo "2) 8GiB of RAM"
echo "3) 16GiB of RAM"
echo "Plese note you need at least the chosen amount of space on your drive + 4GiB"
echo ""

read -r -p "Enter your choice (1-3): " choice

case "$choice" in
  1)
    value=4
    ;;
  2)
    value=8
    ;;
  3)
    value=16
    ;;
  *)
    echo "Invalid choice."
    exit 1
    ;;
esac

download_ram "$value"
