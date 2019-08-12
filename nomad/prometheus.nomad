job "prometheus" {
  datacenters = ["dc1"]
  type = "service"

  meta {
    version = "2.11.1"
    checksum = "sha256:d1b0738cda68004f54bb9a32c056d2a62469f00aa3732382d573c6a05484417f"
  }

  group "prometheus" {
    ephemeral_disk {
      size = 300
    }

    task "prometheus" {
      constraint {
        attribute = "${attr.cpu.arch}"
        value     = "386"
      }

      driver = "exec"
      config {
        command = "local/prometheus-${NOMAD_META_version}.linux-386/prometheus"
        args    = [
          "--config.file=local/prometheus.yml",
        ]
      }

      artifact {
        # https://prometheus.io/download
        source = "https://github.com/prometheus/prometheus/releases/download/v${NOMAD_META_version}/prometheus-${NOMAD_META_version}.linux-386.tar.gz"
        options {
          checksum = "${NOMAD_META_checksum}"
        }
      }

      resources {
        cpu    = 500 # MHz
        memory = 256 # MB
        network {
          # https://github.com/prometheus/prometheus/wiki/Default-port-allocations
          port "ui" {
            static = 9090
          }
        }
      }

      service {
        name = "prometheus"
        tags = ["http"]
        port = "ui"
        check {
          name     = "health check endpoint"
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }

      template {
        change_mode   = "signal"
        change_signal = "SIGHUP"
        destination   = "local/prometheus.yml"
        data = <<EOH
---
alerting:
  alertmanagers:
  - consul_sd_configs:
    - server: '{{ env "NOMAD_IP_ui" }}:8500'
      services: ['alertmanager']

scrape_configs:

  - job_name: prometheus
    consul_sd_configs:
    - server: '{{ env "NOMAD_IP_ui" }}:8500'
      services: ['prometheus']


  - job_name: node_exporter
    consul_sd_configs:
    - server: '{{ env "NOMAD_IP_ui" }}:8500'
      services: ['node-exporter']
EOH
      }
    }
  }
}
