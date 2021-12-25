# yplatform/sh

## Usage

In any bash shell script:

```bash
#!/usr/bin/env bash
set -euo pipefail # optional

. path/to/sh/common.inc.sh

<your code>
```


## Benefits

### strict bash

`set -euo pipefail` is enabled by default, that is:

* `-e` exit on non-zero exit status
* `-u` exit on undefined variables
* 

### on error
