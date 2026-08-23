# Panduan Deployment Portainer & Integration GHCR (Next.js + Strapi + Postgres)

Panduan ini membantu Anda menghubungkan **GitHub Container Registry (GHCR)** ke **Portainer** dan melakukan deployment *Stack* untuk aplikasi **Next.js Frontend**, **Strapi CMS**, serta **PostgreSQL Database** internal.

---

## 1. Persiapan GitHub Personal Access Token (PAT)

Portainer memerlukan token otentikasi agar bisa melakukan `pull` image private dari GHCR.

1. Buka GitHub -> **Settings** -> **Developer Settings** -> **Personal Access Tokens** -> **Tokens (classic)**.
2. Klik **Generate new token (classic)**.
3. Beri nama (misal: `portainer-ghcr-token`).
4. Centang checklist scope berikut:
   - `read:packages` (Wajib untuk pull image dari GHCR)
   - `write:packages` (Opsional jika ingin me-push dari CLI lokal)
5. Klik **Generate token** dan simpan token tersebut.

---

## 2. Menambahkan GHCR Registry di Portainer

1. Login ke Dashboard **Portainer** Anda.
2. Di menu sebelah kiri, pilih **Registries** -> Klik **+ Add registry**.
3. Pilih **Custom registry**.
4. Isi formulir sebagai berikut:
   - **Name**: `GitHub Container Registry` (atau `GHCR`)
   - **Registry URL**: `ghcr.io`
   - **Authentication**: Aktifkan (*Toggle ON*)
   - **Username**: Username GitHub Anda (huruf kecil)
   - **Password / Token**: Paste *Personal Access Token (PAT)* yang Anda buat di Langkah 1.
5. Klik **Add registry**.

---

## 3. Deployment Stack di Portainer

1. Di Portainer, masuk ke menu **Stacks** -> Klik **+ Add stack**.
2. **Name**: Isi nama stack, misalnya `annasr-app`.
3. Pada bagian **Build method**, pilih **Web editor**.
4. Salin dan tempel (*copy-paste*) isi dari file [`docker-compose.portainer.yml`](file:///Users/perdanamain/Documents/it-practicioner/cms-annasr-konsultan/docker-compose.portainer.yml) ke dalam editor text.

5. Tambahkan **Environment Variables** di bagian bawah editor Portainer:

| Variable Name | Example Value / Description |
| :--- | :--- |
| `GHCR_OWNER` | Username atau Organization GitHub Anda (misal: `perdanamain`) |
| `DATABASE_NAME` | `annasr_db` |
| `DATABASE_USERNAME` | `annasr_user` |
| `DATABASE_PASSWORD` | *Password database PostgreSQL yang kuat* |
| `APP_KEYS` | Salin dari `.env` Strapi CMS (`APP_KEYS`) |
| `API_TOKEN_SALT` | Salin dari `.env` Strapi CMS (`API_TOKEN_SALT`) |
| `ADMIN_JWT_SECRET` | Salin dari `.env` Strapi CMS (`ADMIN_JWT_SECRET`) |
| `JWT_SECRET` | Salin dari `.env` Strapi CMS (`JWT_SECRET`) |
| `TRANSFER_TOKEN_SALT`| Salin dari `.env` Strapi CMS (`TRANSFER_TOKEN_SALT`) |
| `ENCRYPTION_KEY` | Salin dari `.env` Strapi CMS (`ENCRYPTION_KEY`) |
| `NEXT_PUBLIC_STRAPI_API_URL` | URL publik Strapi, misal: `http://<IP_VPS_ANDA>:1337` |
| `NEXT_PUBLIC_STRAPI_API_TOKEN`| Token API Strapi untuk Next.js |

6. Klik **Deploy the stack**.

---

## 4. Opsi Auto-Redeploy (Webhook / Auto-Update)

Agar Portainer otomatis memperbarui container saat ada pembaharuan image baru di GHCR:

1. Buka Stack `annasr-app` yang baru dideploy di Portainer.
2. Cari opsi **Automatic updates** atau **Webhook**.
3. Aktifkan **Create a stack webhook**.
4. Salin URL Webhook yang dihasilkan oleh Portainer.
5. Di repository GitHub Anda (Next.js / Strapi), Anda dapat menambahkan step HTTP request di GitHub Actions untuk memanggil URL Webhook tersebut setiap kali build selesai.

---

## 5. Cara Login & Push Manual ke GHCR dari Terminal (Opsional)

Jika ingin me-push Docker image secara manual dari terminal lokal tanpa GitHub Actions:

```bash
# 1. Login ke GHCR
echo "YOUR_GITHUB_PAT" | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin

# 2. Build image Next.js lokal
docker build -t ghcr.io/YOUR_GITHUB_USERNAME/fe-annasr-konsultan:latest ./fe-annasr-konsultan

# 3. Build image Strapi lokal
docker build -t ghcr.io/YOUR_GITHUB_USERNAME/cms-annasr-konsultan:latest ./cms-annasr-konsultan

# 4. Push ke GHCR
docker push ghcr.io/YOUR_GITHUB_USERNAME/fe-annasr-konsultan:latest
docker push ghcr.io/YOUR_GITHUB_USERNAME/cms-annasr-konsultan:latest
```
