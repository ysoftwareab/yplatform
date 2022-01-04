Defensive BASH Programming
==========================

NOV 14TH, 2012 | [COMMENTS](https://kfirlavi.herokuapp.com/blog/2012/11/14/defensive-bash-programming/#disqus_thread)

Here is my Katas for creating BASH programs that work. Nothing is new here, but from my experience pepole like to abuse BASH, forget computer science and create a [Big ball of mud](http://en.wikipedia.org/wiki/Big_ball_of_mud) from their programs.\
Here I provide methods to defend your programs from braking, and keep the code tidy and clean.

Immutable global variables 
---------------------------

-   Try to keep globals to minimum
-   UPPER_CASE naming
-   readonly decleration
-   Use globals to replace cryptic $0, $1, etc.
-   Globals I allways use in my programs:

|

1
2
3

 |

```
readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

```

 |

Everything is local
-------------------

All variable should be local.

|

1
2
3
4
5
6
7

 |

```
change_owner_of_file() {
    local filename=$1
    local user=$2
    local group=$3

    chown $user:$group $filename
}

```

 |

|

1
2
3
4
5
6
7
8
9
10
11

 |

```
change_owner_of_files() {
    local user=$1; shift
    local group=$1; shift
    local files=$@
    local i

    for i in $files
    do
        chown $user:$group $i
    done
}

```

 |

-   self documenting parameters
-   Usually for loop use i variable, so it is very important that you declare it as local.
-   local does not work on global scope.

|

1
2

 |

```
kfir@goofy ~ $ local a
bash: local: can only be used in a function

```

 |

main()
------

-   Help keep all variables local
-   Intuitive for functional programming
-   The only global command in the code is: main

|

1
2
3
4
5
6
7
8
9
10

 |

```
main() {
    local files="/tmp/a /tmp/b"
    local i

    for i in $files
    do
        change_owner_of_file kfir users $i
    done
}
main

```

 |

Everything is a function
------------------------

-   The only code that is running globaly is:
    -   Global declerations that are immutable.
    -   main
-   Keep code clean
-   procedures become descriptive

|

1
2
3

 |

```
main() {
    local files=$(ls /tmp | grep pid | grep -v daemon)
}

```

 |

|

1
2
3
4
5
6
7
8
9
10
11

 |

```
temporary_files() {
    local dir=$1

    ls $dir\
        | grep pid\
        | grep -v daemon
}

main() {
    local files=$(temporary_files /tmp)
}

```

 |

-   Second example is much better. Finding files is the problem of temporary_files() and not of main()'s. This code is also testable, by unit testing of temporary_files().
-   If you try to test the first example, you will mish mash finding temporary files with main algorithm.

|

1
2
3
4
5
6
7
8
9
10
11
12

 |

```
test_temporary_files() {
    local dir=/tmp

    touch $dir/a-pid1232.tmp
    touch $dir/a-pid1232-daemon.tmp

    returns "$dir/a-pid1232.tmp" temporary_files $dir

    touch $dir/b-pid1534.tmp

    returns "$dir/a-pid1232.tmp $dir/b-pid1534.tmp" temporary_files $dir
}

```

 |

As we see, this test does not concern main().

Debugging functions
-------------------

-   Run program with -x flag:

|

1

 |

```
bash -x my_prog.sh

```

 |

-   debug just a small section of code using set -x and set +x, which will print debug info just for the current code wrapped with set -x ... set +x.

|

1
2
3
4
5
6
7
8
9

 |

```
temporary_files() {
    local dir=$1

    set -x
    ls $dir\
        | grep pid\
        | grep -v daemon
    set +x
}

```

 |

-   Printing function name and its arguments:

|

1
2
3
4
5
6
7
8

 |

```
temporary_files() {
    echo $FUNCNAME $@
    local dir=$1

    ls $dir\
        | grep pid\
        | grep -v daemon
}

```

 |

So calling the function:

|

1

 |

```
temporary_files /tmp

```

 |

will print to the standard output:

|

1

 |

```
temporary_files /tmp

```

 |

Code clarity
------------

What this code do?

|

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16

 |

```
main() {
    local dir=/tmp

    [[ -z $dir ]]\
        && do_something...

    [[ -n $dir ]]\
        && do_something...

    [[ -f $dir ]]\
        && do_something...

    [[ -d $dir ]]\
        && do_something...
}
main

```

 |

Let your code speak:

|

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40

 |

```
is_empty() {
    local var=$1

    [[ -z $var ]]
}

is_not_empty() {
    local var=$1

    [[ -n $var ]]
}

is_file() {
    local file=$1

    [[ -f $file ]]
}

is_dir() {
    local dir=$1

    [[ -d $dir ]]
}

main() {
    local dir=/tmp

    is_empty $dir\
        && do_something...

    is_not_empty $dir\
        && do_something...

    is_file $dir\
        && do_something...

    is_dir $dir\
        && do_something...
}
main

```

 |

Each line does just one thing
-----------------------------

-   Break expression with back slash `\`\
    For example:

|

1
2
3
4
5

 |

```
temporary_files() {
    local dir=$1

    ls $dir | grep pid | grep -v daemon
}

```

 |

Can be written much cleaner:

|

1
2
3
4
5
6
7

 |

```
temporary_files() {
    local dir=$1

    ls $dir\
        | grep pid\
        | grep -v daemon
}

```

 |

-   Symbols at the start of the line indented\
    Bad example of symbols at the end:

|

1
2
3
4
5
6
7

 |

```
temporary_files() {
    local dir=$1

    ls $dir |\
        grep pid |\
        grep -v daemon
}

```

 |

Good example where we clearly see the connection between lines and the connecting rods:

|

1
2
3
4
5
6
7

 |

```
print_dir_if_not_empty() {
    local dir=$1

    is_empty $dir\
        && echo "dir is empty"\
        || echo "dir=$dir"
}

```

 |

Printing usage
--------------

Don't do this:

|

1
2
3

 |

```
echo "this prog does:..."
echo "flags:"
echo "-h print help"

```

 |

It should be a function:

|

1
2
3
4
5

 |

```
usage() {
    echo "this prog does:..."
    echo "flags:"
    echo "-h print help"
}

```

 |

echo is repeated in each line. For that we have Here Document:

|

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32

 |

```
usage() {
    cat <<- EOF
    usage: $PROGNAME options

    Program deletes files from filesystems to release space.
    It gets config file that define fileystem paths to work on, and whitelist rules to
    keep certain files.

    OPTIONS:
       -c --config              configuration file containing the rules. use --help-config to see the syntax.
       -n --pretend             do not really delete, just how what you are going to do.
       -t --test                run unit test to check the program
       -v --verbose             Verbose. You can specify more then one -v to have more verbose
       -x --debug               debug
       -h --help                show this help
          --help-config         configuration help

    Examples:
       Run all tests:
       $PROGNAME --test all

       Run specific test:
       $PROGNAME --test test_string.sh

       Run:
       $PROGNAME --config /path/to/config/$PROGNAME.conf

       Just show what you are going to do:
       $PROGNAME -vn -c /path/to/config/$PROGNAME.conf
    EOF
}

```

 |

Pay attention that there should be real tab '\t' in the start of the line for each line.\
In vim you can use this replace command if your tab is 4 spaces:

|

1

 |

```
:s/^    /\t/

```

 |

Command line arguments
----------------------

Here is an example to complement the usage function above. I got this code from [Kirk's blog post - bash shell script to use getopts with gnu style long positional parameters](http://kirk.webfinish.com/2009/10/bash-shell-script-to-use-getopts-with-gnu-style-long-positional-parameters/ "bash shell script to use getopts with gnu style long positional parameters"):

|

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58

 |

```
cmdline() {
    # got this idea from here:
    # http://kirk.webfinish.com/2009/10/bash-shell-script-to-use-getopts-with-gnu-style-long-positional-parameters/
    local arg=
    for arg
    do
        local delim=""
        case "$arg" in
            #translate --gnu-long-options to -g (short options)
            --config)         args="${args}-c ";;
            --pretend)        args="${args}-n ";;
            --test)           args="${args}-t ";;
            --help-config)    usage_config && exit 0;;
            --help)           args="${args}-h ";;
            --verbose)        args="${args}-v ";;
            --debug)          args="${args}-x ";;
            #pass through anything else
            *) [[ "${arg:0:1}" == "-" ]] || delim="\""
                args="${args}${delim}${arg}${delim} ";;
        esac
    done

    #Reset the positional parameters to the short options
    eval set -- $args

    while getopts "nvhxt:c:" OPTION
    do
         case $OPTION in
         v)
             readonly VERBOSE=1
             ;;
         h)
             usage
             exit 0
             ;;
         x)
             readonly DEBUG='-x'
             set -x
             ;;
         t)
             RUN_TESTS=$OPTARG
             verbose VINFO "Running tests"
             ;;
         c)
             readonly CONFIG_FILE=$OPTARG
             ;;
         n)
             readonly PRETEND=1
             ;;
        esac
    done

    if [[ $recursive_testing || -z $RUN_TESTS ]]; then
        [[ ! -f $CONFIG_FILE ]]\
            && eexit "You must provide --config file"
    fi
    return 0
}

