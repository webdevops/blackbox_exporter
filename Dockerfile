FROM golang:1.15 as build

WORKDIR /go/src/github.com/webdevops/blackbox_exporter

# Get deps (cached)
COPY ./go.mod /go/src/github.com/webdevops/blackbox_exporter
COPY ./go.sum /go/src/github.com/webdevops/blackbox_exporter
RUN go mod download

# Compile
COPY ./ /go/src/github.com/webdevops/blackbox_exporter
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -o /blackbox_exporter \
    && chmod +x /blackbox_exporter
RUN /blackbox_exporter --help

#############################################
# FINAL IMAGE
#############################################
FROM gcr.io/distroless/static
USER 0
COPY --from=build /blackbox_exporter /blackbox_exporter
COPY --from=build /go/src/github.com/webdevops/blackbox_exporter/blackbox.yml /etc/blackbox_exporter/config.yml

EXPOSE      9115
ENTRYPOINT  [ "/blackbox_exporter" ]
CMD         [ "--config.file=/etc/blackbox_exporter/config.yml" ]
