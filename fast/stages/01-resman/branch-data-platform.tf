/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# tfdoc:file:description Data Platform stages resources.

# top-level Data Platform folder and service account

module "branch-dp-folder" {
  source = "../../../modules/folder"
  parent = "organizations/${var.organization.id}"
  name   = "Data Platform"
  tag_bindings = {
    context = module.organization.tag_values["context/data"].id
  }
}

# environment: development folder

module "branch-dp-dev-folder" {
  source    = "../../../modules/folder"
  parent    = module.branch-dp-folder.id
  name      = "Development"
  group_iam = {}
  iam = {
    # remove owner here and at project level if SA does not manage project resources
    "roles/compute.xpnAdmin"               = [module.branch-dp-dev-sa.iam_email]
    "roles/logging.admin"                  = [module.branch-dp-dev-sa.iam_email]
    "roles/owner"                          = [module.branch-dp-dev-sa.iam_email]
    "roles/resourcemanager.folderAdmin"    = [module.branch-dp-dev-sa.iam_email]
    "roles/resourcemanager.projectCreator" = [module.branch-dp-dev-sa.iam_email]
  }
  tag_bindings = {
    context = module.organization.tag_values["environment/development"].id
  }
}

module "branch-dp-dev-sa" {
  source      = "../../../modules/iam-service-account"
  project_id  = var.automation_project_id
  name        = "dev-resman-dp-0"
  description = "Terraform Data Platform development service account."
  prefix      = var.prefix
}

module "branch-dp-dev-gcs" {
  source     = "../../../modules/gcs"
  project_id = var.automation_project_id
  name       = "dev-resman-dp-0"
  prefix     = var.prefix
  versioning = true
  iam = {
    "roles/storage.objectAdmin" = [module.branch-dp-dev-sa.iam_email]
  }
}

# environment: production folder

module "branch-dp-prod-folder" {
  source    = "../../../modules/folder"
  parent    = module.branch-dp-folder.id
  name      = "Production"
  group_iam = {}
  iam = {
    # remove owner here and at project level if SA does not manage project resources
    "roles/logging.admin"                  = [module.branch-dp-prod-sa.iam_email]
    "roles/owner"                          = [module.branch-dp-prod-sa.iam_email]
    "roles/resourcemanager.folderAdmin"    = [module.branch-dp-prod-sa.iam_email]
    "roles/resourcemanager.projectCreator" = [module.branch-dp-prod-sa.iam_email]
    "roles/compute.xpnAdmin"               = [module.branch-dp-prod-sa.iam_email]
  }
  tag_bindings = {
    context = module.organization.tag_values["environment/production"].id
  }
}

module "branch-dp-prod-sa" {
  source      = "../../../modules/iam-service-account"
  project_id  = var.automation_project_id
  name        = "prod-resman-dp-0"
  description = "Terraform Data Platform production service account."
  prefix      = var.prefix
}

module "branch-dp-prod-gcs" {
  source     = "../../../modules/gcs"
  project_id = var.automation_project_id
  name       = "prod-resman-dp-0"
  prefix     = var.prefix
  versioning = true
  iam = {
    "roles/storage.objectAdmin" = [module.branch-dp-prod-sa.iam_email]
  }
}
