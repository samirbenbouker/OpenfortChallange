// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Imports interfaces for ERC721 token and ERC721 receiver.
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NFTDelegation is IERC721Receiver {
    // Mapping to store delegate addresses for each token ID.
    mapping(uint256 => address) private delegates;

    // Reference to the ERC721 contract instance.
    IERC721 private nftContract;

    // Event emitted when delegation is made.
    event Delegated(
        address indexed owner,
        address indexed delegate,
        uint256 indexed tokenId
    );

    // Event emitted when delegation is revoked.
    event Revoked(address indexed owner, uint256 indexed tokenId);

    constructor() {}

    // Function to delegate an NFT to another address.
    function delegateNFT(address _delegate, uint256 _tokenId) public {
        // Get the current owner of the NFT
        address owner = nftContract.ownerOf(_tokenId);

        // Ensure that the caller is the owner of the NFT
        // Ensure that the delegate address is valid
        require(owner == msg.sender, "You are not the owner of this NFT");
        require(_delegate != address(0), "Invalid delegate address");

        // Get the current delegate for the tokenId
        // Set the new delegate for the tokenId
        address currentDelegate = delegates[_tokenId];
        delegates[_tokenId] = _delegate;

        // Emit event if there was a previous delegate
        if (currentDelegate != address(0)) {
            emit Revoked(owner, _tokenId);
        }

        emit Delegated(owner, _delegate, _tokenId);
    }

    // Function to revoke delegation of an NFT
    function revokeDelegation(uint256 _tokenId) public {
        address owner = nftContract.ownerOf(_tokenId);

        // Remove the delegate for the tokenId
        delete delegates[_tokenId];
        emit Revoked(owner, _tokenId);
    }

    // Function to get the delegate address for a token ID.
    function getDelegate(uint256 _tokenId) public view returns (address) {
        return delegates[_tokenId];
    }

    // Function to handle ERC721 token reception.
    function onERC721Received(
        address,
        address,
        uint256 _tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        // Ensure that the sender is the NFT contract
        require(
            msg.sender == address(nftContract),
            "Only allowed from the NFT contract"
        );

        // Revoke delegation for the receiver tokenId
        // Return the Recevied selector
        revokeDelegation(_tokenId);
        return this.onERC721Received.selector;
    }

    // Function to set the ERC721 contract address.
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
