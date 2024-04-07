#!/bin/bash

# Function to calculate recommended swap size without hibernation
calculate_swap_size() {
    total_ram=$(grep MemTotal /proc/meminfo | awk '{print $2}')  # Get total RAM in KB
    ram_in_gb=$((total_ram / 1024 / 1024))  # Convert RAM to GB

    if [ $ram_in_gb -lt 2 ]; then
        swap_size=$((total_ram * 2 / 1024))  # Double RAM (MB)
    elif [ $ram_in_gb -lt 8 ]; then
        swap_size=$((total_ram / 1024)) # Equal to RAM (MB)
    else
        # Calculate roughly the square root of RAM in MB
        swap_size=$(( $ram_in_gb ** (1/2) * 1024 ))
    fi

    echo "$swap_size"  # Return the calculated swap size in MB
}

# Get recommended swap size in MB
recommended_swap_size=$(calculate_swap_size)

# Create the swap file (no confirmation)
sudo fallocate -l ${recommended_swap_size}M /swapfile

# Set up swap file permissions
sudo chmod 600 /swapfile

# Format the swap file
sudo mkswap /swapfile

# Activate the swap file
sudo swapon /swapfile

# Make swap permanent (edit /etc/fstab)
echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab

echo "Swap file created and activated!"
