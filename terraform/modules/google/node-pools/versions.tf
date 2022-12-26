# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Developer >> Terraform >> Tutorials >> Configuration Language >> Manage Terraform Versions.
# @see {@link https://developer.hashicorp.com/terraform/tutorials/configuration-language/versions}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
terraform {
    required_version = ">= 1.3.0"
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    # @description: Project Dependencies for Kubernetes and Terraform.
    # @see {@link https://architect.io/blog/2021-02-17/terraform-kubernetes-tutorial/#project-dependencies-for-kubernetes-and-terraform}.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    required_providers {
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = ">= 2.0.0"
        }
        helm = {
            source = "hashicorp/helm"
            version = ">= 2.0.0"
        }
        # --------------------------------------------------------------------------------------------------------------------------------------------
        # @description: Terraform Registry — Hashicorp Google Provider.
        # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest}.
        # --------------------------------------------------------------------------------------------------------------------------------------------
        google = {
            source  = "hashicorp/google"
            version = ">= 4.47.0"
        }
    }
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Define Kubernetes Resources with Terraform.
# @see {@link https://architect.io/blog/2021-02-17/terraform-kubernetes-tutorial/#define-kubernetes-resources-with-terraform}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
provider "kubernetes" {
    config_path = "<kubeconfig_path>"
}

provider "helm" {
    kubernetes {
        config_path = "<kubeconfig_path>"
    }
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: [Terraform] >> Define Global Variables integrated via External Modules.
# @see {@link https://stackoverflow.com/questions/59584420/how-to-define-global-variables-in-terraform/}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
module "global" {
    source = "../../../modules/@global"
}

module "default" {
    source = "../../../modules/google/@global"
}
