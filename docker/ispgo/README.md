# IspGo CRM

Chatwoot edición comunitaria (MIT, sin `enterprise/`) con la marca de IspGo.
Una instancia atiende a muchos ISP: la Cloud de IspGo crea una cuenta por ISP
con la Platform API. Cuando una instancia llega a su cupo, se monta otra igual
y se registra en la Cloud (staff > CRM).

Imagen: `ghcr.io/yeiider/ispgo-crm:latest` (se publica al hacer merge a `develop`).

## Recursos en Coolify (cada uno con su límite de CPU y memoria)

| Recurso | Qué es | Límite sugerido |
| --- | --- | --- |
| `crm-db` | PostgreSQL con pgvector (`pgvector/pgvector:pg16`) | 2 GB, 1 CPU |
| `crm-redis` | Redis 7 | 512 MB |
| `crm-web` | la imagen, `ISPGO_ROLE=web`, puerto 3000, salud `/api` | 2 GB, 2 CPU |
| `crm-worker` | la imagen, `ISPGO_ROLE=worker` | 2 GB, 2 CPU |

`crm-web` corre las migraciones al arrancar; `crm-worker` solo procesa la cola.

## Variables (web y worker)

```
ISPGO_ROLE=web            # worker en crm-worker
FRONTEND_URL=https://crm.ispgo.net
SECRET_KEY_BASE=<openssl rand -hex 64>
DATABASE_URL=postgres://chatwoot:<clave>@crm-db:5432/chatwoot
REDIS_URL=redis://default:<clave>@crm-redis:6379
RAILS_ENV=production
NODE_ENV=production
RAILS_LOG_TO_STDOUT=true
DEFAULT_LOCALE=es
ENABLE_ACCOUNT_SIGNUP=false
ISPGO_CLOUD_URL=https://cloud.ispgo.net
MAILER_SENDER_EMAIL=IspGo CRM <no-reply@ispgo.net>
SMTP_ADDRESS=... SMTP_PORT=587 SMTP_USERNAME=... SMTP_PASSWORD=... SMTP_AUTHENTICATION=login SMTP_ENABLE_STARTTLS_AUTO=true
# adjuntos: S3 (web y worker los leen). Con `local` hay que montar el mismo
# directorio del host en /app/storage en los dos.
ACTIVE_STORAGE_SERVICE=amazon
S3_BUCKET_NAME=... AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=... AWS_REGION=us-east-1
```

## Primera vez

1. En `crm-web` > Terminal: `bundle exec rails c` y crear el super admin
   (`SuperAdmin.create!(email: 'staff@ispgo.net', password: '...', name: 'IspGo')`),
   o entrar a `/installation/onboarding` si aparece.
2. En `/super_admin` > Platform Apps: crear "IspGo Cloud" y copiar su token.
3. En el portal de la Cloud, staff > CRM: agregar la instancia con su URL,
   el token y el cupo de ISP.
