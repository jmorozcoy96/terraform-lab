# Taller: EMR con Spark distribuido (Terraform)

Este módulo crea un **cluster EMR** (1 *master* + ≥2 *core*) con **Spark**. Incluye roles IAM, bucket S3 para logs, conexión por **SSM** (sin SSH) y un *step* de validación opcional (SparkPi).

---

## Requisitos

- **Terraform** ≥ 1.4  
- **AWS CLI** v2 (incluye Session Manager Plugin)  
- Credenciales AWS cargadas (solo para el ejercicio):
  - **PowerShell**
    ```powershell
    $env:AWS_ACCESS_KEY_ID="AKIA..."
    $env:AWS_SECRET_ACCESS_KEY="..."
    $env:AWS_DEFAULT_REGION="us-east-1"
    ```
  - **bash**
    ```bash
    export AWS_ACCESS_KEY_ID="AKIA..."
    export AWS_SECRET_ACCESS_KEY="..."
    export AWS_DEFAULT_REGION="us-east-1"
    ```
  - (Opcional) Usa `aws configure` y exporta `AWS_PROFILE`.

> **Red:** El `main.tf` detecta automáticamente una **subred pública** de la **VPC por defecto**.  
> Si tu cuenta no tiene VPC por defecto o subred pública, puedes crear una con `network_public.tf` y cambiar `subnet_id = aws_subnet.public.id` en `main.tf`.

---

## Estructura del proyecto
emr_spark_cluster/
├─ main.tf
├─ variables.tf
└─ outputs.tf

(opcional) network_public.tf si quieres crear VPC/IGW/subred pública

**PowerShell**
```powershell
terraform init
terraform validate
terraform apply -auto-approve