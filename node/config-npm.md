###Upgrade Node.js via NPM
 - sudo npm cache clean -f
 - sudo npm install -g n
 - sudo n stable
The n package represents a Node helper, and running the last command upgrades node to the latest stable version
 - sudo n 0.8.21
 
###Installing from npm fails
 - Execute npm config set registry http://registry.npmjs.org/
