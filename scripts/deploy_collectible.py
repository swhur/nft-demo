from os import access
from scripts.helpful_scripts import (
    get_account,
    OPENSEA_URL,
    get_contract,
)
from brownie import Collectible, network, config


def deploy_collectible():
    account = get_account()
    collectible = Collectible.deploy(
        config["networks"][network.show_active()]["subscription_id"],
        get_contract("vrf_coordinator"),
        config["networks"][network.show_active()]["keyhash"],
        {"from": account},
    )

    return collectible


def main():
    deploy_collectible()
