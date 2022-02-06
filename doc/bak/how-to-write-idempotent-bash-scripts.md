How to write idempotent Bash scripts
====================================

July 3, 2019

![Photo by Callum Wale on Unsplash](https://d33wubrfki0l68.cloudfront.net/68bfe0b7ffe6a88ba274c0a9b5b102c333433f78/83d58/images/how-to-write-idempotent-bash-scripts-1.jpeg)

Photo by Callum Wale on Unsplash

It happens a lot, you write a bash script and half way it exits due an error. You fix the error in your system and run the script again. But half of the steps in your scripts fail immediately because they were already applied to your system. To build resilient systems you need to write software that is idempotent.

What is idempotency?
--------------------

Idempotent scripts can be called multiple times and each time it's called, it will have the same effects on the system. This means, a second call will exit with the same result and won't have any side effects. From the [dictionary](https://www.google.com/search?q=idempotent):

> Idempotent: denoting an element of a set which is unchanged in value when multiplied or otherwise operated on by itself.

Good software is always written in an idempotent way, especially if you're working in distributed systems, where operations might be eventually consistency and you might end up calling functions multiple times because of duplicate requests (such as in [queues](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/standard-queues.html) with `At-Least-Once` delivery guarantee).

Bash idioms
-----------

Let me show a couple of bash tips and idioms you can use to change your scripts to be idempotent. You're probably using most of them without being aware of the side effects:

### Creating an empty file

This is an easy one. Touch is by default idempotent. This means you can call it multiple times without any issues. A second call won't have any effects on the file content. Note though it'll update the file's modification time, so if you depend on it be careful.

```
touch example.txt

```

### Creating a directory

Never use `mkdir` directly, instead use it with the`-p` flag. This flag make sure mkdir won't error if the directory exists:

```
mkdir -p mydir

```

### Creating a symbolic link

We create symbolic links with the following command:

```
ln -s source target

```

But this will fail if you call it again on the same target. To make it idempotent, pass the `-f`flag:

```
ln -sfn source target

```

The `-f` flag removes the target destination before creating the symbolic link, hence it'll always succeed.

When linking a directory, you need to pass `-n` too. Otherwise calling it again will create a symbolic link inside the directory.

```
mkdir a
ln -sfn a b
ln -sfn a b
ls a
a

```

So to be safe, always use `ln -sfnn source target`.

### Removing a file

Instead of removing a file with:

```
rm example.txt

```

Use the `-f` flag which ignores non-existent files.

```
rm -f example.txt

```

### Modifying a file

Sometimes you're adding a new line to an existing file (i.e: `/etc/fstab`). This means, you need to make sure not to add it the second time if you run your script. Suppose you have this in your script:

```
echo "/dev/sda1 /mnt/dev ext4 defaults 0 0" | sudo tee -a /etc/fstab

```

If this is run again, you'll end up having duplicate entries in your `/etc/fstab`. One way of making this idempotent is to make sure to check for certain placeholders via `grep`:

```
if ! grep -qF "/mnt/dev" /etc/fstab; then
  echo "/dev/sda1 /mnt/dev ext4 defaults 0 0" | sudo tee -a /etc/fstab
fi

```

Here the `-q` means silent mode and `-F` enables `fixed string` mode. Grep will silently fail if `/mnt/dev` doesn't exist so the echo statement will never be called.

### Check if variable, file or dir exists

Most of the time you're writing to a directory, reading from a file or doing simple string manipulations with a variable. For example you might have a tool that creates a new file based on certain inputs:

```
echo "complex set of rules" > /etc/conf/foo.txt

```

Calculating the text might be an expensive operation, hence you don't want to write it every time you call the script. To make it idempotent you check if the file exists via the `-f` flag of the inbuilt `test` property of the shell:

```
if [ ! -f "/etc/conf/foo.txt" ]; then
 echo "complex set of rules" > /etc/conf/foo.txt
fi

```

Here `-f` is just an example, there are many other flags you can use, such:

-   `-d`: directory
-   `-z`: string of zero length
-   `-p`: pipe
-   `-x`: file and has execute permission

For example suppose you want to install a binary, but only if it doesn't exist in your host, you can use the `-x` like this:

```
# install 1password CLI
if ! [ -x "$(command -v op)" ]; then
  export OP_VERSION="v0.5.6-003"
  curl -sS -o 1password.zip https://cache.agilebits.com/dist/1P/op/pkg/${OP_VERSION}/op_linux_amd64_${OP_VERSION}.zip
  unzip 1password.zip op -d /usr/local/bin
  rm -f 1password.zip
fi

```

This installs the `op` binary to /usr/local/bin. If you re-run your script, it won't install it anymore. Another benefit is, you can easily upgrade the binary to a new version by just removing it from your system, update the `OP_VERSION` env and re-run your script.

For a list of complete flags and operators checkout  `man test`.

### Formatting a device

To format a volume, say with an `ext4` format, you can use a command like the following:

```
mkfs.ext4 "$VOLUME_NAME"

```

Of course, this would fail immediately if you call it again. To make this call idempotent, we prepend it with `blkid`:

```
blkid "$VOLUME_NAME" || mkfs.ext4 "$VOLUME_NAME"

```

This command prints attributes for a given block device. Hence prepending basically means to proceed with formatting *only* when `blkid` fails, which is an indication that the given volume is not formatted yet.

### Mounting a device

Trying to mount a volume to an existing directory can be done with the following example command:

```
mount -o discard,defaults,noatime "$VOLUME_NAME" "$DATA_DIR"

```

This will fail however if it's already mounted. One way is to check the output of `mount`command and see if the volume is already mounted. But there is a better way to do it. Using the `mountpoint` command:

```
if ! mountpoint -q "$DATA_DIR"; then
  mount -o discard,defaults,noatime "$VOLUME_NAME" "$DATA_DIR"
fi

```

The `mountpoint` command checks whether a file or directory is a mount point. The `-q` flag just makes sure it doesn't output anything and silently exits. In this case, if the mount point doesn't exist, it'll go forward and mount the volume.

Verdict
-------

Most of these tips and tricks are already known, but when we write Bash scripts those can be easily neglected without even thinking about it. Some of these idioms are very specific (such as mounting or formatting), but as we saw, creating idempotent and resilient software is always beneficial in the long term. So knowing them is useful nevertheless.

I used all of the above tips and tricks recently in my [`bootstrap.sh`](https://github.com/fatih/dotfiles/blob/master/workstation/bootstrap.sh) script that I use to create and provision my [remote development machine](https://arslan.io/2019/01/07/using-the-ipad-pro-as-my-development-machine/). I know that I could use more sophisticated tools to provision a VM from scratch, but sometimes a simple bash script is the only thing you need.