```

 |

You use it like this, using the immutable ARGS variable we defined at the top:

|

1
2
3
4

 |

```
main() {
    cmdline $ARGS
}
main

```

 |

Unit Testing
------------

-   very important in higher level languages
-   Use [shunit2](http://code.google.com/p/shunit2/) for unit testing

|

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19

 |

```
test_config_line_paths() {
    local s='partition cpm-all, 80-90,'

    returns "/a" "config_line_paths '$s /a, '"
    returns "/a /b/c" "config_line_paths '$s /a:/b/c, '"
    returns "/a /b /c" "config_line_paths '$s   /a  :    /b : /c, '"
}

config_line_paths() {
    local partition_line="$@"

    echo $partition_line\
        | csv_column 3\
        | delete_spaces\
        | column 1\
        | colons_to_spaces
}

source /usr/bin/shunit2

```

 |

Here is another example using df command:

|

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32

 |

```
DF=df

mock_df_with_eols() {
    cat <<- EOF
    Filesystem           1K-blocks      Used Available Use% Mounted on
    /very/long/device/path
                         124628916  23063572 100299192  19% /
    EOF
}

test_disk_size() {
    returns 1000 "disk_size /dev/sda1"

    DF=mock_df_with_eols
    returns 124628916 "disk_size /very/long/device/path"
}

df_column() {
    local disk_device=$1
    local column=$2

    $DF $disk_device\
        | grep -v 'Use%'\
        | tr '\n' ' '\
        | awk "{print \$$column}"
}

disk_size() {
    local disk_device=$1

    df_column $disk_device 2
}

```

 |

Here I have exception, for testing, I declare DF in the global scope not readonly. This is because of shunit2 not allowing to change global scope functions.

Posted by Kfir Lavi Nov 14th, 2012  [BASH](https://kfirlavi.herokuapp.com/blog/categories/bash/), [Programming](https://kfirlavi.herokuapp.com/blog/categories/programming/), [Unit-Testing](https://kfirlavi.herokuapp.com/blog/categories/unit-testing/)
