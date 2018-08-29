FROM golang:1.11.0-stretch as builder

WORKDIR /go-modules

COPY . ./

RUN CGO_ENABLED=0 GOOS=linux go build -mod=vendor -o app 

FROM alpine:3.8

WORKDIR /root/

COPY --from=builder /go-modules/app .

CMD ["./app"]
