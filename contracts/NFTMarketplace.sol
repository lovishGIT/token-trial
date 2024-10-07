// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is ERC721, Ownable {
    uint256 public tokenCounter;

    struct ListedToken {
        string name;
        string description;
        uint256 price;
        bool isListed;
    }

    mapping(uint256 => ListedToken) public listedTokens;

    event NFTCreated(uint256 indexed tokenId, string name, string description, uint256 price);
    event NFTListed(uint256 indexed tokenId, uint256 price);
    event NFTSold(uint256 indexed tokenId, address indexed buyer, uint256 price);

    constructor() ERC721("NFTMarketplace", "NFTM") Ownable(msg.sender) {
        tokenCounter = 0;
    }

    function createNFT() public onlyOwner returns (uint256) {
        uint256 newTokenId = tokenCounter;
        _safeMint(msg.sender, newTokenId);
        tokenCounter++;

        // Emit event for NFT creation
        emit NFTCreated(newTokenId, "", "", 0); // Placeholder for name and description
        return newTokenId;
    }

    function listNFT(uint256 tokenId, string memory name, string memory description, uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        require(price > 0, "Price must be positive");
        require(!listedTokens[tokenId].isListed, "Token already listed");

        listedTokens[tokenId] = ListedToken(
            name,
            description,
            price,
            true
        );

        // Emit event for NFT listing
        emit NFTListed(tokenId, price);
    }

    function buyNFT(uint256 tokenId) public payable {
        ListedToken memory tokenData = listedTokens[tokenId];
        require(tokenData.isListed, "Token not for sale");
        require(msg.value == tokenData.price, "Incorrect price");

        address seller = ownerOf(tokenId);
        _transfer(seller, msg.sender, tokenId);
        payable(seller).transfer(msg.value);

        listedTokens[tokenId].isListed = false;

        // Emit event for NFT sale
        emit NFTSold(tokenId, msg.sender, tokenData.price);
    }

    function fetchListedNFTs() public view returns (uint256[] memory) {
        uint256 totalTokens = tokenCounter;
        uint256 listedCount = 0;

        for (uint256 i = 0; i < totalTokens; i++) {
            if (listedTokens[i].isListed) {
                listedCount++;
            }
        }

        uint256[] memory listedTokensArr = new uint256[](listedCount);
        uint256 index = 0;

        for (uint256 i = 0; i < totalTokens; i++) {
            if (listedTokens[i].isListed) {
                listedTokensArr[index] = i;
                index++;
            }
        }

        return listedTokensArr;
    }
}