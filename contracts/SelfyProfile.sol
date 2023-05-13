// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SelfyProfile is ERC721, AccessControl {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // TokenId => URI
    mapping(uint256 => string) public tokenUris;
    // TokenId => Background number
    mapping(uint256 => uint256) public background;
    uint256 public constant MAX_BACKGROUND = 2;
    // TokenId => Body number
    mapping(uint256 => uint256) public body;
    uint256 public constant MAX_BODY = 29;
    // TokenId => Accessory number
    mapping(uint256 => uint256) public accessory;
    uint256 public constant MAX_ACCESSORY = 136;
    // TokenId => Head number
    mapping(uint256 => uint256) public head;
    uint256 public constant MAX_HEAD = 233;
    // TokenId => Glasses number
    mapping(uint256 => uint256) public glasses;
    uint256 public constant MAX_GLASSES = 20;
    // BadgeId => Traits
    mapping(uint256 => uint256) public badgeIdToTraits;
    // Address => Number of evolution
    mapping(address => uint256) public evolutionCount;
    //owner => token id
    mapping(address => uint256) public ownerToTokenId;

    // Base URI
    string private baseURI = "https://noun-api.com/beta/pfp?head=";

    // Error
    error RegularERC721SafeTransferFromAreNotAllowed();
    error RegularERC721TransferFromAreNotAllowed();
    error TraitsNotUpdateable();

    // Event
    event MetadataUpdate(uint256 _tokenId);

    constructor(
        string memory name,
        string memory symbol,
        address _selfyPerksContract
    ) ERC721(name, symbol) {
        _setupRole(MINTER_ROLE, _selfyPerksContract);
    }

    /*
        @notice Creation of a SelfyProfile
     */
    function createSelfyProfile(address recipient) public {
        require(
            balanceOf(recipient) == 0,
            "SelfyProfile: You already have a SelfyProfile"
        );
        // Before tokenId declaration to start at 1
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        background[tokenId] = 0;
        body[tokenId] = 13;
        accessory[tokenId] = 100;
        head[tokenId] = 0;
        glasses[tokenId] = 7;
        ownerToTokenId[recipient] = tokenId;
        _safeMint(recipient, tokenId);
    }

    /*
        @notice Update the token uri, used for example when the token is finalized
        @param _tokenURI : The token id owner
    */
    function evolve(
        uint256 badgeId,
        address recipient
    ) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = this.getTokenId(recipient);
        require(tokenId != 0, "SelfyProfile: You don't have a SelfyProfile");
        require(
            _exists(tokenId),
            "SelfyProfile: URI set for nonexistent token"
        );

        // Increment the trait corresponding to a badge
        if (badgeIdToTraits[badgeId] == 0) {
            head[tokenId] = getTraits(head[tokenId], MAX_HEAD);
        } else if (badgeIdToTraits[badgeId] == 1) {
            body[tokenId] = getTraits(body[tokenId], MAX_BODY);
        } else if (badgeIdToTraits[badgeId] == 2) {
            accessory[tokenId] = getTraits(accessory[tokenId], MAX_ACCESSORY);
        } else if (badgeIdToTraits[badgeId] == 3) {
            glasses[tokenId] = getTraits(glasses[tokenId], MAX_GLASSES);
        }

        tokenUris[tokenId] = string(
            abi.encodePacked(
                baseURI,
                head[tokenId],
                "&background=",
                background[tokenId],
                "&body=",
                body[tokenId],
                "&accessory=",
                accessory[tokenId],
                "&glasses=",
                glasses[tokenId]
            )
        );

        emit MetadataUpdate(tokenId); // To be compatible with the EIP-4906 : https://docs.opensea.io/docs/metadata-standards
    }

    /*
        @notice Return the new traits
        @param _tokenURI : The actual traits id
        @param maxTraits : The max traits number
    */
    function getTraits(
        uint256 actualTokenId,
        uint256 maxTraits
    ) internal view returns (uint256) {
        return
            actualTokenId +
            block.timestamp +
            block.number +
            (_tokenIdCounter.current() % maxTraits);
    }

    //Update the mapping badgeIdToTraits
    function updateBadgeIdToTraits(
        uint256 badgeId,
        uint256 traits
    ) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        badgeIdToTraits[badgeId] = traits;
    }

    // Get token id for an owner
    function getTokenId(address owner) external view returns (uint256) {
        return ownerToTokenId[owner];
    }

    /*
        @notice Get the token uri
        @param tokenId : The token id
    */
    function tokenURI(
        uint256 tokenId
    ) public view virtual override(ERC721) returns (string memory) {
        return tokenUris[tokenId];
    }

    function transferFrom(address, address, uint256) public virtual override {
        revert RegularERC721TransferFromAreNotAllowed();
    }

    function safeTransferFrom(
        address,
        address,
        uint256
    ) public virtual override {
        revert RegularERC721SafeTransferFromAreNotAllowed();
    }

    function safeTransferFrom(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override {
        revert RegularERC721SafeTransferFromAreNotAllowed();
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721, AccessControl) returns (bool) {
        return
            ERC721.supportsInterface(interfaceId) ||
            AccessControl.supportsInterface(interfaceId);
    }

    // Update the BaseUri
    function setBaseURI(
        string memory baseURI_
    ) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        baseURI = baseURI_;
    }
}
