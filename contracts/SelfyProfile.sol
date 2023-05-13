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

    IERC20 public ghoToken;

    // TokenId => URI
    mapping(uint256 => string) public tokenUris;
    // TokenId => Background number
    mapping(uint256 => uint256) public background;
    uint256 public constant  MAX_BACKGROUND = 2;
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

    // Error
    error RegularERC721SafeTransferFromAreNotAllowed();
    error RegularERC721TransferFromAreNotAllowed();

    // Event
    event MetadataUpdate(uint256 _tokenId);

    constructor(
        string memory name,
        string memory symbol,
        address _selfyPerksContract,
        address _ghoTokenAddresse
    ) ERC721(name, symbol){
        _setupRole(MINTER_ROLE, _selfyPerksContract);
        ghoToken = IERC20(_ghoTokenAddresse);
    }

    /*
        @notice Creation of a SelfyProfile
     */
    function createSelfyProfile() public {
        require(balanceOf(msg.sender) == 0, "SelfyProfile: You already have a SelfyProfile");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        background[tokenId] = 0;
        body[tokenId] = 13;
        accessory[tokenId] = 100;
        head[tokenId] = 0;
        glasses[tokenId] = 7;
        ownerToTokenId[msg.sender] = tokenId;
        _safeMint(msg.sender, tokenId);
    }

    /*
        @notice Update the token uri, used for example when the token is finalized
        @param _tokenURI : The token id owner
    */
    function evolve(uint256 tokenId, uint256 badgeId, uint256 _nbTokenPayement) public payable onlyRole(MINTER_ROLE)  {
        require(_exists(tokenId), "SelfyProfile: URI set for nonexistent token");
        require(evolutionCount[msg.sender] < 3 && _nbTokenPayement > 100, "SelfyProfile: You can't evolve more than 3 times");

        ghoToken.transferFrom(msg.sender, address(this), _nbTokenPayement);

        // Increment the trait corresponding to a badge
        if (badgeIdToTraits[badgeId] == 0) {
            head[tokenId] = (head[tokenId] + 1) < MAX_HEAD ? head[tokenId] + 1 : 0;
        } else if (badgeIdToTraits[badgeId] == 1 && body[tokenId] < MAX_BODY) {
            body[tokenId] = (body[tokenId] + 1) < MAX_BODY ? body[tokenId] + 1 : 0;
        } else if (badgeIdToTraits[badgeId] == 2 && accessory[tokenId] < MAX_ACCESSORY) {
            accessory[tokenId] = (accessory[tokenId] + 1) < MAX_ACCESSORY ? accessory[tokenId] + 1 : 0;
        } else if (badgeIdToTraits[badgeId] == 3 && background[tokenId] < MAX_BACKGROUND) {
            glasses[tokenId] = (glasses[tokenId] + 1) < MAX_GLASSES ? glasses[tokenId] + 1 : 0;
        }

        tokenUris[tokenId] = string(abi.encodePacked(
            'https://noun-api.com/beta/pfp?head=', head[tokenId],
            '&background=',background[tokenId],
            '&body=',body[tokenId],
            '&accessory=',accessory[tokenId],
            '&glasses=',glasses[tokenId]
        ));

        emit MetadataUpdate(tokenId); // To be compatible with the EIP-4906 : https://docs.opensea.io/docs/metadata-standards
    }

    //Update the mapping badgeIdToTraits
    function updateBadgeIdToTraits(uint256 badgeId, uint256 traits) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        badgeIdToTraits[badgeId] = traits;
    }

    // Get token id for an owner
    function getTokenId(address owner) external view returns(uint256) {
        return ownerToTokenId[owner];
    }

    /*
        @notice Get the token uri
        @param tokenId : The token id
    */
    function tokenURI(uint256 tokenId) public view virtual override(ERC721) returns (string memory) {
        return tokenUris[tokenId];
    }

    function transferFrom(address, address, uint256) public virtual override {
        revert RegularERC721TransferFromAreNotAllowed();
    }

    function safeTransferFrom(address, address, uint256) public virtual override {
        revert RegularERC721SafeTransferFromAreNotAllowed();
    }

    function safeTransferFrom(address, address, uint256, bytes memory)
    public
    virtual
    override
    {
        revert RegularERC721SafeTransferFromAreNotAllowed();
    }

    // Withdraw the GHO token
    function withdrawGhoToken() external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        ghoToken.transfer(msg.sender, ghoToken.balanceOf(address(this)));
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return ERC721.supportsInterface(interfaceId) ||  AccessControl.supportsInterface(interfaceId) ;
    }
}