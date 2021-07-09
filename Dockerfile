# Build go
FROM golang:1.16-alpine AS builder

ENV CGO_ENABLED=0                         \
    UserNODE_ID=99                        \
    Userdomain=https://baidu.com          \
    Usermukey=key

WORKDIR /app
COPY . .

#安装环境变量读取
RUN apk --no-cache add gettext \
    && cp  /usr/bin/envsubst  /usr/local/bin/
    
#复制配置
COPY config.yml /etc/XrayR/
#替换环境变量
RUN envsubst < /etc/XrayR/config.yml > /etc/XrayR/userconfig.yml

RUN go mod download
RUN go build -v -o XrayR -trimpath -ldflags "-s -w -buildid=" ./main

# Release
FROM  alpine
# 安装必要的工具包
RUN  apk --update --no-cache add tzdata ca-certificates \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#从编译环境拷贝主文件和配置文件
COPY --from=builder /app/XrayR /usr/local/bin
COPY --from=builder /etc/XrayR/userconfig.yml /etc/XrayR/userconfig.yml

#程序入口
ENTRYPOINT [ "XrayR", "--config", "/etc/XrayR/userconfig.yml"]
