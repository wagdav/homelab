job "mosquitto" {
  datacenters = ["dc1"]
  type        = "service"

  group "mqtt" {
    count = 1

    task "broker" {
      driver = "docker"

      config {
        image = "eclipse-mosquitto"

        port_map {
          broker = 1883
        }
      }

      resources {
        cpu    = 200
        memory = 100

        network {
          port  "broker" {}
        }
      }

      service {
        name = "mqtt"
        tags = ["mqtt"]
        port = "broker"

        check {
          type     = "tcp"
          port     = "broker"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
