################################
# Test and Build the source code
################################
FROM golang:1.15 AS build

RUN GOCACHE=OFF

WORKDIR /app
COPY . .

RUN apt-get update && apt-get install -y git

RUN wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /bin v1.36.0
RUN golangci-lint run ./...
RUN go test -v -cover ./...
RUN CGO_ENABLED=0 go build -o build/pgphoney -a -installsuffix cgo

################################
# Copy the binary to the final image
################################
FROM alpine:latest

WORKDIR /app
COPY --from=build /app/pghoney.conf /app/pghoney.conf
COPY --from=build /app/build/pgphoney /app/pgphoney

EXPOSE 5432
ENTRYPOINT ["/app/pgphoney"]