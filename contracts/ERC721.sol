//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interface/IERC721.sol";
import "./interface/IERC721Receiver.sol";
import "./ERC165.sol";
import "./utils/AddressUtils.sol";

contract ERC721 is IERC721, ERC165 {
    using AddressUtils for address;

    bytes4 private constant ERC721_INTERFACE_ID = 0x80ac58cd;

    string private _tokenName;

    string private _tokenSymbol;

    // Revert Constant Declaration with Codes, with this code we can show meaningful 
    // message for UX.
    string internal constant ZERO_ADDRESS = "003001";
    string internal constant NOT_VALID_NFT = "003002";
    string internal constant NOT_OWNER_OR_OPERATOR = "003003";
    string internal constant NOT_OWNER_APPROVED_OR_OPERATOR = "003004";
    string internal constant NOT_ABLE_TO_RECEIVE_NFT = "003005";
    string internal constant NFT_ALREADY_EXISTS = "003006";
    string internal constant NOT_OWNER = "003007";
    string internal constant IS_OWNER = "003008";
    string internal constant SAME_OWNER_OPERATOR = "003009";
    string internal constant ERC721_RECEIVER = "003010";
    string internal constant NON_ERC721_RECEIVER = "003011";

    constructor(string memory _name, string memory _symbol) {
        _tokenName = _name;
        _tokenSymbol = _symbol;
        ERC165._registerInterface(ERC721_INTERFACE_ID);
    }

    // Lookup : TokenId is owned by address
    mapping(uint256 => address) internal tokenIdOwner;

    // Lookup : Address owning number of Tokens
    mapping(address => uint256) internal balances;

    // Lookup : TokenId is approved to address for transfer
    mapping(uint256 => address) internal approvedTokenOwner;

    mapping(address => mapping(address => bool)) internal approvedOperators;


    /// @dev Contains array of all the tokenIds generated.
    uint256[] internal totalTokenMinted;


    /// @dev Returns total number of tokens minted
    function totakTokenSupply() external view returns(uint256) {
        uint256 totalSupply = totalTokenMinted.length;
        return totalSupply;
    }

    /// @notice Revert when address zero is passed
    /// @dev Returns the total tokens owned by address
    function balanceOf(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(owner != address(0), ZERO_ADDRESS);
        return balances[owner];
    }

    /// @notice Revert when address zero is passed
    /// @dev Returns then token id owner's address
    /// @param _tokenId token id for which ownership needs to be checked

    function ownerOf(uint256 _tokenId)
        external
        view
        override
        returns (address)
    {
        address owner = tokenIdOwner[_tokenId];
        require(owner != address(0), ZERO_ADDRESS);
        return owner;
    }

    
    function name() public view returns (string memory tokenName) {
        return _tokenName;
    }

    function symbol() public view returns (string memory tokenSymbol) {
        return _tokenSymbol;
    }

    function _beforeTokenTransferHook(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal virtual {}

    function _afterTokenTransferHook(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal virtual {}

    function _tokenOwnerExists(uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        return tokenIdOwner[tokenId] != address(0);
    }

    function _removeNFToken(address _from, uint256 _tokenId) internal virtual {
        require(approvedTokenOwner[_tokenId] == _from, NOT_OWNER);
        balances[_from] -= 1;
        delete approvedTokenOwner[_tokenId];
    }

    function isTokenExists(uint256 _tokenId) internal view returns (bool) {
        return tokenIdOwner[_tokenId] != address(0);
    }
    function MintTokens(address _to, uint256 _tokenId) external {
        _mint(_to, _tokenId);
        
    }
    function totalTokenSupply() external view returns(uint256) {
        return totalTokenMinted.length;
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address _spender, uint256 _tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        require(isTokenExists(_tokenId), NOT_VALID_NFT);
        address owner = this.ownerOf(_tokenId);
        return (_spender == owner ||
            this.isApprovedForAll(owner, _spender) ||
            this.getApproved(_tokenId) == _spender);
    }

    function _clearApproval(uint256 _tokenId) private {
        delete approvedTokenOwner[_tokenId];
    }

    function _checkOnERC721Received(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) internal returns (bool) {
        if (_to.isContract()) {
            try
                IERC721Receiver(_to).onERC721Received(
                    msg.sender,
                    _from,
                    _tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(NON_ERC721_RECEIVER);
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function safeMint(address to, uint256 tokenId) external virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address _to, uint256 _tokenId) internal virtual {
        //require(_to != address(0), "ERC721: mint to the zero address");
        //require(!_tokenOwnerExists(_tokenId), "ERC721: token already minted");

        _beforeTokenTransferHook(address(0), _to, _tokenId);

        balances[_to] += 1;
        tokenIdOwner[_tokenId] = _to;
        totalTokenMinted.push(_tokenId);
        emit Transfer(address(0), _to, _tokenId);

        _afterTokenTransferHook(address(0), _to, _tokenId);
    }

    function Mint(address _to, uint256 _tokenId) external {
        _mint(_to, _tokenId);
    }

    function _burn(uint256 _tokenId) internal virtual {
        address tokenOwner = tokenIdOwner[_tokenId];
        _clearApproval(_tokenId);
        _removeNFToken(tokenOwner, _tokenId);
        emit Transfer(tokenOwner, address(0), _tokenId);
    }

    function _safeTransfer(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(_from, _to, _tokenId);
        require(
            _checkOnERC721Received(_from, _to, _tokenId, _data),
            ERC721_RECEIVER
        );
    }

    function _approve(address _approvedTo, uint256 _tokenId) internal virtual {
        approvedTokenOwner[_tokenId] = _approvedTo;
        emit Approval(this.ownerOf(_tokenId), _approvedTo, _tokenId);
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal virtual {
        require(this.ownerOf(_tokenId) == _from, NOT_OWNER_OR_OPERATOR);
        require(this.ownerOf(_tokenId) != address(0), ZERO_ADDRESS);

        _beforeTokenTransferHook(_from, _to, _tokenId);

        _approve(_to, _tokenId);

        balances[_from] -= 1;
        balances[_to] += 1;
        tokenIdOwner[_tokenId] = _to;
        totalTokenMinted.push(_tokenId);

        emit Transfer(_from, _to, _tokenId);

        _afterTokenTransferHook(_from, _to, _tokenId);
    }

    function _setApprovalForAll(
        address _owner,
        address _operator,
        bool _approved
    ) internal {
        require(_owner != _operator, SAME_OWNER_OPERATOR);
        require(_operator != address(0), ZERO_ADDRESS);
        approvedOperators[_owner][_operator] = _approved;
        emit ApprovalForAll(_owner, _operator, _approved);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) external override {
        _safeTransfer(_from, _to, _tokenId, _data);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external override {
        _safeTransfer(_from, _to, _tokenId, "");
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external override {
        address tokenOwnerAddress = this.ownerOf(_tokenId);
        require(_from != tokenOwnerAddress, IS_OWNER);
        require(_to != tokenOwnerAddress, ZERO_ADDRESS);
        _transfer(_from, _to, _tokenId);
    }

    function approve(address _to, uint256 _tokenId) external override {
        address tokenOwnerAddress = this.ownerOf(_tokenId);
        require(_to != tokenOwnerAddress, IS_OWNER);
        _approve(_to, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved)
        external
        override
    {
        _setApprovalForAll(msg.sender, _operator, _approved);
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId)
        external
        view
        override
        returns (address approvedAddress)
    {
        require(_tokenOwnerExists(_tokenId), NOT_OWNER_OR_OPERATOR);
        return approvedTokenOwner[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        override
        returns (bool)
    {
        return approvedOperators[_owner][_operator];
    }
}
