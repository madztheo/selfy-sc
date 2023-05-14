// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SelfySnapshotGHO is ERC721, AccessControl {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    // Role used to mint tokens and update URI
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    IERC20 public  ghoToken;

    // TokenId => URI
    mapping(uint256 => string) public tokenUris;
    // Mint price in GHO
    uint256 public constant mintPrice = 50 ether;

    constructor(address _ghoTokenAddress) ERC721("SelfySnapshotGHO", "SSG") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        ghoToken = IERC20(_ghoTokenAddress);
    }

    /*
        @param data: URI for the token
        @param _amountOfGHO: Amount of GHO to pay
     */
    function mint(string memory data, uint256 _amountOfGHO) payable public {
        require(_amountOfGHO >= mintPrice, "Not enough ether sent");
        ghoToken.transferFrom(msg.sender, address(this), _amountOfGHO);
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _mint(msg.sender, tokenId);
        tokenUris[tokenId] = data;
    }

    // Function that return the URI
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return tokenUris[tokenId];
    }

    // Function to withdraw all GHO from the contract
    function withdraw() public onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 balance = ghoToken.balanceOf(address(this));
        ghoToken.transfer(msg.sender, balance);
    }


    // The following functions are overrides required by Solidity.
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}