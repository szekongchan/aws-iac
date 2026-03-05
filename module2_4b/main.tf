module "app_topics" {
  source      = "./modules/app_topics"
  name_prefix = var.project_name
}

module "app_new_topics" {
  source      = "./modules/app_topics"
  name_prefix = "sk_module2_4b_step6"
  cart_count  = var.cart_count
}
