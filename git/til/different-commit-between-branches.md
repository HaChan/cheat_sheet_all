##Show different commits and changes between two branches

If there are two branches, example: `master` and `develop`. To view different commits between both branches, use:

```
  git checkout master
  git cherry develop

  #or

  git checkout develop
  git cherry master
```

To show differences between two branches, use:

    git diff master..develop
