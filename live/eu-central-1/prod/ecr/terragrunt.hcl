include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}//composition/ecr"
}

inputs = {
  create_ecr          = false
  ecr_repository_name = "tf-moduler"
}
