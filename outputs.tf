# outputs file
# using a format that helps for clarity 

output "server_private_ip___________" { value = module.webserver.server_private_ip }
output "server_public_dns___________" { value = module.webserver.server_public_dns }
output "server_public_ip1___________" { value = module.webserver.server_public_ip }
output "server_id___________________" { value = module.webserver.server_id }
output "zssh_command________________" { value = module.webserver.zssh_command }
output "zbrowser____________________" { value = module.webserver.zbrowser }
output "iam_user_details____________" { value = module.webserver.iam_user_details }

