
provider "aws" {
    region = "eu-west-1"
    alias = "Irland"
}
provider "aws" {
    region = "eu-west-2"
    alias = "London"
}



module "mysql_primary" {
    providers= {
        aws = aws.London
    } 
    source = "../../../modules/data-stores/mysql"
    db_password = "tariktarik"
    db_username = "tarik"
    db_name = "mysqlme"

    #allow_replicas = 1
}

module "mysql_replica" {
     providers = {
        aws = aws.Irland
    } 
    count = 3
    source = "../../../modules/data-stores/mysql"
    replicate_source_db = module.mysql_primary.arn


}