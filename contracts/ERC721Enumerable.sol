// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./interface/IERC721Enumerable.sol";


contract ERC721Enumberable is ERC721, IERC721Enumerable {
    
    string constant INVALID_INDEX = "005001";
    bytes4 constant ERC721_ENUMBERABLE_INTERFACE_ID = 0x780e9d63;

    uint256 constant MAX_BATCH_SIZE = 100;

    uint256[] internal tokenIds;

    // mapping(uint256 => uint256) private indexedTokenId;

    // mapping(address => uint256[]) private ownerTokenIds;

    // mapping(uint256 => uint256) private ownerIndexedTokenId;

    // constructor(string memory name, string memory symbol) ERC721(name,symbol){
    //     super._registerInterface(ERC721_ENUMBERABLE_INTERFACE_ID);
    // }

    // function totalSupply()     external
    // override
    // view
    // returns (uint256)  {
    //     return tokenIds.length;
    // }

    // function tokenByIndex(uint256 _index)
    // external
    // override
    // view
    // returns (uint256)
    // {
    //     require(this.totalSupply() > _index, INVALID_INDEX);
    //     return tokenIds[_index];
    // }

    // function tokenOfOwnerByIndex(address _owner, uint256 _index)
    // external
    // override
    // view
    // returns (uint256)
    // {
    //     require(_index < ownerTokenIds[_owner].length, INVALID_INDEX);
    //     return ownerTokenIds[_owner][_index];
    // }

    // function mint(address _to, uint256 _tokenId) external {
    //     super._mint(_to, _tokenId);
    //     tokenIds.push(_tokenId);
    //     indexedTokenId[_tokenId] = tokenIds.length - 1;
    // }

    // function burn(uint256 _tokenId) external {
    //     super._burn(_tokenId);
    //     uint256 tokenIndex = indexedTokenId[_tokenId];
    //     uint256 lastTokenIndex = tokenIds.length - 1;
    //     uint256 lastToken = tokenIds[lastTokenIndex];

    //     tokenIds[lastToken] = lastToken;
    //     tokenIds.pop();

    //     indexedTokenId[lastToken] = tokenIndex;
    //     indexedTokenId[_tokenId] = 0;
    // }

    // function addToken(address _to, uint256 _tokenId) external {
    //     require(
    //         ERC721.tokenIdOwner[_tokenId] == address(0),
    //         ERC721.NFT_ALREADY_EXISTS
    //     );
    //     ERC721.tokenIdOwner[_tokenId] = _to;
    //     ownerTokenIds[_to].push(_tokenId);
    //     ownerIndexedTokenId[_tokenId] = ownerTokenIds[_to].length - 1;
    // }

    // function removeToken(address _from, uint256 _tokenId)
    //     external
    // {
    //     require(ERC721.tokenIdOwner[_tokenId] == _from, ERC721.NOT_OWNER);
    //     delete ERC721.tokenIdOwner[_tokenId];

    //     uint256 tokenToRemoveIndex = ownerIndexedTokenId[_tokenId];
    //     uint256 lastTokenIndex = ownerTokenIds[_from].length - 1;

    //     if (lastTokenIndex != tokenToRemoveIndex) {
    //         uint256 lastToken = ownerTokenIds[_from][lastTokenIndex];
    //         ownerTokenIds[_from][tokenToRemoveIndex] = lastToken;
    //         ownerIndexedTokenId[lastToken] = tokenToRemoveIndex;
    //     }
    //     ownerTokenIds[_from].pop();
    // }

    // function bulkMint(address _to, uint256 _quantity) external {
    //     require(_quantity <= MAX_BATCH_SIZE,"Exceeds Batch size");
    //     for(uint256 i = 0; i < _quantity; i++) {
    //         _safeMint(_to, this.totalSupply(),"");
    //     }
    // }


    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    constructor(string memory name, string memory symbol) ERC721(name,symbol){
        super._registerInterface(ERC721_ENUMBERABLE_INTERFACE_ID);
    }

    // function totalSupply()     external
    // override
    // view
    // returns (uint256)  {
    //     return tokenIds.length;
    // }

    // function tokenByIndex(uint256 _index)
    // external
    // override
    // view
    // returns (uint256)
    // {
    //     require(this.totalSupply() > _index, INVALID_INDEX);
    //     return tokenIds[_index];
    // }

    // function tokenOfOwnerByIndex(address _owner, uint256 _index)
    // external
    // override
    // view
    // returns (uint256)
    // {
    //     require(_index < ownerTokenIds[_owner].length, INVALID_INDEX);
    //     return ownerTokenIds[_owner][_index];
    // }



    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }


    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

        function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

        function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }

} 
