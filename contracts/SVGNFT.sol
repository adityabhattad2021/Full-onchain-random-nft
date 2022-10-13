// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "base64-sol/base64.sol";

contract SVGNFT is ERC721URIStorage {
    uint256 public s_tokenCounter;

    constructor() ERC721("SVGNFT", "SvgNFT") {
        s_tokenCounter = 0;
    }

    function create(string memory svg) public {
        _safeMint(msg.sender, s_tokenCounter);
        string memory imageURI = svgToImageURI(svg);
        string memory tokenURI = formatTokenURI(imageURI);
        _setTokenURI(s_tokenCounter, tokenURI);
        s_tokenCounter += 1;
    }

    function svgToImageURI(string memory svg)
        public
        pure
        returns (string memory)
    {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(
            bytes(string(abi.encodePacked(svg)))
        );

        string memory imageURI = (
            string(abi.encodePacked(baseURL, svgBase64Encoded))
        );

        return imageURI;
    }

    function formatTokenURI(string memory imageURI)
        public
        view
        returns (string memory)
    {
        string memory baseURL = "data:application/json;base64,";
        return
            string(
                abi.encodePacked(
                    baseURL,
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name(),
                                '","description":"An SVG NFT"',
                                '"attributes":[{"awesomeness":"100%"}]',
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
