This is a git configuration file with support for local configuration.

One of the main advantages of using this .gitconfig file is for aliases, which provide shorthand git commands.


Use the following instructions for linking a user .gitconfig file with the .gitconfig tracked in this repository:
    Windows:
        1. Open cmd.exe as administrator
            a. Search for "cmd" in windows search
            b. Right-click "cmd.exe" > Run as administrator
        2. Run the following command:
           mklink "<user_path>\.gitconfig" "<repo_path>\.gitconfig"
    Linux:
        1. Run the following command:
           ln -s "<repo_path>/.gitconfig" ~/.gitconfig
