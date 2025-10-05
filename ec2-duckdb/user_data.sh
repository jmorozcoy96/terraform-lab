#!/bin/bash
exec > /var/log/duckdb-install.log 2>&1
set -eux

# -------------------------------
# Actualizar sistema y dependencias
# -------------------------------
yum update -y
yum install -y python3 python3-pip unzip wget curl

# -------------------------------
# Habilitar y arrancar Amazon SSM Agent
# (Amazon Linux 2 ya lo trae instalado)
# -------------------------------
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# -------------------------------
# Instalar DuckDB (Python)
# -------------------------------
python3 -m pip install --upgrade pip
python3 -m pip install duckdb

# -------------------------------
# Instalar DuckDB CLI (binario)
# -------------------------------
DUCKDB_VERSION="v1.4.0"
DUCKDB_CLI_URL="https://github.com/duckdb/duckdb/releases/download/${DUCKDB_VERSION}/duckdb_cli-linux-amd64.zip"

cd /tmp
wget -O duckdb_cli.zip "$DUCKDB_CLI_URL"
unzip duckdb_cli.zip
mv duckdb /usr/local/bin/duckdb
chmod +x /usr/local/bin/duckdb
rm duckdb_cli.zip

# -------------------------------
# Validar instalación
# -------------------------------
echo "Validando instalación de DuckDB..."
if command -v duckdb >/dev/null 2>&1; then
  echo "DuckDB CLI instalado correctamente: $(duckdb --version)"
else
  echo "DuckDB CLI no se instaló correctamente"
fi

if python3 -c "import duckdb; print('DuckDB (Python) version:', duckdb.__version__)" >/dev/null 2>&1; then
  echo "DuckDB Python instalado correctamente"
else
  echo "DuckDB Python no se instaló correctamente"
fi

echo "Instalación completada. Revisa /var/log/duckdb-install.log"