#!/bin/bash

# Directory for logs
log_directory="setup-log"
log_file="${log_directory}/install_log.txt"

# Create directory for log files
mkdir -p "${log_directory}"

# Function to log messages
log_message() {
    echo "$1" | tee -a "${log_file}"
}

# Function to install fnm
install_fnm() {
    log_message "Starting installation of fnm..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl -fsSL https://fnm.vercel.app/install | bash 2>&1 | tee -a "${log_file}"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install fnm 2>&1 | tee -a "${log_file}"
    elif [[ "$OSTYPE" == "msys" ]]; then
        winget install Schniz.fnm 2>&1 | tee -a "${log_file}"
    else
        log_message "Unsupported OS for fnm installation."
        exit 1
    fi
    log_message "fnm installation complete."
}

# Install fnm
install_fnm

# Install and use Node.js v20
log_message "Installing Node.js version 20..."
fnm use --install-if-missing 20 >> "${log_file}" 2>&1
node_version=$(node -v)
npm_version=$(npm -v)
if [[ "$node_version" == "v20.15.1" && "$npm_version" == "10.7.0" ]]; then
    log_message "Node.js and npm versions verified successfully."
else
    log_message "Error: Node.js or npm version does not match expected versions."
    log_message "Node.js version: ${node_version}, Expected: v20.15.1"
    log_message "npm version: ${npm_version}, Expected: 10.7.0"
fi

# Install project dependencies
log_message "Installing project dependencies..."
npm install --save-dev framer-motion three react-intersection-observer @react-three/drei @react-three/fiber 2>&1 | tee -a "${log_file}"

log_message "Dependency installation complete. Checking installed packages..."
dependencies=("framer-motion" "three" "react-intersection-observer" "@react-three/drei" "@react-three/fiber")

for dep in "${dependencies[@]}"; do
    if npm list "$dep" > /dev/null 2>&1; then
        log_message "${dep} installation success."
    else
        log_message "${dep} installation failed."
    fi
done

log_message "Setup complete!"

# Prompt to keep the log
read -p "Installation complete. Do you want to save the installation log? (y/n) " user_choice
if [[ "$user_choice" == [Yy] ]]; then
    log_message "Log saved in ${log_file}."
else
    rm -f "${log_file}"
    rmdir "${log_directory}"
    log_message "Log discarded."
fi
