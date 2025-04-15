resource "yandex_compute_snapshot_schedule" "daily_snapshots" {
  name        = "daily-snapshots"
  description = "Daily snapshots"
  folder_id   = var.folder_id

  schedule_policy {
    expression = "0 3 * * *" # каждый день в 03:00
  }

  snapshot_count = 7 # храним снапшоты 7 дней

  snapshot_spec {
    description = "Daily snapshot"
  }

  disk_ids = [
    yandex_compute_instance.bastion.boot_disk.0.disk_id,
    yandex_compute_instance.web_a.boot_disk.0.disk_id,
    yandex_compute_instance.web_b.boot_disk.0.disk_id,
    yandex_compute_instance.elastic.boot_disk.0.disk_id,
    yandex_compute_instance.kibana.boot_disk.0.disk_id,
    yandex_compute_instance.zabbix.boot_disk.0.disk_id
  ]
}
