variable "project" {
  description = "Prefijo para nombrar recursos"
  type        = string
  default     = "taller"
}

variable "region" {
  description = "Región AWS"
  type        = string
  default     = "us-east-1"
}

variable "emr_release" {
  description = "Versión de EMR"
  type        = string
  default     = "emr-6.15.0"
}

variable "master_instance_type" {
  description = "Tipo de instancia para el master"
  type        = string
  default     = "m5.xlarge"
}

variable "core_instance_type" {
  description = "Tipo de instancia para los core"
  type        = string
  default     = "m5.xlarge"
}

variable "core_instance_count" {
  description = "Cantidad de nodos core (>=2 para Spark distribuido)"
  type        = number
  default     = 2
}
