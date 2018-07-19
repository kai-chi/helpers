The reason why people use StackOverflow all the time is because they're to lazy to remember things. This is my cheat sheet to avoid constant googling and start remembering things (or Ctrl+F instead).
- Add to last commit / fix last commit
```
git add some_file
git commit --amend // git commit --amend --no-edit
git push -f origin some_branch
```

- Add changes to second to last commit
```
git stash
git rebase -i HEAD~2
// now mark the commit to change by changing pick->edit
git stash pop
git add
git commit --amend
git rebase --continue
// repeat rebasing from step 2 if more commits were marked to edit
git push -f origin some_branch
```

- Base a branch on yet-to-be-merged branch
```
git checkout some_branch
git rebase to_be_merged_branch
```

- Add/Remove file from commit
```
git add <file>
git remove <file>
```

- Squash someone's branch into one commit
```
git checkout some_branch
git reset --soft HEAD~$(git rev-list --count HEAD ^master)
git add -A
git commit -m "squashed commit" --author "The Guy <guy@gmail.com>"
git push --force
```
