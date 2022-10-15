// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "hardhat/console.sol";

contract RandomSVGNFT is ERC721URIStorage,VRFConsumerBaseV2 {

    // Events
    event RequestedRandomSVG(uint256 indexed requestId,uint256 indexed tokenId,address indexed sender);
    event CreatedUnfinishedRandomSVG(uint256 indexed tokenId,uint256 indexed randomNumber);

    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private immutable i_callBackGasLimit;
	uint32 private constant NUM_WORDS = 1;
    uint256 private tokenCounter;


    // Mappings
    mapping(uint256=>address) public requestIdToSender;
    mapping(uint256=>uint256) public requestIdToTokenId;
    mapping(uint256=>uint256) public tokenIdToRandomNumber;


	constructor(
        address vrfCoordinatorV2,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) 
        VRFConsumerBaseV2(vrfCoordinatorV2)
        ERC721("RandomSVGNFT", "randomSVGNFT")
    {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callBackGasLimit = callbackGasLimit;
        tokenCounter = 0;
    }




    function createNFT() public returns(uint256 requestId){
        requestId=i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callBackGasLimit,
            NUM_WORDS
        );
        requestIdToSender[requestId]=msg.sender;
        uint256 tokenId = tokenCounter;
        requestIdToTokenId[requestId]=tokenId;
        tokenCounter+=1;

        emit RequestedRandomSVG(requestId,tokenId,msg.sender);

    }

    function fulfillRandomWords(uint256 requestId,uint256[] memory randomWords) internal override {
        uint256 randomNumber = randomWords[0];
        address nftOwner = requestIdToSender[requestId];
        uint256 tokenId = requestIdToTokenId[requestId];

        _safeMint(nftOwner,tokenId);
        tokenIdToRandomNumber[tokenId]=randomNumber;


        emit CreatedUnfinishedRandomSVG(tokenId,randomNumber);

    }
}
