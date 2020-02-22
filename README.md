# docker-aria2
## Usage
**This `aria2c` does not support BitTorrent and Metalink features**
### Permission issues
* If you do not want the owner of the downloads files is root, make sure you specify the default user to be your desired user through `--user` option when you start a container
  ```
  docker run --user=UID:GID # other options ...
  ```

### Required Bind Mounts
#### `/config`
* **Make sure you mount a folder on the host machine to the `/config` folder in the container.**
* The default user of that running container should have the read, write, execute permissions on that folder being mounted
* The default user of that running container should have the read, write permissions on the files in that folder being mounted
* Your custom aria2c configuration file should be put in this folder and be named as `aria2.conf`
* Aria2c will write the session information into the file `aria2.sessions` which will be put in this folder

#### `/downloads`
* **Make sure you mount a folder on the host machine to the `/downloads` folder in the container.**
* This folder is used for storing downloaded files
* The default user of that running container should have the read, write, execute permissions on that folder being mounted

### Optional Bind Mounts
#### `/log`
* This bind mount is optional
* If you want aria2c output logs for you, **make sure you mount a folder on the host machine to the `/log` folder in the container**
* The default user of that running container should have the read, write, execute permissions on that folder being mounted

### Optional Environment Variables
#### `INPUT_FILE`
* The environment variable let you specify the location of custom input file which is used the `--input-file` option of aria2c
* The value of this environment variable is the relative path respect to `/config` folder
  * For example, if the value is `c/input_file.txt`, the value of `--log` option will be `/config/c/input_file.txt`
* **If this environment variable is not set, aria2c will use `config/aria2.sessions` as input file**

#### `LOG_FILE`
* The environment variable let you specify the location of log file which is value of aria2c `--log` option
* The value of the environment variable is the relative path respect to `/log` folder
  * For example, if the value is `aria2/aria2c.log`, the value of `--log` option will be `/log/aria2/aria2c.log`
* **You should mount a folder to `/log` if you set this environment variable**
* **If this environment variable is not set, aria2c will not user `--log` option when starting**
* **Since the default log level of aria2c is debug, consider set the environment variable [`LOG_LEVEL`](#LOG_LEVEL) to prevent aria2c from outputing too many non-useful logs**

#### `LOG_LEVEL`
* The environment variable let you specify the level of output log, it is the value of aria2c `--log-level` option
* The value of this environment variable is either `debug`, `info`, `notice`, `warn` or `error`
  * The recommended value is either `notice`, `warn` or `error`
* **This environment variable only takes effect when `LOG_FILE` is set and the bind mount for `/log` folder is properly set**

### Default configurations
* **If there is no `aria2.conf` in `/config` folder in the container, the startup script will copy the default configuration file to the `/config` folder and name it as `aria2.conf`**
* **Startup script will generate RPC configurations and put them into the default configuraion, it will print out the RPC secret for first time booting**
* After the default configurations is copied, you can change any options and it will be regarded as custom configurations file

### Custom configurations
* Name your custom configuration file as `aria2.conf` and put it into the folder which will be mounted to `/config` folder in the container

### Start the container
#### Basic
```sh=
docker run --user UID:GID \
--volume CONFIG_FOLDER:/config \
--volume DOWNLOADS_FOLDER:/downloads \
IMAGE_NAME
```
#### With log feature
```sh=
docker run --user UID:GID \
--volume CONFIG_FOLDER:/config \
--volume DOWNLOADS_FOLDER:/downloads \
--volume LOG_FOLDER:/log \
--env LOG_FILE=aria2c.log \
--env LOG_LEVEL=notice \
IMAGE_NAME
```

## Notes on RPC configurations
* **Consider using TLS connections to protect your RPC connections.**
* **Change the RPC secret regularly**
