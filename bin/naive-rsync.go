///usr/bin/true; exec /usr/bin/env go run "$0" "$@"

package main

import (
    "bufio"
    "strings"
    "strconv"
    "flag"
    "fmt"
    "os"
    "path/filepath"
)

type NodeInfo struct {
    IsDir bool
    Path string
    Size int64
}

var closeNode NodeInfo

func scanFolder(folder string, OnNode func (NodeInfo)) error {
    absFolder, err := filepath.Abs(folder)
    if err != nil {
        return err
    }

    err = filepath.Walk(absFolder, func(path string, info os.FileInfo, err error) error {
        if err != nil {
            return err
        }

        var size int64
        if info.IsDir() {
            size = 0
        } else {
            size = info.Size()
        }

        path = strings.Replace(path, absFolder + "/", "./", 1)
        path = strings.Replace(path, absFolder, "./", 1)

        node := NodeInfo{
            IsDir: info.IsDir(),
            Path: path,
            Size: size,
        }

        OnNode(node)
        return nil
    })

    if err != nil {
        return err
    }

    return nil
}

func pullReferenceNodeInfo(reference string) (<-chan NodeInfo, <-chan error) {
    ch := make(chan NodeInfo, 1)
    errorCh := make(chan error, 1)

    go func() {
        referenceFile, err := os.Open(reference)
        if err != nil {
            errorCh <- err
            return
        }
        defer referenceFile.Close()

        scanner := bufio.NewScanner(referenceFile)
        if err := scanner.Err(); err != nil {
            errorCh <- err
            return
        }

        for scanner.Scan() {
            line := scanner.Text()
            cols := strings.Split(line, "\t")
            size, err := strconv.ParseInt(cols[1], 10, 64)
            if err != nil {
                errorCh <- err
                return
            }
            isDir, err := strconv.ParseBool(cols[2])
            if err != nil {
                errorCh <- err
                return
            }
            node := NodeInfo {
                IsDir: isDir,
                Path: cols[0],
                Size: size,
            }
            ch <- node
        }
        ch <- closeNode
        close(ch)
        close(errorCh)
    }()

    return ch, errorCh;
}

func pullFolderNodeInfo(folder string) (<-chan NodeInfo, <-chan error) {
    ch := make(chan NodeInfo, 1)
    errorCh := make(chan error, 1)

    go func() {
        err := scanFolder(folder, func (node NodeInfo) {
            ch <- node
        })
        if err != nil {
            errorCh <- err
            return
        }
        ch <- closeNode
        close(ch)
        close(errorCh)
    }()
    return ch, errorCh
}

func compareFolders(
    srcFolderReference string,
    targetFolder string,
    OnOperation func(string, NodeInfo),
) error {
    srcCh, srcErrorCh := pullReferenceNodeInfo(srcFolderReference)
    go func() {
        err := <- srcErrorCh
        if err != nil {
            panic(err)
        }
    }()

    targetCh, targetErrorCh := pullFolderNodeInfo(targetFolder)
    go func() {
        err := <- targetErrorCh
        if err != nil {
            panic(err)
        }
    }()

    srcNode := <- srcCh
    targetNode := <- targetCh
    for {
        if srcNode == closeNode || targetNode == closeNode {
            break
        }
        if srcNode.Path == targetNode.Path {
            if srcNode.Size != targetNode.Size {
                OnOperation("delete", targetNode)
                if srcNode.IsDir {
                    OnOperation("create", srcNode)

                } else {
                    OnOperation("copy", srcNode)
                }
            }
        } else {
            if targetNode == closeNode || srcNode.Path > targetNode.Path {
                for {
                    if targetNode == closeNode || srcNode.Path <= targetNode.Path {
                        break
                    }
                    OnOperation("delete", targetNode)
                    targetNode = <- targetCh
                }
                continue
            } else {
                for {
                    if srcNode == closeNode || srcNode.Path >= targetNode.Path {
                        break
                    }
                    if srcNode.IsDir {
                        OnOperation("create", srcNode)

                    } else {
                        OnOperation("copy", srcNode)
                    }
                    srcNode = <- srcCh
                }
                continue
            }
        }
        srcNode = <- srcCh
        targetNode = <- targetCh
    }

    for {
        if targetNode == closeNode {
            break
        }
        OnOperation("delete", targetNode)
        targetNode = <- srcCh
    }

    for {
        if srcNode == closeNode {
            break
        }
        if srcNode.IsDir {
            OnOperation("create", srcNode)

        } else {
            OnOperation("copy", srcNode)
        }
        srcNode = <- srcCh
    }

    return nil
}

func main() {
    referencePtr := flag.String("reference", "", "")
    flag.Parse()
    folder := flag.Arg(0)

    if (*referencePtr == "") {
        err := scanFolder(folder, func (node NodeInfo) {
            fmt.Printf("%s\t%d\t%t\n", node.Path, node.Size, node.IsDir)
        })
        if err != nil {
            panic(err)
        }
        return
    }

    err := compareFolders(
        *referencePtr,
        folder,
        func(operation string, node NodeInfo) {
            fmt.Printf("%s '%s'\n", operation, strings.TrimPrefix(node.Path, "./"))
        },
    )
    if err != nil {
        panic(err)
    }
}
