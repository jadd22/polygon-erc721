// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";

contract ERC721GasOp is ERC721 {
    // Mask of an entry in packed address data.
    uint256 private constant BITMASK_ADDRESS_DATA_ENTRY = (1 << 64) - 1;

    // The bit position of `numberMinted` in packed address data.
    uint256 private constant BITPOS_NUMBER_MINTED = 64;

    // The bit position of `numberBurned` in packed address data.
    uint256 private constant BITPOS_NUMBER_BURNED = 128;

    // The bit position of `aux` in packed address data.
    uint256 private constant BITPOS_AUX = 192;

    // Mask of all 256 bits in packed address data except the 64 bits for `aux`.
    uint256 private constant BITMASK_AUX_COMPLEMENT = (1 << 192) - 1;

    // The bit position of `startTimestamp` in packed ownership.
    uint256 private constant BITPOS_START_TIMESTAMP = 160;

    // The bit mask of the `burned` bit in packed ownership.
    uint256 private constant BITMASK_BURNED = 1 << 224;

    // The bit position of the `nextInitialized` bit in packed ownership.
    uint256 private constant BITPOS_NEXT_INITIALIZED = 225;

    // The bit mask of the `nextInitialized` bit in packed ownership.
    uint256 private constant BITMASK_NEXT_INITIALIZED = 1 << 225;

    // The tokenId of the next token to be minted.
    uint256 private _currentIndex;

    // The number of tokens burned.
    uint256 private _burnCounter;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to ownership details
    // An empty struct value does not necessarily mean the token is unowned.
    // See `_packedOwnershipOf` implementation for details.
    //
    // Bits Layout:
    // - [0..159]   `addr`
    // - [160..223] `startTimestamp`
    // - [224]      `burned`
    // - [225]      `nextInitialized`
    mapping(uint256 => uint256) private _packedOwnerships;

    // Mapping owner address to address data.
    //
    // Bits Layout:
    // - [0..63]    `balance`
    // - [64..127]  `numberMinted`
    // - [128..191] `numberBurned`
    // - [192..255] `aux`
    mapping(address => uint256) private _packedAddressData;

    // Mapping from token ID to approved address.
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name, string memory symbol) ERC721(name,symbol){
        _name = name;
        _symbol = symbol;
        _currentIndex = _startTokenId();
    }

    /// @dev Returns the starting token id.
    /**
     * @dev Returns the starting token ID.
     * To change the starting token ID, please override this function.
     */
    function _startTokenId() internal view virtual returns (uint256) {
        return 0;
    }



    /**
     * @dev Returns the total amount of tokens minted in the contract.
     */
    function _totalMinted() internal view returns (uint256) {
        // Counter underflow is impossible as _currentIndex does not decrement,
        // and it is initialized to `_startTokenId()`
        unchecked {
            return _currentIndex - _startTokenId();
        }
    }


    /**
     * @dev Returns the next token ID to be minted.
     */
    function _nextTokenId() internal view returns (uint256) {
        return _currentIndex;
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address _owner) public view override returns (uint256) {
        require(_owner != address(0),"Zero Address!");
        return _packedAddressData[_owner] & BITMASK_ADDRESS_DATA_ENTRY;
    }

    /**
     * @dev Casts the address to uint256 without masking.
     */
    function _addressToUint256(address value)
        private
        pure
        returns (uint256 result)
    {
        assembly {
            result := value
        }
    }

    /**
     * @dev Casts the boolean to uint256 without branching.
     */
    function _boolToUint256(bool value) private pure returns (uint256 result) {
        assembly {
            result := value
        }
    }

    /**
     * @dev Mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `quantity` must be greater than 0.
     *
     * Emits a {Transfer} event.
     */
    function MintBulk(address _to, uint256 _quantity) external {
        require(_to != address(0), "ERC721: mint to the zero address");
        require(_quantity != 0, "ERC721: 0 quantity mint");
        uint256 startTokenId = _currentIndex;

        unchecked {
            _packedAddressData[_to] +=
                _quantity *
                ((1 << BITPOS_NUMBER_MINTED) | 1);

            _packedOwnerships[startTokenId] =
                _addressToUint256(_to) |
                (block.timestamp << BITPOS_START_TIMESTAMP) |
                (_boolToUint256(_quantity == 1) << BITPOS_NEXT_INITIALIZED);

            uint256 updatedIndex = startTokenId;
            uint256 end = updatedIndex + _quantity;

            while (updatedIndex < end) {
                emit Transfer(address(0), _to, updatedIndex++);
            }
        }
    }

    function DefaultMint(address _to, uint256 _quantity) external {
        
        // uint256 endTokenId = startTokenId + _quantity;
        // while(startTokenId <= endTokenId) {
        //     ERC721._mint(_to,startTokenId);
        //     totalTokenMinted.push(startTokenId);
        //     startTokenId += 1
        // }
        //require(quantity <= maxBatchSize, "cannot mint more than maxBatchSize");
        for (uint256 i = 0; i < _quantity; i++) {
            uint256  startTokenId = totalTokenMinted.length;
            _safeMint(_to, startTokenId,"");
        }

    }
}
