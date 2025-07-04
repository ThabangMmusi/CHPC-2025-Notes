# Getting Started with Scripting

This guide will walk you through the basic steps of creating and running scripts, from development to deployment on a remote server.

## Setting Up VS Code

1. Download and install Visual Studio Code from [https://code.visualstudio.com/](https://code.visualstudio.com/)
2. Install helpful extensions:
   - Remote - SSH (for remote development)
   - Python (if working with Python scripts)
   - Shell Script (for bash scripting)

## Creating Your First Script

1. Open VS Code
2. Create a new file with `.sh` extension (for bash) or `.py` (for Python)
3. Add your script content, for example:
   ```bash
   #!/bin/bash
   # A simple bash script
   echo "Instaling nfs on compute nodes"
   sudo apt install nfs-common
   ```

## Running Your Script`

1. **Copy your script to the remote server**:
    - Use `scp` command to copy your script to the remote server.
   - Example:
     ```bash
     #use '- P 2222' if you have changed the default ssh port.
     # e.g scp -r /c/ubuntuScript/scripts thabang@localhost:/home/thabang/
     # else

     scp -r -P 2222 /c/ubuntuScript/scripts thabang@localhost:/home/thabang/
     ```

## Best Practices for Scripting

- **Document Your Code**: Always include clear comments and documentation within your scripts.
- **Test Locally**: Before running on a remote server, test your script on your local machine to ensure it works as expected.
- **Use Version Control**: Keep your scripts under version control to track changes and collaborate with others.

## Running script

- Make the executable:
    - Use `chmod` command to make the script executable.
    - Example:
        ```bash
        chmod +x your_script.sh
        ```
- Run the script:
    - Execute the script as you would run any other command.
    - Example:
        ```bash
        ./your_script.sh
        ```
- use var file in another script file


 