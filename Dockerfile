# Build go
FROM golang:1.16-alpine AS builder

ENV CGO_ENABLED=0                         \
    NodeType=V2ray                        \
    UserNODE_ID=99                        \
    Userdomain=https://baidu.com          \
    EnableProxyProtocol=false             \
    Usermukey=key

WORKDIR /app
COPY . .
RUN go mod download
RUN go build -v -o XrayR -trimpath -ldflags "-s -w -buildid=" ./main

# Release
FROM  alpine
# 安装必要的工具包
RUN  apk --update --no-cache add tzdata ca-certificates \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apk --no-cache add gettext \
    && cp  /usr/bin/envsubst  /usr/local/bin/

#从编译环境拷贝主文件和配置文件
COPY --from=builder /app/XrayR /usr/local/bin

#复制配置
COPY config.yml /etc/XrayR/

#替换环境变量
CMD envsubst < /etc/XrayR/config.yml > /etc/XrayR/userconfig.yml \
    && XrayR --config /etc/XrayR/userconfig.yml
