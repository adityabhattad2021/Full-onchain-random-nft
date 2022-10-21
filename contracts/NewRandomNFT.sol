// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";

import "hardhat/console.sol";

contract NEWRANDOMNFT is ERC721URIStorage {
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

	uint256 private tokenCounter;

	// Mappings
	mapping(uint256 => uint256) public tokenIdToRandomNumber;

	constructor() ERC721("RandomSVGNFT", "randomSVGNFT") {
		tokenCounter = 0;
		maxNumberOfPaths = 40;
		maxNumberOfPathCommands = 20;
		size = 500;
		pathCommands = ["M", "L"];
		colors = ["red", "blue", "green", "yellow", "black", "white"];
	}

	function createNFT(uint256 randomNumber) public  {
	
		uint256 tokenId = tokenCounter;
		tokenCounter += 1;
		_safeMint(msg.sender, tokenId);
		tokenIdToRandomNumber[tokenId] = randomNumber;
		emit CreatedUnfinishedRandomSVG(tokenId, randomNumber);
	}


	function finishMint(uint256 _tokenId) public {
		require(
			bytes(tokenURI(_tokenId)).length <= 0,
			"Token URI is already all set, cannot change it."
		);
		require(
			tokenIdToRandomNumber[_tokenId] > 0,
			"No random number found associted with the following token Id"
		);

		uint256 randomNumber = tokenIdToRandomNumber[_tokenId];
		console.log("Working 1",randomNumber);

		string memory svg = generateSVG(randomNumber);
		console.log("Working 1",randomNumber);

		string memory imageURI = svgToImageURI(svg);
		console.log("Working 1");

		string memory tokenURI = formatTokenURI(imageURI);
		console.log("Working 1");


		_setTokenURI(_tokenId, tokenURI);
		console.log("Working 1");

		emit CreatedRandomSVG(_tokenId, tokenURI);
	}

	function generateSVG(uint256 _randomNumber) internal view returns (string memory finalSVG) {
		uint256 numberOfPaths = (_randomNumber % maxNumberOfPaths) + 1;
		console.log(_randomNumber);
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
			uint256 newRandomNumber = uint256(keccak256(abi.encode(_randomNumber, size + i)));
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
							'","description":"A full on chain generated random SVG NFT",',
							'"attributes":[{"randomness":"100%","awesomeness":"100%"}],',
							'"image":"',
							imageURI,
							'"}'
						)
					)
				)
			)
		);
	}



	// Getter functions.
	function getTokenCounter() public view returns (uint256) {
		return tokenCounter;
	}
}
