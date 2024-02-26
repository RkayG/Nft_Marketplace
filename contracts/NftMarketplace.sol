// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarketplace is ERC721 {
    using Counters for Counters.Counter;

    // Counter for generating unique token IDs
    Counters.Counter private _nftIdCounter;

    mapping(uint256 => uint256) private _nftPrices;

    // Mapping from Nft ID to seller's address
    mapping(uint256 => address) private _nftSellers;

    // Mapping from Nft ID to buyer's address
    mapping(uint256 => address) private _nftBuyers;

    // Admin address with special privileges
    address private _admin;

    // Event for when a token is listed for sale
    event NftListed(uint256 indexed nftId, uint256 price);

    // Event for when a token is sold
    event NftSold(uint256 indexed nftId, uint256 price, address indexed seller, address indexed buyer);

    constructor() ERC721("NFT Marketplace", "NFTM") {
        _admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Only admin can call this function");
        _;
    }

    // Mint a new NFT
    function mintNFT(address _to) external onlyAdmin returns (uint256) {
        uint256 newNftId = _nftIdCounter.current();
        _safeMint(_to, newNftId);
        _nftIdCounter.increment();
        return newNftId;
    }

    // Sell Nft
    function sellNft(uint256 _nftId, uint256 _price) external {
        require(ownerOf(_nftId) == msg.sender, "You are not the owner of this token");
        _nftPrices[_nftId] = _price;
        _nftSellers[_nftId] = msg.sender;
        emit NftListed(_nftId, _price);
    }

    // Buy an NFT
    function buyNFT(uint256 _nftId) external payable {
        require(msg.value >= _nftPrices[_nftId], "Insufficient funds");

        address seller = _nftSellers[_nftId];
        address buyer = msg.sender;
        uint256 price = _nftPrices[_nftId];

        // Transfer ownership
        _transfer(seller, buyer, _nftId);

        _nftBuyers[_nftId] = buyer;

        // Transfer payment to seller
        payable(seller).transfer(price);

        emit NftSold(_nftId, price, seller, buyer);
    }

    // Get the price of an NFT
    function getNftPrice(uint256 _nftId) external view returns (uint256) {
        return _nftPrices[_nftId];
    }

    // Get the seller of an NFT
    function getNftSeller(uint256 _nftId) external view returns (address) {
        return _nftSellers[_nftId];
    }
}