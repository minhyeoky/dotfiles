#!/bin/bash


# Function to search for app, get ID, and install it
mas_auto_install() {
    app_name="$1"
    
    # Check if user is signed in first
    
    echo "Searching for $app_name..."
    
    # Search for the app and get its ID
    search_result=$(mas search "$app_name")
    
    if [[ -z "$search_result" ]]; then
        echo "No app found with name: $app_name"
        return 1
    fi
    
    app_id=$(echo "$search_result" | head -n 1 | awk '{print $1}')
    app_full_name=$(echo "$search_result" | head -n 1 | cut -d' ' -f2-)
    
    if ! [[ "$app_id" =~ ^[0-9]+$ ]]; then
        echo "Failed to extract app ID for: $app_name"
        return 1
    fi
    
    echo "Found \"$app_full_name\" with ID: $app_id"
    echo "Installing \"$app_full_name\"..."
    mas install "$app_id"
    
    if [ $? -eq 0 ]; then
        echo "Successfully installed \"$app_full_name\""
    else
        echo "Failed to install \"$app_full_name\""
    fi
}

# Use the function with the app name
mas_auto_install "$1"
