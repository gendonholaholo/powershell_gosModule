# GosModule - PowerShell AI Assistant Module

GosModule adalah modul PowerShell yang menyediakan fungsionalitas AI assistant untuk membantu dalam berbagai tugas pengembangan dan administrasi sistem. Modul ini menggunakan API OpenAI dan Groq untuk memberikan respons yang cerdas dan terformat dengan baik.

## Fitur Utama

- **Interaksi AI**: Berkomunikasi dengan AI assistant melalui fungsi `gosTanya`
- **Format Respons**: Menampilkan output yang terformat dengan baik menggunakan `Format-Response`
- **Analisis Kode**: Mendukung analisis kode dengan berbagai agen (code, security, optimization, summary)
- **Cache System**: Sistem cache untuk menyimpan dan mengelola respons
- **Multi-API Support**: Dukungan untuk OpenAI dan Groq API
- **Style Customization**: Berbagai style output (default, info, warning, error, success)

## Instalasi

1. Clone repositori ini:
```powershell
git clone https://github.com/gendonholaholo/powershell_gosModule.git
```

2. Import modul:
```powershell
Import-Module .\Modules\GosModule -Force
```

3. Konfigurasi API key di file config:
```powershell
$Global:GosAPIKey = "your-api-key"
$Global:GroqAPIKey = "your-groq-api-key"
```

## Penggunaan

### Berinteraksi dengan AI

```powershell
# Tanya pertanyaan umum
gosTanya "Apa itu PowerShell?"

# Tanya dengan style warning
gosTanya "Berikan peringatan tentang penggunaan rm -rf" -Style warning

# Analisis kode
gosTanya -Read "path/to/file.ps1" -Agent code -Style info
```

### Format Respons

```powershell
# Format teks dengan style default
Format-Response -Text "Ini adalah pesan" -Style default

# Format dengan judul
Format-Response -Text "Ini adalah pesan" -Title "Judul" -Style info
```

## Struktur Proyek

```
GosModule/
├── Modules/
│   └── GosModule/
│       ├── Public/
│       │   └── Format-Response.ps1
│       ├── Private/
│       ├── Config/
│       │   └── config.ps1
│       └── GosModule.psm1
└── README.md
```

## Persyaratan

- PowerShell 7.0 atau lebih baru
- API key OpenAI atau Groq
- Akses internet untuk koneksi API

## Lisensi

MIT License

## Kontribusi

Kontribusi selalu diterima! Silakan buat pull request atau buka issue untuk diskusi. 