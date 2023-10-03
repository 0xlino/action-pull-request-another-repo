#!/bin/sh

set -e
set -x

if [ -z "$INPUT_SOURCE_FOLDER" ]
then
  echo "Source folder must be defined"
  return -1
fi

if [ -z "$INPUT_DESTINATION_FILES" ]
then
  echo "Destination files must be defined"
  return -1
fi

if [ $INPUT_DESTINATION_HEAD_BRANCH == "main" ] || [ $INPUT_DESTINATION_HEAD_BRANCH == "master" ]
then
  echo "Destination head branch cannot be 'main' or 'master'"
  return -1
fi

if [ -z "$INPUT_PULL_REQUEST_REVIEWERS" ]
then
  PULL_REQUEST_REVIEWERS=$INPUT_PULL_REQUEST_REVIEWERS
else
  PULL_REQUEST_REVIEWERS='-r '$INPUT_PULL_REQUEST_REVIEWERS
fi

CLONE_DIR=$(mktemp -d)

echo "Setting git variables"
export GITHUB_TOKEN=$API_TOKEN_GITHUB
git config --global user.email "$INPUT_USER_EMAIL"
git config --global user.name "$INPUT_USER_NAME"

echo "Cloning destination git repository"
git clone "https://$API_TOKEN_GITHUB@github.com/$INPUT_DESTINATION_REPO.git" "$CLONE_DIR"

echo "Copying contents to git repo"
mkdir -p $CLONE_DIR/$INPUT_DESTINATION_FOLDER/
cp -R $INPUT_SOURCE_FOLDER/* "$CLONE_DIR/$INPUT_DESTINATION_FOLDER/"

cd "$CLONE_DIR"
git checkout -b "$INPUT_DESTINATION_HEAD_BRANCH"

echo "$INPUT_BODY"
echo "Adding git commit new"

# echo "$INPUT_DESTINATION_FILES"

# Split the string into an array using space as the delimiter
# IFS=' ' read -r -a pr_files_array <<< "$INPUT_DESTINATION_FILES"

# echo "$pr_files_array"

# # Now, pr_files_array is an array of files to be included
# for file in "${pr_files_array[@]}"
# do
#   # Check if the file is not in the list of ignored files
#   if [[ ! " ${INPUT_FILES_TO_IGNORE[@]} " =~ " $file " ]]; then
#     echo "$INPUT_DESTINATION_FOLDER/$file"
#     git add "$INPUT_DESTINATION_FOLDER/$file"
#   fi
# done

echo "INPUT_DESTINATION_FOLDER: $INPUT_DESTINATION_FOLDER"
echo "file: $file"

# Loop through the array of destination files
# for file in "${INPUT_DESTINATION_FILES[@]}"
# do
#   # Check if the file is not in the list of ignored files
#   if [[ ! " ${INPUT_FILES_TO_IGNORE[@]} " =~ " $file " ]]; then
#     echo "$INPUT_DESTINATION_FOLDER/$file"
#     git add "$INPUT_DESTINATION_FOLDER/$file"
#   fi
# done

# if git status | grep -q "Changes to be committed"
# then
#   git commit --message "Update from https://github.com/$GITHUB_REPOSITORY/commit/$GITHUB_SHA"
#   echo "Pushing git commit"
#   git push -u origin HEAD:$INPUT_DESTINATION_HEAD_BRANCH
#   echo "Creating a pull request"
#   gh pr create -t "[$INPUT_SYMBOL] [$(date '+%d-%m-%Y %H:%M:%S')] $INPUT_MESSAGE" \
#                -b "$INPUT_BODY"$'\n\n\n'"From: https://github.com/$GITHUB_REPOSITORY/commit/$GITHUB_SHA" \
#                -B $INPUT_DESTINATION_BASE_BRANCH \
#                -H $INPUT_DESTINATION_HEAD_BRANCH \
#                $PULL_REQUEST_REVIEWERS
# else
#   echo "No changes detected"
# fi
