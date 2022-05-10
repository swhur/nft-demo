// SPDX-License-Identifier: MIT
pragma solidity >=0.8.12;

// Import openzeppelin ERC721
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// Import VRF(Verifiable Random Function) Consumer V2
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
// Import VRF Coodinator V2 Interface
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

contract Collectible is ERC721URIStorage, VRFConsumerBaseV2 {
    // token counter
    uint256 public tokenCounter;
    // VRF Coodinator V2 Interface
    VRFCoordinatorV2Interface coordinator;
    // subscription Id
    uint64 subscriptionId;
    // keyhash
    bytes32 public keyhash;

    // callback gas limit
    uint32 callbackGasLimit = 100000;
    // request confirmations
    uint16 requestConfirmations = 3;
    // retrieve random number
    uint32 numWords = 1;

    enum Breed {
        PUG,
        SHIBA_INU,
        ST_BERMARD
    }

    mapping(uint256 => Breed) public tokenIdToBreed;
    mapping(uint256 => address) public requestIdToSender;

    event requestedCollectible(uint256 indexed requestId, address requester);
    event breedAssigned(uint256 indexed tokenId, Breed breed);

    constructor(
        uint64 _subscriptionId,
        address _vrfCoodinator,
        bytes32 _keyhash
    ) public VRFConsumerBaseV2(_vrfCoodinator) ERC721("Dogie", "DOG") {
        coordinator = VRFCoordinatorV2Interface(_vrfCoodinator);
        subscriptionId = _subscriptionId;
        tokenCounter = 0;
        keyhash = _keyhash;
    }

    function createCollectible() public returns (uint256) {
        uint256 requestId = coordinator.requestRandomWords(
            keyhash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        requestIdToSender[requestId] = msg.sender;
        emit requestedCollectible(requestId, msg.sender);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        uint256 randomNumber = randomWords[0];
        Breed breed = Breed(randomNumber % 3);
        uint256 newTokenId = tokenCounter;
        tokenIdToBreed[newTokenId] = breed;
        emit breedAssigned(newTokenId, breed);
        address owner = requestIdToSender[requestId];
        _safeMint(owner, newTokenId);
        tokenCounter = tokenCounter + 1;
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not owner or not approved"
        );
        _setTokenURI(tokenId, _tokenURI);
    }
}
