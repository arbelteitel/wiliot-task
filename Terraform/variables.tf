variable "pub_subnet_cidrs" {
 type        = list(string)
 description = "public subnet range values"
 default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "prv_subnet_cidrs" {
 type        = list(string)
 description = "prive subnet ranges values"
 default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}
