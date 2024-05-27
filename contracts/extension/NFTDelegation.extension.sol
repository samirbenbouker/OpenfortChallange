// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTDelegationExtension is ERC1155, IERC1155Receiver, Ownable {
    // Import SafeERC20 library to safely handle ERC20 transfers.
    using SafeERC20 for IERC20;

    // Private variable to store the ERC20 token contract.
    IERC20 private erc20Token;

    mapping(uint256 => address) private erc721Contracts; // Mapping to store the ERC721 contracts corresponding to ERC1155 token IDs.
    mapping(uint256 => mapping(uint256 => address)) private erc721Owners; // Nested mapping to store the owners of ERC721 tokens corresponding to ERC1155 token IDs and ERC721 token IDs.
    mapping(uint256 => mapping(uint256 => address)) private erc721Delegates; // Nested mapping to store the delegates of ERC721 tokens corresponding to ERC1155 token IDs and ERC721 token IDs.
    mapping(address => uint256) private erc20Balances; // Mapping to store the ERC20 token balances of addresses.
    mapping(address => address) private erc20Delegates; // Mapping to store the delegates of ERC20 tokens.

    // Event emitted when an ERC721 token is deposited.
    event ERC721Deposited(
        address indexed owner,
        address indexed nftCOntract,
        uint256 indexed tokenId,
        uint256 id
    );

    // Event emitted when an ERC721 token is withdrawn.
    event ERC721Withdraw(
        address indexed owner,
        address indexed nftCOntract,
        uint256 indexed tokenId,
        uint256 id
    );

    // Event emitted when an ERC721 token is delegated.
    event ERC721Delegated(
        address indexed owner,
        address indexed delegate,
        address indexed nftContract,
        uint256 tokenId,
        uint256 id
    );

    // Event emitted when the delegation of an ERC721 token is revoked.
    event ERC721DelegationRevoked(
        address indexed owner,
        address indexed nftContract,
        uint256 indexed tokenId,
        uint256 id
    );

    // Event emitted when ERC20 tokens are deposited.
    event ERC20Deposited(address indexed from, uint256 amount);

    // Event emitted when ERC20 tokens are delegated.
    event ERC20Delegated(
        address indexed owner,
        address indexed delegate,
        uint256 amount
    );

    // Event emitted when the delegation of ERC20 tokens is revoked.
    event ERC20DelegationRevoked(address indexed owner);

    // Event emitted when ERC20 tokens are transferred.
    event ERC20Transfered(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    constructor(string memory _uri, address _erc20TokenAddress) ERC1155(_uri) {
        erc20Token = IERC20(_erc20TokenAddress);
    }

    // Support ERC721
    // Function to deposit ERC721 tokens into the contract.
    function depositERC721(
        address _nftContract,
        uint256 _tokenId,
        uint256 _id
    ) external {
        // Transfer the ERC721 token to this contract.
        IERC721(_nftContract).transferFrom(msg.sender, address(this), _tokenId);

        // Set the owner of the ERC721 token corresponding to the ERC1155 token ID.
        // Set the ERC721 contract corresponding to the ERC1155 token ID.
        erc721Owners[_id][_tokenId] = msg.sender;
        erc721Contracts[_id] = _nftContract;

        // Mint the ERC1155 token to the depositor.
        _mint(msg.sender, _id, 1, "");

        emit ERC721Deposited(msg.sender, _nftContract, _tokenId, _id);
    }

    // Function to withdraw ERC721 tokens from the contract.
    function withDrawERC721(uint256 _id, uint256 _tokenId) external {
        // Check if the sender owns the specified ERC1155 token.
        // Check if the sender owns the specified ERC721 token.
        require(
            balanceOf(msg.sender, _id) > 0,
            "You do not own this ERC1155 token"
        );
        require(
            erc721Owners[_id][_tokenId] == msg.sender,
            "You do not own the deposited ERC721 token"
        );

        // Get the ERC721 contract corresponding to the ERC1155 token ID.
        // Remove the owner of the ERC721 token.
        address nftContract = erc721Contracts[_id];
        erc721Owners[_id][_tokenId] = address(0);
        // _burn(msg.sender, _id, 1);

        // Transfer the ERC721 token to the sender.
        IERC721(nftContract).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId
        );

        emit ERC721Withdraw(msg.sender, nftContract, _tokenId, _id);
    }

    // Function to delegate ERC721 tokens to another address.
    function delegateERC271(
        address _to,
        uint256 _id,
        uint256 _tokenId
    ) external {
        // Check if the sender owns the specified ERC721 token.
        require(
            erc721Owners[_id][_tokenId] == msg.sender,
            "You do not own the deposited ERC721 token"
        );

        // Set the delegate for the ERC721 token.
        erc721Delegates[_id][_tokenId] = _to;
        emit ERC721Delegated(
            msg.sender,
            _to,
            erc721Contracts[_id],
            _tokenId,
            _id
        );
    }

    // Function to revoke delegation of ERC721 tokens.
    function revokeERC721Delegation(uint256 _id, uint256 _tokenId) external {
        // Check if the sender owns the specified ERC721 token.
        require(
            erc721Owners[_id][_tokenId] == msg.sender,
            "You do not own the deposited ERC721 token"
        );

        // Revoke the delegate for the ERC721 token.
        erc721Delegates[_id][_tokenId] = address(0);

        emit ERC721DelegationRevoked(
            msg.sender,
            erc721Contracts[_id],
            _tokenId,
            _id
        );
    }

    // Function to get the delegate of an ERC721 token.
    function getERC721Delegate(
        uint256 _id,
        uint256 _token
    ) external view returns (address) {
        return erc721Delegates[_id][_token];
    }

    // Support ERC20
    // Function to deposit ERC20 tokens into the contract.
    function depositERC20(uint256 _amount) external {
        // Safely transfer ERC20 tokens to this contract.
        // Update the ERC20 token balance of the sender.
        erc20Token.safeTransferFrom(msg.sender, address(this), _amount);
        erc20Balances[msg.sender] += _amount;

        emit ERC20Deposited(msg.sender, _amount);
    }

    // Function to delegate ERC20 tokens to another address.
    function delegateERC20(address _to, uint256 _amount) external {
        // Check if the sender has sufficient ERC20 token balance.
        require(erc20Balances[msg.sender] >= _amount, "Insufficient balance");

        // Update the ERC20 token balance of the delegate.
        // Set the delegate for the ERC20 tokens.
        erc20Balances[_to] += _amount;
        erc20Delegates[msg.sender] = _to;

        emit ERC20Delegated(msg.sender, _to, _amount);
    }

    // Function to revoke delegation of ERC20 tokens.
    function revokeERC20Delegation() external {
        // Check if the sender has any ERC20 tokens to revoke delegation.
        require(
            erc20Balances[msg.sender] > 0,
            "No ERC20 token to revoke delegation"
        );

        // Revoke the delegate for the ERC20 tokens.
        erc20Delegates[msg.sender] = address(0);

        emit ERC20DelegationRevoked(msg.sender);
    }

    // Function to get the delegate of ERC20 tokens.
    function getERC20Delegate(address _owner) external view returns (address) {
        return erc20Delegates[_owner];
    }

    // Function to get the ERC20 token balance of an address.
    function getERCBalance(address _owner) external view returns (uint256) {
        return erc20Balances[_owner];
    }

    // Override functions
    // Override function to enable safe transfer of ERC1155 tokens.
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) public virtual override {
        // Check if the caller is approved for transfer.
        require(
            _from == msg.sender || isApprovedForAll(_from, msg.sender),
            "Caller is not approved"
        );

        // Revoke ERC721 delegation
        if (_id >= 1 && _id <= type(uint256).max / 2) {
            erc721Delegates[_id][_amount] = address(0);
            emit ERC721DelegationRevoked(
                _from,
                erc721Contracts[_id],
                _amount,
                _id
            );
        }

        // Call the overridden function in the parent contract.
        super.safeTransferFrom(_from, _to, _id, _amount, _data);
    }

    // Override function to enable safe batch transfer of ERC1155 tokens.
    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) public virtual override {
        // Check if the caller is approved for transfer.
        require(
            _from == msg.sender || isApprovedForAll(_from, msg.sender),
            "Caller is not approved"
        );

        // Iterate through each token ID in the batch.
        for (uint256 i = 0; i < _ids.length; ++i) {
            // Revoke ERC721 delegation
            if (_ids[i] >= 1 && _ids[i] <= type(uint256).max / 2) {
                erc721Delegates[_ids[i]][_amounts[i]] = address(0);
                emit ERC721DelegationRevoked(
                    _from,
                    erc721Contracts[_ids[i]],
                    _amounts[i],
                    _ids[i]
                );
            }
        }

        // Call the overridden function in the parent contract
        super.safeBatchTransferFrom(_from, _to, _ids, _amounts, _data);
    }

    // ERC1155 token receiver function signature.
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    // ERC1155 batch token receiver function signature.
    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    // Function to check if a contract implements an interface.
    function supportsInterface(
        bytes4 _interfaceId
    ) public view virtual override(ERC1155, IERC165) returns (bool) {
        // Check if the contract implements the ERC1155 receiver interface or any other supported interface.
        return
            _interfaceId == type(IERC1155Receiver).interfaceId ||
            super.supportsInterface(_interfaceId);
    }
}
