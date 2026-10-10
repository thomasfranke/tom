# Setup

Install it, then open a folder.

Stuck already? Jump to [[#Troubleshooting|the fixes further down]].

## Requirements

A machine running macOS, Windows or Linux, with git on the path. Nothing else is asked for: the app drives the git you already have.

The folder you open has to sit inside a repository. A folder outside one still opens, without the git column.

## Installing

Download the build for your platform and move it where your applications live. The first launch shows Home and nothing else.

On macOS the first launch asks whether to open an app from the internet. Answer once and it never asks again.

## Opening a folder

Choose folder on Home, then pick the folder that holds the documents. The tree lists every markdown file under it.

The folder is remembered, and the next launch offers it again among the recent spaces.

## Writing

Pick a document in the tree. The preview shows it rendered, and the source mode shows the text you type.

Saving writes the file where it was. Nothing is kept anywhere else, and closing the window loses only what was never saved.

## Committing

The git column lists what changed. Tick what goes into the commit, write a summary, and commit to the branch that is checked out.

A push sends the commits to the remote. A pull brings the remote's back, and a conflict is shown in the document where it happened.

## Updating

A new version replaces the old one in place. The recent spaces and the preferences stay where they were.

## Troubleshooting

If the folder does not open, check that git is installed and that the folder is still there.

If the git column says nothing about the remote, the repository may have none. Add one with git and reload the column.

If a push is refused, pull first: the remote has commits this branch does not, and git will not throw them away.

If the preview stays empty, the document may not be markdown. Only files ending in `.md` are listed in the tree.

If a link is drawn in red, the document it names does not exist yet. Point at it and the tip offers to create it.

If a link carries a small number, two documents share its name. Press it and choose the one you meant.

## Getting help

Every screen of the app is described in the handbook this document belongs to. Start at the index and follow the links.

When something still does not work, write down what you pressed and what the app said, and open an issue with both.

A screenshot helps, and so does the version of git the machine runs.

Nothing leaves your machine unless you send it yourself.
