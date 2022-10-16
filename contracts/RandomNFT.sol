// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";

import "hardhat/console.sol";

contract RandomSVGNFT is ERC721URIStorage, VRFConsumerBaseV2 {
	// Events
	event RequestedRandomSVG(
		uint256 indexed requestId,
		uint256 indexed tokenId,
		address indexed sender
	);
	event CreatedUnfinishedRandomSVG(uint256 indexed tokenId, uint256 indexed randomNumber);
	event CreatedRandomSVG(uint256 indexed tokneId, string indexed tokenURI);

	// SVG Parameters.
	uint256 public maxNumberOfPaths;
	uint256 public maxNumberOfPathCommands;
	uint256 public size;
	string[] public pathCommands;
	string[] public colors;

	VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
	bytes32 private immutable i_gasLane;
	uint64 private immutable i_subscriptionId;
	uint16 private constant REQUEST_CONFIRMATIONS = 3;
	uint32 private immutable i_callBackGasLimit;
	uint32 private constant NUM_WORDS = 1;
	uint256 private tokenCounter;

	// Mappings
	mapping(uint256 => address) public requestIdToSender;
	mapping(uint256 => uint256) public requestIdToTokenId;
	mapping(uint256 => uint256) public tokenIdToRandomNumber;

	constructor(
		address vrfCoordinatorV2,
		bytes32 gasLane,
		uint64 subscriptionId,
		uint32 callbackGasLimit
	) VRFConsumerBaseV2(vrfCoordinatorV2) ERC721("RandomSVGNFT", "randomSVGNFT") {
		i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
		i_gasLane = gasLane;
		i_subscriptionId = subscriptionId;
		i_callBackGasLimit = callbackGasLimit;
		tokenCounter = 0;
		maxNumberOfPaths = 40;
		maxNumberOfPathCommands = 20;
		size = 500;
		pathCommands = ["M", "L"];
		colors = ["red", "blue", "green", "yellow", "black", "white"];
	}

	function createNFT() public returns (uint256 requestId) {
		requestId = i_vrfCoordinator.requestRandomWords(
			i_gasLane,
			i_subscriptionId,
			REQUEST_CONFIRMATIONS,
			i_callBackGasLimit,
			NUM_WORDS
		);
		requestIdToSender[requestId] = msg.sender;
		uint256 tokenId = tokenCounter;
		requestIdToTokenId[requestId] = tokenId;
		tokenCounter += 1;

		emit RequestedRandomSVG(requestId, tokenId, msg.sender);
	}

	function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
		internal
		override
	{
		uint256 randomNumber = randomWords[0];
		address nftOwner = requestIdToSender[requestId];
		uint256 tokenId = requestIdToTokenId[requestId];

		_safeMint(nftOwner, tokenId);
		tokenIdToRandomNumber[tokenId] = randomNumber;

        // finishMint(tokenId);

		emit CreatedUnfinishedRandomSVG(tokenId, randomNumber);
	}

	function finishMint(uint256 _tokenId) public {
		require(
			bytes(tokenURI(_tokenId)).length <= 0,
			"Token URI is already all set, cannot change it."
		);
		require(tokenCounter > _tokenId, "The token Id has not minted yet.");
		require(
			tokenIdToRandomNumber[_tokenId] > 0,
			"No random number found associted with the following token Id"
		);

		uint256 randomNumber = tokenIdToRandomNumber[_tokenId];

		string memory svg = generateSVG(randomNumber);
		string memory imageURI = svgToImageURI(svg);
		string memory tokenURI = formatTokenURI(imageURI);

		_setTokenURI(_tokenId, tokenURI);
		emit CreatedRandomSVG(_tokenId, tokenURI);
	}

	function generateSVG(uint256 _randomNumber) internal view returns (string memory finalSVG) {
		uint256 numberOfPaths = (_randomNumber % maxNumberOfPaths) + 1;
		finalSVG = string(
			abi.encodePacked(
				"<svg xmlns='http://www.w3.org/2000/svg' height='",
				Strings.toString(size),
				"' width='",
				Strings.toString(size),
				"'>"
			)
		);

		for (uint256 i = 0; i < numberOfPaths; i++) {
			uint256 newRandomNum = uint256(keccak256(abi.encode(_randomNumber, i)));
			string memory pathSVG = generatePath(newRandomNum);
			finalSVG = string(abi.encodePacked(finalSVG, pathSVG));
		}
		finalSVG = string(abi.encodePacked(finalSVG, " </svg>"));
	}

	function generatePath(uint256 _randomNumber) internal view returns (string memory pathSVG) {
		uint256 numberOfPthCommands = (_randomNumber % maxNumberOfPathCommands) + 1;
		pathSVG = "<path d='";
		for (uint256 i = 0; i < numberOfPthCommands; i++) {
			uint256 newRandomNumber = uint256(keccak256(abi.encode(_randomNumber, size + 1)));
			string memory pathCommand = generatePathCommand(newRandomNumber);
			pathSVG = string(abi.encodePacked(pathSVG, pathCommand));
		}
		string memory color = colors[_randomNumber % colors.length];
		pathSVG = string(
			abi.encodePacked(pathSVG, "' fill='transparent' stroke='", color, "' />")
		);
	}

	function generatePathCommand(uint256 _randomNumber)
		internal
		view
		returns (string memory genertedPathCommand)
	{
		genertedPathCommand = pathCommands[_randomNumber % pathCommands.length];

		uint256 paramenterOne = uint256(keccak256(abi.encode(_randomNumber, size * 2))) % size;
		uint256 paramenterTwo = uint256(keccak256(abi.encode(_randomNumber, size + 2))) % size;

		genertedPathCommand = string(
			abi.encodePacked(
				genertedPathCommand,
				" ",
				Strings.toString(paramenterOne),
				" ",
				Strings.toString(paramenterTwo),
				" "
			)
		);
	}

	function svgToImageURI(string memory svg) internal pure returns (string memory imageURI) {
		string memory baseURL = "data:image/svg+xml;base64,";
		string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
		imageURI = (string(abi.encodePacked(baseURL, svgBase64Encoded)));
	}

	function formatTokenURI(string memory imageURI)
		internal
		view
		returns (string memory tokenURI)
	{
		string memory baseURI = "data:application/json;base64,";
		tokenURI = string(
			abi.encodePacked(
				baseURI,
				Base64.encode(
					bytes(
						abi.encodePacked(
							'{"name":"',
							name(),
							'","description":"A full on chain generated random SVG NFT"',
							'"attributes":[{"randomness":"100%","awesomeness":"100%"}]',
							'"image":"',
							imageURI,
							'"}'
						)
					)
				)
			)
		);
	}
}
