// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NFTDelegation is IERC721Receiver {
    mapping(uint256 => address) private _delegates;
    IERC721 private _nftContract;

    event Delegated(
        address indexed owner,
        address indexed delegate,
        uint256 indexed tokenId
    );
    event Revoked(address indexed owner, uint256 indexed tokenId);

    constructor() {}

    function delegateNFT(address delegate, uint256 tokenId) public {
        address owner = _nftContract.ownerOf(tokenId);
        require(
            owner == msg.sender || _delegates[tokenId] == msg.sender,
            "You are not the owner or current delegate of this NFT"
        );
        require(delegate != address(0), "Invalid delegate address");

        address currentDelegate = _delegates[tokenId];
        _delegates[tokenId] = delegate;

        if (currentDelegate != address(0)) {
            emit Revoked(owner, tokenId);
        }
        emit Delegated(owner, delegate, tokenId);
    }

    function _revokeDelegation(uint256 tokenId) public {
        address owner = _nftContract.ownerOf(tokenId);
        delete _delegates[tokenId];
        emit Revoked(owner, tokenId);
    }

    function getDelegate(uint256 tokenId) public view returns (address) {
        return _delegates[tokenId];
    }

    function onERC721Received(
        address,
        address,
        uint256 tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        require(
            msg.sender == address(_nftContract),
            "Only allowed from the NFT contract"
        );
        _revokeDelegation(tokenId);
        return this.onERC721Received.selector;
    }

    function setNFTContract(address nftContractAddress) public {
        _nftContract = IERC721(nftContractAddress);
    }

    function transferDelegateRights(uint256 tokenId, address to) external {
        require(
            _delegates[tokenId] == msg.sender,
            "Only the current delegate can transfer their rights"
        );
        require(to != address(0), "Invalid delegate address");

        _delegates[tokenId] = to;
    }
}
