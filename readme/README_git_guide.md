# Git Guide

## Introduction

Git is a powerfull tool that can handle different kind work flows, up to you to find what best suits you.\
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

You can find all the information you need in the [online documention](https://git-scm.com/doc): [Reference Manual](https://git-scm.com/docs), [Pro Git Book](https://git-scm.com/book), [Tutorial and more](https://git-scm.com/doc/ext).

## Git usage

Here you will find how to use the git with aliases. The full git command and sometimes a similar alias would be put in comment before.\
As a reminder, when you use the git alias, it will print the full git command used so you can still learn the real git command after time.\
In a terminal you can most of the time start to type git and the beginning of an alias (eg. git add\_) and press Tab to see the list of possible aliases.

## Clone the repository

Simply doing "git clone" to clone a repository is not enough if you want to ease your life. Dont not forget that the repo can have submodules. Also add the reference to the main repo to help staying up to date. Also ensure to be on the right branch.

- Go the main repository (upstream)
- Fork the repository (origin)
- Clone your fork in local

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

- Check your local branch

  ```bash
  # git branch -vv
  # git br
  git branch-local
  ```

- Check local and remote branches (also from origin and upstream)

  ```bash
  # git branch -vva
  # git bra
  git branch-all
  ```

- Checkout and track a branch (eg. the default branch you clone is master but you need to work on develop). Notice that the branch name is prefix by 'origin/' because you it comes from your fork (origin).

  ```bash
  # git branch --track origin/develop
  # git brc origin/develop
  git branch-checkout origin/develop
  ```

## Basic flow (Never pull but fetch and rebase)

- Add newly added or modified file (check this [documentation](https://git-scm.com/book/en/v2/Git-Basics-Recording-Changes-to-the-Repository))

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

- Commit your changes

  - Simple commit

    ```bash
    # git ci 'commit message'
    git commit -m 'commit message'
    ```

  - Amend commit: if you had to do a minor change that can be integrated in your previous commit, prefer to amend to it instead of creating a new commit

    ```bash
    # git ca
    git commit-amend
    ```

- Check to be up to date with upstream before pushing anything.

  Please do not pull to stay up to date, it creates useless merge commit and tend to bring an history really hard to read.\
  Please prefer to fetch the upstream and rebase.

  - Fetch upstream, then rebase

    ```bash
    # git fetch upstream --prune && git fetch --force --tags upstream
    # git fu
    git fetch-upstream
    # git rebase upstream/develop
    # git rbu
    git rebase-upstream
    ```

  - Fetch and rebase in one command

    ```bash
    # git fru
    git fetch-rebase-upstream
    ```

- Check history

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

- Push to your fork

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

- Make a pull request

  Go on your fork and do a pull request to the main repository.

- Make change related to the review of your pull request

  If you have some changes to do based on a code review, most of the time you do not need to create a new commit, you can just amend it to the previous one and force push. Here is a command that adds the updated files, amend it to the previous commit and push force:

  ```bash
  # git acf
  git add-commit-push
  ```

## To remember

Here are the few commands to remember and that you should do often.

- Long aliases

  ```bash
  git status # repository status
  git fetch-rebase-upstream # retrieve update from main repository
  git commit-amend # amend current change to your previous commit instead of creating a new commit
  git push -f # force push on your fork, might be needed after rebase or commit amend
  git log-all # display full history
  git log-local-upstream # display only history diff between your local and the upstream
  ```

- Short aliases

  ```bash
  git st # repository status
  git fru # retrieve update from main repository
  git ca # amend current change to your previous commit instead of creating a new commit
  git pf # force push on your fork, might be needed after rebase or commit amend
  git lga # display full history
  git lglru # display only history diff between your local and the upstream
  ```
