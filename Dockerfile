# Build go
FROM golang:1.16-alpine AS builder

WORKDIR /app
COPY . .
ENV CGO_ENABLED=0                           \
    UserNODE_ID="97"                        \
    Userdomain="https://baidu.com/"         \
    Usermukey="key"               
    
RUN go mod download
RUN go build -v -o XrayR -trimpath -ldflags "-s -w -buildid=" ./main

# Release
FROM  alpine
# 安装必要的工具包
RUN  apk --update --no-cache add tzdata ca-certificates \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apk --no-cache add gettext \
    && cp  /usr/bin/envsubst  /usr/local/bin/

COPY --from=builder /app/XrayR /usr/local/bin
COPY /app/config.yml /etc/XrayR/

RUN envsubst < /etc/XrayR/config.yml > /etc/XrayR/userconfig.yml

ENTRYPOINT [ "XrayR", "--config", "/etc/XrayR/userconfig.yml"]
