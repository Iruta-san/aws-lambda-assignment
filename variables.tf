variable "tags" {
  description = "Tags to apply to Resources"
  default = {
    Owner   = "Andrey Petrenko"
  }
}

variable "name" {
  description = "Name to use for Resources"
  default     = "IncreaseInt"
}


# Quota variables
variable "quota_limit" {
  description = "Total requests limit per time period"
  default     = "1000"
}

variable "quota_offset" {
  description = "When to reset the quota limit"
  default     = "0" # Resets every day
}

variable "quota_period" {
  description = "Period to reset the quota limit"
  default     = "DAY" # Valid values are "DAY", "WEEK" or "MONTH".
}

# Throttle variables
variable "throttle_burst" {
  description = "Maximum busrt for API allowed"
  default     = "5"
}

variable "throttle_ratelimit" {
  description = "Rate limit (RPS) after the burst value has been reached"
  default     = "2"
}
