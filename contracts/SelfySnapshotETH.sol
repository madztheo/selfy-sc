// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";

contract SelfySnapshotETH is ERC721, AccessControl {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    // Role used to mint tokens and update URI
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // TokenId => URI
    mapping(uint256 => string) public tokenUris;
    // Mint price in ETH
    uint256 public constant mintPrice = 0.01 ether;

    constructor() ERC721("SelfySnapshotETH", "SSE") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    /*
        @notice Mint your token and keep it forever
        @param data: URI for the token
     */
    function mint(string memory data) payable public {
        require(msg.value >= mintPrice, "Not enough ether sent");
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _mint(msg.sender, tokenId);
        tokenUris[tokenId] = data;
    }

    // Function that return the URI
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return tokenUris[tokenId];
    }

    // Function to withdraw all ETH from the contract
    function withdraw() public onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 balance = address(this).balance;
        (bool sent, bytes memory data) = payable(msg.sender).call{value: balance}("");
        require(sent, "Failed to send Ether");
    }

    // The following functions are overrides required by Solidity.
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}