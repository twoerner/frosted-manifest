FROSTED repo manifest
=====================

Here are the setup scripts, patches, and manifest for building
[frosted](https://hackerspace.be/FrostedOS).

To get started you'll need the 'repo' tool:
```
$ mkdir ~/bin
$ PATH=~/bin:$PATH
$ curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
$ chmod a+x ~/bin/repo
```

Running 'repo init' will pull down the latest version of 'repo'. You'll need
to use the '-u' option to tell 'repo' where to find the particular manifest
for this project:

```
$ mkdir -p somewhere/to/work
$ cd somewhere/to/work
$ repo init -u http://github.com/twoerner/frosted-manifest.git -b stable
```

If you are prompted, configure 'repo' with your real name and email address.

A successful initialization will end with a message stating that 'repo' is
initialized in your working directory. Note that, at this point, your working
directory will only contain one hidden directory '.repo'. In order to pull the
sources (as specified in the manifest) to your working directory:
```
$ repo sync
```

The 'repo' command has a '-b' option that lets you switch between different
manifest branches (which then determines which branches of the corresponding
repositories are pulled). In the above command you're being directed to use
the 'stable' branch. If, after trying the 'stable' branch, you'd like to try
the 'master' branch, for example, simply run the initialization again
specifying the 'master' branch, then 'sync' again. If a branch is not
specified, 'master' is assumed:
```
$ repo init -u http://github.com/twoerner/frosted-manifest.git -b master
$ repo sync
```

While performing the 'repo sync' you can safely ignore any messages that look
something like:
> curl: (22) The requested URL returned error: 404 Not Found  
> Server does not provide clone.bundle; ignoring.

'repo' tries to find "clone bundles" on the server (which reduce download
time). If it doesn't find any, it reports this to the user, but it's not
fatal; clone bundles are not required for downloading, it will simply fall
back to using a plain 'git clone'.

If new updates of the various sub-repositories are available and you would
like to update to the latest, simply:
```
$ repo sync -dl
$ repo sync
```

If downloading from behind a proxy (which is common in some corporate
environments) it might be necessary to explicitly specify the proxy which is
then used by repo:
```
$ export HTTP_PROXY=http://<proxy_user_id>:<proxy_password>@<proxy_server>:<proxy_port>
$ export HTTPS_PROXY=http://<proxy_user_id>:<proxy_password>@<proxy_server>:<proxy_port>
```

More rarely, Linux clients experience connectivity issues, getting stuck in
the middle of downloads (typically during "Receiving objects"). It has been
reported that tweaking the settings of the TCP/IP stack and using non-parallel
commands can improve the situation. You need root access to modify the TCP
setting:
```
$ sudo sysctl -w net.ipv4.tcp_window_scaling=0
$ repo sync -j1
```

For more information regarding 'repo' please have a look at:
- https://source.android.com/source/developing.html
- https://source.android.com/source/using-repo.html

Toolchain
---------
When starting to work with frosted you'll need a toolchain. You only need to
build a toolchain once (unless you want or need to build a more updated one).
After your toolchain is built you'll only need to _source_ its environment
file in order to use it again in future shells.

To build the toolchain:
```
$ ./buildtoolchain.sh
```

When done an 'env.frosted' file will be created, simple source it:
```
$ . env.frosted
```

Configuring And Building Frosted
--------------------------------
Now that you have a toolchain on your $PATH you are ready to configure, build,
and flash frosted:
```
$ cd frosted
$ make menuconfig
```
At a minimum you'll need to verify you have the correct settings for your
hardware in the 'Platform' section.

Then:
```
$ cd frosted-userland
$ make menuconfig
```

To build both the kernel and userland go up one directory and start the build:
```
$ cd ..
$ make
```

NOTE: using the '-j' option to 'make' to perform a parallel build is likely to
not end in success.

The 'stlink' utilities from https://github.com/texane/stlink were built as part
of your toolchain build. If you are using a target that uses ST-LINK (i.e. the ST Discovery
boards) you can use the 'st-flash' utility to flash the resulting 'image.bin'
to your board:
```
# st-flash write image.bin 0x0800000
```
