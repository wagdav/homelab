job "fabio" {
  datacenters = ["dc1"]
  type = "system"

  group "fabio" {
    task "fabio" {
      driver = "docker"
      config {
        image = "fabiolb/fabio"
        args = [
          "-proxy.addr", ":80",
          "-proxy.addr", ":1883;proto=tcp",
        ]
        network_mode = "host"
      }

      resources {
        cpu    = 100
        memory = 64
        network {
          mbits = 20
          port "lb" {
            static = 80
          }
          port "mqtt" {
            static = 1883
          }
          port "ui" {
            static = 9998
          }
        }
      }
    }
  }
}
