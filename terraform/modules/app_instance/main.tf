resource "aws_instance" "this" {
  for_each = {
    for inst in var.instances :
    inst.name => inst
  }

  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = each.value.security_group_ids
  key_name               = each.value.key_name
  associate_public_ip_address = true
  iam_instance_profile = var.iam_instance_profile

  # Use .tpl (template) file because (other than .sh file) it allows Terraform to inject variables dynamically at runtime
  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    # For multi server setup
    # app_name      = each.value.name
    app_repo_url  = var.app_repo_url
    docker_port   = each.value.docker_port
    jwt_secret   = var.jwt_secret
    db_user      = var.db_user
    db_password  = var.db_password
    db_name      = var.db_name
    db_host      = var.db_host
    db_uri       = "postgresql://${var.db_user}:${var.db_password}@${var.db_host}:5432/${var.db_name}"
    env_file_content = var.env_file_content
    s3_bucket_name = var.s3_bucket_name
    s3_region      = var.s3_region
  })

  tags = merge(
    {
      Name = each.value.name
    },
    each.value.tags
  )
}
