- Server 側の Prisma Client を生成する。

```
npx prisma generate
```

- 環境の起動

```
docker compose build
docker compose up -d
```

```
http://localhost:8080
```

# migration

```
npx prisma migrate dev --name <file_name>
```
