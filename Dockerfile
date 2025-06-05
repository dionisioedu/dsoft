# === STAGE 1: build do binário ===
FROM golang:1.23-alpine AS builder

# Instala dependências de pacote para compilar e TLS
RUN apk add --no-cache git ca-certificates

# Define diretório de trabalho
WORKDIR /app

# Copia go.mod e go.sum e baixa dependências
COPY go.mod go.sum ./
RUN go mod download

# Copia todo o código fonte (incluindo migrations)
COPY . .

# Compila o binário estático
# CGO_ENABLED=0 garante que não haja dependências C, produzindo binário estático
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o dsoft .



# === STAGE 2: imagem final leve ===
FROM alpine:3.18 AS runner

# Instala apenas certificados de CA (para TLS)
RUN apk add --no-cache ca-certificates

# Cria usuário não-root (opcional, mas recomendado)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Diretório onde o binário e migrations ficarão
WORKDIR /app

# Copia binário compilado do stage anterior
COPY --from=builder /app/dsoft      /app/dsoft

# Copia a pasta de migrations para dentro da imagem
COPY --from=builder /app/migrations /app/migrations

# Ajusta permissões para o usuário não-root
RUN chown -R appuser:appgroup /app

# Passa a rodar como appuser
USER appuser

# Porta padrão exposta (se quiser mudar, ajuste conforme necessário)
EXPOSE 8080

# O ENTRYPOINT executa o binário (que já aplica migrations e inicia o servidor)
ENTRYPOINT ["/app/dsoft"]
