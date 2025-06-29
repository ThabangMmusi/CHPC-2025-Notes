## Terminal Multiplexers and Basic System Monitoring

1. Install `tmux` on your head node:

   * APT
   ```bash
   sudo apt install tmux
   ```


1. To start a new `tmux` session on your head node:

   ```bash
   tmux

   # To open a new session and give it a <name>
   # tmux new -s <name>
   ```

1. Working on your head node and compute node in two adjacent panes

   Once you've started a new `tmux` session (daemon / server), on your head node, there are a number of very useful tools and functionality you can utilize.

1. Tmux commands are used to manage sessions, windows, and panes within a terminal multiplexer.
   Window Management:
   * Creates a new window. Press `Ctrl+b` then `c` **OR**
      ``` bash 
      tmux new-window
      ```
   * Switches between window. Press `Ctrl+b` then `n` for next **OR** `Ctrl+b` then `p` for previous.
   * Kills the current window. Press `Ctrl+b` then `&` **OR**
      ``` bash 
      tmux kill-window
      ```
   Pane Management:
   *  Splits the current pane vertically. Press `Ctrl+b` then `"` **OR**
      ``` bash 
      tmux split-window
      ```
   *  Splits the current pane horizontally. Press `Ctrl+b` then `%` **OR**
      ``` bash 
      tmux split-window -h
      ```
   * Navigates between panes. Press `Ctrl+b` then `<arrow key>`.
   * Kills the current pane. Press `Ctrl+b` then `x` **OR**
      ``` bash 
      tmux kill-pane
      ```
   
1. Install [`btop`](https://github.com/aristocratos/btop) on your **head node**. Depending on the Linux distribution you chose to install:

   * APT
   ```bashs
   sudo apt install btop
   ```


1. SSH into your **compute node** and install [`htop`](https://htop.dev/):
   ```bash
   ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no <user>@<compute node ip>
   ```

   Once you are successfully logged into your compute node:

   * APT
   ```bash
   sudo apt install htop
   ```

Your team must decide which tool you will be using for basic monitoring of your cluster. Choose between `top`, `htop` and `btop` and make sure your choice of application is installed across your cluster.

> [!IMPORTANT]
> Using `tmux` is an excellent way to ensure your work continues even if your SSH connection breaks between your workstation and the login node. To connect to an existing `tmux` session on your head node:
> ```bash
> tmux attach
>
> # If you have multiple, named sessions, use
> # tmux a -t session_name
> ```