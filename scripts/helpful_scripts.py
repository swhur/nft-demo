from brownie import accounts, network, config, VRFCoordinatorV2Mock, Contract
from web3 import Web3


LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["hardhat", "development", "ganache", "mainnet-fork"]
OPENSEA_URL = "https://testnets.opensea.io/assets/{}/{}"
BREED_MAPPING = {0: "PUG", 1: "SHIBA_INU", 2: "ST_BERNARD"}

MOCK_BASE_FEE = 100000000000000000
MOCK_GAS_PRICE_LINK = 100000000000000000


def get_breed(breed_number):
    return BREED_MAPPING[breed_number]


def get_account(index=None, id=None):
    if index:
        return accounts[index]
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        return accounts[0]
    if id:
        return accounts.load(id)

    return accounts.add(config["wallets"]["from_key"])


contract_to_mock = {"vrf_coordinator": VRFCoordinatorV2Mock}


def get_contract(contract_name):
    contract_type = contract_to_mock[contract_name]
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        if len(contract_type) <= 0:
            deploy_mocks()
        contract = contract_type[-1]
    else:
        contract_address = config["networks"][network.show_active()][contract_name]
        contract = Contract.from_abi(
            contract_type._name, contract_address, contract_type.abi
        )
    return contract


def deploy_mocks():
    print(f"The active network is {network.show_active()}")
    print("Deploying mocks...")
    account = get_account()
    print("Deploying Mock VRF Coordinator...")
    vrf_coordinator = VRFCoordinatorV2Mock.deploy(
        MOCK_BASE_FEE, MOCK_GAS_PRICE_LINK, {"from": account}
    )
    print(f"VRFCoordinator deployed to {vrf_coordinator.address}")
    print("All done!")
