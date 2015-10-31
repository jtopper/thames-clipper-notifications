# Thames Clipper Status Bar Notification

## Introduction

This is a small hack designed for use with https://github.com/matryer/bitbar/ which will display live departure information for the London [Thames Clipper service](http://www.thamesclippers.com/) in the Mac status bar.

It uses the 'lost' gem to gain access to the Mac's CoreLocation service, and uses that latitude and longitude to search for river service piers and fetch live departure data from TFL.

## Location Data

In order to reduce the number of calls to CoreLocation, your location will be cached for 30 minutes.

## Installation

First of all, fetch and install BitBar from its own GitHub page. When you first run it, it will ask you to choose a plugin directory. I created `~/bitbar_plugins` and will use that in the following example.

You'll also need a modern ruby interpreter installed, along with Bundler.  I've used Ruby 2.1.5 installed using rbenv.

Having created the new plugin directory, now check out this project into it and ensure we have all the dependencies installed:

```
cd ~/bitbar_plugins
git clone git@github.com:jtopper/thames-clipper-notifications.git
cd thames-clipper-notifications
bundle install
```

BitBar needs an executable script to be in place under its plugin directory - there's one in this project, so just symlink it into place:

```
cd ~/bitbar_plugins
ln -s clipper/clipper.1m.sh .
```

Now start or reset BitBar, and you should see a new icon on the menu bar. Click it for departure data.

