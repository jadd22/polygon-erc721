// https://eips.ethereum.org/EIPS/eip-721, http://erc721.org/ 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IERC165.sol";
/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.

interface IERC721 is IERC165 {
    
    /// @dev Emits when ownership is token is changed.

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);


    /// @dev Emits when approved address of token is changed.

    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);


    /// @dev emits when an operator is enabled or disabled for an owner
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);


    /// @dev Queryable method to check number of tokens assigned to owner
    /// @param _owner Address for whom query is executed
    /// @return Count of assigned tokens

    function balanceOf(address _owner) external view returns(uint256);


    /// @dev Queryable method to check address of token owner.
    /// @param _tokenId Unique Identifier for token 
    /// @return Address of token owner

    function ownerOf(uint256 _tokenId) external view returns(address);

    /// @dev Transfer token from 'from' to 'to' with extra data 
    /// @param _tokenId Unique Identifier for token 

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external ;

    /// @notice Safely transfer token from owner to spender
    /// @dev Transfer token from 'from' to 'to' without any extra data
    /// @param _from spender address 
    /// @param _to receiver address
    /// @param _tokenId unique id of token

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external ;

    /// @notice Transfer tokne from ownwer to spender
    /// @dev Transfer token from 'from' to 'to' without any extra data
    /// @param _from spender address
    /// @param _to receiver address
    /// @param _tokenId unique id of token

    function transferFrom(address _from, address _to, uint256 _tokenId) external ;

    /// @notice Explain to an end user what this does
    /// @dev Transfer ownership to _approved
    /// @param _approved new token Id owner's address
    /// @param _tokenId token Id who's ownership is transferred
    function approve(address _approved, uint256 _tokenId) external ;

    /// @notice 
    /// @dev Transfer ownership to _approved
    /// @param _operator new token Id owner's address
    /// @param _approved approval status   
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @dev Returns the address aproved for Token ID.
    /// @param _tokenId token id for which approved address needs to be checked
 
    function getApproved(uint256 _tokenId) external view returns (address);
    
    /// @dev To check is operator is allowed to manage all tokens for owner
    /// @param _operator takes operator address
    /// @param _owner takes owner address
    /// @return Returns the bool status if operator is allowed or not

    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

    // ==============================
    //        IERC721Metadata
    // ==============================

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);


}