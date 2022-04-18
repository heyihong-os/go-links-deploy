FROM golang:1.17-alpine as builder

RUN go install github.com/heyihong-os/go-links@latest

FROM quay.io/oauth2-proxy/oauth2-proxy:v7.2.1

COPY --from=builder /go/bin/go-links /bin/server
COPY start.sh ./

USER 2000:2000

ENTRYPOINT ["/bin/sh", "start.sh"]
