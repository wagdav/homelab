job "alertmanager" {
  datacenters = ["dc1"]
  type = "service"

  meta {
    version = "0.18.0"
    checksum = "sha256:77bd1b88fa4526096df05d57d4150bc7aadb048f3b4a1ae90f7165eea9f4671d"
  }

  group "alerting" {
    count = 1

    ephemeral_disk {
      size = 300
    }

    task "alertmanager" {
      driver = "exec"

      constraint {
        attribute = "${attr.cpu.arch}"
        value     = "386"
      }

      config {
        command = "local/alertmanager-${NOMAD_META_version}.linux-386/alertmanager"
        args    = [
          "--config.file=local/alertmanager-${NOMAD_META_version}.linux-386/alertmanager.yml"
        ]
      }

      artifact {
        # https://prometheus.io/download
        source = "https://github.com/prometheus/alertmanager/releases/download/v${NOMAD_META_version}/alertmanager-${NOMAD_META_version}.linux-386.tar.gz"
        options {
          checksum = "${NOMAD_META_checksum}"
        }
      }

      resources {
        network {
          port "alertmanager_ui" {
            static = 9093
          }
        }
      }

      service {
        name = "alertmanager"
        tags = ["http"]
        port = "alertmanager_ui"
        check {
          name     = "alertmanager_ui port alive"
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
