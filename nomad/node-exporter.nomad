job "node-exporter" {
  datacenters = ["dc1"]
  type = "system"

  meta {
    version = "0.18.1"
    checksum = "sha256:a6c7eb64bb5f27a5567d545a1b93780f3aa72d0627751fd9f054626bb542a4b5"
  }

  group "i386" {
    constraint {
        attribute = "${attr.cpu.arch}"
        value     = "386"
    }

    task "node-exporter" {
      driver = "exec"
      config {
        command = "local/node_exporter-${NOMAD_META_version}.linux-386/node_exporter"
        args = []
      }

      artifact {
        source = "https://github.com/prometheus/node_exporter/releases/download/v${NOMAD_META_version}/node_exporter-${NOMAD_META_version}.linux-386.tar.gz"
        options {
          checksum = "${NOMAD_META_checksum}"
        }
      }

      resources {
        cpu    = 100
        memory = 64
        network {
          port "metrics" {
            static = 9100
          }
        }
      }

      service {
        name = "node-exporter"
        tags = ["http"]
        port = "metrics"
        check {
          name     = "metrics port alive"
          type     = "http"
          path     = "/metrics"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
