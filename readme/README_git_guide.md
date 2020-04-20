# Git Guide

---

<!-- TOC -->

- [Git Guide](#git-guide)
  - [Introduction](#introduction)
  - [Git usage](#git-usage)
  - [Clone a repository](#clone-a-repository)
  - [Basic flow](#basic-flow)
    - [Add newly added or modified file](#add-newly-added-or-modified-file)
    - [Commit your changes](#commit-your-changes)
    - [Get update from upstream](#get-update-from-upstream)
    - [Check history](#check-history)
    - [Push to your fork](#push-to-your-fork)
    - [Make a pull request](#make-a-pull-request)
    - [Make change related to the review of your pull request](#make-change-related-to-the-review-of-your-pull-request)
  - [Basic handling of submodules](#basic-handling-of-submodules)
    - [Init/Update submodules](#initupdate-submodules)
    - [Upgrade submodules](#upgrade-submodules)
  - [To remember](#to-remember)
  - [More advanced](#more-advanced)
    - [Branches](#branches)
    - [Enforce executable filemode](#enforce-executable-filemode)
    - [Commits](#commits)
    - [Update the repository](#update-the-repository)
    - [Branches history](#branches-history)
    - [Diff](#diff)
    - [List files](#list-files)
    - [Using UI](#using-ui)
  - [More advanced to remember](#more-advanced-to-remember)

<!-- /TOC -->

---

## Introduction

Git is a powerfull tool that can handle different kind of work flows, up to you to find what best suits you.\
Here I will focus on how to work with [GitHub flow](https://guides.github.com/introduction/flow/).\
Let's picture the different respositories and branches:

- **upstream**: the main repository
  - **master**: main stable branch
  - **develop**: branch for ongoing development
- **origin**: your fork of the main repostory
  - **develop**: your development branch
  - **feature_xxx**: some optional feature branches if needed
- **local**: your local repository on your machine
  - **develop**: your development branch
  - **feature_xxx**: some optional feature branches if needed

You can find all the information you need in the [online documention](https://git-scm.com/doc): [git command description](https://git-scm.com/docs/git), [Reference Manual](https://git-scm.com/docs), [Pro Git Book](https://git-scm.com/book), [Tutorial and more](https://git-scm.com/doc/ext).

## Git usage

Here you will find how to use the git with aliases prodived by this "common env". The full git command and sometimes a similar alias would be put in comment before.\
As a reminder, when you use the git alias, it will print the full git command used so you can still learn the real git command after time.\
In a terminal you can most of the time start to type git and the beginning of an alias (eg. git add-) and press Tab to see the list of possible aliases.

## Clone a repository

To work on a git repository, keep those 3 points in mind:

1. Clone the repository **AND** its submdoules.
2. Adding the reference to the main repository helps to stay up to date.
3. Checkout the right branch.

You can just follow those steps:

- Go the main repository (upstream) on your browser
- Fork the repository (origin) still on your browser
- Clone your fork in local on your machine (--recursive option ensure to clone submodules if any)

  ```bash
  # git clone --recursive <fork url> <name>
  git clones <fork url> <name>
  cd <name>
  ```

- Add the reference to upstream

  ```bash
  # git remote add upstream <main repo url>
  git upstream <main repo url>
  ```

- Check local and remote branches (from origin and upstream)

  ```bash
  # git branch -vva
  # git bra
  git branch-all
  ```

- Checkout and track the right branch (eg. default branch cloned is "master" but you need to work on "develop" branch). Notice that the branch name is prefix by 'origin/' because you it comes from your fork (origin).

  ```bash
  # git branch --track origin/develop
  # git brc origin/develop
  git branch-checkout origin/develop
  ```

## Basic flow

You can have a look at this official [documentation](https://git-scm.com/book/en/v2/Git-Basics-Recording-Changes-to-the-Repository)

### Add newly added or modified file

- Check status and diff to see your changes

  ```bash
  # git st
  git status
  # git df
  git diff
  ```

- Add newly added or modified files by path

  ```bash
  # git a
  git add <file> [<file>]
  ```

- Add all new files (untracked)

  ```bash
  # git add --all --verbose
  # git aa
  git add-all
  ```

- Add all modified files

  ```bash
  # git add --update --verbose
  # git au
  git add-update
  ```

- Check again status and staged diff to see your changed before commit

  ```bash
  git status
  # git diff --cached
  # git dc
  git diff-staged
  ```

### Commit your changes

- Simple commit

  ```bash
  # git ci 'commit message'
  git commit -m 'commit message'
  ```

- Amend commit: if you had to do a minor change that can be integrated in your previous commit, prefer to amend to it instead of creating a new commit. The previous commit should be yours and not already pushed in the main repository (upstream).

  ```bash
  # git ca
  git commit-amend
  ```

### Get update from upstream

Please do not pull to stay up to date, it creates useless merge commit and tend to bring an history really hard to read.\
 Please prefer to fetch the upstream and rebase.

- Fetch upstream, then rebase, and ensure to update submodules if any

  - Fetch and rebase

    ```bash
    # git fetch upstream --prune && git fetch --force --tags upstream
    # git fu
    git fetch-upstream
    # git rebase upstream/develop
    # git rbu
    git rebase-upstream
    ```

  - Update submodules

    ```bash
    # git submodule update --init --recursive
    # git subm
    git submodule-update
    ```

- Fetch, rebase and update submodules in one command

  ```bash
  # git fru
  git fetch-rebase-upstream
  ```

### Check history

Before to push your work, it is always good to see what are your difference with the main repository

- Check full history

  ```bash
  # git log -a --oneline --graph
  # git lga
  git log-all
  ```

- Check only the history difference between your local and the main repository

  ```bash
  # git lglru
  git log-local-upstream
  ```

### Push to your fork

- Simple push

  ```bash
  # git p
  git push
  ```

- Forced push: when you do a rebase or amend changes on your last commit, your git tree diverge from your fork, so you need to force the push to realign your fork

  ```bash
  # git pf
  git push -f
  ```

### Make a pull request

Go on your fork and do a pull request to the main repository.

### Make change related to the review of your pull request

If you have some changes to do based on a code review, most of the time you do not need to create a new commit, you can just amend it to the previous one and force push. Here is a command that adds the updated files, amend it to the previous commit and push force:

```bash
# git acf
git add-commit-push
```

## Basic handling of submodules

Please have a look at the [documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules).

### Init/Update submodules

- Ensure to have git submodules initialized and up to date

  ```bash
  # git submodule update --init --recursive
  # git subm
  git submodule-update
  ```

- Update git submodules and discard any changes in them if any

  ```bash
  # git submodule update --init --recursive && git cmd submodule foreach git cmd reset --hard HEAD
  # git submr
  git submodule-reset
  ```

### Upgrade submodules

It will retrieve the latest version of all the submodules.

```bash
# git cmd submodule update --remote && git cmd submodule foreach git submodule update --init --recursive
# git submu
git submodule-upgrade
```

It is possible to apply in only for a specific module by passing its path:

```bash
git submodule-update <path_to_submodule>
git submodule-reset <path_to_submodule>
git submodule-upgrade <path_to_submodule>
```

## To remember

Here are the few commands to remember and that you should do often.

- Long command/aliases

  ```bash
  git status # repository status
  git fetch-rebase-upstream # update from main repository (upstream)
  git submodule-update # ensure to have submodules up to date with the repository
  git submodule-upgrade # upgrade submodules (only in case you need new feature from submodules)
  git commit-amend # amend current change to your previous commit instead of creating a new commit
  git push -f # force push on your fork, might be needed after rebase or commit amend
  git log-all # display full history
  git log-local-upstream # display only history diff between your local and the upstream
  ```

- Short aliases

  ```bash
  git st # repository status
  git fru # update from main repository (upstream)
  git subm # ensure to have submodules up to date with the repository
  git submu # upgrade submodules (only in case you need new feature from submodules)
  git ca # amend current change to your previous commit instead of creating a new commit
  git pf # force push on your fork, might be needed after rebase or commit amend
  git lga # display full history
  git lglru # display only history diff between your local and the upstream
  ```

## More advanced

You can check this [official reference guide](https://git-scm.com/docs).

### Branches

- Track more remote branches

  ```bash
  # git brc origin/feature_001
  git branch-checkout origin/feature_001
  # git brc origin/feature_001
  git branch-checkout origin/feature_002
  # etc.
  ```

- Switch from one branch to another

  Once you have checked and tracked branches from origin, now you can switch from one to another:

  ```bash
  # git co master
  git checkout master
  # git co develop
  git checkout develop
  # git co feature_001
  git checkout feature_001
  # etc.
  ```

  You can also checout the default branch from origin or upstream:

  ```bash
  # git codb
  git checkout-default-branch
  # git codbu
  git checkout-default-branch-upstream
  ```

- Create your branch to develop your feature (feature_010)

  ```bash
  # git brn feature_010
  git branch-new feature_010
  ```

### Enforce executable filemode

If you work on Windows or a filesystem that does not support filemode but you still want to add this state in the repository.

```bash
# Add executable filemode to the given filename
# git add --chmod=+x <filename>
# git ax <filename>
git add-chmodx <filename>

# Add executable filemode to all files in the repository matching the given regrexp
# If no regexp provided it uses '\\.(sh|py|awk)$' to do it for all shell, python and awk files
# git ls-files | grep -E "<regexp>" | xargs git add --chmod=+x
git chmodx [<regexp>]
```

### Commits

- Remove one or several commits made by accident without losing their changes

  ```bash
  # Reset the last commit
  # git reset --soft HEAD~1
  # git rs 1
  git reset-commit-last 1

  # Reset the last 2 commits
  # git reset --soft HEAD~2
  # git rs 2
  git reset-commit-last 2

  # etc. reset last n commits
  ```

- Completely remove one or several commits (you will lose their changes)

  ```bash
  # Remove the last commit
  # git reset --hard HEAD~1
  # git rsh 1
  git remove-commit-last 1

  # Remove the last 2 commits
  # git reset --hard HEAD~2
  # git rsh 2
  git remove-commit-last 2

  # etc. remove last n commits
  ```

- Completely remove one specific commit (you will lose its changes)

  ```bash
  # Example with a commit fc4a6fe
  # git rebase --onto fc4a6fe^ fc4a6fe
  # git rmc fc4a6fe
  git remove-commit fc4a6fe
  ```

### Update the repository

- Only fetch data

  ```bash
  # git fetch --prune upstream && git fetch --force --tags upstream
  # git fu
  git fetch-upstream
  ```

- Update your files

  1. You work on upstream default branch (lets say develop), just rebase on it

     ```bash
     # git rebase upstream/develop develop
     # git rbu
     git rebase-upstream
     ```

  1. You work on your own feature branch, rebase on upstream default branch (develop)

     ```bash
     # git rebase upstream/develop feature
     # git rbdu
     git rebase-upstream-default
     ```

- You can also fecth and rebase with one command (it will also update the submodules if no conflicts)

  ```bash
  # Fetch and rebase on the same upstream branch
  # git fru
  git fetch-rebase-upstream

  # Fetch and rebase on the the default upstream branch
  # git frdu
  git fetch-rebase-upstream-default
  ```

- Conflicts during the rebase

  1. Check files with conflict

     ```bash
     # git st
     git status
     ```

  1. Edit the files and fix the conflict or use those commands (check the rebase part of [this guide](https://nitaym.github.io/ourstheirs/))

     ```bash
     # select the changes from upstream (you can specify a filename)
     # git checkout --ours [<filename>]
     # git rbcor [<filename>]
     git rebase-checkout-remote [<filename>]

     # select the your local changes (you can specify a filename)
     # git checkout --theirs [<filename>]
     # git rbcol [<filename>]
     git rebase-checkout-local [<filename>]
     ```

  1. Add the files when all conflicts resolved and continue the rebase

     ```bash
     # git add --update
     # git au
     git add-upate

     # git rebase --continue
     # git rbc
     git rebase-continue
     ```

  1. In case nothing goes as expected, you can abort the rebase

     ```bash
     # git rebase --abort
     # git rba
     git rebase-abort
     ```

- Update submodules if needed

  - Just update

    ```bash
    # git subm
    git submodule-update
    ```

  - Update and remove any local changes on the submodules if any

    ```bash
    # git subr
    git submodule-reset
    ```

### Branches history

1. In the terminal

   You can add '-x' (x being a number) to any of the following commands to display only x commits

   ```bash
   # log the current branch (last 20 commits)
   # git lg -20
   git log-current -20

   # log all branches (last 50 commits)
   # git lga -50
   git log-all -50

   # log the commits difference bewteen local and upstream
   # git lglru
   git log-local-upstream

   # log the commits difference bewteen local and upstream default branch
   # git lgdlru
   git log-local-default-upstream
   ```

1. In the UI

   You can run the UI to better visualize the state of your repository

   ```bash
   # visualize the repostory
   git-gui
   # visualize the branches history
   gitk
   ```

   You can also visualize only the commits difference between local and upstream

   ```bash
   # local commits not in upstream
   # git lguilu
   git log-ui-local-upstream
   # commits in upstream not in local
   # git lguiru
   git log-ui-upstream-local
   # local commits not in upstream default branch
   # git lguidlu
   git log-ui-local-default-upstream
   # commits in upstream default branch not in local
   # git lguidru
   git log-ui-default-upstream-local
   ```

### Diff

You can visualize statistic diff (only the files list), or full diff between your local and the upstream.

1. Statistic diff

   ```bash
   # diff between local and upstream
   # git dfslu
   git diff-stat-upstream
   # diff between local and upstream default branch
   # git dfsdlu
   git diff-stat-upstream-default
   ```

1. Diff

   ```bash
   # diff between local and upstream
   # git dflu
   git diff-upstream
   # diff between local and upstream default branch
   # git dfdlu
   git diff-upstream-default
   ```

### List files

```bash
# list files from . or the given path
# git ls-tree HEAD --abbrev [<path>]
git ls [<path>]

# recursively list files from . or the given path
# git ls-tree HEAD -rt [<path>]
# lsr [<path>]
git ls-all [<path>]

# list untracked files
# git ls-files --directory --no-empty-directory -o
# git lso
git ls-untracked

# List files in the repository that matche an ignore rule
# git ls-files --directory --no-empty-directory --exclude-standard -i
# git lsi
git ls-ignored
```

### Using UI

You can graphically view the state of your repository with those commands that open UI:

```bash
git-gui # open UI to graphically handle the repo
gitk # open UI to graphically visualize all branches history
```

## More advanced to remember

- Long aliases

  ```bash
  git branch-checkout origin/feature_001 # checkout and track another branch
  git checkout-default-branch # checkout default branch from origin
  git checkout-default-branch-upstream # checkout default branch from upstream
  git branch-new feature_010 # create new branch and push to origin
  git reset-commit-last 3 # softly reset the last 3 commits
  git remove-commit-last 3 # remove the last 3 commits (cannot be undone easily, check git reflog)
  git remove-commit fc4a6fe # remove commit fc4a6fe (cannot be undone easily, check git reflog)
  git fetch-rebase-upstream-default # update from default branch of main repository (upstream)
  git rebase-checkout-remote [<filename>] # during rebase conflict, choose remote changes
  git rebase-checkout-local [<filename>] # during rebase conflict, choose local changes
  git log-local-default-upstream # log commits difference between local and upstream default branch
  git log-ui-local-upstream # see in the UI the commits in local not in upstream
  git log-ui-upstream-local # see in the UI the commits in upstream not in local
  git log-ui-local-default-upstream # see in the UI the commits in local not in upstream default branch
  git log-ui-default-upstream-local # see in the UI the commits in upstream default branch not in local
  git diff-stat-upstream # see stat diff between local and upstream
  git diff-stat-upstream-default # see stat diff between local and upstream default branch
  git diff-upstream # see diff between local and upstream
  git diff-upstream-default # see diff between local and upstream default branch
  ```

- Short aliases

  ```bash
  git brc origin/feature_001 # checkout and track another branch
  git codb # checkout default branch from origin
  git codbu # checkout default branch from upstream
  git brn feature_010 # create new branch and push to origin
  git rs 3 # softly reset the last 3 commits
  git rsh 3 # remove the last 3 commits (cannot be undone easily, check git reflog)
  git rmc fc4a6fe # remove commit fc4a6fe (cannot be undone easily, check git reflog)
  git frdu # update from default branch main repository (upstream)
  git rbcor [<filename>] # during rebase conflict, choose remote changes
  git rbcol [<filename>] # during rebase conflict, choose local changes
  git lgdlru # log commits difference between local and upstream default branch
  git lguilu # see in the UI the commits in local not in upstream
  git lguiru # see in the UI the commits in upstream not in local
  git lguidlu # see in the UI the commits in upstream default branch not in local
  git lguidru # see in the UI the commits in upstream default branch not in local
  git dfslu # see stat diff between local and upstream
  git dfsdlu # see stat diff between local and upstream default branch
  git dflu # see diff between local and upstream
  git dfdlu # see diff between local and upstream default branch
  ```
