module "dns-records" {
  for_each           = local.dns_records
  source             = "git::ssh://git@github.com/ejbest/cloudflare-dns-terraform-module.git//?ref=main"
  cloudflare_zone_id = local.cloudflare_zone
  cloudflare_name    = each.value.name
  cloudflare_content = each.value.content
  cloudflare_type    = each.value.type
  ttl                = each.value.ttl
  proxied            = false
  priority           = each.value.priority
}

