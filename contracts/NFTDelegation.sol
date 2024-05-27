// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NFTDelegation is IERC721Receiver {
    mapping(uint256 => address) private delegates;
    IERC721 private nftContract;

    event Delegated(
        address indexed owner,
        address indexed delegate,
        uint256 indexed tokenId
    );
    event Revoked(address indexed owner, uint256 indexed tokenId);

    constructor() {}

    function delegateNFT(address _delegate, uint256 _tokenId) public {
        address owner = nftContract.ownerOf(_tokenId);
        require(owner == msg.sender, "You are not the owner of this NFT");
        require(_delegate != address(0), "Invalid delegate address");

        address currentDelegate = delegates[_tokenId];
        delegates[_tokenId] = _delegate;

        if (currentDelegate != address(0)) {
            emit Revoked(owner, _tokenId);
        }
        emit Delegated(owner, _delegate, _tokenId);
    }

    function _revokeDelegation(uint256 _tokenId) public {
        address owner = nftContract.ownerOf(_tokenId);
        delete delegates[_tokenId];
        emit Revoked(owner, _tokenId);
    }

    function getDelegate(uint256 _tokenId) public view returns (address) {
        return delegates[_tokenId];
    }

    function onERC721Received(
        address,
        address,
        uint256 _tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        require(
            msg.sender == address(nftContract),
            "Only allowed from the NFT contract"
        );
        _revokeDelegation(_tokenId);
        return this.onERC721Received.selector;
    }

    function setNFTContract(address _nftContractAddress) public {
        nftContract = IERC721(_nftContractAddress);
    }

    // The delegate can transfer the nft to another wallet, losing said nft
    //function transferDelegateRights(uint256 tokenId, address to) external {
    //    require(
    //        delegates[tokenId] == msg.sender,
    //        "Only the current delegate can transfer their rights"
    //    );
    //    require(to != address(0), "Invalid delegate address");

    //    delegates[tokenId] = to;
    //}
}
