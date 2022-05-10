from brownie import Collectible
from scripts.helpful_scripts import get_account


def create_collectible():
    account = get_account()
    collectible = Collectible[-1]
    creation_transaction = collectible.createCollectible({"from": account})
    creation_transaction.wait(1)
    print("Collectible created!")


def main():
    create_collectible()
