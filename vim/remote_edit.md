#Remotely edit files via ssh

To remotely edit files in Vim, use `scp` like this:

    vim scp://user@sshserver[:port]//path/to/file.txt

The two slashes `//` between server and path is needed to correctly resolve the absolute path. `[:[port] is optional.

This is handled by vim's `netrw.vim` standard plugin. Several other protocol are supported.
