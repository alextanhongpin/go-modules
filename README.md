# go-modules with Docker

## Project Folder
Create a project outside of `$GOPATH`, e.g. `~/Documents/<your-project-name>`.

```bash
$ mkdir ~/Documents/go-modules && cd ~/Documents/go-modules
```

## Init go modules

Init go modules by specifying the project namespace:

```bash
$ go mod init <project-namespace>

# E.g.
$ go mod init go-modules
```

Any packages that you create within this project will have the namespace `go-modules`. 


## main

Create a bare `main.go` file and include this:

```golang
package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/julienschmidt/httprouter"
)

func main() {
	r := httprouter.New()
	r.GET("/", func(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
		fmt.Fprint(w, "hello world")
	})
	log.Println("listening to port *:8080. press ctrl + c to cancel.")
	log.Fatal(http.ListenAndServe(":8080", r))
}
```

## pkg

Create a folder called `pkg` and include a `greet` package:

```go
// pkg/greet/greet.go
package greet

const Version = 1
```

Change your `main.go` file to call the `greet` package. It should look like this:

```golang
package main

import (
	"fmt"
	"log"
	"net/http"

	"go-modules/pkg/greet" // go-modules is our project namespace

	"github.com/julienschmidt/httprouter"
)

func main() {
	r := httprouter.New()
	r.GET("/", func(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
		fmt.Fprintf(w, "hello world, v%v", greet.Version)
	})
	log.Println("listening to port *:8080. press ctrl + c to cancel.")
	log.Fatal(http.ListenAndServe(":8080", r))
}
```

## Vendor

This command will create a `vendor` directory locally for external dependencies. This is useful when building the binary (especially in Docker), as you do not need to fetch the dependencies again:

```bash
$ go mod vendor
```

## Dockerize

A simplified multi-stage docker build `Dockerfile` would look like this:

```dockerfile
FROM golang:1.11.0-stretch as builder

WORKDIR /go-modules

COPY . ./

# Building using -mod=vendor, which will utilize the v
RUN CGO_ENABLED=0 GOOS=linux go build -mod=vendor -o app 

FROM alpine:3.8

WORKDIR /root/

COPY --from=builder /go-modules/app .

CMD ["./app"]
```

Refer [here](https://github.com/alextanhongpin/go-docker-multi-stage-build) for a more complete example. 

Run the docker build:

```bash
# Build
$ docker build --no-cache -t alextanhongpin/go-modules .

# Run the image
$ docker run -d -p 8080:8080 alextanhongpin/go-modules

# Test
$ curl http://localhost:8080
hello world, v1%
```