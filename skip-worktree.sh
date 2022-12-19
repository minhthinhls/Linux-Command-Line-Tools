#!/bin/bash

####################################################################################
########## REFERENCE: https://compiledsuccessfully.dev/git-skip-worktree/ ##########
####################################################################################

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @type: Array<String::"H ${path}">
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# paths=$(git ls-files -v | grep --perl-regexp "service(.*)account(.*)json");

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @type: Array<String::"${path}">
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# paths=$(git ls-files | grep --perl-regexp "service(.*)account(.*)json");

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @type: Array<String::"${path}">
# @pipe: <xargs> - Join multiple lines into Single Line with Space ${" "} Delimiter.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# shellcheck disable=SC2155
# ----------------------------------------------------------------------------------------------------------------------------------------------------
export PATHS=$(git ls-files --exclude-per-directory -v | grep --perl-regexp "service(.*)account(.*)json" | xargs);

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @no-skip: git update-index --no-skip-worktree $PATHS;
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# shellcheck disable=SC2086
# ----------------------------------------------------------------------------------------------------------------------------------------------------
git update-index --skip-worktree $PATHS;
