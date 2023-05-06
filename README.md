# Project change directory – pcd

Bash shell script code for jumping between project directories, including auto
completion.

## Installation

1. Copy [`pcd.sh`](pcd.sh) to your home directory:

        curl https://raw.githubusercontent.com/oyvindstegard/pcd/main/pcd.sh \
             -o ~/.pcd.sh
             
2. Add code to shell init file `~/.bashrc`:

        PROJECTS_PATH=~/your-projects-root-directory
        source ~/.pcd.sh
    
3. Open a shell, type `pcd` and hit <kbd>TAB</kbd> three times – you should see
   your project directories being auto completed.

## Usage

After loading the code, type `pcd` and hit <kbd>TAB</kbd> a couple of times to
see completion of all project directories. Hit <kbd>ENTER</kbd> to jump to
project. It will also complete into a project sub-directory as optional second
argument.

To jump up to a project root directory you can use `pcd ..` – this works if it
is a git repository. You can combine it with a second arg to drill into another
directory tree of the same project:

    ~/dev/myrepo/target/build/foo/bar$ pcd .. src
    ~/dev/myrepo/src$ 

Lastly, you can use the option `-p` to use `pushd` instead `cd` when changing
directory.

### Screencast

<p><img src=".screencast.gif?raw=true" alt="Screencast"/></p>

## Future ideas

- Consider supporting a colon-delimited PROJECTS_PATH-variable with multiple
  roots.
