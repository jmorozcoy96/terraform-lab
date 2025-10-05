#!/bin/bash
# Actualizar paquetes
sudo apt-get update -y
sudo apt-get upgrade -y

# Instalar dependencias
sudo apt-get install -y openjdk-11-jdk wget curl unzip python3-pip

# Variables de versión fijas
SPARK_VERSION="3.5.0"
HADOOP_VERSION="3"
SPARK_ARCHIVE="spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}"
SPARK_URL="https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_ARCHIVE}.tgz"

# Descargar y descomprimir Spark en /opt
cd /tmp
wget -q ${SPARK_URL}
tar -xzf ${SPARK_ARCHIVE}.tgz
sudo mv ${SPARK_ARCHIVE} /opt/spark

# Configurar variables de entorno
echo 'export SPARK_HOME=/opt/spark' | sudo tee /etc/profile.d/spark.sh
echo 'export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin' | sudo tee -a /etc/profile.d/spark.sh
echo 'export PYSPARK_PYTHON=python3' | sudo tee -a /etc/profile.d/spark.sh

# Cargar variables para esta sesión
. /etc/profile.d/spark.sh

# Instalar PySpark (para usar desde Python)
pip3 install pyspark

# Validación inicial: guardar versión en un log
spark-submit --version >> /var/log/spark-install.log 2>&1
python3 -c "from pyspark.sql import SparkSession; print(SparkSession.builder.getOrCreate().version)" >> /var/log/spark-install.log 2>&1
