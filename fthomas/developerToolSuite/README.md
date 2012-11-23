======================================================================
APACHE FLEX SDK DEVELOPER TOOL SUITE - DEVELOPER INSTRUCTIONS
======================================================================

Thanks for checking out Apache Flex SDK Developer Tool Suite from Git. 
These instructions detail how to get started with your freshly 
checked-out source tree.

These instructions are aimed at experienced developers looking to
participate in the development of Apache Flex SDK Developer Tool Suite.

If you are new to this project or would like to know more, read the
"GETTING START" note bellow.

======================================================================
ONE-TIME SETUP INSTRUCTIONS
======================================================================

1- Run the Apache Flex Installer 1.0 to install the ApacheFlex SDK 4.8.0.1359417

  http://incubator.apache.org/flex/installer.html

2- Create your own mavenized ApacheFlex SDK 4.8.0.1359417 and copy it in your Maven repository

  http://incubator.apache.org/flex/utilities.html#mavenizer

3- Build and install in your Maven repository FlexMojos 6.0-SNAPSHOT

  https://github.com/chrisdutz/flexmojos

4- Checkout and build the ApacheFlex SDK 4.9.0 Develop Branch

  svn co https://svn.apache.org/repos/asf/incubator/flex/sdk/branches/develop/ flex

5- Clone this project
We'll assume you typed the following to checkout Apache Flex SDK 
Developer Tool Suite.
(if not, adjust the paths in the following instructions accordingly):

  cd ~
  git clone git@github.com:doublefx/AFSDTS.git

6- Import AFSDTS as Maven project in IntelliJ IDEA

Next double-check you meet the installation requirements:

 * A proper installation of IntelliJ IDEA 11.x or above.
 * A proper installation of Apache Flex SDK 4.8.0.1359417.

======================================================================
GIT POLICIES
======================================================================

When checking into Git, you must provide a commit message.
You should not commit any IDE file.

Try to avoid "git pull", as it creates lots of commit messages like
"Merge branch 'master'. You can avoid
this with "git pull --rebase". See the "Git Tips" below for advice.

======================================================================
GIT TIPS
======================================================================

Setup Git correctly before you do anything else:

  git config --global user.name "My Name"
  git config --global user.email myname@myemaildomain.com

Perform the initial checkout with this:

  git clone git@github.com:doublefx/AFSDTS.git

Let's take the simple case where you just want to make a minor change
against master. You don't want a new branch etc, and you only want a
single commit to eventually show up in "git log". The easiest way is
to start your editing session with this:

  git pull

That will give you the latest code. Go and edit files. Determine the
changes with:

  git status

You can use "git add -A" if you just want to add everything you see.

Next you need to make a commit. Do this via:

  git commit -e

The -e will cause an editor to load, allowing you to edit the message.
Every commit message should reflect the "Git Policies" above.

Now if nobody else has made any changes since your original "git
pull", you can simply type this:

  git push origin

If the result is '[ok]', you're done. If the result is '[rejected]',
someone else beat you to it. The simplest way to workaround this is:

  git pull --rebase

The --rebase option will essentially do a 'git pull', but then it will
reapply your commits again as if they happened after the 'git pull'.
This avoids verbose logs like "Merge branch 'master'".

If you're doing something non-trivial, it's best to create a branch.
Learn more about this at http://sysmonblog.co.uk/misc/git_by_example/.

======================================================================
GETTING START
======================================================================

This project is intended to be used by developpers who like to participate
to the effort I started, creating Apache Flex SDK Developer Tool Suite.

If you have any questions, thoughts, suggestions, please use the community support 
mailing list at flex-dev@incubator.apache.org or my email address webdoublefx@gmail.com
with [DEVELOPER TOOL SUITE] in the subject.

Thanks for your interest in Apache Flex SDK Developer Tool Suite !
